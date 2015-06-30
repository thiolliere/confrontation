code.pistoleros = {}

function code.pistoleros.load()
	numberOfGame = 0
	limitOfGame = 5
	love.keyboard.setKeyRepeat(false)
	love.physics.setMeter(10)
	world = love.physics.newWorld(0, 700, false)
	world:setCallbacks( pistolerosBeginContact)
	color = {
		{255,0,0},
		{0,255,0},
		{0,0,255},
		{0,255,255},
	}
	position = {
		{x = 100, y = 250},
		{x = 700, y = 250},
		{x = 550, y = 550},
		{x = 250, y = 550},
	}
	character={}
	width = 30
	height = 15
	for i=1,player.nbr do
		character[i]={}
		character[i].body = love.physics.newBody(world, position[i].x, position[i].y, "dynamic")
		character[i].body:setBullet(true)
		character[i].body:setLinearDamping(damping)
		character[i].body:setFixedRotation(true)
		character[i].shape = love.physics.newRectangleShape(width, height)
		character[i].fixture = love.physics.newFixture(character[i].body, character[i].shape, 10)
		character[i].fixture:setUserData({type = "character", object = character[i]})
		character[i].color = color[i]
		character[i].orientation = "right"
		character[i].number = i
	end
end

function code.pistoleros.update(dt)
	world:update(dt)
	for i=1,player.nbr do
	end
end

function code.pistoleros.draw()
	love.graphics.scale(love.window.getWidth()/800, love.window.getHeight()/600)
	for i=1,player.nbr do
			local c = character[i].color
			love.graphics.setColor(c[1],c[2],c[3])
			love.graphics.polygon("fill", character[i].body:getWorldPoints(character[i].shape:getPoints()))
			love.graphics.setColor(255 - c[1], 255 - c[2], 255 - c[3])
	end
end

function code.pistoleros.keypressed(key, isrepeat)
	for i=1,player.nbr do
		if key == keymap[i].key then
		end
	end
end

function pistolerosBeginContact(a, b, coll)
	ua,ub = a:getUserData(), b:getUserData()
end

function pistolerosNewGame()
end

function code.pistoleros.close()
	state = "next"
	love.keyboard.setKeyRepeat(true)
	world:destroy()
end
