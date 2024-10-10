local Signal = require(script.Parent.SignalModule)

local MouseField = {}
MouseField.__index = MouseField

local Buttony = {}

function MouseField:WithinBounds(button: GuiButton, x: number, y: number)
	local truePosition = button.AbsolutePosition
	local trueSize = button.AbsoluteSize

	if trueSize.X < 0 then
		truePosition = truePosition - Vector2.new(-trueSize.X, 0)

		trueSize = Vector2.new(-trueSize.X, trueSize.Y)
	end

	if trueSize.Y < 0 then
		truePosition = truePosition - Vector2.new(0, -trueSize.Y)

		trueSize = Vector2.new(trueSize.X, -trueSize.Y)
	end

	local startPosition = truePosition
	local endPosition = truePosition + trueSize

	return x > startPosition.X and x < endPosition.X and y > startPosition.Y and y < endPosition.Y
end

function MouseField:IsVisible(button: GuiButton)
	local parent = button

	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		parent = parent.Parent
	end

	return true
end

function MouseField:RegisterButton(button: GuiButton)
	if self.RegisteredButtons[button] then
		return self.RegisteredButtons[button]
	end

	local events = {
		LeftPress = Signal.new(),
		LeftRelease = Signal.new(),

		LeftClick = Signal.new(),
		LeftDouble = Signal.new(),
		LeftDrag = Signal.new(),
		LeftDragRelease = Signal.new(),

		MiddlePress = Signal.new(),
		MiddleRelease = Signal.new(),

		MiddleClick = Signal.new(),
		MiddleDouble = Signal.new(),
		MiddleDrag = Signal.new(),
		MiddleDragRelease = Signal.new(),

		RightPress = Signal.new(),
		RightRelease = Signal.new(),

		RightClick = Signal.new(),
		RightDouble = Signal.new(),
		RightDrag = Signal.new(),
		RightDragRelease = Signal.new(),
	}

	local buttonData = {
		Button = button,
		Events = events,
	}

	self.RegisteredButtons[button] = buttonData

	return buttonData
end

function MouseField:DeregisterButton(button: GuiButton)
	local buttonData = self.RegisteredButtons[button]

	for _, event in buttonData.Events do
		event:DisconnectAll()
	end

	self.RegisteredButtons[button] = nil
end

function MouseField:LeftPress(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.LeftPress:Connect(fn)
end

function MouseField:LeftRelease(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.LeftRelease:Connect(fn)
end

function MouseField:LeftClick(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.LeftClick:Connect(fn)
end

function MouseField:LeftDouble(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.LeftDouble:Connect(fn)
end

function MouseField:LeftDrag(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.LeftDrag:Connect(fn)
end

function MouseField:LeftDragRelease(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.LeftDragRelease:Connect(fn)
end

function MouseField:RightPress(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.RightPress:Connect(fn)
end

function MouseField:RightRelease(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.RightRelease:Connect(fn)
end

function MouseField:RightClick(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.RightClick:Connect(fn)
end

function MouseField:RightDouble(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.RightDouble:Connect(fn)
end

function MouseField:RightDrag(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.RightDrag:Connect(fn)
end

function MouseField:RightDragRelease(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.RightDragRelease:Connect(fn)
end

function MouseField:MiddlePress(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.MiddlePress:Connect(fn)
end

function MouseField:MiddleRelease(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.MiddleRelease:Connect(fn)
end

function MouseField:MiddleClick(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.MiddleClick:Connect(fn)
end

function MouseField:MiddleDouble(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.MiddleDouble:Connect(fn)
end

function MouseField:MiddleDrag(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.MiddleDrag:Connect(fn)
end

function MouseField:MiddleDragRelease(button: GuiButton, fn)
	local buttonData = self:RegisterButton(button)
	buttonData.Events.MiddleDragRelease:Connect(fn)
end

type MouseFieldEventTable = {
	Down: (any) -> (number, number),
	Up: (any) -> (number, number),
	Move: (any) -> (number, number),
	Leave: (any) -> (number, number),
}

local function buildEventsMouseField(self, downEvent, upEvent, moveEvent, leaveEvent, events: MouseFieldEventTable, eventNames)
	local canClick = false
	local isDragging = false
	local lastClickRelease = nil
	local initialPosition = nil

	local initialClickedButtons = {}
	local buttonsDragged = {}

	local function clearState()
		for _, clickData in initialClickedButtons do
			clickData.connection:Disconnect()
		end

		table.clear(initialClickedButtons)
		table.clear(buttonsDragged)

		isDragging = false
		canClick = false
	end

	downEvent:Connect(function(...)
		local x, y = events.Down(...)

		if not x and not y then
			return
		end

		canClick = true
		initialPosition = Vector2.new(x, y)

		for _, buttonData in self.RegisteredButtons do
			local button = buttonData.Button :: GuiButton

			if self:WithinBounds(button, x, y) and MouseField:IsVisible(button) then
				local clickData = {
					button = button,
					order = button:GetAttribute("ClickOrder") or button.ZIndex,
				}

				clickData.connection = button.MouseLeave:Connect(function()
					clickData.connection:Disconnect()

					local position = table.find(initialClickedButtons, clickData)
					initialClickedButtons[position] = nil
				end)

				table.insert(initialClickedButtons, clickData)

				buttonData.Events[eventNames.Press]:Fire(x, y)
			end
		end

		table.sort(initialClickedButtons, function(a, b)
			return a.order > b.order
		end)
	end)

	upEvent:Connect(function(...)
		local x, y = events.Up(...)

		if not x and not y then
			return
		end

		for _, buttonData in self.RegisteredButtons do
			local button = buttonData.Button :: GuiButton

			if self:WithinBounds(button, x, y) and MouseField:IsVisible(button) then
				buttonData.Events[eventNames.Release]:Fire(x, y)
			end
		end

		if not canClick or isDragging then
			if isDragging then
				for _, buttonData in buttonsDragged do
					buttonData.Events[eventNames.DragRelease]:Fire(x, y)
				end
			end

			clearState()

			return
		end

		local isDoubleClick = false

		if not lastClickRelease then
			lastClickRelease = os.clock()
		elseif lastClickRelease then
			local currentTime = os.clock()

			if currentTime - lastClickRelease < .25 then
				isDoubleClick = true
				lastClickRelease = nil
			elseif currentTime - lastClickRelease >= .25 then
				lastClickRelease = currentTime
			end
		end

		for _, clickData in initialClickedButtons do
			local button = clickData.button
			clickData.connection:Disconnect()

			if not self:WithinBounds(button, x, y) or not MouseField:IsVisible(button) then
				continue
			end

			local buttonData = self.RegisteredButtons[button]

			if isDoubleClick then
				buttonData.Events[eventNames.Double]:Fire(x, y)
			else
				buttonData.Events[eventNames.Click]:Fire(x, y)
			end

			if button:GetAttribute("ClickActive") == false then
				break
			end
		end

		clearState()
	end)

	moveEvent:Connect(function(...)
		local x, y = events.Move(...)

		if not x and not y then
			return
		end

		--do dragging here
		if not canClick then
			return
		end

		if not isDragging and initialPosition and (math.abs(initialPosition.X - x) > 5 or math.abs(initialPosition.Y - y) > 5) then
			isDragging = true

			for _, clickData in initialClickedButtons do
				local button = clickData.button
				clickData.connection:Disconnect()

				if not self:WithinBounds(button, x, y) or not MouseField:IsVisible(button) then
					continue
				end

				local buttonData = self.RegisteredButtons[button]
				table.insert(buttonsDragged, buttonData)
			end
		end

		if not isDragging then
			return
		end

		for _, buttonData in buttonsDragged do
			buttonData.Events[eventNames.Drag]:Fire(x, y)
		end
	end)

	leaveEvent:Connect(function(...)
		local x, y = events.Leave(...)

		if not x and not y then
			return
		end

		clearState()
	end)
end

function Buttony.MouseField(buttonFrame: GuiButton, guiInset: number?)
	guiInset = guiInset or 0

	local self = {
		RegisteredButtons = {},
		ButtonFrame = buttonFrame,
	}

	setmetatable(self, MouseField)

	--leftEventsMouseField(self)
	buildEventsMouseField(self, buttonFrame.MouseButton1Down, buttonFrame.MouseButton1Up, buttonFrame.MouseMoved, buttonFrame.MouseLeave, {
		Down = function(x, y)
			return x, y - guiInset
		end,

		Up = function(x, y)
			return x, y - guiInset
		end,

		Move = function(x, y)
			return x, y - guiInset
		end,

		Leave = function(x, y)
			return x, y - guiInset
		end
	}, {
		Press = "LeftPress",
		Release = "LeftRelease",

		Click = "LeftClick",
		Double = "LeftDouble",
		Drag = "LeftDrag",
		DragRelease = "LeftDragRelease"
	})

	buildEventsMouseField(self, buttonFrame.InputBegan, buttonFrame.InputEnded, buttonFrame.MouseMoved, buttonFrame.MouseLeave, {
		Down = function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton3 then
				return input.Position.X, input.Position.Y - guiInset
			end

			return
		end,

		Up = function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton3 then
				return input.Position.X, input.Position.Y - guiInset
			end

			return
		end,

		Move = function(x, y)
			return x, y - guiInset
		end,

		Leave = function(x, y)
			return x, y - guiInset
		end
	}, {
		Press = "MiddlePress",
		Release = "MiddleRelease",

		Click = "MiddleClick",
		Double = "MiddleDouble",
		Drag = "MiddleDrag",
		DragRelease = "MiddleDragRelease"
	})

	buildEventsMouseField(self, buttonFrame.MouseButton2Down, buttonFrame.MouseButton2Up, buttonFrame.MouseMoved, buttonFrame.MouseLeave, {
		Down = function(x, y)
			return x, y - guiInset
		end,

		Up = function(x, y)
			return x, y - guiInset
		end,

		Move = function(x, y)
			return x, y - guiInset
		end,

		Leave = function(x, y)
			return x, y - guiInset
		end
	}, {
		Press = "RightPress",
		Release = "RightRelease",

		Click = "RightClick",
		Double = "RightDouble",
		Drag = "RightDrag",
		DragRelease = "RightDragRelease"
	})

	return self
end

function Buttony.Single(button: GuiButton, guiInset: number?)
	local mouseField = Buttony.MouseField(button, guiInset)
	local buttonData = mouseField:RegisterButton(button)

	return buttonData, mouseField
end

return Buttony