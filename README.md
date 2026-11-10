## Starter Template

```main.lua
UI = require('ui')

function love.load()
 -- Load components
end

function love.update(dt)
 local mx, my = love.mouse.getPosition()
 UI.update(dt, mx, my)
end

function love.draw()
 UI.draw()
end

function love.mousepressed(x, y, button)
 UI.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
 UI.mousereleased(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
 UI.keypressed(key)
end

function love.textinput(t)
 UI.textinput(t)
end
```

![ Example Image ](./screenshots/sample.png)

For more examples and documentation, please refer to the [Wiki](https://github.com/tonmoy998/LuvUI/wiki)
