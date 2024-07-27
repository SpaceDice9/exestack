-- this module is meant to provide additional click events and click handling for plugins. Inspired by my old util module
local Signal = require(script.Parent.SignalModule)

local ClickField = {}
ClickField.__index = ClickField

function ClickField:RegisterElement(element: GuiButton)
	if element:IsA("GuiButton") then
		table.insert(self.ElementField, element)

		self.ElementEvents[element] = {
			LeftClick = Signal.new(),
			RightClick = Signal.new(),
			
			DoubleLeftClick = Signal.new(),
			DoubleRightClick = Signal.new(),
			
			HoldLeftClick = Signal.new(),
			HoldRightClick = Signal.new(),
		}
	end
end

function ClickField:RegisterElements(elementList: {GuiButton})
	for _, element in pairs(elementList) do
		self:RegisterElement(element)
	end
end

function ClickField:UnregisterElement(element: GuiButton)
	local index = table.find(self.ElementField, element)
	
	if index then
		table.remove(self.ElementField, index)
		
		for _, event in pairs(self.ElementEvents[element]) do
			event:DisconnectAll()
		end
		
		self.ElementEvents[element] = nil
	end
end

--disables elements so they are not checked for click events
function ClickField:DisableElements()
	
end

--re enables elements that are visible
function ClickField:ReenableElements()

end

function ClickField:BindToEvent(element: GuiButton, eventName: string, fn)
	local events = self.ElementEvents[element]

	if not events then
		self:RegisterElement(element)

		events = self.ElementEvents[element]
	end
	
	return events[eventName]:Connect(fn)
end

function ClickField:OnLeftClick(element: GuiButton, fn)
	return self:BindToEvent(element, "LeftClick", fn)
end

function ClickField:OnHoldLeftClick(element: GuiButton, fn)
	return self:BindToEvent(element, "HoldLeftClick", fn)
end

function ClickField:OnDoubleLeftClick(element: GuiButton, fn)
	return self:BindToEvent(element, "DoubleLeftClick", fn)
end

function ClickField:OnRightClick(element: GuiButton, fn)
	return self:BindToEvent(element, "RightClick", fn)
end

local function isSelfAndAncestorsVisible(clickable)
	local parent = clickable
	
	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end
		
		parent = parent.Parent
	end
	
	return true
end

function ClickField:GetClickables(x: number, y: number): {GuiButton}
	local clickableFrames = {}

	for _, frame in pairs(self.ElementField) do
		local posStart = frame.AbsolutePosition
		local posEnd = posStart + frame.AbsoluteSize

		if x > posStart.X and x < posEnd.X and y > posStart.Y and y < posEnd.Y and isSelfAndAncestorsVisible(frame) then
			table.insert(clickableFrames, frame)
		end
	end

	table.sort(clickableFrames, function(a, b)
		return a.ZIndex > b.ZIndex
	end)

	return clickableFrames
end

function ClickField.new(clickFieldFrame: GuiButton)
	local self = {
		Frame = clickFieldFrame,
		ElementField = {},
		ElementEvents = {}
	}
	
	setmetatable(self, ClickField)
	
	clickFieldFrame.MouseButton1Down:Connect(function(x, y)
		local holding = true
		
		clickFieldFrame.MouseButton1Up:Once(function()
			holding = false
		end)
		
		if holding then
			local clickableFrames = self:GetClickables(x, y)

			for _, clickableFrame in pairs(clickableFrames) do
				task.spawn(function()
					task.wait(clickableFrame:GetAttribute("HoldLeftClickWait") or 1)
					
					if holding then
						local events = self.ElementEvents[clickableFrame]

						events.HoldLeftClick:Fire(x, y)
					end
				end)
				
				if not clickableFrame:GetAttribute("ClickActive") then
					break
				end
			end
		end
	end)
	
	clickFieldFrame.MouseButton1Up:Connect(function(x, y)
		local clickableFrames = self:GetClickables(x, y)
		local lastClick = os.clock()

		for _, clickableFrame in pairs(clickableFrames) do
			local events = self.ElementEvents[clickableFrame]

			events.LeftClick:Fire(x, y)

			if not clickableFrame:GetAttribute("ClickActive") then
				break
			end
		end

		clickFieldFrame.MouseButton1Up:Once(function(x, y)
			local clickableFrames = self:GetClickables(x, y)

			for _, clickableFrame in pairs(clickableFrames) do
				local events = self.ElementEvents[clickableFrame]

				if os.clock() - lastClick < 0.25 then
					events.DoubleLeftClick:Fire(x, y)
				end

				if not clickableFrame:GetAttribute("ClickActive") then
					break
				end
			end

			lastClick = math.huge
		end)
	end)
	
	
	clickFieldFrame.MouseButton2Down:Connect(function(x, y)
		local holding = true

		clickFieldFrame.MouseButton2Up:Once(function()
			holding = false
		end)

		if holding then
			local clickableFrames = self:GetClickables(x, y)

			for _, clickableFrame in pairs(clickableFrames) do
				task.spawn(function()
					task.wait(clickableFrame:GetAttribute("HoldLeftClickWait") or 1)

					if holding then
						local events = self.ElementEvents[clickableFrame]

						events.HoldRightClick:Fire(x, y)
					end
				end)

				if not clickableFrame:GetAttribute("ClickActive") then
					break
				end
			end
		end
	end)
	
	clickFieldFrame.MouseButton2Up:Connect(function(x, y)
		local clickableFrames = self:GetClickables(x, y)
		local lastClick = os.clock()

		for _, clickableFrame in pairs(clickableFrames) do
			local events = self.ElementEvents[clickableFrame]

			events.RightClick:Fire(x, y)

			if not clickableFrame:GetAttribute("ClickActive") then
				break
			end
		end

		clickFieldFrame.MouseButton2Up:Once(function(x, y)
			local clickableFrames = self:GetClickables(x, y)

			for _, clickableFrame in pairs(clickableFrames) do
				local events = self.ElementEvents[clickableFrame]

				if os.clock() - lastClick < 0.25 then
					events.DoubleRightClick:Fire(x, y)
				end

				if not clickableFrame:GetAttribute("ClickActive") then
					break
				end
			end

			lastClick = math.huge
		end)
	end)
	
	return self
end

return ClickField
