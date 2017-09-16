local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local metrics = class('client')
function metrics:initialize()
    client.initialize(self)
end

function metrics:draw()
    imgui.ShowMetricsWindow()
end

return metrics