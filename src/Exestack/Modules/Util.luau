local Util = {}

function Util.ForceWidgetOpen(widget)
	widget.Enabled = true
	widget.Enabled = false
	widget.Enabled = true
end

function Util.ForceWidgetToggle(widget)
	local wasEnabled = widget.Enabled
	
	widget.Enabled = not wasEnabled
	widget.Enabled = wasEnabled
	widget.Enabled = not wasEnabled
end

function Util.YieldCurrentThread()
	return coroutine.yield(coroutine.running())
end

function Util.SpawnLoop(t, fn)
	task.spawn(function()
		while true do
			fn()
			task.wait(t)
		end
	end)
end

function Util.DelayLoop(t, fn)
	task.delay(t, function()
		Util.SpawnLoop(t, fn)
	end)
end

return Util
