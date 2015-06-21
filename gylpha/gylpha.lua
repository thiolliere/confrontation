code.gylpha = {}

function code.gylpha.load()
	love.keyboard.setKeyRepeat(false)
	world = love.physics.newWorld(0, 40, false)
	world:setCallbacks( beginContact, endContact, preSolve, postSolve )
	color = {
		{255,0,0},
		{0,255,0},
		{0,0,255},
		{0,255,255},
	}
	position = {
		{10,20},
		{30,20},
		{50,20},
		{70,20},
	}
	character={}
	for i=1,player.nbr do
		character[i]={}
		character[i].body = love.physics.newBody(world, position[i][1], position[i][2], "dynamic")
		character[i].body:setBullet(true)
		character[i].shape = love.physics.newRectangleShape(2,1)
		character[i].fixture = love.physics.newFixture(character[1].body, character[1].shape, 10)
		character[i].color = color[i]
	end
	impulse = 0.7
	force = 2
end

function code.gylpha.update(dt)
	world:update(dt)
	for i=1,player.nbr do
		if character[i].body:getX() > 80 then
			character[i].body:setX(0)
		elseif character[i].body:getX() < 0 then
			character[i].body:setX(80)
		end
		if character[i].body:getY() > 60 then
			character[i].body:setY(0)
		elseif character[i].body:getY() < 0 then
			character[i].body:setY(0)
		end
		if love.keyboard.isDown(keymap[i].left) then
			character[i].body:applyForce(-force, 0)
		end
		if love.keyboard.isDown(keymap[i].right) then
			character[i].body:applyForce(force, 0)
		end
	end
end

function code.gylpha.draw()
	love.graphics.scale(10,10)
	for i=1,player.nbr do
		local c = character[i].color
		love.graphics.setColor(c[1],c[2],c[3])
		love.graphics.polygon("fill", character[i].body:getWorldPoints(character[i].shape:getPoints()))
	end
end

function code.gylpha.keypressed(key, isrepeat)
	for i=1,player.nbr do
		if key == keymap[i].up or key == keymap[i].key then
			character[i].body:applyLinearImpulse(0, -impulse)
		end
	end
end

function code.gylpha.close()
	love.keyboard.setKeyRepeat(true)
end
