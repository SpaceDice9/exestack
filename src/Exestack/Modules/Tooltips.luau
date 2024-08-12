local TextService = game:GetService("TextService")

local Tooltips = {}
Tooltips.__index = Tooltips

function Tooltips.init(tooltipGui, frame)
	local self = {
		instance = tooltipGui,
		frame = frame,
		deviation = {X = 0, Y = 0},
		padding = 10,
		enabled = true,
		
		deviationAmount = 3,
		mouseSize = 20
	}
	
	return setmetatable(self, Tooltips)
end

function Tooltips:reanchor()
	local instance = self.instance
	local deviation = self.deviation
	local padding = self.padding
	
	if instance and self.frame then
		local position = instance.Position
		local size = instance.Size

		local anchorX = 0
		local anchorY = 1

		if position.X.Offset + size.X.Offset - deviation.X + padding >= self.frame.AbsoluteSize.X then
			anchorX = 1
			
			deviation.X = -self.deviationAmount
		else
			deviation.X = self.deviationAmount
		end
		
		if position.Y.Offset - size.Y.Offset - deviation.Y - padding <= 0 then
			anchorY = 0
			
			deviation.Y = self.mouseSize + self.deviationAmount
		else
			deviation.Y = -self.deviationAmount
		end
		
		instance.AnchorPoint = Vector2.new(anchorX, anchorY)
	end
end

function Tooltips:reposition(x, y)
	local deviation = self.deviation

	self.instance.Position = UDim2.fromOffset(x + deviation.X, y + deviation.Y)
end

function Tooltips:newTooltip(gui, tip)
	local tooltip = {
		Text = tip,
		Element = gui,
		Enabled = true
	}
	
	gui.MouseEnter:Connect(function(x, y)
		local instance = self.instance
		local canDisplayTip = true

		local leaveConnection; leaveConnection = gui.MouseLeave:Connect(function()
			canDisplayTip = false
			
			leaveConnection:Disconnect()
		end)
		
		task.wait(.8)
		
		if canDisplayTip and instance and tooltip.Enabled then
			local label = instance.Label
			local size = TextService:GetTextSize(tooltip.Text, label.TextSize, label.Font, Vector2.new(math.huge, label.Size.Y.Offset))
			
			label.Text = tooltip.Text
			instance.Size = UDim2.fromOffset(size.X + 4 + 4 + 1, instance.Size.Y.Offset)
			instance.Visible = self.enabled
		end
	end)
	
	gui.MouseMoved:Connect(function(x, y)
		if self.instance and tooltip.Enabled then
			self:reposition(x, y)
			self:reanchor()
			self:reposition(x, y)
		end
	end)
	
	gui.MouseLeave:Connect(function()
		if self.instance then
			self.instance.Visible = false
		end
	end)
	
	return tooltip
end

return Tooltips
