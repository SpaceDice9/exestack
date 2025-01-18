local userInputService = game:GetService("UserInputService")

local Draggable = {}

-- TODO: return list of connections for possible cleaning
function Draggable.hook(gripButton: GuiButton, frame: GuiObject)
	local relPos = Vector2.new(0, 0)
	local gripping = false
	
	gripButton.MouseButton1Down:Connect(function(x: number, y: number) 
		relPos = frame.AbsolutePosition - Vector2.new(x, y)
		gripping = true
	end)
	
	userInputService.InputChanged:Connect(function(input: InputObject, _: boolean) 
		if input.UserInputType == Enum.UserInputType.MouseMovement and gripping then
			local mousePosition = input.Position
			frame.Position = UDim2.fromOffset(mousePosition.X + relPos.X, mousePosition.Y + relPos.Y)
		end
	end)
	
	gripButton.MouseButton1Up:Connect(function() 
		gripping = false	
	end)
end

return Draggable