code.rope = {}

function code.rope.load()
	numberOfGame = 0
	limitOfGame = 1
	function angleOfPoint( pt )
		local x, y = pt.x, pt.y
		local angle = math.atan2(y,x)
		if angle < 0 then angle = 2*math.pi + angle end
		return angle
	end

	function angleOfVector(x1,y1,x2,y2)
		local x, y = x2-x1, y2-y1
		return angleOfPoint( { x=x, y=y } )
	end

	love.physics.setMeter(10)
	love.keyboard.setKeyRepeat(false)
	world = love.physics.newWorld(0, 1000, false)
	world:setCallbacks(ropeBeginContact)
	color = {
		{255,0,0},
		{0,255,0},
	}
	ropeMaxLength = 400
	radius = 20
	position = {
		{x = 250, y = ropeMaxLength + radius}
		, {x = 550, y = ropeMaxLength + radius}
	}
	character = {}
	anchor = {}
	sword = {}
	swordLength = 35
	swordThickness = 4
	for i = 1, 2 do
		character[i] = {}
		character[i].body = love.physics.newBody(world, position[i].x, position[i].y, "dynamic")
		character[i].shape = love.physics.newCircleShape(radius)
		character[i].fixture = love.physics.newFixture(character[i].body, character[i].shape)
		character[i].fixture:setUserData({type = "character", number = i, object = character[i]})

		anchor[i] = {}
		anchor[i].body = love.physics.newBody(world, position[i].x, position[i].y - ropeMaxLength, "static")

		character[i].joint = love.physics.newRopeJoint(character[i].body, anchor[i].body, character[i].body:getX(), character[i].body:getY()-radius, anchor[i].body:getX(), anchor[i].body:getY(), ropeMaxLength, true)

		sword[i] = {}
		sword[i].body = love.physics.newBody(world, position[i].x + swordLength/2, position[i].y, "dynamic")
		sword[i].shape = love.physics.newRectangleShape(swordLength, swordThickness)
		sword[i].fixture = love.physics.newFixture(sword[i].body, sword[i].shape)
		sword[i].fixture:setUserData({type = "sword", number = i, object = sword[i]})
	end
	ceiling = {}
	ceiling.body = love.physics.newBody(world, 400, anchor[1].body:getY() - radius, "static")
	ceiling.shape = love.physics.newRectangleShape( 1800, 2*radius)
	ceiling.fixture = love.physics.newFixture(ceiling.body, ceiling.shape)
	ceiling.fixture:setUserData({type = "ceiling", object = ceiling})
	impulse = 100
	upImpulse = 300
end

function code.rope.update(dt)
	world:update(dt)
	for i = 1, 2 do
		local j = i % 2 + 1
		jcx, jcy = character[j].body:getPosition()
		jax, jay = anchor[j].body:getPosition()
		if sword[i].fixture:rayCast(jcx, jcy, jax, jay, 1) then
			character[j].dead = true
			score[j] = score[j] - 1
		end
	end
	for i = 1, 2 do
		if character[i].dead then
			numberOfGame = numberOfGame + 1
			if numberOfGame >= limitOfGame then
				code.rope.close()
				return
			end
			ropeNewGame()
		end
	end
	for i = 1, 2 do
		local da = 0
		if i == 2 then
			da = math.pi
		end
		character[i].body:setAngle(angleOfVector(character[i].body:getX(), character[i].body:getY(), anchor[i].body:getX(), anchor[i].body:getY()) + math.pi/2 + da)
		local cx,cy = character[i].body:getPosition()
		local a = character[i].body:getAngle()
		sword[i].body:setPosition(cx + swordLength/2*math.cos(a), cy + swordLength/2*math.sin(a))
		sword[i].body:setAngle(a)
	end
	for i = 1, 2 do
		local da = 0
		if i == 2 then
			da = math.pi
		end
		local angle
		if love.keyboard.isDown(keymap[i].up) then
			angle = character[i].body:getAngle() - math.pi/2 + da
			character[i].body:applyLinearImpulse(upImpulse*math.cos(angle),upImpulse*math.sin(angle))
		end
		if love.keyboard.isDown(keymap[i].down) then
			angle = character[i].body:getAngle() + math.pi/2 + da
			character[i].body:applyLinearImpulse(impulse*math.cos(angle),impulse*math.sin(angle))
		end
		if love.keyboard.isDown(keymap[i].left) then
			angle = character[i].body:getAngle() + math.pi + da
			character[i].body:applyLinearImpulse(impulse*math.cos(angle),impulse*math.sin(angle))
		end
		if love.keyboard.isDown(keymap[i].right) then
			angle = character[i].body:getAngle() + da
			character[i].body:applyLinearImpulse(impulse*math.cos(angle),impulse*math.sin(angle))
		end
	end
end

function code.rope.draw()
	love.graphics.scale(love.window.getWidth()/800, love.window.getHeight()/600)
	love.graphics.setColor(125,125,125)
	love.graphics.polygon("fill", ceiling.body:getWorldPoints(ceiling.shape:getPoints()))
	for i = 1, 2 do
		local c = color[i]
		love.graphics.setColor(255 - c[1], 255 - c[2], 255 - c[3])
		love.graphics.line(character[i].body:getX(), character[i].body:getY(),  anchor[i].body:getX(), anchor[i].body:getY()) 
		love.graphics.setColor(c[1],c[2],c[3])
		love.graphics.circle("fill", character[i].body:getX(), character[i].body:getY(), character[i].shape:getRadius(), 20)
		love.graphics.setColor(255 - c[1], 255 - c[2], 255 - c[3])
		local l,t = swordLength/2+5,swordThickness/2+1
		love.graphics.polygon("fill", sword[i].body:getWorldPoints(-l,-t,l,-t,l,t,-l,t))
	end
end

function ropeNewGame()	
	for i = 1, 2 do
		local c = character[i]
		c.dead = false
		c.body:setPosition(position[i].x, position[i].y)
		c.body:setLinearVelocity(0,0)
	end
end

function ropeBeginContact(a, b, coll)
	ua, ub = a:getUserData(), b:getUserData()
	if ua.type == "character" and ub.type == "sword" and ua.number ~= ub.number then
		score[ua.number] = score[ua.number] - 1
		ua.object.dead = true
	elseif ua.type == "sword" and ub.type == "character" and ua.number ~= ub.number then
		score[ub.number] = score[ub.number] - 1
		ub.object.dead = true
	end
end

function code.rope.close()
	state = "next"
	love.keyboard.setKeyRepeat(true)
	world:destroy()
	world = nil
	for i,v in pairs(character) do
		character[i] = nil
	end
	character = nil
	for i,v in pairs(sword) do
		sword[i] = nil
	end
	sword = nil
	for i,v in pairs(anchor) do
		anchor[i] = nil
	end
	anchor = nil
	color = nil
	position = nil

	love.physics.setMeter(1)
end
