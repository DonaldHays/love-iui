local iui --- @type IUILib

local currentPath = (...):gsub('%.init$', '') .. "."
local resourcePath = currentPath:gsub("%.", "/")

local rootContext --- @type IUIRootContext

local aaUVShader  --- @type love.Shader
local msdfShader  --- @type love.Shader

--- @class LoveIUI9SliceQuads
--- @field tl love.Quad
--- @field tc love.Quad
--- @field tr love.Quad
--- @field ml love.Quad
--- @field mc love.Quad
--- @field mr love.Quad
--- @field bl love.Quad
--- @field bc love.Quad
--- @field br love.Quad
--- @field verticalWidth number
--- @field horizontalHeight number

local nineSliceCache = {}    --- @type table<any, LoveIUI9SliceQuads>
local newNineSliceCache = {} --- @type table<any, LoveIUI9SliceQuads>

--- @class LoveIUISystem: IUISystemBackend
local system = {}

function system.getTimestamp()
    return love.timer.getTime()
end

function system.getSystemCursor(name)
    return love.mouse.getSystemCursor(name)
end

function system.setCursor(cursor)
    love.mouse.setCursor(cursor --[[@as love.Cursor]])
end

function system.getDPI()
    return love.graphics.getDPIScale()
end

function system.quit()
    love.event.quit()
end

--- @class LoveIUIGraphics: IUIGraphicsBackend
local graphics = {}

function graphics.beginDraw()

end

function graphics.endDraw()

end

function graphics.newFont(size, hinting, dpiscale)
    return love.graphics.newFont(size, hinting, dpiscale)
end

--- @param image love.Texture
function graphics.getImageDimensions(image)
    return image:getDimensions()
end

function graphics.clip(x, y, w, h)
    love.graphics.setScissor(x, y, w, h)
end

function graphics.setColor(r, g, b, a)
    love.graphics.setColor(r, g, b, a)
end

function graphics.rectangle(x, y, w, h, rx, ry)
    love.graphics.rectangle("fill", x, y, w, h, rx, ry)
end

function graphics.circle(x, y, r)
    love.graphics.circle("fill", x, y, r)
end

function graphics.setFont(f)
    love.graphics.setFont(f)
end

function graphics.print(s, x, y)
    love.graphics.print(s, x, y)
end

--- @param image love.Texture
function graphics.image(image, filter, x, y, w, h)
    local sw, sh = image:getDimensions()
    sw = w / sw
    sh = h / sh

    local loveFilter = "linear"
    if filter == "nearest" then
        loveFilter = "nearest"
    end

    image:setFilter(loveFilter, loveFilter)
    if filter == "smooth" then
        love.graphics.setShader(aaUVShader)
    end

    love.graphics.draw(image, x, y, 0, sw, sh)

    if filter == "smooth" then
        love.graphics.setShader()
    end
end

function graphics.nineSlice(nineSlice, filter, x, y, w, h)
    --- @type love.Texture
    local image = nineSlice.image
    local l, t, r, b = nineSlice.l, nineSlice.t, nineSlice.r, nineSlice.b

    local quads = nineSliceCache[nineSlice]
    local iw, ih = image:getDimensions()

    if quads == nil then
        local vw = iw - (l + r)
        local hh = ih - (t + b)

        quads = {
            tl = love.graphics.newQuad(0, 0, l, t, image),
            tc = love.graphics.newQuad(l, 0, vw, t, image),
            tr = love.graphics.newQuad(iw - r, 0, r, t, image),
            ml = love.graphics.newQuad(0, t, l, hh, image),
            mc = love.graphics.newQuad(l, t, vw, hh, image),
            mr = love.graphics.newQuad(iw - r, t, r, hh, image),
            bl = love.graphics.newQuad(0, ih - b, l, b, image),
            bc = love.graphics.newQuad(l, ih - b, vw, b, image),
            br = love.graphics.newQuad(iw - r, ih - b, r, b, image),
            verticalWidth = vw,
            horizontalHeight = hh
        }
    end

    newNineSliceCache[nineSlice] = quads

    local vw, hh = quads.verticalWidth, quads.horizontalHeight
    local vs, hs = (h - (t + b)) / hh, (w - (l + r)) / vw

    local loveFilter = "linear"
    if filter == "nearest" then
        loveFilter = "nearest"
    end

    image:setFilter(loveFilter, loveFilter)
    if filter == "smooth" then
        love.graphics.setShader(aaUVShader)
    end

    love.graphics.draw(image, quads.tl, x, y)
    love.graphics.draw(image, quads.tc, x + l, y, 0, hs, 1)
    love.graphics.draw(image, quads.tr, x + w - r, y)
    love.graphics.draw(image, quads.ml, x, y + t, 0, 1, vs)
    love.graphics.draw(image, quads.mc, x + l, y + t, 0, hs, vs)
    love.graphics.draw(image, quads.mr, x + w - r, y + t, 0, 1, vs)
    love.graphics.draw(image, quads.bl, x, y + h - b)
    love.graphics.draw(image, quads.bc, x + l, y + h - b, 0, hs, 1)
    love.graphics.draw(image, quads.br, x + w - r, y + h - b)

    if filter == "smooth" then
        love.graphics.setShader()
    end
end

--- @param image love.Texture
function graphics.msdfImage(image, x, y, w, h)
    local sw, sh = image:getDimensions()
    sw = w / sw
    sh = h / sh

    love.graphics.setShader(msdfShader)

    love.graphics.draw(image, x, y, 0, sw, sh)

    love.graphics.setShader()
end

--- @class LoveIUIBackend: IUIBackend
local backend = {
    graphics = graphics,
    system = system,
}

function backend.config(config)
    config.idiom = config.idiom or "desktop"

    if love.window.getDPIScale() > 1 then
        config.detail = "high"
    else
        config.detail = "low"
    end
end

function backend.load(lib)
    iui = lib

    rootContext = iui.newRootContext()
    iui.setRootContext(rootContext)

    aaUVShader = love.graphics.newShader(
        resourcePath .. "shaders/ui-image.glsl"
    )

    msdfShader = love.graphics.newShader(
        resourcePath .. "shaders/ui-msdf.glsl"
    )
end

function backend.beginFrame(dt)
    rootContext:beginFrame()

    nineSliceCache = newNineSliceCache
    newNineSliceCache = {}
end

function backend.endFrame()
    rootContext:endFrame()
end

--- @param x number
--- @param y number
--- @param dx number
--- @param dy number
function backend.mousemoved(x, y, dx, dy)
    iui.input.mouse("move", 0, x, y, dx, dy)
end

--- @param x number
--- @param y number
--- @param button number
function backend.mousepressed(x, y, button)
    iui.input.mouse("down", button, x, y, 0, 0)
end

--- @param x number
--- @param y number
--- @param button number
function backend.mousereleased(x, y, button)
    iui.input.mouse("up", button, x, y, 0, 0)
end

--- @param x number
--- @param y number
function backend.wheelmoved(x, y)
    iui.input.mouse("scroll", 0, 0, 0, x, y)
end

--- @param key love.KeyConstant
--- @param scancode love.Scancode
--- @param isRepeat boolean
function backend.keypressed(key, scancode, isRepeat)
    iui.input.keyboard("down", key, isRepeat)
end

--- @param key love.KeyConstant
--- @param scancode love.Scancode
function backend.keyreleased(key, scancode)
    iui.input.keyboard("up", key, false)
end

--- @param text string
function backend.textinput(text)
    iui.input.text(text)
end

return backend
