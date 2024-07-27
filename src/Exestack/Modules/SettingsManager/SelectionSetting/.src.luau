local SelectionSetting = {}
SelectionSetting.__index = SelectionSetting

function update(self, state)
	local parameterFrame = self.Instance.ParameterFrame
	
	parameterFrame.StringBox.Text = state
	parameterFrame.Arrow.Image = "rbxassetid://6031090994"
	parameterFrame.Choices.Visible = false
end

function SelectionSetting:Set(state)
	if table.find(self.Restrictions, state) then
		self.State = state
	else
		self.State = self.DefaultState
	end
	
	update(self, self.State)
end

function SelectionSetting:ChangeTheme(theme)
	self.theme = theme

	local parameterFrame = self.Instance.ParameterFrame
	local stringBox = parameterFrame.StringBox
	
	stringBox.TextColor3 = theme.TextColor
	parameterFrame.Arrow.ImageColor3 = theme.TextColor
	
	for _, choiceFrame in pairs(parameterFrame.Choices:GetChildren()) do
		if choiceFrame.Name == "ChoiceFrame" then
			choiceFrame.BackgroundColor3 = theme.Setting
			choiceFrame.BorderColor3 = theme.Border
			choiceFrame.Choice.TextColor3 = theme.TextColor
		end
	end
end

function SelectionSetting.create(self, genericSetting)
	setmetatable(self, SelectionSetting)
	
	local stringBox = script.StringBox:Clone()
	stringBox.Parent = genericSetting.ParameterFrame
	
	local arrow = script.Arrow:Clone()
	arrow.Parent = genericSetting.ParameterFrame
	
	local choices = script.Choices:Clone()
	
	table.sort(self.Restrictions)
	
	for _, choice in self.Restrictions do
		local choiceFrame = script.ChoiceFrame:Clone()
		choiceFrame.Choice.Text = choice
		choiceFrame.Parent = choices
		
		choiceFrame.Choice.MouseButton1Down:Connect(function()
			choiceFrame.BackgroundColor3 = self.theme.Hold
		end)
		
		choiceFrame.Choice.MouseButton1Up:Connect(function()
			choiceFrame.BackgroundColor3 = self.theme.Hover

			self:Set(choice)
		end)
		
		choiceFrame.Choice.MouseEnter:Connect(function()
			choiceFrame.BackgroundColor3 = self.theme.Hover
		end)
		
		choiceFrame.Choice.MouseLeave:Connect(function()
			choiceFrame.BackgroundColor3 = self.theme.Setting
		end)
	end
	
	choices.Size = UDim2.new(1, 0, 0, #self.Restrictions*19)
	genericSetting.ParameterFrame:SetAttribute("TrueSize", #self.Restrictions*20 + 20 + 10)
	choices.Parent = genericSetting.ParameterFrame

	stringBox.MouseButton1Up:Connect(function()
		choices.Visible = not choices.Visible
		
		if choices.Visible then
			arrow.Image = "rbxassetid://6031091004"
		else
			arrow.Image = "rbxassetid://6031090994"
		end
	end)
	
	return self
end

return SelectionSetting
