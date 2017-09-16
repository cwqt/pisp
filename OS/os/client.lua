local class = require('libs.middleclass.middleclass')

local client = class('client')
function client:initialize(windowTitle)
	self.windowTitle = windowTitle or "nil"
	self.drawing = false
end

return client