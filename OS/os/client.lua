local class = require('libs.middleclass.middleclass')

local client = class('client')
function client:initialize(args)
	self.drawing = false
	self.args = args or {}
end

return client