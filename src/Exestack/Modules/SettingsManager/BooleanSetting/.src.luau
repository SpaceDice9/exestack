local BooleanSetting = {
	theme = {}
}
BooleanSetting.__index = BooleanSetting

function update(self, state)
	local checkbox = self.Instance.ParameterFrame.Checkbox

	if state then
		--checkbox.BackgroundColor3 = BooleanSetting.theme.Confirm or Color3.fromRGB(0, 170, 255)
		checkbox.ImageTransparency = 0
	else
		--checkbox.BackgroundColor3 = BooleanSetting.theme.Background or Color3.fromRGB(47, 47, 47)
		checkbox.ImageTransparency = 1
	end
end

function BooleanSetting:Set(state)
	self.State = state

	update(self, state)
end

function BooleanSetting:ChangeTheme(theme)
	self.theme = theme
	
	local checkbox = self.Instance.ParameterFrame.Checkbox
	checkbox.BackgroundColor3 = theme.Background
	checkbox.BorderColor3 = theme.Border
	checkbox.ImageColor3 = theme.Positive
	
	update(self, self.State)
end

function BooleanSetting.create(self, genericSetting)
	setmetatable(self, BooleanSetting)
	
	local checkbox = script.Checkbox:Clone()
	checkbox.Parent = genericSetting.ParameterFrame
	
	checkbox.MouseButton1Up:Connect(function()
		self:Set(not self.State)
	end)
	
	return self
end

return BooleanSetting
