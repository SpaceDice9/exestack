--!strict
local CoreGui = game:GetService("CoreGui")

local ScratchpadGenerator = require(script.Parent.Parent.Parent.GuiGenerators.ScratchpadGenerator)
local OdeScriptEditor = require(script.Parent.Parent.OdeScriptEditor)
local Draggable = require(script.Parent.util.Draggable)
local GoodSignal = require(script.Parent.Parent.SignalModule)

export type ThemeData = {
	Background: Color3,
	LightBackground: Color3,
	InsetHeader: Color3,
	LightBorder: Color3,
	HeavyBorder: Color3,
	NegativeBorder: Color3,

	NormalIcon: Color3,
	HoverIcon: Color3,
	SelectIcon: Color3,
	SelectHoverIcon: Color3,
	
	NormalElement: Color3,
	HoverElement: Color3,
	SelectElement: Color3,

	Positive: Color3,
	Neutral: Color3,
	Negative: Color3,
	Other: Color3,
	
	FolderIcon: Color3,

	HiddenByt: Color3,
	DisabledIcon: Color3,

	TextColor: Color3,
	SelectTextColor: Color3,
	FadedText: Color3,
}

type ScratchpadImpl = {
	__index: ScratchpadImpl,
	new: (themeData: ThemeData) -> Scratchpad,
	ChangeTheme: (Scratchpad, ThemeData) -> (),
}

type ScratchpadFields = {
	ScreenGui: ScreenGui,
	Container: ScratchpadGenerator.ScratchpadContainer,
	OnWantToRun: any,
	_odeScriptEditor: any,
	_themeData: ThemeData,
}

export type Scratchpad = typeof(setmetatable({} :: ScratchpadFields, {} :: ScratchpadImpl))

--[=[
	@class Scratchpad

	The Byt Scratchpad
--]=]
local Scratchpad = {} :: ScratchpadImpl
Scratchpad.__index = Scratchpad

function getScreen(screenName): ScreenGui
	if CoreGui:FindFirstChild(screenName) then
		CoreGui:FindFirstChild(screenName):Destroy()
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = screenName
	screen.Archivable = false
	screen.Parent = game.CoreGui

	return screen
end

function Scratchpad.new(themeData: ThemeData)
	local scratchpadGui = getScreen("ScratchpadGui")
	local container = ScratchpadGenerator.generate(scratchpadGui)
	local odeScriptEditor = OdeScriptEditor.Embed(container.OdeFrame)

	local self = {
		ScreenGui = scratchpadGui,
		Container = container,
		OnWantToRun = GoodSignal.new(),
		_odeScriptEditor = odeScriptEditor,
		_themeData = themeData
	}

	setmetatable(self, Scratchpad)

	local gripButton = container.ScratchpadInteractions.GripButton :: ScratchpadGenerator.Interaction
	Draggable.hook(gripButton, container)

	local runButton = container.ScratchpadInteractions.RunButton
	runButton.MouseButton1Click:Connect(function()
		self.OnWantToRun:Fire(odeScriptEditor.RawSource)
	end)

	local clearButton = container.ScratchpadInteractions.ClearButton
	clearButton.MouseButton1Click:Connect(function()
		odeScriptEditor:Unload()
	end)

	return self
end

function Scratchpad:ChangeTheme(themeData: ThemeData)
	self._themeData = themeData
	local container = self.Container

	container.BackgroundColor3 = themeData.Background

	local interactions = container.ScratchpadInteractions
	interactions.RunButton.BackgroundColor3 = themeData.Neutral
	interactions.ClearButton.BackgroundColor3 = themeData.Negative
	
	for _, interaction in container.ScratchpadInteractions:GetChildren() :: {ScratchpadGenerator.Interaction} do
		if interaction:IsA("GuiButton") then
			interaction.ImageLabel.ImageColor3 = themeData.NormalIcon
		end
	end

	self._odeScriptEditor:ApplyStudioTheme(settings().Studio)
end

return Scratchpad