--!strict

-- Implements breadcrumbs and handles state for the opened folder.

local SignalModule = require(script.Parent.Parent.SignalModule)

local Breadcrumbs = {}
Breadcrumbs.__index = Breadcrumbs

type ElementData = any -- TODO: put an actual type later
type BreadcrumbPreset = TextButton
export type BreadcrumbsNewParams = {
	MouseField: any,
	
	Container: ScrollingFrame & {
		UIStroke: UIStroke,
		Separator: Frame,
		FolderButton: ImageButton,
	},
	BreadcrumbPreset: BreadcrumbPreset,
	
	RootName: string,
}
function Breadcrumbs.new(params: BreadcrumbsNewParams)
	local self = setmetatable({
		MouseField = params.MouseField,
		
		Container = params.Container,
		BreadcrumbPreset = params.BreadcrumbPreset,
		
		RootName = params.RootName,
		OpenedFolder = nil :: ElementData?,
		
		_breadcrumbs = {} :: {TextButton},
		_textColor = Color3.new(1, 1, 1),
	}, Breadcrumbs)
	
	-- Events
	self.PathChanged = SignalModule.new() -- args: (oldElementData, newElementData)
	self.LeftReleasedOnBreadcrumb = SignalModule.new() -- args: (folderElementData)
	
	-- For type-checking (so the method types get inferred) 😔
	if false then
		self:GetFullPath()
		self:ChangeTheme({} :: any)
		self:Open(nil)
	end
	
	-- Create the root breadcrumb
	self:_createBreadcrumb(nil, false)
	
	return self
end

-- Returns the full path of the current folder from the root.
function Breadcrumbs:GetFullPath()
	if self.OpenedFolder then
		local path = {}
		local current = self.OpenedFolder
		while current do
			table.insert(path, current.Name)
			current = current.Parent
		end
		
		return `{self.RootName}:/{table.concat(path, "/")}`
	else
		return `{self.RootName}:/`
	end
end

export type BreadcrumbsThemeData = {
	BackgroundColor: Color3,
	BorderColor: Color3,
	SeparatorColor: Color3,
	IconColor: Color3,
	TextColor: Color3,
}
function Breadcrumbs:ChangeTheme(themeData: BreadcrumbsThemeData)
	self.Container.BackgroundColor3 = themeData.BackgroundColor
	self.Container.UIStroke.Color = themeData.BorderColor
	self.Container.Separator.BackgroundColor3 = themeData.SeparatorColor
	self.Container.FolderButton.ImageColor3 = themeData.IconColor
	
	for _, breadcrumb in self._breadcrumbs do
		breadcrumb.TextColor3 = themeData.TextColor
	end
	self._textColor = themeData.TextColor
end

local function wrapUnderlineTags(s: string): string
	return `<u>{s}</u>`
end

function Breadcrumbs:Open(folderElementData: ElementData)
	if self.OpenedFolder == folderElementData then return end
	
	-- Cleanup old breadcrumbs for re-render
	for _, breadcrumb in self._breadcrumbs do
		self.MouseField:DeregisterButton(breadcrumb)
		breadcrumb:Destroy()
	end
	table.clear(self._breadcrumbs)
	
	-- Get the path
	local stack = {}
	if folderElementData then
		local current = folderElementData
		while current do
			table.insert(stack, current)
			current = current.Parent
		end
	end
	
	-- Create breadcrumbs
	local old = self.OpenedFolder
	self.OpenedFolder = folderElementData
	
	self:_createBreadcrumb(nil, false)
	
	for i = #stack, 1, -1 do
		local elementData = stack[i]
		self:_createBreadcrumb(elementData, i == 1)
	end
	
	self.PathChanged:Fire(old, folderElementData)
end

-- Private

function Breadcrumbs:_createBreadcrumb(folderElementData: ElementData?, isLast: boolean): BreadcrumbPreset
	local breadcrumb = self.BreadcrumbPreset:Clone()
	local text =
		if folderElementData == nil then `{self.RootName}:/`
		elseif isLast then folderElementData.Name
		else `{folderElementData.Name}/`
	breadcrumb.Text = text
	breadcrumb.TextColor3 = self._textColor
	if self.OpenedFolder == folderElementData then
		breadcrumb.TextTransparency = 0
	end

	-- Events

	local hovering = false
	local originalColor: Color3
	breadcrumb.InputBegan:Connect(function(input)
		if self.OpenedFolder == folderElementData then return end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			hovering = true
			
			if folderElementData == nil then
				breadcrumb.Text = wrapUnderlineTags(text)
			else
				breadcrumb.Text = wrapUnderlineTags(folderElementData.Name) .. (if isLast then "" else "/")
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			breadcrumb.TextTransparency = 0
		end
	end)
	breadcrumb.InputEnded:Connect(function(input)
		if self.OpenedFolder == folderElementData then return end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			hovering = false
			
			breadcrumb.Text = text
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			breadcrumb.TextTransparency = 0.3
		end
	end)
	self.MouseField:LeftClick(breadcrumb, function()
		if not hovering then
			-- Mouse may still be within bounds of the button even when it's clipped by the ScrollingFrame.
			-- Make sure it's actually hovering on the button for this reason.
			return
		end
		self:Open(folderElementData)
	end)
	self.MouseField:LeftRelease(breadcrumb, function()
		if not hovering then return end
		self.LeftReleasedOnBreadcrumb:Fire(folderElementData)
	end)
	
	table.insert(self._breadcrumbs, breadcrumb)
	breadcrumb.Parent = self.Container
	
	return breadcrumb
end

return Breadcrumbs