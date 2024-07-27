local FreeStringSetting = {}
FreeStringSetting.__index = FreeStringSetting

function update(self, state)
	self.Instance.ParameterFrame.StringBox.Text = state
end

function FreeStringSetting:Set(state)
	self.State = state

	update(self, state)
end

function FreeStringSetting:ChangeTheme(theme)
	local stringbox = self.Instance.ParameterFrame.StringBox
	
	stringbox.TextColor3 = theme.TextColor
end

function FreeStringSetting.create(self, genericSetting)
	setmetatable(self, FreeStringSetting)
	
	local stringbox = script.StringBox:Clone()
	stringbox.Parent = genericSetting.ParameterFrame
	
	local previousText = self.State
	
	stringbox.Focused:Connect(function()
		previousText = stringbox.Text
	end)
	
	stringbox.FocusLost:Connect(function()
		local text = stringbox.Text

		if type(self.Restrictions) ~= "function" or self.Restrictions(text) then
			self:Set(text)
		else
			self:Set(previousText)
		end
	end)
	
	return self
end

return FreeStringSetting
