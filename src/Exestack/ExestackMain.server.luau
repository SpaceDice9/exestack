-- stops accidental save in as plugin to script
if not script.Parent:IsA("Folder") then
	coroutine.yield(coroutine.running())
end

local PluginToolbar = plugin:CreateToolbar("Exestack")
local OpenPreferences = PluginToolbar:CreateButton("Preferences", "Opens Preferences", "rbxassetid://14031743705")
OpenPreferences.ClickableWhenViewportHidden = true

local TweenService = game:GetService("TweenService")
local Selection = game:GetService("Selection")

local ExestackFile = script.Parent
local Storage = ExestackFile.Storage
local Modules = ExestackFile.Modules

local References = require(Modules.References)
local Util = require(Modules.Util)
local SettingsManager = require(Modules.SettingsManager)
local Console = require(Modules.Console)
local MicroTerminal = require(Modules.MicroTerminal)
local AppList = require(Modules.AppList)

local PreferencesWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	true,
	600,
	450,
	600,
	450
)

local PreferencesWidget = plugin:CreateDockWidgetPluginGui("Preferences", PreferencesWidgetInfo)
PreferencesWidget.Name = "Preferences"
PreferencesWidget.Title = "Preferences"

local SaveKeys = References.PluginSaveKeys

local success = pcall(function()
	local testScript = Instance.new("Script")

	testScript.Parent = PreferencesWidget

	task.delay(1, function()
		testScript:Destroy()
	end)
end)

if not success then
	warn("Script injection failed. Make sure it is enabled first before restarting Studio")

	Util.YieldCurrentThread()
end

local Preferences = SettingsManager.BuildSettings(PreferencesWidget, "Dark")
Preferences:ChangeTheme(tostring(settings().Studio.Theme))
Preferences:Compile()
local GeneralCategory = Preferences:AddCategory("General")

local SavedPreferences = plugin:GetSetting(SaveKeys.Preferences) or {}
Preferences:ApplySettings(SavedPreferences)

GeneralCategory:AddSection("Updates")

GeneralCategory:AddSpacing()
GeneralCategory:AddSection("Debug")

GeneralCategory:AddSetting{
	Name = "LoggingEnabled",
	Descriptor = "Logging Enabled",
	Description = "Allows printing into the console",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
}

GeneralCategory:AddSetting{
	Name = "LogNoncritical",
	Descriptor = "Log Non-critical",
	Description = "Allows printing non-critical logs into the console",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
}

local CompiledPreferences = Preferences.Options

function _isCurrentVersionOutdated(currentVersion, newVersion)
	local currentSplit = string.split(currentVersion, ".")
	local newSplit = string.split(newVersion, ".")

	for i = 1, #currentSplit do
		local currentVersionNumber = tonumber(currentSplit[i])
		local newVersionNumber = tonumber(newSplit[i])

		if newVersionNumber > currentVersionNumber then
			return true
		elseif newVersionNumber < currentVersionNumber then
			return false -- non-published version
		end
	end

	return false
end

function getTempScreen(screenName)
	if game.CoreGui:FindFirstChild(screenName) then
		return game.CoreGui:FindFirstChild(screenName)
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = screenName
	screen.Archivable = false
	screen.Parent = game.CoreGui

	return screen
end

function _createNotification(text)
	local notification = Storage.NotifyFrame:Clone()
	notification.Position = UDim2.new(1, -10, 1, 100)
	notification.Label.Text = text
	notification.Parent = getTempScreen("ExestackNotifyGui")

	local tweenInfo = TweenInfo.new(.25)

	local addNotifyTween = TweenService:Create(notification, tweenInfo, {Position = UDim2.new(1, -10, 1, -10)})
	local removeNotifyTween = TweenService:Create(notification, tweenInfo, {Position = UDim2.new(1, 650, 1, -10)})

	addNotifyTween:Play()

	notification.Button.MouseButton1Up:Connect(function()
		removeNotifyTween:Play()
		task.wait(.25)

		notification:Destroy()
	end)

	task.delay(4, function()
		removeNotifyTween:Play()
		task.wait(.25)

		notification:Destroy()
	end)
end

function updateConsole()
	Console.Enabled = CompiledPreferences.LoggingEnabled
	Console.ReportNoncritical = CompiledPreferences.LogNoncritical
end

function buildPlugin(parent)
	parent = parent or workspace
	
	local build = ExestackFile:Clone()
	build.Parent = parent
	
	return build
end


Preferences.OnChange:Connect(function(name, state)
	if name == "LoggingEnabled" or name == "LogNoncritical" then
		updateConsole()
	end
end)


OpenPreferences.Click:Connect(function()
	Util.ForceWidgetOpen(PreferencesWidget)
end)

settings().Studio.ThemeChanged:Connect(function()
	Preferences:ChangeTheme(tostring(settings().Studio.Theme))
end)

PreferencesWidget:BindToClose(function()
	Preferences:Compile()
	PreferencesWidget.Enabled = false

	plugin:SetSetting(SaveKeys.Preferences, Preferences:Serialize())
end)

plugin.Unloading:Connect(function()
	
end)

References.ExestackToolbar = PluginToolbar
References.PreferencesWidget = PreferencesWidget
References.Preferences = Preferences

updateConsole()

local apps = ExestackFile.Applications:GetChildren()

for _, app in apps do
	task.spawn(function()
		local startLoading = os.clock()
		local API = require(app)
		
		if API then
			local finishedLoading = os.clock()
			AppList[app.Name] = API
			
			Console.Print("Time taken to load", app.Name .. ":", (finishedLoading - startLoading))
		else
			Console.CriticalWarn("Failed to load", app.Name)
		end
	end)
end

local exestackMT = plugin:GetSetting(SaveKeys.ExestackMetadata)

if exestackMT then
	if exestackMT.Version ~= ExestackFile:GetAttribute("Version") then
		Console.Warn("Outdated save data detected")
	end
end

plugin:SetSetting(SaveKeys.ExestackMetadata, {
	Version = ExestackFile:GetAttribute("Version"),
})

GeneralCategory:Resize()
Preferences:Compile()

task.delay(1, function()
	Preferences:ChangeTheme(tostring(settings().Studio.Theme))
	Preferences:Compile()
end)

local helpString = [[

usage:
   exestack [-h --help]

subcommands:
   clone      Builds a copy of Exestack

Incomplete
]]

MicroTerminal.RegisterCommand("exestack", function(tokens)
	--if tokens[1].flags[1] == "-h" or tokens[1].flags[1] == "--help" then
	if MicroTerminal.HasFlags(tokens[1].flags, "-h", "--help") then
		task.spawn(print, helpString)
		
		return
	end
	
	if tokens[2] and tokens[2].token == "clone" then
		local build = buildPlugin(Selection:Get()[1])
		Selection:Set({build})
		
		print("Built Exestack")
	end
end)

MicroTerminal.InitOutputHook()