local ColorSetting = {}
ColorSetting.__index = ColorSetting

function update(self, state)
	self.Instance.ParameterFrame.Colorbox.BackgroundColor3 = state
	self.Instance.ParameterFrame.StringBox.Text = math.round(state.R*255) .. ", " .. math.round(state.G*255) .. ", " .. math.round(state.B*255)
end

function ColorSetting:Set(state)
	if type(state) == "string" then
		state = self:Deserialize(state)
	end
	
	self.State = state

	update(self, state)
end

function ColorSetting:ChangeTheme(theme)
	
end

function ColorSetting:Serialize()
	return {
		self.State.R,
		self.State.G,
		self.State.B,
	}
end

function ColorSetting:Deserialize(state)
	return Color3.new(state[1], state[2], state[3])
end

function ColorSetting.create(self, genericSetting)
	setmetatable(self, ColorSetting)
	print(self)
	
	local colorbox = script.Colorbox:Clone()
	colorbox.Parent = genericSetting.ParameterFrame
	
	local stringbox = script.StringBox:Clone()
	stringbox.Parent = genericSetting.ParameterFrame
	
	colorbox.MouseButton1Up:Connect(function()
		local SettingsContainer = genericSetting.Parent.Parent.Parent
		SettingsContainer.ColorWidget.Visible = true
		SettingsContainer.DarkSponge.Visible = true
		
		SettingsContainer.ColorWidget.SubmitButton.MouseButton1Up:Once(function()
			self:Set(SettingsContainer.ColorWidget.ColorPreview.BackgroundColor3)
			
			SettingsContainer.ColorWidget.Visible = false
			SettingsContainer.DarkSponge.Visible = false
		end)
	end)
	
	return self
end

return ColorSetting
