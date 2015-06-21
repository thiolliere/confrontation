function love.load()
	if not love.filesystem.exists("confrontation.conf.lua") then
		local content
		content = love.filesystem.read("defaultConf.lua")
		love.filesystem.write("confrontation.conf.lua",content)
	end
	love.filesystem.load("confrontation.conf.lua")()
	configure()
	state = "menu"
	cursor = 1
	player = {
		nbr = 2,
		limit = 4
	}
	game = {}
	selection = {}
	menu = {
		escape = function()
			love.event.quit()
		end,
		{name = function()
			return player.nbr.." player"
		end,
		right = function()
			player.nbr = player.nbr % player.limit + 1
		end,
		left = function()
			player.nbr = (player.nbr - 2) % player.limit + 1
		end},
		{name = function()
			return "select all"
		end,
		right = function()
			for i,v in ipairs(game) do
				selection[i] = v
			end
		end,
		left = right},
		{name = function()
			return "select none"
		end,
		right = function()
			for i,_ in ipairs(game) do
				selection[i] = nil
			end
		end,
		left = right},
		{name = function()
			return "return"
		end,
		right = menu.escape
		left = right}
	}
	for i,v in ipairs(game) do
		local t = {}
		t.name = function() return v end
		t.right = function()
			table.insert(selection, v)
		end
		t.left = function()
			for j,w in ipairs(selection) do
				if w == v then
					table.remove(selection, j)
					break
				end
			end
		end
		table.insert(menu, t)
	end
end

function love.update(dt)
	if state == "game" then
		confrontation.update(dt)
	elseif state == "next" then
	end
end

function love.draw()
	love.graphics.printf("Confrontation",love.window.getWidth()/2,love.window.getHeight()/4,0,"center",0,10,9)

	for i,v in ipairs(menu) do
		local name = v.name()
		if cursor == i then
		end
	end
end

function love.keypressed(key, isrepeat)
	if state == "game" then
		confrontation.keypressed(key, isrepeat)
	elseif state == "menu" then
		if key=="up" then
			cursor = (cursor - 2 ) % table.getn(menu) + 1
		elseif key=="down" then
			cursor = cursor % table.getn(menu) + 1
		elseif key=="right" then
			menu[cursor].right()
		elseif key=="left" then
			menu[cursor].left()
		elseif key=="escape" then
			menu.escape()
		end
	end
end
