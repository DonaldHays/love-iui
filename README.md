# LÖVE-IUI

A LÖVE backend for the [IUI](https://github.com/DonaldHays/iui) immediate mode
GUI library.

A [sample project](https://github.com/DonaldHays/iui-sample-love) that uses this
backend is available.

## Installation

This library provides the backend for [IUI](https://github.com/DonaldHays/iui)
for use in LÖVE projects. Both `iui` and `love-iui` must be added to your LÖVE
project.

## Minimal Sample

```lua
local iui = require "iui"
local backend = require "love-iui"

local labelText = "Click the button!"

function love.load()
    iui.load(backend)
end

function love.update(dt)
    iui.beginFrame(dt)
    iui.beginWindow(love.graphics.getDimensions())

    iui.panelBackground()
    iui.label(labelText)
    if iui.button("Say Hello") then
        labelText = "Hello, World!"
    end

    iui.endWindow()
    iui.endFrame()
end

function love.draw()
    iui.draw()
end

function love.mousemoved(x, y, dx, dy)
    backend.mousemoved(x, y, dx, dy)
end

function love.mousepressed(x, y, button)
    backend.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    backend.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
    backend.wheelmoved(x, y)
end

function love.keypressed(key, scancode, isRepeat)
    backend.keypressed(key, scancode, isRepeat)
end

function love.keyreleased(key, scancode)
    backend.keyreleased(key, scancode)
end

function love.textinput(text)
    backend.textinput(text)
end
```
