code.gylpha = {}

function code.gylpha.load()
	love.keyboard.setKeyRepeat(false)
	world = love.physics.newWorld(0, 70, false)
	world:setCallbacks( gylphaBeginContact)
	color = {
		{255,0,0},
		{0,255,0},
		{0,0,255},
		{0,255,255},
	}
	position = {
		{x = 10, y = 25},
		{x = 25, y = 55},
		{x = 55, y = 55},
		{x = 70, y = 25},
	}
	wall = {
		{x = 40, y = 1, w = 50, h = 2}
		, {x = 40, y = 59, w = 50, h = 2}
		, {x = 12.5, y = 30, w = 25, h = 4}
		, {x = 80-12.5, y = 30, w = 25, h = 4}
	}
	for i,v in ipairs(wall) do
		v.body = love.physics.newBody(world, v.x, v.y, "static")
		v.shape = love.physics.newRectangleShape(v.w, v.h)
		v.fixture = love.physics.newFixture(v.body, v.shape)
		v.fixture:setUserData({type = "wall", object = wall[i]})
	end
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
	contactImpulse = 0.5
	force = 2
	damageWidth = 3/4
	damageHeight = 1/4
end

function code.gylpha.update(dt)
	setInactive = {}
	doImpulse = {}
	world:update(dt)
	for _,v in ipairs(doImpulse) do
		if v.type == "up" then
			v.body:applyLinearImpulse(0, -contactImpulse)
		elseif v.type == "down" then
			v.body:applyLinearImpulse(0, contactImpulse)
		elseif v.type == "left" then
			v.body:applyLinearImpulse(-contactImpulse, 0)
		elseif v.type == "right" then
			v.body:applyLinearImpulse(contactImpulse, 0)
		end
	end

	for _,v in ipairs(setInactive) do
		v.body:setActive(false)
	end
	local counter = 0
	for i = 1, player.nbr do
		if character[i].body:isActive() then
			counter = counter + 1
		end
	end
	if counter <= 1 then
		gylphaNewGame()
	end

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
	for _,v in ipairs(wall) do
		love.graphics.setColor(125, 125, 125)
		love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
	end
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
		local collax,collay,collbx,collby = coll:getPositions()
		if collay == collby then
			local sup,inf
			if ua.object.body:getY() > ub.object.body:getY() then
				sup = ua.object
				inf = ub.object
			else
				sup = ub.object
				inf = ua.object
			end
			table.insert(doImpulse,{body = sup.body, type = "up"})
			table.insert(doImpulse,{body = inf.body, type = "down"})
			if (sup.orientation == "right" 
				and ((sup.body:getX() - inf.body:getX()) < width*damageWidth))
				or (sup.orientation == "left"
				and ((sup.body:getX() - inf.body:getX()) > -width*damageWidth)) then
				table.insert(setInactive,inf)
			end
		else
			local left,right
			if ua.object.body:getX() > ub.object.body:getX() then
				right = ua.object
				left = ub.object
			else
				right = ub.object
				left = ua.object
			end
			table.insert(doImpulse,{body = left.body, type = "left"})
			table.insert(doImpulse,{body = right.body, type = "right"})
			if left.orientation == "left" and right.orientation == "left" then
				if (left.body:getY() - right.body:getY()) < height*0.25 then
					table.insert(setInactive,right)
				end
			elseif left.orientation == "right" and right.orientation == "right" then
				if (right.body:getY() - left.body:getY()) < height*0.25 then
					table.insert(setInactive,right)
				end
			elseif left.orientation == "right" and right.orientation == "left" then
				local sup,inf
				if ua.object.body:getY() > ub.object.body:getY() then
					sup = ua.object
					inf = ub.object
				else
					sup = ub.object
					inf = ua.object
				end
				if (sup.body:getY() - inf.body:getY()) > 0.25 then
					table.insert(setInactive,right)
				end
			end
		end
	elseif (ua.type == "character" and ub.type == "pike") or (ua.type == "pike" and ub.type == "character") then
		local char
		if ua.type == "character" then
			char = ua.object
		else
			char = ub.object
		end
		table.insert(setInactive,char)
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
