local ClickUtil = {}

function ClickUtil.OnLeftClick(button, fn)
	return button.MouseButton1Up:Connect(fn)
end

function ClickUtil.OnRightClick(button, fn)
	return button.MouseButton2Up:Connect(fn)
end

return ClickUtil
