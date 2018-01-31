hdlc = true

Sprite = {
    is_walking = false,
    is_backwards = false
}

function Sprite:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Sprite:getCurrentSprite(t)
    if self.is_idle then
        self.src = self.idle
    elseif self.is_walking then
        if Window.TICK % 20 == 0 then
            self.src = self.wlk1
        elseif Window.TICK % 20 == 10 then
            self.src = self.wlk2
        end
    else
        self.src = self.quad
    end
    return self.src
end

function Sprite:draw()
    if self.shdw ~= nil then
        love.graphics.draw(
        --[[texture]]  spritesheet,
        --[[quad]]     self.shdw.src,
        --[[x]]        fif(self.name == "hero",
            self.x + self.w * Window.SCALE / 2 - self.shdw.w * Window.SCALE / 2,
            self.x - Window.x * Window.SCALE + self.w * Window.SCALE / 2 - self.shdw.w * Window.SCALE / 2),
        --[[y]]        self.y + (self.h - 1) * Window.SCALE,
        --[[rotation]] 0,
        --[[scale X]]  Window.SCALE,
        --[[scale Y]]  Window.SCALE,
        --[[offset X]] 0,
        --[[offset Y]] 0
        )
    end
    love.graphics.draw(
    --[[texture]]  spritesheet,
    --[[quad]]     self:getCurrentSprite(Window.TICK),
    --[[x]]        fif(self.name == "hero", self.x, self.x - Window.x * Window.SCALE),
    --[[y]]        self.y,
    --[[rotation]] 0,
    --[[scale X]]  fif(self.is_backwards, -1, 1) * Window.SCALE,
    --[[scale Y]]  Window.SCALE,
    --[[offset X]] fif(self.is_backwards, self.w, 0),
    --[[offset Y]] 0
    )
    if self.name == "hero" and hdlc then
        love.graphics.draw(
        --[[texture]]  spritesheet,
        --[[quad]]     hero.hdlc,
        --[[x]]        self.x,
        --[[y]]        self.y - 4 * Window.SCALE,
        --[[rotation]] 0,
        --[[scale X]]  Window.SCALE,
        --[[scale Y]]  Window.SCALE,
        --[[offset X]] 0,
        --[[offset Y]] 0
        )
    end
end

function love.focus(f)
    blurred = not f
end

function fif(cond, if_true, if_false)
    if cond then return if_true else return if_false end
end

function drawInOrder(sprites_list)
    local count = #sprites_list
    local changed
    repeat
        changed = false
        count = count - 1
        for i=1, count do
            if sprites_list[i].y + sprites_list[i].h > sprites_list[i+1].y + sprites_list[i+1].h then
                sprites_list[i], sprites_list[i+1] = sprites_list[i+1], sprites_list[i]
                changed = true
            end
        end
    until changed == false

    for i=1,#sprites_list do
        sprites_list[i]:draw()
    end
end

function isColliding(x1, y1, w1, h1, x2, y2, w2, h2)
  w1 = w1 * Window.SCALE
  w2 = w2 * Window.SCALE
  h1 = h1 * Window.SCALE
  h2 = h2 * Window.SCALE
  return x1 <= x2+w2 and
         x2 <= x1+w1 and
         y1 <= y2+h2 and
         y2 <= y1+h1
end

function love.load()
    min_dt = 1/80
    next_time = love.timer.getTime()

    threshold = {
        top = 50,
        bottom = 10,
        left = 80,
        right = 100
    }

    Window = {
        x = 0
    }
    Window.WIDTH = love.graphics.getWidth()
    Window.HEIGHT = love.graphics.getHeight()
    Window.SCALE = 10
    Window.TICK = 0

    love.graphics.setBackgroundColor(255, 255, 255)
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    spritesheet = love.graphics.newImage("sprites.png")
    background = love.graphics.newImage("background.png")
    --love.graphics.setNewFont("m3x6.ttf", 70)

    hero = Sprite:new{
        name = "hero",
        x = 10,
        y = 10,
        w = 9,
        h = 19,
        life = 90,
        is_idle = true,
        shdw = {
            w = 11,
            h = 2
        }
    }
    hero.quad = love.graphics.newQuad(0, 0, hero.w, hero.h, spritesheet:getDimensions())
    hero.wlk1 = love.graphics.newQuad(hero.w, 0, hero.w, hero.h, spritesheet:getDimensions())
    hero.wlk2 = love.graphics.newQuad(hero.w*2, 0, hero.w, hero.h, spritesheet:getDimensions())
    hero.idle = love.graphics.newQuad(hero.w*3, 0, hero.w, hero.h, spritesheet:getDimensions())
    hero.shdw.src = love.graphics.newQuad(hero.w*5, 0, hero.shdw.w, hero.shdw.h, spritesheet:getDimensions())
    hero.hdlc = love.graphics.newQuad(hero.w*4, 0, hero.w, 4, spritesheet:getDimensions())
    hero.src = hero.quad

    guy_with_stick = Sprite:new{
        name = "guy with stick",
        x = 300,
        y = 300,
        w = 11,
        h = 19,
        life = 100,
        shdw = {
            w = 11,
            h = 2
        }
    }
    guy_with_stick.quad = love.graphics.newQuad(0, 19, guy_with_stick.w, guy_with_stick.h, spritesheet:getDimensions())
    guy_with_stick.wlk1 = love.graphics.newQuad(guy_with_stick.w, 19, guy_with_stick.w, guy_with_stick.h, spritesheet:getDimensions())
    guy_with_stick.wlk2 = love.graphics.newQuad(guy_with_stick.w*2, 19, guy_with_stick.w, guy_with_stick.h, spritesheet:getDimensions())
    guy_with_stick.shdw.src = love.graphics.newQuad(hero.w*5, 0, guy_with_stick.shdw.w, guy_with_stick.shdw.h, spritesheet:getDimensions())
    guy_with_stick.src = guy_with_stick.quad

    guy_with_two_sticks = Sprite:new{
        name = "guy with two sticks",
        x = 400,
        y = 500,
        w = 13,
        h = 19,
        life = 100,
        shdw = {
            w = 11,
            h = 2
        }
    }
    guy_with_two_sticks.quad = love.graphics.newQuad(0, 38, guy_with_two_sticks.w, guy_with_two_sticks.h, spritesheet:getDimensions())
    guy_with_two_sticks.wlk1 = love.graphics.newQuad(guy_with_two_sticks.w, 38, guy_with_two_sticks.w, guy_with_two_sticks.h, spritesheet:getDimensions())
    guy_with_two_sticks.wlk2 = love.graphics.newQuad(guy_with_two_sticks.w*2, 38, guy_with_two_sticks.w, guy_with_two_sticks.h, spritesheet:getDimensions())
    guy_with_two_sticks.shdw.src = love.graphics.newQuad(hero.w*5, 0, guy_with_two_sticks.shdw.w, guy_with_two_sticks.shdw.h, spritesheet:getDimensions())
    guy_with_two_sticks.src = guy_with_two_sticks.quad

    local blood = love.graphics.newImage("blood.png")
    blood_system = love.graphics.newParticleSystem(blood, 20)
    blood_system:setParticleLifetime(0.001,0.25)
    blood_system:setLinearAcceleration(500, 5000)
    blood_system:setSpeed(-500, 500)
end

function love.draw()
    love.graphics.draw(background, 0, 0, 0, Window.SCALE, Window.SCALE, Window.x)
    drawInOrder({
        hero, guy_with_stick, guy_with_two_sticks
    })

    love.graphics.draw(blood_system, hero.x + (hero.w * Window.SCALE) / 2, hero.y + 50)

    --love.graphics.setColor(0, 0, 0, 255)
    --love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    --love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("fill", 25, Window.HEIGHT - 50, 200, 25)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.rectangle("fill", 25, Window.HEIGHT - 50, hero.life * 2, 25)
    love.graphics.setColor(255, 255, 255, 255)

    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    love.timer.sleep(next_time - cur_time)
end

function love.update(dt)
    next_time = next_time + min_dt
    Window.TICK = Window.TICK + 1
    if blurred then return end
    blood_system:update(dt)

    print(hero.x + Window.x)
    print(guy_with_stick.x)
    if isColliding(hero.x - Window.x, hero.y, hero.w, hero.h,
       guy_with_stick.x, guy_with_stick.y, guy_with_stick.w, guy_with_stick.h) then
        blood_system:emit(32)
    end


    hero.is_idle = false
    if (love.keyboard.isDown("right") or love.keyboard.isDown("d"))
    and (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
        hero.is_idle = true
        return
    end

    hero.is_walking = false
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        hero.x = hero.x + 5
        hero.is_walking = true
        hero.is_backwards = false
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        hero.x = hero.x - 5
        hero.is_walking = true
        hero.is_backwards = true
    end
    if hero.x < threshold.left then
        Window.x = Window.x - .5
        if Window.x < 0 then Window.x = 0 end
        hero.x = threshold.left
    end
    if hero.x > Window.WIDTH - hero.w*Window.SCALE - threshold.right then
        Window.x = Window.x + .5
        hero.x = Window.WIDTH - hero.w*Window.SCALE - threshold.right
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        hero.y = hero.y - 5
        hero.is_walking = true
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        hero.y = hero.y + 5
        hero.is_walking = true
    end
    if hero.y < threshold.top then hero.y = threshold.top end
    if hero.y > Window.HEIGHT - hero.h*Window.SCALE - threshold.bottom then
        hero.y = Window.HEIGHT - hero.h*Window.SCALE - threshold.bottom
    end
end