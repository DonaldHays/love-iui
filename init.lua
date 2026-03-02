local iui         --- @type IUILib

local rootContext --- @type IUIRootContext

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
end

function backend.beginFrame(dt)
    rootContext:beginFrame()
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
