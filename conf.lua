function love.conf(t)
   t.title = "parallax adventure"
   t.author = "payload"
   t.identity = "parallax-adventure"
   t.release = false
   t.screen.width = 600
   t.screen.height = 400
   t.screen.fullscreen = false
   t.screen.vsync = true
   t.screen.fsaa = 0
   t.modules.joystick = false
   t.modules.audio = false
   t.modules.keyboard = true
   t.modules.event = true
   t.modules.image = true
   t.modules.graphics = true
   t.modules.timer = true
   t.modules.mouse = true
   t.modules.sound = false
   t.modules.physics = false
end