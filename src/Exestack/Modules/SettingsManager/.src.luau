--Manages settings 15/7/2022
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")

--support true/false, strings, list of strings, colors.
local Redirects = require(script.Redirects)
local Tooltips = require(Redirects.Tooltips)
local SignalModule = require(Redirects.Signal)
local Themes = require(script.Themes)
local Images = require(script.Images)

type ThemeName = "Light" | "Dark"

type SettingData = {
	Type: "Boolean" | "Color" | "FreeString" | "Selection",
	Name: string,
	Descriptor: string,
	Description: string?,
	State: any,
	DefaultState: any,
	Restrictions: any,
	SettingsState: {[string]: string}
}

local Category = {}
Category.__index = Category
type SettingsCategory = typeof(Category)

type SettingObject = {
	Name: string,
	Id: number,
	ParameterType: string,
	Type: string,
	Instance: Instance,
	State: any,
	DefaultState: any,
	Restrictions: any,

	Set: (any) -> (),
}

function Category:AddSetting(settingData: SettingData)
	local genericSetting = script.GUI.GenericSetting:Clone()
	local settingModule = require(script:FindFirstChild(settingData.Type .. "Setting"))
	
	local descriptorFrame = genericSetting.DescriptorFrame
	descriptorFrame.Descriptor.Text = settingData.Descriptor
	
	self.TooltipsZone:newTooltip(descriptorFrame, settingData.Description or "Empty description")
	
	local state = self.Settings.Options[settingData.Name]
	
	if state == nil then
		state = settingData.DefaultState
	end
	
	local settingObject = {
		Name = settingData.Name,
		Id = #self.Parameters,
		ParameterType = "Setting",
		Type = settingData.Type,
		Instance = genericSetting,
		
		State = state,
		DefaultState = settingData.DefaultState,
		Restrictions = settingData.Restrictions,
	} :: SettingObject
	
	settingModule.create(settingObject, genericSetting)
	settingObject:Set(settingObject.State)
	
	genericSetting.Parent = self.Frame.CategoryList
	
	genericSetting.MouseEnter:Connect(function()
		local theme = self.Settings.Theme

		descriptorFrame.BackgroundColor3 = theme.Hover
		genericSetting.ParameterFrame.BackgroundColor3 = theme.Hover
	end)
	
	genericSetting.MouseLeave:Connect(function()
		local theme = self.Settings.Theme

		descriptorFrame.BackgroundColor3 = theme.Setting
		genericSetting.ParameterFrame.BackgroundColor3 = theme.Setting
	end)
	
	table.insert(self.Parameters, settingObject)
	
	return settingObject
end

function Category:AddSpacing(pixelSize: number)
	local spacing = script.GUI.Spacing:Clone()
	spacing.Size = UDim2.new(1, 0, 0, pixelSize or spacing.Size.Y.Offset)
	
	local parameterObject = {
		Id = #self.Parameters,
		ParameterType = "Spacing",
		Instance = spacing,
		Size = pixelSize
	}
	
	spacing.Parent = self.Frame.CategoryList
	
	table.insert(self.Parameters, parameterObject)
end

function Category:AddSection(sectionName: string)
	local section = script.GUI.Section:Clone()
	section.Text = sectionName
	
	local parameterObject = {
		Name = sectionName,
		Id = #self.Parameters + 1,
		ParameterType = "Section",
		Instance = section,
		
		State = true
	}

	section.Parent = self.Frame.CategoryList
	
	section.MouseButton1Down:Connect(function()
		section.BackgroundColor3 = self.Settings.Theme.Hold
	end)
	
	section.MouseButton1Up:Connect(function()
		section.BackgroundColor3 = self.Settings.Theme.Hover
		
		local visible = not parameterObject.State
		parameterObject.State = visible
		
		if visible then
			section.Arrow.Image = Images.Open
		else
			section.Arrow.Image = Images.Closed
		end
		
		for i = parameterObject.Id + 1, #self.Parameters do
			local otherParameter = self.Parameters[i]
			
			if otherParameter then
				local parameterType = otherParameter.ParameterType
				
				if parameterType == "Section" or parameterType == "Spacing" and self.Parameters[i + 1] and self.Parameters[i + 1].ParameterType == "Section" then
					break
				else
					otherParameter.Instance.Visible = visible
				end
			end
		end
	end)
	
	section.MouseEnter:Connect(function()
		section.BackgroundColor3 = self.Settings.Theme.Hover
	end)

	section.MouseLeave:Connect(function()
		section.BackgroundColor3 = self.Settings.Theme.Section
	end)

	table.insert(self.Parameters, parameterObject)
end

function Category:Resize()
	local scroller = self.Frame
	local padding = scroller.CategoryList.UIListLayout.Padding.Offset
	local listSize = 15

	for i, parameterObject in pairs(self.Parameters) do
		local parameterFrame = parameterObject.Instance:FindFirstChild("ParameterFrame")
		local size = parameterObject.Instance.AbsoluteSize.Y

		if parameterFrame and parameterFrame:GetAttribute("TrueSize") and i == #self.Parameters then
			size = parameterFrame:GetAttribute("TrueSize") + padding
		end
		
		listSize += size + padding
	end

	scroller.CanvasSize = UDim2.new(0, 0, 0, listSize)
end


local Settings = {}
Settings.__index = Settings

function Settings:AddCategory(categoryName: string)
	local category = {
		Parameters = {},
		Frame = nil,
		Settings = self,
		TooltipsZone = nil,
		
		Button = nil
	}
	
	setmetatable(category, Category)
	
	local container = self.Frame.SettingsContainer

	local frame = script.GUI.CategoryFrame:Clone()
	frame.Parent = container
	category.Frame = frame
	
	if #self.Categories == 0 then
		frame.Visible = true
	end
	
	local categoryButton = script.GUI.CategoryLink:Clone()
	categoryButton.Label.Text = categoryName
	categoryButton.Parent = container.CategoriesFrame
	
	categoryButton.MouseButton1Down:Connect(function()
		categoryButton.BackgroundColor3 = self.Theme.Hold
	end)
	
	categoryButton.MouseButton1Up:Connect(function()
		categoryButton.BackgroundColor3 = self.Theme.Hover
		self:OpenCategory(category)
	end)
	
	categoryButton.MouseEnter:Connect(function()
		categoryButton.BackgroundColor3 = self.Theme.Hover
	end)

	categoryButton.MouseLeave:Connect(function()
		categoryButton.BackgroundColor3 = self.Theme.Background
	end)
	
	category.TooltipsZone = self.TooltipsZone
	category.Button = categoryButton
	
	table.insert(self.Categories, category)
	
	return category
end

function Settings:Compile()
	--local instanceModule = require(self.Instance)
	local options = self.Options

	for _, category in pairs(self.Categories) do
		for _, parameter in pairs(category.Parameters) do
			if parameter.ParameterType == "Setting" then
				--instanceModule:Set(parameter.Name, parameter.State)
				
				local name = parameter.Name
				local state = parameter.State
				
				local canFire = true

				if options[name] == state then
					canFire = false
				end

				options[name] = state

				if canFire then
					self.OnChange:Fire(name, state, self)
				end
			end
		end
	end
end

function Settings:Serialize()
	local t = {}

	for _, category in pairs(self.Categories) do
		for _, parameter in pairs(category.Parameters) do
			if parameter.ParameterType == "Setting" then
				local name = parameter.Name
				local state = parameter.State

				t[name] = state
			end
		end
	end

	return t
end

function Settings:SerializeAsInstance()
	local folder = Instance.new("Configuration")
	folder.Name = "SettingsFolder"
	
	for name, state in pairs(self.Options) do
		local stateType = typeof(state)
		local stateInstance
		
		if stateType == "boolean" then
			stateInstance = Instance.new("BoolValue")
		elseif stateType == "number" then
			stateInstance = Instance.new("NumberValue")
		elseif stateType == "string" then
			stateInstance = Instance.new("StringValue")
		else
			warn("Failed to serialize option '" .. name .. "' as an instance")
			
			continue
		end
		
		stateInstance.Name = name
		stateInstance.Value = state
		stateInstance.Parent = folder
	end
	
	folder.Parent = workspace
end

function Settings:ChangeTheme(themeName: ThemeName)
	local theme = Themes[themeName]
	local container = self.Frame.SettingsContainer
	
	self.Theme = theme
	
	for _, settingItem in pairs(container:GetChildren()) do
		if settingItem:FindFirstChild("CategoryList") then
			settingItem.BackgroundColor3 = theme.Background
			settingItem.BorderColor3 = theme.Border

			for _, item in pairs(settingItem.CategoryList:GetChildren()) do
				if item:IsA("Frame") and item.BackgroundTransparency == 0 then
					item.DescriptorFrame.BackgroundColor3 = theme.Setting
					item.DescriptorFrame.Descriptor.TextColor3 = theme.TextColor
					item.DescriptorFrame.BorderColor3 = theme.Border

					item.ParameterFrame.BackgroundColor3 = theme.Setting
					item.ParameterFrame.BorderColor3 = theme.Border
				elseif item:IsA("TextButton") then
					item.BackgroundColor3 = theme.Section
					item.TextColor3 = theme.TextColor
					item.BorderColor3 = theme.Border

					item.Arrow.ImageColor3 = theme.TextColor
				end
			end
		elseif settingItem.Name == "BottomBar" then
			settingItem.BackgroundColor3 = theme.Setting
			settingItem.BorderColor3 = theme.Border
			
			local resetAll = settingItem.ResetAll
			resetAll.TextColor3 = theme.TextColor
			resetAll.BackgroundColor3 = theme.Section
			resetAll.BorderColor3 = theme.Border
			
			local exportSettings = settingItem.ExportSettings
			exportSettings.TextColor3 = theme.TextColor
			exportSettings.BackgroundColor3 = theme.Section
			exportSettings.BorderColor3 = theme.Border
			
			local importSettings = settingItem.ImportSettings
			importSettings.TextColor3 = theme.TextColor
			importSettings.BackgroundColor3 = theme.Section
			importSettings.BorderColor3 = theme.Border
			
			continue
		elseif settingItem.Name == "CategoryColumn" then
			settingItem.BackgroundColor3 = theme.Setting
			settingItem.BorderColor3 = theme.Border
			
			settingItem.Arrow.ImageColor3 = theme.TextColor
		elseif settingItem.Name == "CategoriesFrame" then
			settingItem.BackgroundColor3 = theme.Background
			settingItem.BorderColor3 = theme.Border
			
			for _, item in pairs(settingItem:GetChildren()) do
				if item:IsA("TextButton") then
					item.BackgroundColor3 = theme.Background
					item.Label.TextColor3 = theme.TextColor
				end
			end
		end
	end
	
	container.TooltipFrame.BackgroundColor3 = theme.Background
	container.TooltipFrame.BorderColor3 = theme.Border
	container.TooltipFrame.Label.TextColor3 = theme.TextColor
	
	for _, category in pairs(self.Categories) do
		for _, parameterObject in pairs(category.Parameters) do
			if parameterObject.ParameterType == "Setting" then
				parameterObject:ChangeTheme(theme)
			end
		end
	end
end

function Settings:OpenCategory(category)
	for _, settingItem in pairs(self.Frame.SettingsContainer:GetChildren()) do
		if settingItem:FindFirstChild("CategoryList") then
			settingItem.Visible = false
		end
	end

	category.Frame.Visible = true
end

function Settings:ApplySettings(savedSettings)
	for optionName, option in savedSettings do
		self.Options[optionName] = option
	end
	
	for _, category in pairs(self.Categories) do
		for _, parameter in pairs(category.Parameters) do
			if parameter.ParameterType == "Setting" then
				local optionName = parameter.Name
				local savedState = savedSettings[optionName]
				
				if savedState ~= nil then
					parameter:Set(savedState)
				end
			end
		end
	end
	
	self:Compile()
end

function Settings:ApplySettingsWithInstance(savedInstance: Configuration)
	local savedSettings = {}

	for _, valueObj in pairs(savedInstance:GetChildren()) do
		if valueObj:IsA("ValueBase") then
			savedSettings[valueObj.Name] = valueObj.Value
		end
	end

	self:ApplySettings(savedSettings)
end

local SettingsManager = {}

function SettingsManager.BuildSettings(frame: GuiBase2d, themeName: ThemeName)
	local self = {
		Categories = {},
		Frame = frame,
		Instance = nil,
		TooltipsZone = nil,
		Options = {},
		
		OnChange = SignalModule.new(),
		Theme = Themes[themeName]
	}
	
	setmetatable(self, Settings)
	
	local guiFolder = script.GUI
	local settingsContainer = script.GUI.SettingsContainer
	settingsContainer.Parent = frame
	
	local bottomBar = guiFolder.BottomBar:Clone()
	bottomBar.Parent = settingsContainer
	local resetAll = bottomBar.ResetAll
	local exportSettings = bottomBar.ExportSettings
	local importSettings = bottomBar.ImportSettings
	
	local categoryColumn = guiFolder.CategoryColumn:Clone()
	categoryColumn.Parent = settingsContainer
	
	local categoriesFrame = guiFolder.CategoriesFrame:Clone()
	categoriesFrame.Parent = settingsContainer
	
	local tooltipGui = script.GUI.TooltipFrame:Clone()
	tooltipGui.Parent = settingsContainer
	
	self.TooltipsZone = Tooltips.init(tooltipGui, settingsContainer)
	
	categoryColumn.MouseButton1Down:Connect(function()
		categoryColumn.BackgroundColor3 = self.Theme.Hold
	end)
	
	categoryColumn.MouseButton1Up:Connect(function()
		categoryColumn.BackgroundColor3 = self.Theme.Hover
		
		categoriesFrame.Visible = not categoriesFrame.Visible
		
		local categoryColumnPosition, categoryPosition, categorySize, columnId
		
		if categoriesFrame.Visible then
			categoryColumnPosition = UDim2.new(.3, 0, 0, 0)
			categoryPosition = UDim2.new(.3, 14, 0, 0)
			categorySize = UDim2.new(.7, -14, 1, -29)
			
			columnId = "rbxassetid://6031094670"
		else
			categoryColumnPosition = UDim2.new(0, 0, 0, 0)
			categoryPosition = UDim2.new(0, 14, 0, 0)
			categorySize = UDim2.new(1, -14, 1, -29)
			
			columnId = "rbxassetid://6031094680"
		end
		
		categoryColumn.Position = categoryColumnPosition
		categoryColumn.Arrow.Image = columnId
		
		for _, settingItem in pairs(self.Frame.SettingsContainer:GetChildren()) do
			if settingItem:FindFirstChild("CategoryList") then
				settingItem.Position = categoryPosition
				settingItem.Size = categorySize
			end
		end
	end)
	
	categoryColumn.MouseEnter:Connect(function()
		categoryColumn.BackgroundColor3 = self.Theme.Hover
	end)
	
	categoryColumn.MouseLeave:Connect(function()
		categoryColumn.BackgroundColor3 = self.Theme.Setting
	end)

	resetAll.MouseEnter:Connect(function()
		resetAll.BackgroundColor3 = self.Theme.Hover
	end)

	resetAll.MouseLeave:Connect(function()
		resetAll.BackgroundColor3 = self.Theme.Section
	end)
	
	resetAll.MouseButton1Down:Connect(function()
		resetAll.BackgroundColor3 = self.Theme.Hold
	end)
	
	resetAll.MouseButton1Up:Connect(function()
		resetAll.BackgroundColor3 = self.Theme.Hover
		
		for _, category in pairs(self.Categories) do
			for _, parameter in pairs(category.Parameters) do
				if parameter.ParameterType == "Setting" then
					parameter:Set(parameter.DefaultState)
				end
			end
		end
	end)
	
	
	exportSettings.MouseEnter:Connect(function()
		exportSettings.BackgroundColor3 = self.Theme.Hover
	end)

	exportSettings.MouseLeave:Connect(function()
		exportSettings.BackgroundColor3 = self.Theme.Section
	end)

	exportSettings.MouseButton1Down:Connect(function()
		exportSettings.BackgroundColor3 = self.Theme.Hold
	end)

	exportSettings.MouseButton1Up:Connect(function()
		exportSettings.BackgroundColor3 = self.Theme.Hover
		
		self:SerializeAsInstance()
	end)
	
	
	importSettings.MouseEnter:Connect(function()
		importSettings.BackgroundColor3 = self.Theme.Hover
	end)

	importSettings.MouseLeave:Connect(function()
		importSettings.BackgroundColor3 = self.Theme.Section
	end)

	importSettings.MouseButton1Down:Connect(function()
		importSettings.BackgroundColor3 = self.Theme.Hold
	end)

	importSettings.MouseButton1Up:Connect(function()
		importSettings.BackgroundColor3 = self.Theme.Hover
		
		local settingsFolder = Selection:Get()[1]
		
		if settingsFolder and settingsFolder:IsA("Configuration") and settingsFolder.Name == "SettingsFolder" then
			self:ApplySettingsWithInstance(settingsFolder)
		end
	end)
	
	
	if RunService:IsStudio() then
		exportSettings.Visible = true
		importSettings.Visible = true
	end
	
	do
		local colorPicker = settingsContainer.ColorWidget.ColorPicker
		local shadePicker = settingsContainer.ColorWidget.ShadePicker
		local isMoving = false
		
		local function moveCross(x, y)
			local absPos = colorPicker.AbsolutePosition
			local relPos = Vector2.new(x - absPos.X, y - absPos.Y)
			colorPicker.Cross.Position = UDim2.fromOffset(relPos.X, relPos.Y)
			
			local xRel = relPos.X/150
			local yRel = relPos.Y/130
			local sRel = shadePicker.Bar.Position.Y.Offset/130
			
			local pureColor = Color3.fromHSV(1 - xRel, 1 - yRel, 1)
			local trueColor = Color3.fromHSV(1 - xRel, 1 - yRel, 1 - sRel)
			
			shadePicker.BackgroundColor3 = pureColor
			settingsContainer.ColorWidget.ColorPreview.BackgroundColor3 = trueColor
		end
		
		colorPicker.MouseButton1Down:Connect(function(x, y)
			moveCross(x, y)
			
			isMoving = true
		end)
		
		colorPicker.MouseButton1Up:Connect(function(x, y)
			moveCross(x, y)
			
			isMoving = false
		end)
		
		colorPicker.MouseMoved:Connect(function(x, y)
			if isMoving then
				moveCross(x, y)
			end
		end)
	end
	
	do
		local colorPicker = settingsContainer.ColorWidget.ColorPicker
		local shadePicker = settingsContainer.ColorWidget.ShadePicker
		local isMoving = false

		local function moveBar(x, y)
			local absPos = shadePicker.AbsolutePosition
			local relPos = Vector2.new(x - absPos.X, y - absPos.Y)
			shadePicker.Bar.Position = UDim2.new(.5, 0, 0, relPos.Y)
			
			local xRel = colorPicker.Cross.Position.X.Offset/150
			local yRel = colorPicker.Cross.Position.Y.Offset/130
			local sRel = relPos.Y/130
			
			local pureColor = Color3.fromHSV(1 - xRel, 1 - yRel, 1)
			local trueColor = Color3.fromHSV(1 - xRel, 1 - yRel, 1 - sRel)

			shadePicker.BackgroundColor3 = pureColor
			settingsContainer.ColorWidget.ColorPreview.BackgroundColor3 = trueColor
		end

		shadePicker.MouseButton1Down:Connect(function(x, y)
			moveBar(x, y)

			isMoving = true
		end)

		shadePicker.MouseButton1Up:Connect(function(x, y)
			moveBar(x, y)

			isMoving = false
		end)

		shadePicker.MouseMoved:Connect(function(x, y)
			if isMoving then
				moveBar(x, y)
			end
		end)
	end
	
	self:ChangeTheme(themeName)
	
	return self
end

return SettingsManager