require "luarocks.loader"
require "pl"
stringx.import()
local g = love.graphics

local profiler
if profiling then
   profiler = require "profiler"
else
   profiler = { start=function()end, stop=function()end }
end

local game

--

function addset(o, a, x) o[a] = o[a] + x end
do
   local id = 0
   function get_id() id = id + 1 return id end
end
function between(a, b, x) return math.min(a, b) <= x and x <= math.max(a, b) end

--

class.Notifier()
function Notifier:_init() self.notified = false end
function Notifier:set() self.notified = true end
function Notifier:reset()
   if self.notified then
      self.notified = false
      return true
   else
      return false
   end
end

class.NotifierList(List)
function NotifierList:notify()
   for notifier in self:iter() do
      notifier:set()
   end
end

--

class.V()
function V:_init(x, y)
   self[1] = x or 0
   self[2] = y or 0
   self.changed = NotifierList()
end

function V:__index(k)
   if k == "x" then return rawget(self, 1)
   elseif k == "y" then return rawget(self, 2)
   else return rawget(self, k)
   end
end

function V:__newindex(k, v)
   if k == "x" then rawset(self, 1, v) self.changed:notify()
   elseif k == "y" then rawset(self, 2, v) self.changed:notify()
   else rawset(self, k, v)
   end
end

function V:__unm() return V(-self.x, -self.y) end

function V:__div(o) return V(self.x/2, self.y/2) end

--

class.Ground()
function Ground:_init()
   self.pos = V(-1000,0)
   self.size = V(2000,10)

   local w, h = unpack(self.size)
   local heights = {}
   self.heights = heights
   for x = 0, w, 50 do
      heights[#heights+1] = x
      heights[#heights+1] = -math.random(0, h)
   end
end

function Ground:top(x)
   x = x - self.pos.x
   local hs = self.heights
   local lx, ly, rx, ry = hs[1], hs[2], hs[#hs-1], hs[#hs]
   if x <= lx then return ly + self.pos.y end
   if x >= rx then return ry + self.pos.y end
   for i, rx in ipairs(hs) do
      if i % 2 == 1 then
         ry = hs[i+1]
         if rx >= x then
            local m = (ry - ly)/(rx - lx)
            local y = ly + m * (x - lx)
            return y + self.pos.y
         end
         lx = rx
         ly = ry
      end
   end
end

function Ground:draw()
   local pos = self.pos
   g.push()
   g.translate(unpack(self.pos))
   g.line(self.heights)
   g.pop()
end

--

class.Tree()
function Tree:_init(layer)
   self.id = get_id()
   self.layer = layer
   if layer then layer.objects:set(self.id, self) end
   self.pos = V(0,0)
   self.pos_changed = Notifier()
   self.pos.changed:append(self.pos_changed)
   self.draw_kind = self["draw_"..({ "circle", "triangle" })[math.random(1,2)]]
end

function Tree:update(dt)
   local layer, pos = self.layer, self.pos
   if self.pos_changed:reset() then
      pos[2] = layer.ground:top(pos.x)
   end
end

function Tree:draw()
   local pos, draw_kind = self.pos, self.draw_kind
   g.push()
   g.translate(unpack(pos))
   g.line(0, 0, 0, -10)
   g.translate(0, -10)
   draw_kind()
   g.pop()
end

function Tree.draw_triangle()
   g.triangle("fill", -10, 0, 10, 0, 0, -20)
   g.triangle("line", -10, 0, 10, 0, 0, -20)
end

function Tree.draw_circle()
   g.circle("fill", 0, -10, 10)
   g.circle("line", 0, -10, 10)
end

--

class.Layer()
function Layer:_init()
   self.ground = Ground()
   self.objects = Map()
end

function Layer:update(dt)
   for id, obj in self.objects:iter() do
      obj:update(dt)
   end
end

function Layer:draw()
   self.ground:draw()
   for id, obj in self.objects:iter() do
      obj:draw()
   end
end

--

class.Game()
function Game:_init()
   local w, h = g.getMode()
   self.player = nil
   self.view_pt = { 0, 0 }
   self.vanish_pt = { w/2, h*2/3 }
   self.layers = List()
   self.keymap = {
      escape = love.event.quit,
      q = love.event.quit,
      a = function(dt) addset(self.view_pt, "x", -100*dt) end,
      d = function(dt) addset(self.view_pt, "x",  100*dt) end,
--      w = function(dt) addset(self.view_pt, 2, -100*dt) end,
--      s = function(dt) addset(self.view_pt, 2,  100*dt) end,
   }
end

--

function love.load()
   love.graphics.setBackgroundColor(255, 255, 255)
   love.graphics.setColor(0, 0, 0)

   game = Game()

   for i = 1, 6 do
      local layer = Layer()
      layer.ground.pos.y = 300
      game.layers:append(layer)

      for x = layer.ground.pos.x, layer.ground.pos.x + layer.ground.size.x, 30 do
         if math.random() < 0.1 then
            local tree = Tree(layer)
            tree.pos.x = x
         end
      end
   end

   do
      local o = game.layers[1].objects
      game.player = o[math.random(1,#o)]
      game.view_pt = game.player.pos
   end
   
   profiler.start()
end

function love.update(dt)
   for key, action in pairs(game.keymap) do
      if love.keyboard.isDown(key) then action(dt) end
   end
   for layer in game.layers:iter() do layer:update(dt) end
   g.setCanvas()
end

function love.keypressed(key, unicode)
   print(key)
   local action = game.keymap[key.."_press"]
   if action then action() end
end

function love.draw()
   print(love.timer.getFPS())
   local w, h = 600, 400
   local vx, vy = unpack(game.view_pt)

   g.push()

   g.translate(-vx + w/2, 0)

   local layers = game.layers
   for i = #layers, 1, -1 do
      local layer = layers[i]
      local s = 0.7 ^ (i-1)
      
      g.push()

      g.translate(vx, vy - 40*s)
      g.scale(s, s)
      g.translate(-vx, -(vy - 40*s))

      layer:draw()
      
      g.pop()
   end

   g.pop()
end

