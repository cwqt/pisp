function imguiMetric_LOAD()

end


function imguiMetrics_DRAW()
	if clients.imguiMetrics then
	    setFullscreen()
	    status, clients.imguiMetrics = imgui.Begin("ImGui Metrics", true, {"AlwaysAutoResize"})
		    imgui.ShowMetricsWindow()
	    imgui.End()
	end
end