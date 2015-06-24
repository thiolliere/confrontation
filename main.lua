code = {}

require "gylpha.gylpha"
require "rope.rope"

function love.load()
	love.keyboard.setKeyRepeat(true)
	if not love.filesystem.exists("confrontation.conf.lua") then
		local content
		content = love.filesystem.read("defaultConf.lua")
		love.filesystem.write("confrontation.conf.lua",content)
	end
	love.filesystem.load("confrontation.conf.lua")()
	configure()
	state = "menu"
	font = love.graphics.getFont()
	font:setFilter("linear","linear",8)
	cursor = 1
	player = {
		nbr = 2,
		limit = 4
	}
	game = {
		{name = "gylpha", selected = true},
		{name = "rope", selected = false},
	}
	for i,_ in ipairs(game) do
		game[i].buttonName = function()
			if game[i].selected then
				return game[i].name.." X"
			else
				return game[i].name
			end
		end
	end
	menu = {
		escape = function()
			love.event.quit()
		end,
		{name = function() return "play" end,
		enter = function() state = "next" end},
		{name = function()
			return "set number of player: "..player.nbr
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
		enter = function()
			for i,v in ipairs(game) do
				v.selected = true
			end
		end},
		{name = function()
			return "select none"
		end,
		enter = function()
			for i,v in ipairs(game) do
				v.selected = false
			end
		end},
		{name = function()
			return "return"
		end,
		enter = function()
			love.event.quit()
		end}
	}
	menu.game = table.getn(menu) + 1
	for i,v in ipairs(game) do
		local t = {}
		t.name = function() 
			return v.buttonName()
		end
		t.enter = function()
			game[i].selected = not game[i].selected
		end
		table.insert(menu, t)
	end
	confrontation={}
	confrontation.keypressed = function() end
	confrontation.keyreleased = function() end

	score = {0,0,0,0}
end

function love.update(dt)
	if state == "game" then
		confrontation.update(dt)
	elseif state == "next" then
		local selection = {}
		for _,v in ipairs(game) do
			if v.selected then
				table.insert(selection,v.name)
			end
		end
		local r = math.random(1,table.getn(selection))
		local x = selection[r]
		confrontation.update = code[x].update
		confrontation.draw = code[x].draw
		if code[x].keyreleased then
			confrontation.keyreleased = code[x].keyreleased
		else
			confrontation.keyreleased = function() end
		end
		if code[x].keypressed then
			confrontation.keypressed = code[x].keypressed
		else
			confrontation.keypressed = function() end
		end
		confrontation.load = code[x].load
		state = "game"
		confrontation.load()
		confrontation.update(dt)
	end
end

function love.draw()
	if state == "game" then
		confrontation.draw()
	elseif state == "menu" then
		love.graphics.printf("Confrontation",love.window.getWidth()/3,love.window.getHeight()/5,0,"center",0,10/2,9/2)

		local dh = love.window.getHeight()/2.5
		local dw = love.window.getWidth()/2.5
		for i=1,menu.game-1 do
			local name = menu[i].name()
			local scale = 1
			if cursor == i then
				love.graphics.printf("-->",dw-100,dh,500,"center",0,scale,scale,250,0)
			end
			love.graphics.printf(name,dw,dh,500,"center",0,scale,scale,250,0)
			dh=dh+font:getHeight()
		end
		border = font:getHeight()*10
		local topleft={}
		topleft.height = border
		local gameInHeight = math.floor((love.window.getHeight() - border - topleft.height)/font:getHeight())
		local gameInWidth = math.ceil(table.getn(game)/gameInHeight)
		topleft.width = love.window.getWidth()*3/4
		dh = topleft.height
		dw = topleft.width
		i = menu.game
		for k=1,gameInWidth do
			for j=1,gameInHeight do
				if not menu[i] then
					break
				end
				local name = menu[i].name()
				local scale = 1
				if cursor == i then
					love.graphics.printf("-->",dw-50,dh,500,"center",0,scale,scale,250,0)
				end
				love.graphics.printf(name,dw,dh,500,"center",0,scale,scale,250,0)
				dh=dh+font:getHeight()
				i = i + 1
			end
			dh = topleft.height
			dw = dw + (love.window.getWidth()-topleft.width)/2
		end
	end
	love.graphics.origin()
	love.graphics.printf("joueur 1 :"..score[1],0,0,1000,"left")
	love.graphics.printf("joueur 2 :"..score[2],800-font:getWidth("joueur 2 :"..score[2]),0,1000,"left")
end

function love.keypressed(key, isrepeat)
	if key == keymap.quit then
		love.event.quit()
	end
	if state == "game" then
		confrontation.keypressed(key, isrepeat)
	elseif state == "menu" then
		if key=="up" then
			cursor = (cursor - 2 ) % table.getn(menu) + 1
		elseif key=="down" then
			cursor = cursor % table.getn(menu) + 1
		elseif key=="right" then
			if menu[cursor].right then
				menu[cursor].right()
			elseif menu[cursor].enter then
				menu[cursor].enter()
			end
		elseif key=="left" then
			if menu[cursor].left then
				menu[cursor].left()
			elseif menu[cursor].enter then
				menu[cursor].enter()
			end
		elseif key=="escape" then
			menu.escape()
		end
	end
end

function love.keyreleased(key, isrepeat)
	if state == "game" then
		confrontation.keyreleased(key, isrepeat)
	end
end
