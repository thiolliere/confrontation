function love.load()
	if not love.filesystem.exists("confrontation.conf.lua") then
		local content
		content = love.filesystem.read("defaultConf.lua")
		love.filesystem.write("confrontation.conf.lua",content)
	end
	love.filesystem.load("confrontation.conf.lua")()
	configure()
end

function love.update()
end

function love.draw()
end
