code.gylpha = {}

function code.gylpha.load()
	love.keyboard.setKeyRepeat(false)
	world = love.physics.newWorld(0, 70, true)
	world:setCallbacks( gylphaBeginContact)
	color = {
		{255,0,0},
		{0,255,0},
		{0,0,255},
		{0,255,255},
	}
	position = {
		{x = 10, y = 20},
		{x = 30, y = 20},
		{x = 50, y = 20},
		{x = 70, y = 20},
	}
	character={}
	width = 2
	height = 1
	local damping = 1
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
	end
	impulse = 0.7
	force = 2
	damageWidth = 3/4
	damageHeight = 1/4
end

function code.gylpha.update(dt)
	world:update(dt)
	for i=1,player.nbr do
		if character[i].body:isActive() then
			if character[i].body:getX() > 80 then
				character[i].body:setX(0)
			elseif character[i].body:getX() < 0 then
				character[i].body:setX(80)
			end
			if character[i].body:getY() > 60 then
				character[i].body:setY(0)
			elseif character[i].body:getY() < 0 then
				character[i].body:setY(60)
			end
			if love.keyboard.isDown(keymap[i].left) then
				character[i].body:applyForce(-force, 0)
				character[i].orientation = "left"
			end
			if love.keyboard.isDown(keymap[i].right) then
				character[i].body:applyForce(force, 0)
				character[i].orientation = "right"
			end
		end
	end
end

function code.gylpha.draw()
	love.graphics.scale(10,10)
	for i=1,player.nbr do
		if character[i].body:isActive() then
			local c = character[i].color
			love.graphics.setColor(c[1],c[2],c[3])
			love.graphics.polygon("fill", character[i].body:getWorldPoints(character[i].shape:getPoints()))
			love.graphics.setColor(255 - c[1], 255 - c[2], 255 - c[3])
			local cx, cy = character[i].body:getPosition()
			local o = 1
			if character[i].orientation == "left" then
				o = -1
			end
			love.graphics.polygon("fill"
		  		, cx + o* width*(1/2 - damageWidth)	, 	cy + height*(1/2 - damageHeight)
		  		, cx + o*width*(1/2 - damageWidth)	, 	cy + height*(1/2)
		  		, cx + o*width*(1/2)			, 	cy + height*(1/2)
		  		, cx + o*width*(1/2)			, 	cy + height*(1/2 - damageHeight)
		  		)
		end
	end
end

function code.gylpha.keypressed(key, isrepeat)
	for i=1,player.nbr do
		if key == keymap[i].up or key == keymap[i].key then
			character[i].body:applyLinearImpulse(0, -impulse)
		end
	end
end

function gylphaBeginContact(a, b, coll)
	ua,ub = a:getUserData(), b:getUserData()
	if ua.type == "character" and ub.type == "character" then
		local ca = ua.object
		local cb = ub.object
		local oa = ca.orientation
		local ob = cb.orientation
		local collax,collay,collbx,collby = coll:getPositions()
		if collax == collbx then
			if collay > collby then
			else
			end
		else
			if collax > collbx then
			else
			end
		end

	elseif (ua.type == "character" and ub.type == "pike") or (ua.type == "pike" and ub.type == "character") then
		local char
		if ua.type == "character" then
			char = ua.object
		else
			char = ub.object
		end
		char.body:setAtive(false)
		local counter = 0
		for i = 1, player.nbr do
			if character[i].body:isActive() then
				counter = counter + 1
			end
		end
		if counter <= 1 then
			gylphaNewGame()
		end
	end
end

function gylphaNewGame()
	for i = 1, player.nbr do
		local c = character[i]
		c.body:setActive(true)
		c.body:setPosition(position[i].x, position[i].y)
		c.body:setLinearVelocity(0,0)
	end
end

function code.gylpha.close()
	love.keyboard.setKeyRepeat(true)
end
