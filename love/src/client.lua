-- Client is any kind of window
local class = require("libs.middleclass.middleclass")
require("imgui")

--[[
Client:new("Title",
	{
		imgui.Text("Hello world!"),
		imgui.Button("text")},
	{
		x = 10, y= 20,
		closeButton = true,
		options = { "AlwaysAutoResize", "NoTitleBar"}
	})

]]
local Client = class('Client')
function Client:initialise(title, contents, config)
	self.title = tostring(title)
	self.contents = contents
	self.x = 0
	self.y = 0
	self.w = config.w
	self.h = config.y
end

function Client:update(dt)

end

function Client:draw()
	--imgui.SetNextWindowPos(self.x, self.y)
	imgui.Begin("test",  true)
	self.contents()
	imgui.End()
end

return Client