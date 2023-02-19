local bump = require 'lib/bump/bump'
local world = nil

function drawBox(box, fill)
    love.graphics.rectangle(fill or "line", box.x, box.y, box.w, box.h)
end

function landBox(x, y)
    love.graphics.rectangle("fill", x, y, 32, 32)
end


function initPlayer()
    p = {}
    p.x = 100
    p.y = 50
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
	p.x, p.y, collisions, len = world:move(p, goalX, goalY)

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

	world = bump.newWorld(32)
	world:add(p, p.x, p.y, p.w, p.h)

    land = {}

    map ={{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    	  {1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1},
    	  {1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1},
    	  {1,1,1,1,0,0,0,0,0,1,0,0,0,0,1,1},
    	  {1,0,0,0,0,0,1,1,1,1,1,0,0,0,0,1},
    	  {1,1,1,1,0,0,0,0,0,1,0,0,0,0,1,1},
    	  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}}
	for i,v in ipairs(map) do
    	for j,w in ipairs(v) do
        	if w == 1 then
            	table.insert(land, {x = (j-1)*32, y = (i-1)*32, w = 32, h = 32})
        	end
    	end
	end

	for i,v in ipairs(land) do
    	world:add(land[i], v.x, v.y, v.w, v.h)
	end
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
    for i,v in ipairs(land) do
        landBox(v.x, v.y)
    end
    
end
