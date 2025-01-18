--luau cat guigenerator
export type LucideSelection = {
	uri: string,
	rectSize: Vector2,
	rectOffset: Vector2,
}

local ScratchpadGenerator = {}

function newLucideSelection(uri: string, rectSize: Vector2, rectOffset: Vector2): LucideSelection
	return {
		uri = uri,
		rectSize = rectSize,
		rectOffset = rectOffset
	}
end

export type Interaction = TextButton & {
	ImageLabel: ImageLabel
}

function ScratchpadGenerator.addInteraction(name: string, order: number, interactions: Frame, imageContent: LucideSelection)
	local interaction = Instance.new("TextButton")
	interaction.Text = ""
	interaction.Name = name .. "Button"
	interaction.Size = UDim2.fromOffset(30, 30)
	interaction.LayoutOrder = order

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = interaction

	local image = Instance.new("ImageLabel")
	image.Image = imageContent.uri
	image.ImageRectSize = imageContent.rectSize
	image.ImageRectOffset = imageContent.rectOffset
	image.Size = UDim2.fromOffset(20, 20)
	image.Position = UDim2.fromScale(.5, .5)
	image.AnchorPoint = Vector2.new(.5, .5)
	image.BackgroundTransparency = 1
	image.Name = "ImageLabel"
	image.Parent = interaction

	interaction.Parent = interactions

	return interaction
end

export type ScratchpadContainer = Frame & {
	ScratchpadInteractions: Frame & {
		RunButton: Interaction,
		ClearButton: Interaction,
		GripButton: Interaction
	},
	OdeFrame: Frame
}

function ScratchpadGenerator.generate(parent: Instance): ScratchpadContainer
	local scratchpadContainer = Instance.new("Frame")
	scratchpadContainer.Size = UDim2.fromOffset(500, 300)
	scratchpadContainer.Name = "ScratchpadContainer"

	local scratchpadInteractions = Instance.new("Frame")
	scratchpadInteractions.Name = "ScratchpadInteractions"
	scratchpadInteractions.Size = UDim2.new(0, 40, 1, 0)
	scratchpadInteractions.BackgroundTransparency = 1
	scratchpadInteractions.Parent = scratchpadContainer

	local interactionsUiList = Instance.new("UIListLayout")
	interactionsUiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	interactionsUiList.VerticalAlignment = Enum.VerticalAlignment.Center
	interactionsUiList.Padding = UDim.new(0, 5)
	interactionsUiList.Parent = scratchpadInteractions

	local runIcon = newLucideSelection("rbxassetid://16898731919", Vector2.new(256, 256), Vector2.new(0, 514))
	local gripIcon = newLucideSelection("rbxassetid://16898672700", Vector2.new(256, 256), Vector2.new(514, 0))
	local clearIcon = newLucideSelection("rbxassetid://16898669772", Vector2.new(256, 256), Vector2.new(257, 257))

	ScratchpadGenerator.addInteraction("Run", -1, scratchpadInteractions, runIcon)
	ScratchpadGenerator.addInteraction("Clear", 1, scratchpadInteractions, clearIcon)
	local gripButton = ScratchpadGenerator.addInteraction("Grip", 0, scratchpadInteractions, gripIcon)
	gripButton.BackgroundTransparency = 1
	gripButton.Size = UDim2.fromOffset(30, 50)

	local odeFrame = Instance.new("Frame")
	odeFrame.Name = "OdeFrame"
	odeFrame.BackgroundTransparency = 1
	odeFrame.Size = UDim2.new(1, -45, 1, -10)
	odeFrame.Position = UDim2.new(0, 40, 0, 5)
	odeFrame.Parent = scratchpadContainer

	scratchpadContainer.Parent = parent

	return scratchpadContainer
end

return ScratchpadGenerator