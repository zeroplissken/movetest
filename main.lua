local bump = require 'lib/bump/bump'

local world = nil

function drawBox(box, fill)
    love.graphics.rectangle(fill or "line", box.x, box.y, box.w, box.h)
end

function initPlayer()
    p = {}
    p.x = 400
    p.y = 200
    p.w = 16
    p.h = 16
    p.dx = 0
    p.dy = 0
    p.maxSpeed = 5
    p.acc = 25
    p.gravity = 15
    p.grounded = false
end

collisionFilter = function(item, other)
    local x, y, w, h = world:getRect(other)
    local px, py, pw, ph = world:getRect(item)
    local playerBottom = py + ph
    local otherBottom = y + h

    if playerBottom <= y then
        return 'slide'
    end
end

function movePlayer(dt)
	local goalX = p.x + p.dx
	local goalY = p.y + p.dy

	--gravity
    p.dy = p.dy + p.gravity * dt

    if love.keyboard.isDown("left") and p.dx > -p.maxSpeed then
		p.dx = p.dx - p.acc * dt
	elseif love.keyboard.isDown("right") and p.dx < p.maxSpeed then
    	p.dx = p.dx + p.acc * dt
	elseif not love.keyboard.isDown("left", "right") and p.dx < 0 then
    	p.dx = math.min(0, p.dx + p.acc * dt)
	elseif not love.keyboard.isDown("left", "right") and p.dx > 0 then
    	p.dx = math.max(0, p.dx - p.acc * dt)
	end

	if love.keyboard.isDown("up") and p.grounded then
    	p.dy = -300 * dt
    	p.grounded = false
	end
	p.x, p.y, collisions, len = world:move(p, goalX, goalY, collisionFilter)

	for i, coll in ipairs(collisions) do
    	if coll.touch.y > goalY then
        	p.grounded = false
    	elseif coll.normal.y < 0 then
        	p.grounded = true
    	end
	end
end

function love.load()
    initPlayer()

    b = {x = 100, y = 300, w = 100, h = 40}
	g = {x = 0, y = love.graphics.getHeight() - 10, w = love.graphics.getWidth(), h = 10}
	world = bump.newWorld(16)
	world:add(p, p.x, p.y, p.w, p.h)
	world:add(b, b.x, b.y, b.w, b.h)
	world:add(g, g.x, g.y, g.w, g.h)
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.push("quit")
    end
end

function love.update(dt)
    movePlayer(dt)
end

function love.draw()
    drawBox(p)
    drawBox(b, "fill")
    drawBox(g, "fill")
end
