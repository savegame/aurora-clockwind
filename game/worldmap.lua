worldmap = {}
-- buttons
local buttonsize = math.floor(WINHEIGHT * 0.2)
local buttoncorner = math.floor(buttonsize * 0.3)
local buttons = {
	["left"] = {4, WINHEIGHT - buttonsize - 4, nil, nil},
	["right"] = {WINWIDTH - buttonsize - 4, WINHEIGHT - buttonsize - 4, nil, nil},
	["esc"] = {4, 4, nil, nil}
}
--transition effects
local transitionin = false
local transitionintime = 0.4
local transitionout = false
local transitionouttime = 0.3

local levelselection = 1
local levels = 4

local markerspeed = 5
local markeroffset = 0 -- -1 to 1

local fliptimer = 0

function worldmap.load()
	transitionin = transitionintime

	if levelselection > levelscompleted+1 then
		levelselection = levelscompleted+1
	end

	buttons.esc[4] = love.graphics.newImage("graphics/buttons/back.png")
	buttons.left[4] = love.graphics.newImage("graphics/buttons/left.png")
	buttons.right[4] = love.graphics.newImage("graphics/buttons/right.png")
end

function worldmap.update(dt)
	--transitions
	if transitionin then
		transitionin = transitionin - dt
		if transitionin < 0 then
			transitionin = false
		end
	elseif transitionout then
		transitionout = transitionout - dt
		if transitionout < 0 then
			setgamestate("game", {levelselection})
			transitionout = false
		end
	end

	--marker
	if markeroffset ~= 0 then
		if markeroffset < 0 then
			markeroffset = markeroffset + markerspeed*dt
			if markeroffset >= 0 then
				markeroffset = 0
			end
		else
			markeroffset = markeroffset - markerspeed*dt
			if markeroffset <= 0 then
				markeroffset = 0
			end
		end
	end

	fliptimer = (fliptimer + 1.8*dt)%1
end

function worldmap.draw()
	--world map
	love.graphics.setColor(1,1,1)
	love.graphics.draw(worldmapimg, 0, 0)

	--level marker
	love.graphics.setColor(1,1,1)
	for i = 1, levels do
		local q = 1
		if i <= levelscompleted+1 then
			q = 2
		end
		love.graphics.draw(levelmarkerimg, levelmarkerq[q], 38+75*(i-1), 130)
	end

	--marker
	local dirscale = 1
	if fliptimer > 0.5 then
		dirscale = -1
	end
	love.graphics.draw(playerimg, playerq[1][19], 48+75*(levelselection-1+markeroffset), 140, 0, dirscale, 1, 20, 40)

	--transitions
	if transitionin then
		love.graphics.setColor(0,0,0,transitionin/transitionintime)
		love.graphics.rectangle("fill",0,0,WINWIDTH,WINHEIGHT)
	elseif transitionout then
		love.graphics.setColor(0,0,0,1-(transitionout/transitionouttime))
		love.graphics.rectangle("fill",0,0,WINWIDTH,WINHEIGHT)
	end
	local text = "Tap on screen to start level"
	love.graphics.print(text, math.floor((WINWIDTH-font:getWidth(text))/2), 6)

	for k, v in pairs(buttons) do
		if k ~= "joystick" then
			if v[4] ~= nil then
				love.graphics.setColor(1.0,1.0,1.0,0.6)
				love.graphics.draw(v[4],v[1],v[2])
			else
				love.graphics.setColor(0.4,0.4,0.9,0.6)
				love.graphics.rectangle("fill",v[1],v[2],buttonsize,buttonsize, buttoncorner, buttoncorner, 4 )
			end
		end
	end
end

function worldmap.touchpressed(id, x, y, dx, dy, pressure)
	local getbutton = function (x, y)
		print("xy = "..x.." "..y)
		-- print("lef :"..buttons["left"])
		-- print("r :"..buttons["right"])
		-- print("esc :"..buttons["esc"])
		for k, v in pairs(buttons) do
			-- print("v = "..v[1].." "..v[2])
			if v[1] < x and v[2] < y and x < v[1] + buttonsize and y < v[2] + buttonsize then
				-- print("catch "..k)
				return k
			end
		end
		return "all"
	end
	if getbutton(x,y) == "esc" then
		-- here should back button 
		worldmap.keypressed("escape")
	elseif getbutton(x,y) == "left" then
		-- here should left arrow picture
		worldmap.keypressed("left")
		-- print("left pressed")
	elseif getbutton(x,y) == "right" then
		-- here should right arrow picture
		worldmap.keypressed("right")
		-- print("right pressed")
	else
		worldmap.keypressed(controls["jump"])
	end
	-- print("markeroffset = "..markeroffset)
	-- print("x.y = "..x.." "..y.." rb "..(WINWIDTH - buttonsize).." "..(WINHEIGHT - buttonsize))
end

function worldmap.keypressed(k)
	if transitionin or transitionout then
		return
	end
	if k == "escape" then
		setgamestate("menu")
		return
	end
	if markeroffset == 0 then
		if k == controls["left"] or k == "left" then
			if levelselection > 1 then
				markeroffset = 1
				playSound("press")
			end
			levelselection = math.max(1, levelselection - 1)
		elseif k == controls["right"] or k =="right" then
			if levelselection < levels and levelselection < levelscompleted+1 then
				markeroffset = -1
				playSound("press")
			end
			levelselection = math.min(math.min(levelscompleted+1, levels), levelselection + 1)
		elseif k == controls["action"] or k == controls["jump"] or k == "return" then
			transitionout = transitionouttime
			playSound("select")
		end
	end
end