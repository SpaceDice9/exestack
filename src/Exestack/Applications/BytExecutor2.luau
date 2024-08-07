local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local ScriptEditorService = game:GetService("ScriptEditorService")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local Apps = script.Parent
local ExestackFile = Apps.Parent
local plugin = ExestackFile.Parent

local Storage = ExestackFile.Storage.BytExecutor2
local InsertedScripts = ExestackFile.Inserted.BytExecutor2
local Modules = ExestackFile.Modules

local References = require(Modules.References)
local Util = require(Modules.Util)
local Buttony = require(Modules.Buttony)
local LuaTableModule = require(Modules.LuaTable)
local GoodSignal = require(Modules.SignalModule)
local TooltipsModule = require(Modules.Tooltips)
local SettingsManager = require(Modules.SettingsManager)
local Ode = require(Modules.OdeScriptEditor)
local Console = require(Modules.Console)

local Breadcrumbs = require(Modules.UI.Breadcrumbs)

local AppList = require(Modules.AppList)

local returnAPI = {}

local BytExecutorWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	370,
	400,
	280,
	350
)

local ExecutorWidget = plugin:CreateDockWidgetPluginGui("BytExecutor", BytExecutorWidgetInfo)
ExecutorWidget.Name = "BytExecutor2"
ExecutorWidget.Title = "BytExecutor2"

local OdeWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	true,
	450,
	450,
	450,
	400
)

local OdeWidget = plugin:CreateDockWidgetPluginGui("OdeScriptEditor", OdeWidgetInfo)
OdeWidget.Name = "OdeScriptEditor"
OdeWidget.Title = "OSE"

local ExestackToolbar = References.ExestackToolbar

local OpenBytExecutor = ExestackToolbar:CreateButton("Code Executor", "Opens BytExecutor2", "rbxassetid://14031750483")
OpenBytExecutor.ClickableWhenViewportHidden = true

local ExecutorBackground = ExestackFile.UI.BytExecutorBackground:Clone()
local ElementListFrame = ExecutorBackground.ElementListContainer.ElementList
local ClickFieldFrame = ExecutorBackground.ClickFieldFrame
local DragContainer = ExecutorBackground.DragContainer
local MoreElementListOptionsButton = ExecutorBackground.MoreElementListOptionsButton

local Topbar = ExecutorBackground.TopbarContainer.Topbar
local NewBytScriptButton = Topbar.NewElementButton
local MoreOptionsButton = Topbar.MoreOptionsButton
local Searchbar = Topbar.SearchbarContainer.Searchbar

local SelectionBox = ExecutorBackground.SelectionBox

local PromptContainer = ExecutorBackground.PromptContainer
local PromptBox = PromptContainer.Prompt

local EditorScripts = Storage.EditorScripts:Clone()
local DummyScriptsFolder = Storage.DummyScripts:Clone()
local ExecutablesFolder = Storage.Executables:Clone()
local Documents = ExestackFile.Documents:Clone()

EditorScripts.Parent = ExecutorWidget
ExecutablesFolder.Parent = ExecutorWidget
Documents.Parent = ExecutorWidget

DummyScriptsFolder.Parent = ExecutorWidget
DummyScriptsFolder.Name = "BYT_DEBUG_REDIRECT"

local BytSourcesList = {}
local ElementDataListFromGui = {}
local ScriptDataListFromScript = {}
local TemporaryFolders = {}

local ElementSelection = {}
local ElementDragged = {}
local ElementHovering = nil
local ElementLastHovered = nil
local ElementRightClicked = nil
local SearchWord = ""

local Dragging = false
local HoldingControl = false

local TextboxFocusedOn = nil

local DummyScripts = {}
local IsRunning = RunService:IsRunning()
local StateUpdated = false
local DirectoryChanged = false

local PreviouslyInteractedByt = {
	Opened = nil,
	Executed = nil,
	Both = nil,
}

local snippetAutocompleteData = {}

local BoxStart = Vector2.new(0, 0)
local BoxEnd = Vector2.new(0, 0)

local createAdvancedMenu = plugin:CreatePluginMenu("CreateAdvancedBE")
local createBytAction = plugin:CreatePluginAction("NewBytScriptBE", "New Byt Script", "Create new Byt script", "rbxassetid://10723365877")
local createFolderAction = plugin:CreatePluginAction("NewFolderBE", "New Folder", "Create new folder", "rbxassetid://10723386531")
local createSnippetAction = plugin:CreatePluginAction("NewSnippetBE", "New Snippet", "Create new snippet", "rbxassetid://10734942778")
local createLocalBytAction = plugin:CreatePluginAction("CreateLocalByt", "Create Local Byt", "Create new local Byt", "rbxassetid://10734909540")
local addLocalBytAction = plugin:CreatePluginAction("AddLocalByt", "Add Local Byt", "Add new local Byt", "rbxassetid://10734909540")
--local createSyncedAction = plugin:CreatePluginAction("NewSynced", "New Synced Byt", "Create new synced Byt", "rbxassetid://10734909016")
createAdvancedMenu:AddAction(createBytAction)
createAdvancedMenu:AddAction(createFolderAction)
createAdvancedMenu:AddAction(createSnippetAction)
createAdvancedMenu:AddAction(addLocalBytAction)
createAdvancedMenu:AddAction(createLocalBytAction)

local runDMScriptsAction = plugin:CreatePluginAction("RunDMScripts", "Run DataModel Scripts", "Run selected DataModel scripts")
local runSelectedScriptsAction = plugin:CreatePluginAction("RunSelectedScripts", "Run Selected Scripts", "Run selected scripts")
local runLastRanScriptsAction = plugin:CreatePluginAction("RunLastRanScripts", "Run Previously Interacted With Byt", "Run previously interacted with byt")

local advancedMenu = plugin:CreatePluginMenu("GenericAdvancedBE")
advancedMenu:AddAction(createBytAction)
advancedMenu:AddAction(createFolderAction)
advancedMenu:AddAction(createSnippetAction)
advancedMenu:AddAction(addLocalBytAction)
advancedMenu:AddAction(createLocalBytAction)
advancedMenu:AddSeparator()
advancedMenu:AddAction(runSelectedScriptsAction)
advancedMenu:AddAction(runLastRanScriptsAction)
advancedMenu:AddAction(runDMScriptsAction)
advancedMenu:AddSeparator()
local advImport = advancedMenu:AddNewAction("ImportScripts", "Import Selected Scripts", "rbxassetid://10723344270")
local advExport = advancedMenu:AddNewAction("ExportScripts", "Export Selected Scripts", "rbxassetid://10747366434")
local advSave = advancedMenu:AddNewAction("SaveElements", "Save BytSources Directory", "rbxassetid://10734941499")
local advCreateBackup = advancedMenu:AddNewAction("CreateBackup", "Create a BytSources Backup", "rbxassetid://10709762233")
local advLoadBackup = advancedMenu:AddNewAction("LoadBackup", "Load Selected BytSources Backup", "rbxassetid://10709762058")
local advLoadLastBackup = advancedMenu:AddNewAction("LoadLastBackup", "Load Last BytSources Backup", "rbxassetid://10709762058")
advancedMenu:AddSeparator()
local advReload = advancedMenu:AddNewAction("ReloadBytExecutor2", "Reload BytExecutor2 Instances", "rbxassetid://10734933222")

local moreMenu = plugin:CreatePluginMenu("MoreOptionsBE")
local moreSettings = moreMenu:AddNewAction("OpenSettings", "Preferences")
local moreHelp = moreMenu:AddNewAction("OpenHelp", "Help", "rbxassetid://10723406988")
local moreAbout = moreMenu:AddNewAction("OpenAbout", "About")
local buildExestack = moreMenu:AddNewAction("BuildExestack", "Clone Plugin")

local executeAdvancedMenu = plugin:CreatePluginMenu("ExecuteAdvancedBE")
local advExeServerByt = executeAdvancedMenu:AddNewAction("ExecuteServerside", "Execute on Server", "rbxassetid://10723365877")
local advExeClientByt = executeAdvancedMenu:AddNewAction("ExecuteClientside", "Execute on Client", "rbxassetid://10723365877")

local elementAdvancedMenu = plugin:CreatePluginMenu("ElementAdvancedBE")
local advElementRename = elementAdvancedMenu:AddNewAction("RenameElement", "Rename Element", "")

local odeScriptEditor = Ode.Embed(OdeWidget)

type ElementData = {
	Name: string,
	Gui: Frame,
	Events: {},
	PartsRegistered: {},
	Type: string,
	Parent: ElementData,
	ReplicationInstance: Instance,

	--BytScript & Snippet
	RawSource: string,
	Script: Script,
	
	--Snippet
	InsertString: string,

	--Folder
	ElementList: {ElementData},
}

local SaveKeys = References.PluginSaveKeys

local BytElementStates = {
	Unhover = {
		"Status",
	},

	Hover = {
		"Execute",
		"Export",
		"Edit",
		"Delete",
	},

	RunningNoControl = {
		"Export",
		"Edit",
		"Delete",
	},

	Running = {
		"Export",
		"Edit",
		"Delete",

		"Terminate",
		"Pause"
	},

	Pause = {
		"Resume",
		"Export",
		"Edit",
		"Delete",
	},
}

local ExecutionStateIcons = {
	Idle = "rbxassetid://6035053285",
	Running = "rbxassetid://6031260777",
	--Finished = "rbxassetid://6023426929",
	Finished = "rbxassetid://7733919947",
	Failed = "rbxassetid://6031071050",

	Paused = "rbxassetid://6031260777",
	Terminated = "rbxassetid://6023426901",
}

local ElementTypes = {
	BytScript = "BytScript",
	Folder = "Folder",

	Snippet = "Snippet",
	
	LocalByt = "LocalByt",
}

local ExecutionStatuses = {
	Idle = "Idle",
	Running = "Running",
	Finished = "Finished",
	Failed = "Failed",

	Terminated = "Terminated",
	Paused = "Paused"
}

local ExecutionStatusColors = {
	Idle = "NormalIcon",
	Running = "Neutral",
	Finished = "Positive",
	Failed = "Negative",

	Terminated = "Negative",
	Paused = "NormalIcon"
}

local Themes = {
	Dark = {
		Background = Color3.fromRGB(47, 47, 47),
		LightBackground = Color3.fromRGB(57, 57, 57),
		InsetHeader = Color3.fromRGB(37, 37, 37),
		LightBorder = Color3.fromRGB(17, 17, 17),
		HeavyBorder = Color3.fromRGB(0, 0, 0),
		NegativeBorder = Color3.fromRGB(255, 255, 255),

		NormalIcon = Color3.fromRGB(210, 210, 210),
		HoverIcon = Color3.fromRGB(255, 255, 255),
		NormalByt = Color3.fromRGB(47, 47, 47),
		HoverByt = Color3.fromRGB(77, 77, 77),

		Positive = Color3.fromRGB(0, 220, 0),
		Neutral = Color3.fromRGB(50, 180, 240),
		Negative = Color3.fromRGB(230, 70, 70),
		Other = Color3.fromRGB(255, 85, 255),

		HiddenByt = Color3.fromRGB(27, 27, 27),
		DisabledIcon = Color3.fromRGB(100, 100, 100),

		TextColor = Color3.fromRGB(220, 220, 220),
		FadedText = Color3.fromRGB(157, 157, 157),
	},

	Light = {
		Background = Color3.fromRGB(247, 247, 247),
		LightBackground = Color3.fromRGB(237, 237, 237),
		InsetHeader = Color3.fromRGB(217, 217, 217),
		LightBorder = Color3.fromRGB(197, 197, 197),
		HeavyBorder = Color3.fromRGB(177, 177, 177),
		NegativeBorder = Color3.fromRGB(0, 0, 0),

		NormalIcon = Color3.fromRGB(50, 50, 50),
		HoverIcon = Color3.fromRGB(20, 20, 20),
		NormalByt = Color3.fromRGB(247, 247, 247),
		HoverByt = Color3.fromRGB(197, 237, 247),

		Positive = Color3.fromRGB(40, 200, 40),
		Neutral = Color3.fromRGB(20, 150, 250),
		Negative = Color3.fromRGB(230, 70, 70),
		Other = Color3.fromRGB(220, 85, 220),

		HiddenByt = Color3.fromRGB(177, 177, 177),
		DisabledIcon = Color3.fromRGB(160, 160, 160),

		TextColor = Color3.fromRGB(40, 40, 40),
		FadedText = Color3.fromRGB(47, 47, 47),
	}
}

local scriptEditorThemeProperties = {
	"Script Editor Color Preset",

	"Background Color",
	"Text Color",
	"Script Editor Scrollbar Background Color",
	"Keyword Color",
	"Built-in Function Color",
	"String Color",
	"Number Color",
	"Comment Color",

	"Property Color",
	"Method Color",
	"Function Name Color",
	"Bool Color",
	
	"Operator Color",
	"Luau Keyword Color",
	"\"nil\" Color",
	"\"function\" Color",
	"\"nil\" Color",
	"\"function\" Color",
}

local Theme = Themes.Dark
type Theme = typeof(Theme)

ExecutorBackground.Visible = true
ExecutorBackground.Parent = ExecutorWidget

local MouseField = Buttony.MouseField(ClickFieldFrame)

local FolderBreadcrumbs = Breadcrumbs.new({
	MouseField = MouseField,
	Container = ExecutorBackground.FolderBreadcrumbsContainer,
	BreadcrumbPreset = Storage.FolderBreadcrumb_Preset,

	RootName = "BS",
})

local Tooltips = TooltipsModule.init(ExecutorBackground.TooltipFrame, ExecutorBackground)
Tooltips:newTooltip(NewBytScriptButton, "New Element")
Tooltips:newTooltip(MoreOptionsButton, "More Options")
Tooltips:newTooltip(FolderBreadcrumbs.Container, "Folder Path")

local Preferences = References.Preferences
local BytExecutor2Category = Preferences:AddCategory("BytExecutor2")

BytExecutor2Category:AddSection("UI")

BytExecutor2Category:AddSetting({
	Name = "TooltipsEnabledBE",
	Descriptor = "Tooltips Enabled",
	Description = "Displays tooltips when hovering over a UI element",
	Type = "Boolean",

	DefaultState = true,
	Restrictions = {}
})

BytExecutor2Category:AddSetting({
	Name = "SelectionBorderOnElementBE",
	Descriptor = "Element Selection Border",
	Description = "Show selection border outline on element",
	Type = "Boolean",

	DefaultState = true,
	Restrictions = {}
})

BytExecutor2Category:AddSetting{
	Name = "TooltipsEnabledBE",
	Descriptor = "Tooltips Enabled",
	Description = "Display tooltips when hovering over some UI elements",
	Type = "Boolean",

	DefaultState = true,
	Restrictions = {}
}

BytExecutor2Category:AddSetting{
	Name = "SwapBehaviorOfCreateElementIconBE",
	Descriptor = "Swap Behavior Of Create Element Icon",
	Description = "Swap the left and right click behavior of the create element icon",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
}

BytExecutor2Category:AddSpacing()
BytExecutor2Category:AddSection("Elements")

BytExecutor2Category:AddSetting{
	Name = "OpenWhenCreateByt",
	Descriptor = "Open When Create Byt",
	Description = "Open the preferred script editor when creating a byt",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
}

BytExecutor2Category:AddSetting{
	Name = "AutoRenameElementBE",
	Descriptor = "Automatically Rename Element",
	Description = "Automatically prompts user to rename an element as soon as it is created",
	Type = "Boolean",

	DefaultState = true,
	Restrictions = {}
}

BytExecutor2Category:AddSetting{
	Name = "AutomaticallyInsertBytLib",
	Descriptor = "Automatically Insert Byt Library",
	Description = "Automatically inserts the byt util library",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
}

BytExecutor2Category:AddSetting({
	Name = "BytInteractDefinition",
	Descriptor = "Byt Interaction Definition",
	Description = "Definition of a byt interaction",
	Type = "Selection",

	DefaultState = "Executed",
	
	Restrictions = {"Opened", "Executed", "Both"}
})

BytExecutor2Category:AddSetting{
	Name = "FastSavingBE",
	Descriptor = "Fast Saving",
	Description = "Uses the legacy save behavior of the original BytExecutor",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
}

BytExecutor2Category:AddSpacing()
BytExecutor2Category:AddSection("Default Names")

BytExecutor2Category:AddSetting{
	Name = "DefaultBytName",
	Descriptor = "Default Byt Name",
	Description = "The default name of a byt when it is created",
	Type = "FreeString",

	DefaultState = "BytScript",
	Restrictions = function(newName)
		return string.match(newName, "[%w_]+") == newName
	end,
}

BytExecutor2Category:AddSetting{
	Name = "DefaultFolderName",
	Descriptor = "Default Folder Name",
	Description = "The default name of a folder when it is created",
	Type = "FreeString",

	DefaultState = "Folder",
	Restrictions = function(newName)
		return string.match(newName, "[%w_]+") == newName
	end,
}

BytExecutor2Category:AddSetting{
	Name = "DefaultSnippetName",
	Descriptor = "Default Snippet Name",
	Description = "The default name of a snippet when it is created",
	Type = "FreeString",

	DefaultState = "Snippet",
	Restrictions = function(newName)
		return string.match(newName, "[%w_]+") == newName
	end,
}

BytExecutor2Category:AddSpacing()
BytExecutor2Category:AddSection("Drag Behavior")

BytExecutor2Category:AddSetting{
	Name = "OpenFolderOnDrag",
	Descriptor = "Open Folder On Drag",
	Description = "Automatically opens folder on dragging to it",
	Type = "Boolean",

	DefaultState = true,
	Restrictions = {}
}

BytExecutor2Category:AddSetting{
	Name = "SelectElementsDraggedOnOpeningFolder",
	Descriptor = "Select Elements Dragged On Opening Folder",
	Description = "Select previously dragged elements upon opening folder",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
}


BytExecutor2Category:AddSpacing()
BytExecutor2Category:AddSection("Importing/Exporting")

BytExecutor2Category:AddSetting({
	Name = "AlwaysExportAsBE",
	Descriptor = "Export As",
	Description = "Determines what class a byt exports as if Contextual Exporting is disabled",
	Type = "Selection",

	DefaultState = "Server",
	Restrictions = {"Server", "Client", "Module"}
})

BytExecutor2Category:AddSetting({
	Name = "ContextualExportingBE",
	Descriptor = "Contextual Exporting (Smart Exporting)",
	Description = "Dynamically changes the class or RunContext of an exported script depending on its parent",
	Type = "Boolean",

	DefaultState = true,
	Restrictions = {}
})

BytExecutor2Category:AddSetting({
	Name = "UseNewRunContextWhenExportingBE",
	Descriptor = "Use New RunContext When Exporting",
	Description = "Use the new RunContext property rather than Class when exporting elements",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})


BytExecutor2Category:AddSpacing()
BytExecutor2Category:AddSection("Experimental")

BytExecutor2Category:AddSetting({
	Name = "ScriptErrorRedirectBE",
	Descriptor = "Redirect Byt Script Errors",
	Description = "Redirect byt script errors to the editor",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})

BytExecutor2Category:AddSetting({
	Name = "CustomScriptEditorBE",
	Descriptor = "Custom Script Editor",
	Description = "Use Ode script editor over the default",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})

BytExecutor2Category:AddSetting({
	Name = "ServerClientExecution",
	Descriptor = "Server/Client Execution",
	Description = "Allows option to run a byt either on the server or client",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})

BytExecutor2Category:AddSetting({
	Name = "SaveCurrentDirectoryPositionBE",
	Descriptor = "Save Current Directory Position",
	Description = "Saves the user's current directory position",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})

BytExecutor2Category:AddSetting({
	Name = "ForceUniqueNamesBE",
	Descriptor = "Force Unique Element Names",
	Description = "Forces unique element names",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})

Preferences:ChangeTheme(tostring(settings().Studio.Theme))
Preferences:Compile()
BytExecutor2Category:Resize()

local CompiledPreferences = Preferences.Options
local Debug = {}

function pushTable(source, destination)
	table.move(source, 1, #source, #destination + 1, destination)
end

function lookForInTable(haystack, needle)
	for k, v in haystack do
		if v == needle then
			return k
		end
	end
end

function isCurrentVersionOutdated(currentVersion, newVersion)
	local currentSplit = string.split(currentVersion, ".")
	local newSplit = string.split(newVersion, ".")

	for i = #currentSplit, 1, -1 do
		local currentVersionNumber = tonumber(currentSplit[i])
		local newVersionNumber = tonumber(newSplit[i])

		if newVersionNumber > currentVersionNumber then
			return true
		end
	end

	return false
end

function isInactive()
	return not ExecutorBackground.Parent
end

function secondsToStamp(seconds)
	local Stamp = {RawSeconds = seconds}

	Stamp.Hours = math.floor(seconds/3600)
	seconds = seconds - Stamp.Hours*3600

	if Stamp.Hours < 10 then
		Stamp.Hours = "0" .. Stamp.Hours
	end

	Stamp.Minutes = math.floor(seconds/60)
	seconds = seconds - Stamp.Minutes*60

	if Stamp.Minutes < 10 then
		Stamp.Minutes = "0" .. Stamp.Minutes
	end

	Stamp.Seconds = seconds

	if Stamp.Seconds < 10 then
		Stamp.Seconds = "0" .. Stamp.Seconds
	end

	Stamp.Seconds = string.sub(Stamp.Seconds, 1, 6)

	local stampString = Stamp.Hours .. ":" .. Stamp.Minutes .. ":" .. Stamp.Seconds

	return stampString
end

function getErrorContext(errorMsg)
	local rawContext = string.split(tostring(errorMsg), ":")

	local context

	if #rawContext == 1 then
		context = {
			Path = "NO.PATH",
			Line = 0,
			Message = rawContext[1],
			Clock = secondsToStamp(os.clock()),
			Timestamp = os.date("%X"),
		}
	elseif #rawContext == 3 then
		context = {
			Path = rawContext[1],
			Line = rawContext[2],
			Message = rawContext[3]:sub(2),
			Clock = secondsToStamp(os.clock()),
			Timestamp = os.date("%X"),
		}
	else
		error("Failed to get error context, there are " .. #rawContext .. " parts")
	end

	return context
end

function selfAndAncestorIs(instance: Instance, class)
	return instance:IsA(class) or instance:FindFirstAncestorWhichIsA(class)
end

function returnDefaultParent(parent)
	return parent or ServerScriptService
end

function clearAllSaveData()
	plugin:SetSetting(SaveKeys.BytExecutorList, nil)
end

function loadTempFolder(parent, name)
	return parent:FindFirstChild(name)
end

function lazyLoadTempFolder(parent, name)
	local tempFolder = parent:FindFirstChild(name)
	
	if tempFolder then
		return tempFolder
	end

	tempFolder = Instance.new("Folder")
	tempFolder.Name = name
	tempFolder.Parent = parent

	table.insert(TemporaryFolders, tempFolder)

	return tempFolder
end

function createTempFolder(parent, name)
	if parent:FindFirstChild(name) then
		local tempFolder = parent:FindFirstChild(name)

		if not table.find(TemporaryFolders, tempFolder) then
			table.insert(TemporaryFolders, tempFolder)
		end

		tempFolder:ClearAllChildren()

		return tempFolder
	end

	local tempFolder = Instance.new("Folder")
	tempFolder.Name = name
	tempFolder.Parent = parent

	table.insert(TemporaryFolders, tempFolder)

	return tempFolder
end

function deleteTempFolder(parent, name)
	local tempFolder = parent:FindFirstChild(name)
	
	if not tempFolder then
		return
	end
	
	local index = table.find(TemporaryFolders, tempFolder)

	if index then
		table.remove(TemporaryFolders, index)
	end

	tempFolder:Destroy()
end

function addSnackbar(text)
	for _, previousSnackbar in ExecutorBackground.SnackbarContainer:GetChildren() do
		if previousSnackbar:IsA("Frame") then
			previousSnackbar.LayoutOrder += 1

			if previousSnackbar.LayoutOrder > 3 then
				previousSnackbar:Destroy()
			end
		end
	end

	local snackbar = Storage.Snackbar_Preset:Clone()
	snackbar.Name = "Snackbar"
	snackbar.TextLabel.Text = text
	snackbar.Parent = ExecutorBackground.SnackbarContainer
	
	MouseField:LeftClick(snackbar.ImageButton, function()
		MouseField:DeregisterButton(snackbar.ImageButton)

		snackbar:Destroy()
	end)
	

	createFeedbackForIcons(snackbar.ImageButton, "Negative", "NormalIcon")

	task.delay(7, function()
		if not snackbar or not snackbar.Parent then
			return
		end

		MouseField:DeregisterButton(snackbar.ImageButton)

		snackbar:Destroy()
	end)

	return snackbar
end

function initReplication()
	createTempFolder(ReplicatedStorage, "BytReplicationFolder")
	createTempFolder(ReplicatedStorage, "BytEventFolder")

	local bytExeServer = createTempFolder(ServerScriptService, "BytExeServerScripts")
	local bytExeClient = createTempFolder(StarterPlayer:FindFirstChildOfClass("StarterPlayerScripts"), "BytExeClientScripts")


	local bytEventFolder = loadTempFolder(ReplicatedStorage, "BytEventFolder")

	local externalEventCaller = Instance.new("RemoteEvent")
	externalEventCaller.Name = "ExternalEvent"
	externalEventCaller.Parent = bytEventFolder

	local internalEventCaller = Instance.new("BindableEvent")
	internalEventCaller.Name = "InternalEvent"
	internalEventCaller.Parent = bytEventFolder


	local serverExeScript = InsertedScripts.BytExecutorServer:Clone()
	serverExeScript.Enabled = true
	serverExeScript.Parent = bytExeServer

	local clientExeScript = InsertedScripts.BytExecutorClient:Clone()
	clientExeScript.Enabled = true
	clientExeScript.Parent = bytExeClient
end

function removeReplication()
	deleteTempFolder(ReplicatedStorage, "BytReplicationFolder")
	deleteTempFolder(ReplicatedStorage, "BytEventFolder")
	
	deleteTempFolder(ServerScriptService, "BytExeServerScripts")
	deleteTempFolder(StarterPlayer:FindFirstChildOfClass("StarterPlayerScripts"), "BytExeClientScripts")
end

function isReplicationEditable()
	return (CompiledPreferences.ServerClientExecution and not IsRunning)
end

function isReplicationUsable()
	return (CompiledPreferences.ServerClientExecution and IsRunning)
end

function changeElementTheme(element, themeData: Theme)
	element.BackgroundColor3 = themeData.Background

	element.ConfirmInteractions.BackgroundColor3 = themeData.HiddenByt
	element.ConfirmInteractions.Confirm.ImageColor3 = themeData.NormalIcon
	element.ConfirmInteractions.Cancel.ImageColor3 = themeData.NormalIcon

	element.Warning.TextColor3 = themeData.TextColor

	element.ElementNameBackground.BackgroundColor3 = themeData.InsetHeader
	element.ElementName.TextColor3 = themeData.TextColor

	element.ElementIcon.ImageColor3 = themeData.NormalIcon

	element.SelectionStroke.Color = themeData.NegativeBorder

	for _, interactionButton in element.Interactions:GetChildren() do
		if interactionButton:IsA("ImageButton") then
			interactionButton.ImageColor3 = themeData.NormalIcon
		end
	end
end

function changeTheme(themeName)
	local themeData = Themes[themeName] :: Theme

	Theme = themeData
	
	if isInactive() then
		return
	end

	ExecutorBackground.BackgroundColor3 = themeData.Background

	ExecutorBackground.NoElementDisplay.ImageLabel.ImageColor3 = themeData.DisabledIcon
	ExecutorBackground.NoElementDisplay.TextLabel1.TextColor3 = themeData.FadedText
	--ExecutorBackground.NoElementDisplay.TextLabel2.TextColor3 = themeData.FadedText
	--ExecutorBackground.NoElementDisplay.TextLabel3.TextColor3 = themeData.FadedText

	ExecutorBackground.TooltipFrame.BackgroundColor3 = themeData.Background
	ExecutorBackground.TooltipFrame.BorderColor3 = themeData.LightBorder
	ExecutorBackground.TooltipFrame.Label.TextColor3 = themeData.TextColor

	ExecutorBackground.TopbarContainer.BackgroundColor3 = themeData.InsetHeader
	ExecutorBackground.TopbarContainer.BorderColor3 = themeData.LightBorder

	Topbar.SearchbarContainer.BackgroundColor3 = themeData.LightBackground
	Topbar.SearchbarContainer.UIStroke.Color = themeData.HeavyBorder
	Searchbar.TextColor3 = themeData.TextColor
	Searchbar.PlaceholderColor3 = themeData.FadedText
	Topbar.SearchbarContainer.Separater.BackgroundColor3 = themeData.NegativeBorder
	Topbar.SearchbarContainer.ImageLabel.ImageColor3 = themeData.NormalIcon

	NewBytScriptButton.ImageColor3 = themeData.NormalIcon
	MoreOptionsButton.ImageColor3 = themeData.NormalIcon

	FolderBreadcrumbs:ChangeTheme({
		BackgroundColor = themeData.InsetHeader,
		BorderColor = themeData.LightBorder,
		SeparatorColor = themeData.NegativeBorder,
		IconColor = themeData.NormalIcon,
		TextColor = themeData.TextColor,
	})

	ExecutorBackground.Display.Separater1.BackgroundColor3 = themeData.HeavyBorder
	ExecutorBackground.Display.Separater2.BackgroundColor3 = themeData.HeavyBorder

	for element, _ in ElementDataListFromGui do
		changeElementTheme(element, themeData)
	end

	for _, snackbar in ExecutorBackground.SnackbarContainer:GetChildren() do
		if snackbar:IsA("Frame") then
			snackbar.BackgroundColor3 = themeData.InsetHeader
			snackbar.UIStroke.Color = themeData.LightBorder
			snackbar.ImageButton.ImageColor3 = themeData.NormalIcon
			snackbar.TextLabel.TextColor3 = themeData.TextColor
		end
	end
	
	PromptContainer.BackgroundColor3 = themeData.LightBackground
	PromptContainer.UIStroke.Color = themeData.HeavyBorder
	PromptBox.TextColor3 = themeData.TextColor
	
	Preferences:ChangeTheme(themeName)
end

function applyOdeTheme()
	local studio = settings().Studio
	odeScriptEditor:ApplyStudioTheme(studio)
end

function selectElement(elementData)
	if table.find(ElementSelection, elementData) then return end
	
	local element = elementData.Gui
	local elementIcon = element.ElementIcon

	table.insert(ElementSelection, elementData)

	elementIcon.ImageColor3 = Theme.Neutral
	element.SelectionStroke.Enabled = CompiledPreferences.SelectionBorderOnElementBE
end

function deselectElement(selectionPosition)
	local elementData = ElementSelection[selectionPosition]
	local element = elementData.Gui
	local elementIcon = element.ElementIcon

	table.remove(ElementSelection, selectionPosition)

	elementIcon.ImageColor3 = Theme.NormalIcon
	element.SelectionStroke.Enabled = false
end

function deselectAllElements()
	for i, elementData in ElementSelection do
		local element = elementData.Gui
		local elementIcon = element.ElementIcon

		elementIcon.ImageColor3 = Theme.NormalIcon
		element.BackgroundColor3 = Theme.NormalByt
		element.SelectionStroke.Enabled = false
	end
	
	table.clear(ElementSelection)
end

function startSelectionBox(x, y)
	SelectionBox.Visible = true
	SelectionBox.Size = UDim2.fromOffset(0, 0)
	SelectionBox.Position = UDim2.fromOffset(x, y)

	BoxStart = Vector2.new(x, y)
end

function updateSelectionBox(x, y)
	SelectionBox.Size = UDim2.fromOffset(x - BoxStart.X, y - BoxStart.Y)
end

function hideSelectionBox(x, y)
	BoxEnd = Vector2.new(x, y)
	SelectionBox.Visible = false
end

function intersectsWith(start1, end1, start2, end2)
	return start1.X < end2.X and end1.X > start2.X and start1.Y < end2.Y and end1.Y > start2.Y
end

function convertToReal(pos, size)
	if 0 > size.X then
		pos = Vector2.new(pos.X + size.X, pos.Y)
		size = Vector2.new(-size.X, size.Y)
	end

	if 0 > size.Y then
		pos = Vector2.new(pos.X, pos.Y + size.Y)
		size = Vector2.new(size.X, -size.Y)
	end

	return pos, size
end

function reselectWithSelectionBox()
	local elementDataList = getElementList(FolderBreadcrumbs.OpenedFolder)

	if not HoldingControl then
		table.clear(ElementSelection)
	end

	local realBoxStart, realBoxSize = convertToReal(BoxStart, BoxEnd - BoxStart)
	local realBoxEnd = realBoxStart + realBoxSize

	for _, elementData in elementDataList do
		local absStart = elementData.Gui.ElementMainButton.AbsolutePosition
		local absSize = elementData.Gui.ElementMainButton.AbsoluteSize
		local absEnd = absStart + absSize

		if intersectsWith(realBoxStart, realBoxEnd, absStart, absEnd) and not table.find(ElementSelection, elementData) then
			selectElement(elementData)
		end
	end
end

function mouseMoved(x, y)
	if Dragging then
		--updateDraggingState(x, y)
	elseif SelectionBox.Visible then
		updateSelectionBox(x, y)
	end
end

function getElementList(folderData)
	local elementDataList = BytSourcesList

	if folderData then
		elementDataList = folderData.ElementList
	end

	return elementDataList
end

function getIndexPathOfElement(elementData)
	local parent
	local child = elementData
	local indices = {}
	
	if not elementData then
		return indices
	else
		parent = elementData.Parent
	end
	
	repeat
		local elementDataList = getElementList(parent)
		local index = table.find(elementDataList, child)
		
		if not index then
			Console.CriticalWarn("Failed to get index path")
			
			return
		end
		
		table.insert(indices, 1, index)
		
		child = parent
		
		if parent then
			parent = parent.Parent
		end
	until not child
	
	return indices
end

function searchViableElements(folderData)
	local elementDataList = getElementList(folderData)
	local viableElements = {}
	
	for _, elementData in elementDataList do
		if elementData.Name:lower():match(SearchWord:lower()) then
			table.insert(viableElements, elementData)
		elseif elementData.Type == ElementTypes.Folder then
			local folderViableElements = searchViableElements(elementData)
			
			if #folderViableElements > 0 then
				table.insert(viableElements, elementData)
			end
		end
	end
	
	return viableElements
end

function updateElementVisibility(folderData)
	local elementDataList = getElementList(folderData)
	local viableElements = searchViableElements(folderData)
	
	for _, elementData in elementDataList do
		elementData.Gui.Visible = false
	end
	
	for _, elementData in viableElements do
		elementData.Gui.Visible = true
	end
end

function updateScrollSize()
	local listSize = 0
	local elementDataList = getElementList()

	for _, elementData in elementDataList do
		if elementData.Gui.Visible and elementData.Gui.Parent then
			listSize = listSize + 1
		end
	end

	local bytListContainer = ElementListFrame.Parent
	local padding = ElementListFrame.UIListLayout.Padding.Offset
	local newSize = listSize*(Storage.Byt_Preset.Size.Y.Offset + padding) + 50

	bytListContainer.CanvasSize = UDim2.new(0, 0, 0, newSize)
end

function updateNoElementDisplayVisibility()
	if isInactive() then
		return
	end
	
	local hasElements = false

	for _, elementData in BytSourcesList do
		hasElements = true

		break
	end

	ExecutorBackground.NoElementDisplay.Visible = not hasElements
end

function openFolder(folderElementData)
	FolderBreadcrumbs:Open(folderElementData)
end

function moveElementTo(folderElementData, elementData)
	local oldElementList = BytSourcesList
	local newElementList = BytSourcesList

	if FolderBreadcrumbs.OpenedFolder then
		oldElementList = FolderBreadcrumbs.OpenedFolder.ElementList
	end

	if folderElementData then
		newElementList = folderElementData.ElementList
	end

	if oldElementList == newElementList then
		return
	end

	local oldPosition = table.find(oldElementList, elementData)
	table.remove(oldElementList, oldPosition)

	table.insert(newElementList, elementData)
	elementData.Parent = folderElementData

	if folderElementData == FolderBreadcrumbs.OpenedFolder then
		elementData.Gui.Parent = ElementListFrame
	else
		elementData.Gui.Parent = nil
	end

	if isReplicationEditable() then
		local replicationParent = nil

		if folderElementData then
			replicationParent = folderElementData.ReplicationInstance
		else
			replicationParent = loadTempFolder(ReplicatedStorage, "BytReplicationFolder")
		end

		elementData.ReplicationInstance.Parent = replicationParent
	end

	StateUpdated = true
end

function onStartDragging(element, elementData, x, y)
	if #ElementSelection > 0 and not table.find(ElementSelection, elementData) then
		return
	end

	Dragging = true

	ElementDragged = table.clone(ElementSelection)

	for _, selectedElementData in ElementSelection do
		local visualElementDragging = selectedElementData.Gui:Clone()
		visualElementDragging.ZIndex = 1500
		visualElementDragging.ElementName.ZIndex = 1501
		visualElementDragging.ElementIcon.ZIndex = 1501
		
		visualElementDragging.Visible = true
		visualElementDragging.Parent = DragContainer
	end

	updateDraggingState(x, y)
	hideSelectionBox()
end

function tryDropIntoFolder(folderData: ElementData?)
	onDragElementToFolder(folderData)
	updateReplicationOrdering()
	Dragging = false
end

function onDragElementToFolder(elementData: ElementData?)
	local isElementInvalid = (elementData ~= nil) and (elementData.Type ~= ElementTypes.Folder or table.find(ElementDragged, elementData))
	if isElementInvalid or (not Dragging) then
		return
	end
	
	for _, otherElementData in ElementDragged do
		moveElementTo(elementData, otherElementData)
	end
	
	if CompiledPreferences.OpenFolderOnDrag then
		openFolder(elementData)
		
		if not CompiledPreferences.SelectElementsDraggedOnOpeningFolder then
			return
		end

		for _, elementData in ElementDragged do
			task.defer(selectElement, elementData)
		end
	end
end

function onStopDragging(x, y)
	for _, visual in DragContainer:GetChildren() do
		if visual:IsA("GuiObject") then
			visual:Destroy()
		end
	end

	task.defer(function()
		Dragging = false
	end)
end

function updateDraggingState(x, y)
	DragContainer.Position = UDim2.fromOffset(x, y)
end

--unused
--for moving elements to desired position which isnt implemented yet
function getListPositionFromMouse(y)
	--80 pixels is when the byt list gui starts
	return math.ceil((y - 80)/25)
end

function addPartsToElementData(elementData, parts)
	for _, part in parts do
		table.insert(elementData.PartsRegistered, part)
	end
end

function buildExecutableEnvironment(executable)
	local function forceEndThread(env)
		if executable.ExecutionStatus == "Terminated" then
			error("001")
		elseif executable.ExecutionStatus == "Paused" then
			--coroutine.yield(coroutine.running())
			Util.YieldCurrentThread()
		end
	end

	local env; env = {
		task = {
			wait = function(t)
				local dt = task.wait(t)

				forceEndThread(env)
				return dt
			end,

			delay = function(t, f, ...)
				task.wait(t)

				forceEndThread(env)
				return task.spawn(f, ...)
			end,

			spawn = task.spawn,
			defer = task.defer,
			cancel = task.cancel,
		},

		wait = function(t)
			local dt = wait(t)

			forceEndThread(env)
			return dt
		end,

		delay = function(t, f, ...)
			local dt = wait(t)

			forceEndThread(env)
			spawn(f, ...)
		end,

		script = executable.LoadedScript
	}

	return env
end

local Executable = {}
Executable.__index = Executable

function Executable:Execute()
	task.defer(function()
		ChangeHistoryService:SetWaypoint("Executing byt script")
		self.ExecutionStatus = ExecutionStatuses.Running
		self.OnStatusChange:Fire(self.ExecutionStatus)

		local routine = coroutine.create(function(...)
			local success, msg = pcall(self.Function, ...)

			self.InternalData = nil

			if success then
				self.ExecutionStatus = ExecutionStatuses.Finished
				self.ReturnValue = msg
				
				self.OnReturn:Fire(msg)
			else
				local errorContext = getErrorContext(msg)

				if errorContext.Message == "001" then
					return
				end

				self.ExecutionStatus = ExecutionStatuses.Failed
				self.Message = msg
			end

			self.LoadedScript:Destroy()
			self.OnStatusChange:Fire(self.ExecutionStatus)
		end)

		self.Routine = routine

		task.spawn(routine)
	end)
end

function Executable:Pause()
	self.ExecutionStatus = ExecutionStatuses.Paused
	self.OnStatusChange:Fire(self.ExecutionStatus)
end

function Executable:Terminate()
	self.ExecutionStatus = ExecutionStatuses.Terminated
	self.OnStatusChange:Fire(self.ExecutionStatus)
end

function Executable:Resume()
	self.ExecutionStatus = ExecutionStatuses.Running

	if not self.Routine then
		--warn("Attempted to resume non-existant routine")
		Console.Warn("Attempted to resume non-existant routine")
	end

	task.defer(self.Routine)
	self.OnStatusChange:Fire(self.ExecutionStatus)
end

function loadScriptSource(scriptSource)
	local loadedLua = LuaTableModule.FromScript(InsertedScripts.BytExecutable)
	local bytLua = LuaTableModule.FromString(scriptSource)

	local bytFirstLine = bytLua.Code[1]
	local executableStart = {"local ScriptExecutable = function() " .. bytFirstLine}

	loadedLua
		:Write(1, 1, executableStart)
		:Write(2, 1, bytLua:ToArray(2))

	return loadedLua
end

function loadScript(scriptObject)
	local scriptElementData = ScriptDataListFromScript[scriptObject]
	local source

	if scriptElementData then
		source = scriptElementData.RawSource
	else
		source = scriptObject.Source
	end

	local loadelScript = InsertedScripts.BytExecutable:Clone()
	local loadedLua = loadScriptSource(source)

	loadelScript.Name = scriptObject.Name .. " [INTERNAL EXECUTABLE]"
	loadelScript.Parent = ExecutablesFolder

	local redirect = Instance.new("ObjectValue")
	redirect.Name = "BytScriptRedirect"
	redirect.Value = scriptObject
	redirect.Parent = loadelScript

	loadedLua:ToScript(loadelScript)

	return loadelScript
end

function giveScriptBytLib(scriptObject)
	local newBytLib = InsertedScripts.BytLib:Clone()
	newBytLib.Parent = scriptObject
	
	require(newBytLib)._Apps = AppList
end

function fetchMostRecentError()
	local logHistory = LogService:GetLogHistory()
	
	for i = #logHistory, 1, -1 do
		local logData = logHistory[i]
		
		if logData.messageType == Enum.MessageType.MessageError then
			return logData.message
		end
	end
end

function escapePattern(str)
	return (str:gsub('%%', '%%%%')
		:gsub('^%^', '%%^')
		:gsub('%$$', '%%$')
		:gsub('%(', '%%(')
		:gsub('%)', '%%)')
		:gsub('%.', '%%.')
		:gsub('%[', '%%[')
		:gsub('%]', '%%]')
		:gsub('%*', '%%*')
		:gsub('%+', '%%+')
		:gsub('%-', '%%-')
		:gsub('%?', '%%?'))
end

function convertScriptToExecutable(loadedScript)
	local success, func = pcall(require, loadedScript)

	if not success then
		task.delay(.25, function()
			if not CompiledPreferences.ScriptErrorRedirectBE then
				return
			end
			
			local errorMsg = fetchMostRecentError()
			
			if not errorMsg:match(escapePattern(loadedScript.Name)) then
				return
			end
			
			local redirect = loadedScript:FindFirstChild("BytScriptRedirect")
			local errorContext = getErrorContext(errorMsg)
			local line = tonumber(errorContext.Line)
			
			if line > 0 then
				redirect:SetAttribute("LineOccurred", line)
			end
		end)
		
		return false, func
	end

	local executable = {
		Function = func,
		LoadedScript = loadedScript,
		ExecutionStatus = ExecutionStatuses.Idle,
		Message = nil,

		OnStatusChange = GoodSignal.new(),
		OnReturn = GoodSignal.new()
	}

	setmetatable(executable, Executable)

	return true, executable
end

function getExecutableFromScript(scr, allowBytLib)
	local loadedScript = loadScript(scr)

	if allowBytLib then
		giveScriptBytLib(loadedScript)
	end

	local success, executable = convertScriptToExecutable(loadedScript)
	return success, executable
end

function getExecutableFromElement(scriptElementData, allowBytLib)
	return getExecutableFromScript(scriptElementData.Script, allowBytLib)
end

function createDummyScript(redirect, line, msg)
	local dummyScript = Instance.new("ModuleScript")
	dummyScript.Name = redirect.Name
	dummyScript.Source = string.rep("\n", line - 1) .. "error(\"" .. msg .. "\")\nreturn"
	dummyScript.Parent = DummyScriptsFolder

	dummyScript:SetAttribute("Line", line)

	DummyScripts[redirect] = dummyScript

	return dummyScript
end

function callExecuteInModel(model, loadedScript)
	if model == "Server" and RunService:IsClient() then
		local bytEventFolder = loadTempFolder(ReplicatedStorage, "BytEventFolder")

		if not bytEventFolder then
			return
		end

		local event = bytEventFolder.ExternalEvent :: RemoteEvent

		event:FireServer(loadedScript)
	elseif model == "Client" and not RunService:IsClient() then
		local bytEventFolder = loadTempFolder(ReplicatedStorage, "BytEventFolder")

		if not bytEventFolder then
			return
		end

		local event = bytEventFolder.ExternalEvent :: RemoteEvent

		event:FireAllClients(loadedScript)
	else
		local bytEventFolder = loadTempFolder(ReplicatedStorage, "BytEventFolder")

		if not bytEventFolder then
			return
		end

		local event = bytEventFolder.InternalEvent :: BindableEvent

		event:Fire(loadedScript)
	end
end

function createFeedbackForIcons(icon : ImageButton, hoverName, unhoverName)
	icon.MouseEnter:Connect(function()
		icon.ImageColor3 = Theme[hoverName]
	end)

	icon.MouseLeave:Connect(function()
		icon.ImageColor3 = Theme[unhoverName]
	end)
end

function editInteractionsVisible(element, interactionsList)
	for _, interactionButton in element.Interactions:GetChildren() do
		if interactionButton:IsA("GuiBase2d") then
			interactionButton.Visible = false
		end
	end

	for _, interactionName in interactionsList do
		local interactionButton = element.Interactions:FindFirstChild(interactionName)

		if interactionButton then
			interactionButton.Visible = true
		end
	end
end

function onHover(elementData)
	elementData.Gui.BackgroundColor3 = Theme.HoverByt

	local elementState

	if not elementData.Executable then
		elementState = BytElementStates.Hover
	else
		elementState = BytElementStates.RunningNoControl
	end

	editInteractionsVisible(elementData.Gui, elementState)
	ElementHovering = elementData
	ElementLastHovered = elementData
end

function onUnhover(elementData)
	elementData.Gui.BackgroundColor3 = Theme.NormalByt
	editInteractionsVisible(elementData.Gui, BytElementStates.Unhover)
	
	ElementHovering = nil
end

function deferError(errorMsg, level)
	task.defer(error, errorMsg, level)
end

function onExecutableStatusChange(newStatus, executable, elementData)
	local interactions = elementData.Gui.Interactions

	interactions.Status.Image = ExecutionStateIcons[newStatus]
	interactions.Status.ImageColor3 = Theme[ExecutionStatusColors[newStatus]]

	if DummyScripts[elementData.Script] then
		DummyScripts[elementData.Script]:Destroy()
		DummyScripts[elementData.Script] = nil
	end

	if newStatus == ExecutionStatuses.Finished or newStatus == ExecutionStatuses.Failed or newStatus == ExecutionStatuses.Terminated then
		elementData.Executable = nil

		if ElementHovering == elementData then
			editInteractionsVisible(elementData.Gui, BytElementStates.Hover)
		else
			editInteractionsVisible(elementData.Gui, BytElementStates.Unhover)
		end
	end

	if newStatus == ExecutionStatuses.Failed then
		local errorContext = getErrorContext(executable.Message)

		if errorContext.Line ~= 0 then
			if not CompiledPreferences.ScriptErrorRedirectBE then
				if errorContext.Path:match("%.BytLib") and not errorContext.Path:match("EditorScripts%.BytLib") then
					deferError("Internal BytLib error | " .. errorContext.Line .. ": " .. errorContext.Message)
					return
				end
				
				deferError("Byt script error | " .. elementData.Name .. ":" .. errorContext.Line .. ": " .. errorContext.Message)
			else
				local dummyScript = createDummyScript(elementData.Script, errorContext.Line, errorContext.Message)
				pcall(require, dummyScript)
			end
		else
			deferError("Byt script error | " .. elementData.Name .. ": " .. errorContext.Message)
		end
	end
end

function addReplicationInstance(elementData, replicationInstance, parent, ignoreOpenedFolder)
	if parent then
		replicationInstance.Parent = parent.ReplicationInstance
	elseif FolderBreadcrumbs.OpenedFolder and not ignoreOpenedFolder then
		replicationInstance.Parent = FolderBreadcrumbs.OpenedFolder.ReplicationInstance
	else
		replicationInstance.Parent = ReplicatedStorage.BytReplicationFolder
	end

	elementData.ReplicationInstance = replicationInstance
end

function createReplicationInstances(folderData)
	local elementList = getElementList(folderData)

	if IsRunning then
		return
	end

	for _, elementData in elementList do
		if elementData.ReplicationInstance and elementData.ReplicationInstance:FindFirstAncestorOfClass("DataModel") then
			continue
		end

		if elementData.Type == ElementTypes.BytScript or elementData.Type == ElementTypes.LocalByt then
			local replicationInstance = Instance.new("Script")
			replicationInstance.Name = elementData.Name
			replicationInstance.Source = elementData.RawSource

			local internalReplicationScript = Instance.new("ModuleScript")
			internalReplicationScript.Name = "InternalScript"
			internalReplicationScript.Parent = replicationInstance

			local loadedLua = loadScriptSource(elementData.RawSource)
			loadedLua:ToScript(internalReplicationScript)

			addReplicationInstance(elementData, replicationInstance, folderData, true)
		elseif elementData.Type == ElementTypes.Folder then
			local replicationInstance = Instance.new("Folder")
			replicationInstance.Name = elementData.Name

			addReplicationInstance(elementData, replicationInstance, folderData, true)
			createReplicationInstances(elementData)
		end
	end
end

function updateReplicationOrdering(folderData)
	local elementList = getElementList(folderData)
	
	for order, elementData in elementList do
		local replicationInstance = elementData.ReplicationInstance
		
		if not replicationInstance then
			continue
		end
		
		replicationInstance:SetAttribute("LoadOrder", order)
		
		if elementData.Type == ElementTypes.Folder then
			updateReplicationOrdering(elementData)
		end
	end
end

function loadReplicatedElementList(replicationElementList, parent)
	table.sort(replicationElementList, function(a, b)
		return (a:GetAttribute("LoadOrder") or 1e3) < (b:GetAttribute("LoadOrder") or 1e3)
	end)
	
	for _, serializedElementInstance in replicationElementList do
		local elementData

		if serializedElementInstance:IsA("LuaSourceContainer") then
			local elementData = addBytElement(serializedElementInstance.Name, parent)

			if parent ~= FolderBreadcrumbs.OpenedFolder then
				elementData.Gui.Parent = nil
			end

			elementData.Script.Source = serializedElementInstance.Source
			elementData.RawSource = serializedElementInstance.Source
			elementData.ReplicationInstance = serializedElementInstance
			--print(elementData)
		elseif serializedElementInstance:IsA("Folder") then
			local folderElementData = addFolderElement(serializedElementInstance.Name, parent)

			loadReplicatedElementList(serializedElementInstance:GetChildren(), folderElementData)
		end
	end
end

function setElementName(elementData, newName)
	elementData.Gui.ElementName.Text = newName
	elementData.Name = newName

	if elementData.Script then
		elementData.Script.Name = newName
	end

	if CompiledPreferences.ServerClientExecution and elementData.Type ~= ElementTypes.Snippet then
		elementData.ReplicationInstance.Name = newName
	end
end

function findFirstElement(folderData, name)
	local elementList = getElementList(folderData)

	for _, elementData in elementList do
		if elementData.Name == name then
			return elementData
		end
	end
end

function getUniqueName(newName, nameList)
	local name = newName
	local repeats = 1
	
	while nameList[name] do
		repeats += 1
		name = newName .. "_" .. repeats
	end
	
	return name
end

function renameDuplicateNames(folderData)
	local elementDataList = getElementList(folderData)
	local names = {}
	local duplicateList = {}

	for _, elementData in elementDataList do
		local exists = names[elementData.Name]

		if not exists then
			names[elementData.Name] = true
		else
			local duplicates = duplicateList[elementData.Name] or {}
			table.insert(duplicates, elementData)

			duplicateList[elementData.Name] = duplicates
		end
	end
	
	for name, duplicates in duplicateList do
		for _, elementData in duplicates do
			--flawed, may rename something the same thing
			local uniqueName = getUniqueName(name, names)
			setElementName(elementData, uniqueName)
			
			names[uniqueName] = true
		end
	end
	
	for _, elementData in elementDataList do
		if elementData.Type == ElementTypes.Folder then
			renameDuplicateNames(elementData)
		end
	end
end

function addEmptyElement(elementPreset, elementType, name, parent)
	local element = elementPreset:Clone()
	element.BackgroundColor3 = Theme.NormalByt
	element.Parent = ElementListFrame

	local interactions = element.Interactions
	local mainButton = element.ElementMainButton

	local newElementData: ElementData = {
		Type = elementType,
		Name = name or elementType,
		Gui = element,
		Events = {},
		PartsRegistered = {},

		Parent = nil
	} :: ElementData

	local elementDataList = getElementList(parent)
	newElementData.Parent = parent

	element.ElementName.Text = newElementData.Name

	ElementDataListFromGui[element] = newElementData
	table.insert(elementDataList, newElementData)
	
	local mainButtonEvents = MouseField:RegisterButton(mainButton).Events
	
	mainButtonEvents.LeftDrag:Connect (function(x, y)
		if element.ConfirmInteractions.Visible then
			return
		end
		
		if not Dragging then
			onStartDragging(element, newElementData, x, y)
		else
			updateDraggingState(x, y)
		end
	end)
	
	mainButtonEvents.RightClick:Connect(function()
		if TextboxFocusedOn then
			TextboxFocusedOn:ReleaseFocus()
		end

		ElementRightClicked = newElementData
		elementAdvancedMenu:ShowAsync()
	end)
	
	MouseField:LeftClick(interactions.Delete, function()
		element.Warning.Text = "Delete \"" .. newElementData.Name .. "\"?"

		element.ConfirmInteractions.Visible = true
		element.Warning.Visible = true
		interactions.Visible = false
	end)
	
	MouseField:LeftClick(element.ConfirmInteractions.Cancel, function()
		element.ConfirmInteractions.Visible = false
		element.Warning.Visible = false
		interactions.Visible = true
	end)
	
	MouseField:LeftClick(element.ConfirmInteractions.Confirm, function()
		removeElement(newElementData)
	end)

	addPartsToElementData(newElementData, {
		mainButton,
		interactions.Delete,

		element.ConfirmInteractions.Cancel,
		element.ConfirmInteractions.Confirm
	})

	element.ElementName.Focused:Connect(function()
		TextboxFocusedOn = element.ElementName

		element.ElementNameBackground.BackgroundTransparency = 0
	end)

	element.ElementName.FocusLost:Connect(function()
		local newName = element.ElementName.Text
		
		element.ElementNameBackground.BackgroundTransparency = 1
		TextboxFocusedOn = nil
		
		if newName:len() == 0 or newName:match("^%s+$") then
			element.ElementName.Text = newElementData.Name
			
			warn("Element name can not be empty")
			
			return
		end
		
		if newName:match("%s+") then
			element.ElementName.Text = newElementData.Name

			warn("Element name can not contain whitespace")

			return
		end
		
		if CompiledPreferences.ForceUniqueNamesBE then
			local elementList = getElementList(newElementData.Parent)
			local nameList = {}
			
			for _, elementData in elementList do
				nameList[elementData.Name] = true
			end
			
			newName = getUniqueName(newName, nameList)
		end

		setElementName(newElementData, newName)
	end)

	element.MouseEnter:Connect(function()
		onHover(newElementData)
	end)

	element.MouseLeave:Connect(function()
		onUnhover(newElementData)
	end)

	createFeedbackForIcons(interactions.Export, "Neutral", "NormalIcon")
	createFeedbackForIcons(interactions.Delete, "Negative", "NormalIcon")

	createFeedbackForIcons(element.ConfirmInteractions.Cancel, "Negative", "NormalIcon")
	createFeedbackForIcons(element.ConfirmInteractions.Confirm, "Positive", "NormalIcon")

	Tooltips:newTooltip(interactions.Export, "Export")
	Tooltips:newTooltip(interactions.Delete, "Delete")

	if TextboxFocusedOn then
		TextboxFocusedOn:ReleaseFocus()
	end
	
	if parent ~= FolderBreadcrumbs.OpenedFolder then
		element.Parent = nil
	end

	TextboxFocusedOn = element.ElementName

	updateNoElementDisplayVisibility()
	updateScrollSize()

	StateUpdated = true

	return newElementData
end

-- abstraction
type ScriptElementArguments = {
	Name: string,
	Preset: Frame,
	ElementType: string,
	AllowReplication: boolean,
	EditorScript: Script,
	Parent: any,
}

function addScriptElement(args: ScriptElementArguments)
	local scriptElementData = addEmptyElement(args.Preset, args.ElementType, args.Name, args.Parent)
	local element = scriptElementData.Gui

	local editorScript = args.EditorScript
	editorScript.Name = scriptElementData.Name
	
	local ogParent = editorScript.Parent
	
	scriptElementData.Script = editorScript
	scriptElementData.RawSource = editorScript.Source

	if isReplicationEditable() and args.AllowReplication then
		local replicationInstance = Instance.new("Script")
		replicationInstance.Name = scriptElementData.Name

		local internalReplicationScript = Instance.new("ModuleScript")
		internalReplicationScript.Name = "InternalScript"
		internalReplicationScript.Parent = replicationInstance

		addReplicationInstance(scriptElementData, replicationInstance, args.Parent)
		updateReplicationOrdering()
		
		local replicationInstance = scriptElementData.ReplicationInstance
		replicationInstance.Source = scriptElementData.RawSource

		local loadedLua = loadScriptSource(scriptElementData.RawSource)
		loadedLua:ToScript(replicationInstance.InternalScript)
	end

	ScriptDataListFromScript[editorScript] = scriptElementData
	local interactions = element.Interactions
	
	MouseField:LeftDouble(element.ElementMainButton, function()
		openScript(editorScript)
	end)
	
	MouseField:LeftClick(interactions.Export, function()
		local firstSelected = Selection:Get()[1]
		local exportedScript = exportScriptElement(scriptElementData, returnDefaultParent(firstSelected))

		Selection:Set({exportedScript})
	end)
	
	editorScript:GetPropertyChangedSignal("Source"):Connect(function()
		if not IsRunning and not ScriptEditorService:FindScriptDocument(editorScript) then
			editScriptElementSource(scriptElementData, editorScript.Source)
		end
	end)

	addPartsToElementData(scriptElementData, {
		interactions.Export,
	})

	changeElementTheme(element, Theme)

	return scriptElementData
end

function addBytElement(bytName, parent)
	local bytEditorScript = Instance.new("Script")
	bytEditorScript.Parent = EditorScripts
	
	local bytData = addScriptElement({
		Name = bytName,
		Preset = Storage.Byt_Preset,
		ElementType = ElementTypes.BytScript,
		AllowReplication = true,
		EditorScript = bytEditorScript,
		Parent = parent,
	})
	
	giveScriptBytLib(bytEditorScript)
	
	local element = bytData.Gui
	local interactions = element.Interactions
	
	local executeEvents = MouseField:RegisterButton(interactions.Execute).Events
	
	executeEvents.LeftClick:Connect(function()
		local success, executable = getExecutableFromElement(bytData, true)

		if not success then
			return
		end

		bytData.Executable = executable

		PreviouslyInteractedByt.Executed = bytData
		PreviouslyInteractedByt.Both = bytData

		executable.OnStatusChange:Connect(function(newStatus)
			onExecutableStatusChange(newStatus, executable, bytData)
		end)

		editInteractionsVisible(element, BytElementStates.RunningNoControl)

		executable:Execute()
	end)
	
	executeEvents.RightClick:Connect(function()
		if isReplicationUsable() then
			executeAdvancedMenu:ShowAsync()
		end
	end)
	
	MouseField:LeftClick(interactions.Pause, function()
		local executable = bytData.Executable

		if not bytData.Executable then
			return
		end

		executable:Pause()
	end)
	
	MouseField:LeftClick(interactions.Terminate, function()
		local executable = bytData.Executable

		if not bytData.Executable then
			return
		end

		executable:Terminate()
	end)
	
	MouseField:LeftClick(interactions.Resume, function()
		local executable = bytData.Executable

		if not bytData.Executable then
			return
		end

		executable:Resume()
	end)

	element.MouseEnter:Connect(function()
		if not bytData.Executable then
			interactions.Status.Image = ExecutionStateIcons.Idle
			interactions.Status.ImageColor3 = Theme[ExecutionStatusColors[ExecutionStatuses.Idle]]
		end
	end)

	addPartsToElementData(bytData, {
		interactions.Execute,
		interactions.Pause,
		interactions.Terminate,
		interactions.Resume,
	})

	createFeedbackForIcons(interactions.Execute, "Positive", "NormalIcon")
	createFeedbackForIcons(interactions.Pause, "Neutral", "NormalIcon")
	createFeedbackForIcons(interactions.Resume, "Neutral", "NormalIcon")
	createFeedbackForIcons(interactions.Terminate, "Negative", "NormalIcon")

	Tooltips:newTooltip(interactions.Execute, "Execute Byt")
	Tooltips:newTooltip(interactions.Pause, "Pause Byt")
	Tooltips:newTooltip(interactions.Resume, "Resume Byt")
	Tooltips:newTooltip(interactions.Terminate, "Terminate Byt")
	
	return bytData
end

function addSnippetElement(snippetName, parent)
	local snippetEditorScript = Instance.new("Script")
	snippetEditorScript.Parent = EditorScripts

	local snippetData = addScriptElement({
		Name = snippetName,
		Preset = Storage.Snippet_Preset,
		ElementType = ElementTypes.Snippet,
		AllowReplication = false,
		EditorScript = snippetEditorScript,
		Parent = parent,
	})

	local element = snippetData.Gui
	local interactions = element.Interactions
	
	return snippetData
end

function addFolderElement(folderName, parent)
	local folderData = addEmptyElement(Storage.Folder_Preset, ElementTypes.Folder, folderName, parent)
	folderData.ElementList = {}
	
	local element = folderData.Gui
	local mainButton = element.ElementMainButton
	local interactions = element.Interactions

	if isReplicationEditable() then
		local replicationInstance = Instance.new("Folder")
		replicationInstance.Name = folderData.Name

		addReplicationInstance(folderData, replicationInstance, parent)
		updateReplicationOrdering()
	end

	MouseField:LeftClick(interactions.Export, function()
		local firstSelected = Selection:Get()[1]
		local parent, exportedElements = serializeElementListToInstance({folderData}, returnDefaultParent(firstSelected))

		Selection:Set(exportedElements)
	end)
	
	MouseField:LeftRelease(mainButton, function()
		tryDropIntoFolder(folderData)
	end)
	
	MouseField:LeftDouble(mainButton, function(holdX, holdY)
		openFolder(folderData)
	end)

	changeElementTheme(folderData.Gui, Theme)

	return folderData
end

function addLocalBytElement(editorScript, parent)
	local bytName = editorScript.Name

	local localBytData = addScriptElement({
		Name = bytName,
		Preset = Storage.LocalByt_Preset,
		ElementType = ElementTypes.LocalByt,
		AllowReplication = true,
		EditorScript = editorScript,
		Parent = parent,
	})

	local element = localBytData.Gui
	local interactions = element.Interactions
	
	MouseField:LeftClick(interactions.Execute, function()
		local success, executable = getExecutableFromElement(localBytData, true)

		if not success then
			return
		end

		localBytData.Executable = executable

		PreviouslyInteractedByt.Executed = localBytData
		PreviouslyInteractedByt.Both = localBytData

		executable.OnStatusChange:Connect(function(newStatus)
			onExecutableStatusChange(newStatus, executable, localBytData)
		end)

		editInteractionsVisible(element, BytElementStates.RunningNoControl)

		executable:Execute()
	end)
	
	MouseField:RightClick(interactions.Execute, function()
		if isReplicationUsable() then
			executeAdvancedMenu:ShowAsync()
		end
	end)

	
	MouseField:LeftClick(interactions.Pause, function()
		local executable = localBytData.Executable

		if not localBytData.Executable then
			return
		end

		executable:Pause()
	end)
	
	MouseField:LeftClick(interactions.Terminate, function()
		local executable = localBytData.Executable

		if not localBytData.Executable then
			return
		end

		executable:Terminate()
	end)
	
	MouseField:LeftClick(interactions.Resume, function()
		local executable = localBytData.Executable

		if not localBytData.Executable then
			return
		end

		executable:Resume()
	end)

	element.MouseEnter:Connect(function()
		if not localBytData.Executable then
			interactions.Status.Image = ExecutionStateIcons.Idle
			interactions.Status.ImageColor3 = Theme[ExecutionStatusColors[ExecutionStatuses.Idle]]
		end
	end)
	
	editorScript.AncestryChanged:Connect(function()
		if not editorScript.Parent then
			removeElement(localBytData)
		end
	end)
	
	editorScript:GetPropertyChangedSignal("Name"):Connect(function()
		local name = editorScript.Name
		
		if CompiledPreferences.ForceUniqueNamesBE then
			local elementList = getElementList(localBytData.Parent)
			local nameList = {}

			for _, elementData in elementList do
				nameList[elementData.Name] = true
			end
			
			name = getUniqueName(name, nameList)
		end
		
		setElementName(localBytData, name)
	end)

	addPartsToElementData(localBytData, {
		interactions.Execute,
	})

	createFeedbackForIcons(interactions.Execute, "Positive", "NormalIcon")
	createFeedbackForIcons(interactions.Pause, "Neutral", "NormalIcon")
	createFeedbackForIcons(interactions.Resume, "Neutral", "NormalIcon")
	createFeedbackForIcons(interactions.Terminate, "Negative", "NormalIcon")

	Tooltips:newTooltip(interactions.Execute, "Execute Byt")
	Tooltips:newTooltip(interactions.Pause, "Pause Byt")
	Tooltips:newTooltip(interactions.Resume, "Resume Byt")
	Tooltips:newTooltip(interactions.Terminate, "Terminate Byt")

	return localBytData
end

function removeElement(elementData, keepScript)
	local elementDataList = BytSourcesList

	if elementData.Parent then
		elementDataList = elementData.Parent.ElementList
	end

	local listPosition = table.find(elementDataList, elementData)

	if not listPosition then
		--warn("Failed to find child in parent")
		Console.Warn("Failed to find child in parent")

		return
	end

	if elementData.Type == ElementTypes.BytScript or elementData.Type == ElementTypes.Snippet then
		if DummyScripts[elementData.Script] then
			DummyScripts[elementData.Script]:Destroy()
			DummyScripts[elementData.Script] = nil
		end
		
		elementData.Script:Destroy()
	elseif elementData.Type == ElementTypes.Folder then
		local elementDataList = elementData.ElementList

		for _, childElementData in elementDataList do
			removeElement(childElementData)
		end
	end

	table.remove(elementDataList, listPosition)

	for _, part in elementData.PartsRegistered do
		MouseField:DeregisterButton(part)
	end

	elementData.Gui:Destroy()

	if CompiledPreferences.ServerClientExecution and elementData.Type ~= ElementTypes.Snippet then
		elementData.ReplicationInstance:Destroy()
	end

	updateNoElementDisplayVisibility()
	updateScrollSize()
	
	StateUpdated = true
end

function editScriptElementSource(scriptElementData, newSource)
	scriptElementData.RawSource = newSource
	StateUpdated = true
	
	if scriptElementData.Type == ElementTypes.Snippet then
		onSnippetUpdate(scriptElementData)
	end
	
	if CompiledPreferences.FastSavingBE or IsRunning then
		saveElementList()
	end

	if CompiledPreferences.ServerClientExecution and scriptElementData.Type ~= ElementTypes.Snippet then
		local replicationInstance = scriptElementData.ReplicationInstance
		--print(replicationInstance)
		replicationInstance.Source = newSource

		local loadedLua = loadScriptSource(newSource)
		loadedLua:ToScript(replicationInstance.InternalScript)
	end
end

local snippetPattern = "%-%-@[%w]+"
local snippetRawPattern = "%-%-@[%w/]+"

function getSnippetCall(line, rawCallString)
	local placeholders = string.split(rawCallString, "/")
	local rawCall = placeholders[1]
	local call = rawCall:match(snippetPattern)
	
	if call ~= rawCall then
		return
	end
	
	table.remove(placeholders, 1)
	
	return call, placeholders
end

function onSnippetUpdate(snippetData)
	local loadedLua = LuaTableModule.FromString(snippetData.RawSource)
	local autocomp = loadedLua.Code[1]
	
	if not autocomp:match(snippetPattern) or not autocomp:match("%w+") then
		return
	end

	local fillIn = loadedLua:ToString(2)
	
	local placeholders = string.split(autocomp, "/")
	local call = placeholders[1]
	
	table.remove(placeholders, 1)
	
	snippetAutocompleteData[snippetData.Script] = {
		Call = call,
		RawCall = autocomp,
		Placeholders = placeholders,
		FillIn = fillIn,
	}
end

function lineHasSnippet(line, call)
	local incompleteCall = line:match(snippetPattern)
	
	if incompleteCall then
		local hasSnippet = call:sub(1, incompleteCall:len()) == incompleteCall

		return hasSnippet
	end
	
	return false
end

function snippetAutocompleteCallback(request, response)
	local scriptDoc = request.textDocument.document :: ScriptDocument
	local linePosition = request.position.line
	local line: string = scriptDoc:GetLine(linePosition)
	
	--print(response)
	
	if snippetAutocompleteData[scriptDoc:GetScript()] then
		return response
	end
	
	local autocompleteItems = {}

	for _, snippetAutocomplete in snippetAutocompleteData do
		--local exists = line:match(snippetPattern) == snippetAutocomplete.Call
		local hasSnippet = lineHasSnippet(line, snippetAutocomplete.Call)

		if hasSnippet then
			table.insert(autocompleteItems, {Autocomplete = snippetAutocomplete, FillIn = snippetAutocomplete.FillIn})
		end
	end
	
	if #autocompleteItems == 0 then
		return response
	end
	
	table.sort(autocompleteItems, function(a, b)
		return a.Autocomplete.Call < b.Autocomplete.Call
	end)
	
	local placeholders = string.split(line, "/") --TODO: fix issue with bad placeholder detection
	table.remove(placeholders, 1)
	
	local replaceStart, replaceEnd = line:find("%-%-@[%w/ ]+")
	-- local replaceEnd = line:len()
	local defaultReplaceString = line:sub(replaceStart, replaceEnd)
	
	for i, autocompleteItem in autocompleteItems do
		local snippetAutocompleteData = autocompleteItem.Autocomplete
		local documentation = `<code>{snippetAutocompleteData.RawCall}</code>`
		
		for j, placeholder in placeholders do
			local placeholderVar = autocompleteItem.Autocomplete.Placeholders[j]

			if not placeholderVar then
				break
			end

			autocompleteItem.FillIn = string.gsub(autocompleteItem.FillIn, placeholderVar, placeholder)
		end
		
		local replaceString = defaultReplaceString
		
		if replaceEnd - replaceStart + 1 <= snippetAutocompleteData.Call:len() then
			replaceString = snippetAutocompleteData.Call
		end
		
		local responseData = {
			label = replaceString,
			preselect = true,

			kind = Enum.CompletionItemKind.Snippet,
			documentation = {value = documentation},

			textEdit = {
				newText = autocompleteItem.FillIn or "",
				replace = {
					start = {
						line = linePosition,
						character = replaceStart,
					},

					["end"] = {
						line = linePosition,
						character = replaceEnd + 1,
					}
				}
			},

			codeSample = autocompleteItem.FillIn,
		}

		table.insert(response.items, responseData)
	end

	return response
end

function onScriptDocumentOpen(scriptDocument)
	local scriptOpened = scriptDocument:GetScript()

	if not scriptOpened then
		return
	end

	if ScriptDataListFromScript[scriptOpened] then
		onOpenScriptElementDocument(scriptDocument)
	end

	local redirectScript = lookForInTable(DummyScripts, scriptOpened)

	if redirectScript and CompiledPreferences.ScriptErrorRedirectBE then
		scriptDocument:CloseAsync()
		openScript(redirectScript, scriptOpened:GetAttribute("Line"))
	end

	local primaryRedirectScript = scriptOpened:FindFirstChild("BytScriptRedirect")

	if primaryRedirectScript and primaryRedirectScript.Value then
		scriptDocument:CloseAsync()
		openScript(primaryRedirectScript.Value, primaryRedirectScript:GetAttribute("LineOccurred"))
	end
end

function onOpenScriptElementDocument(scriptDocument)
	local scriptOpened = scriptDocument:GetScript()
	local scriptElementData = ScriptDataListFromScript[scriptOpened]

	scriptDocument.SelectionChanged:Connect(function()
		if scriptDocument:GetText() == scriptElementData.RawSource then
			return
		end
		
		editScriptElementSource(scriptElementData, scriptDocument:GetText())
	end)
end

function openScript(scriptObject, lineNumber)
	local scriptElementData = ScriptDataListFromScript[scriptObject]

	if isReplicationUsable() then
		warn("Editing byt scripts during playtesting with S/C execution enabled is very experimental!")
		warn("Code may not update, replicate, or save correctly")

		--return
	end

	if scriptElementData then
		PreviouslyInteractedByt.Opened = scriptElementData
		PreviouslyInteractedByt.Both = scriptElementData
		
		scriptObject.Source = scriptElementData.RawSource
	end

	if CompiledPreferences.CustomScriptEditorBE then
		OdeWidget.Title = scriptObject.Name
		Util.ForceWidgetOpen(OdeWidget)

		odeScriptEditor.OutputScript = scriptObject
		odeScriptEditor:LoadStringAsync(scriptObject.Source, lineNumber)
	else
		if lineNumber then
			plugin:OpenScript(scriptObject, lineNumber)
		else
			ScriptEditorService:OpenScriptDocumentAsync(scriptObject)
			
			if scriptElementData.Type == ElementTypes.LocalByt then
				ScriptEditorService:OpenScriptDocumentAsync(scriptObject)
			end
		end
	end
end

--Contextual Exporting
function returnScriptType(parent)
	local isLocal = selfAndAncestorIs(parent, "GuiBase2D")
		or selfAndAncestorIs(parent, "PlayerGui")
		or selfAndAncestorIs(parent, "StarterPlayer")
	
	local useRunContextWhenExporting = CompiledPreferences.UseNewRunContextWhenExportingBE
	local returnScript
	
	if not CompiledPreferences.ContextualExportingBE then
		local scriptClasses = {
			Server = "Script",
			Client = "LocalScript",
			Module = "ModuleScript"
		}
		
		return Instance.new(scriptClasses[CompiledPreferences.AlwaysExportAsBE])
	end
	
	if isLocal then
		if useRunContextWhenExporting then
			returnScript = Instance.new("Script")
			returnScript.RunContext = Enum.RunContext.Client
		else
			returnScript = Instance.new("LocalScript")
		end
	elseif selfAndAncestorIs(parent, "LuaSourceContainer") then
		returnScript = Instance.new("ModuleScript")
	else
		returnScript = Instance.new("Script")
		
		if useRunContextWhenExporting then
			returnScript.RunContext = Enum.RunContext.Server
		end
	end
	
	return returnScript
end

function serializeElementList(elementDataList)
	local serializedElementList = {}

	for _, elementData in elementDataList do
		local serializedElementData = {
			elementData.Type,
			elementData.Name,
		}

		if elementData.Type == ElementTypes.BytScript or elementData.Type == ElementTypes.Snippet then
			table.insert(serializedElementData, elementData.RawSource)
		elseif elementData.Type == ElementTypes.Folder then
			local folderElementList = elementData.ElementList

			table.insert(serializedElementData, serializeElementList(folderElementList))
		else
			continue
		end

		table.insert(serializedElementList, serializedElementData)
	end

	return serializedElementList
end

function serializeElementListToInstance(elementDataList, parent)
	local serializedElements = {}

	for _, elementData in elementDataList do
		local serializedElementData

		if elementData.Type == ElementTypes.BytScript or elementData.Type == ElementTypes.Snippet then
			serializedElementData = returnScriptType(parent)
			serializedElementData.Name = elementData.Name
			serializedElementData.Source = elementData.RawSource
		elseif elementData.Type == ElementTypes.Folder then
			local folderElementList = elementData.ElementList

			serializedElementData = Instance.new("Folder")
			serializedElementData.Name = elementData.Name

			serializeElementListToInstance(folderElementList, serializedElementData)
		else
			continue
		end

		serializedElementData.Parent = returnDefaultParent(parent)
		serializedElementData:SetAttribute("BE2_TYPE", elementData.Type)
		table.insert(serializedElements, serializedElementData)
	end

	return parent, serializedElements
end

function exportScriptElement(scriptElementData, parent)
	local exportedBytScript = returnScriptType(parent)
	exportedBytScript.Name = scriptElementData.Name
	exportedBytScript.Source = scriptElementData.RawSource
	exportedBytScript.Parent = parent

	return exportedBytScript
end

function createBackup()
	local serializedElementListInstance, _ = serializeElementListToInstance(BytSourcesList, Instance.new("Folder"))
	serializedElementListInstance.Name = "Backup_" .. os.date()

	serializedElementListInstance:SetAttribute("TimeCreated", os.time())
	serializedElementListInstance:SetAttribute("Version", ExestackFile:GetAttribute("Version"))

	return serializedElementListInstance
end

--Makes sure we arent selecting both parent and descendant
function removeImportRedundanciesInHierarchy()
	local selected = {}
	local redundancies = {}

	for _, selectedInstance in Selection:Get() do
		for _, otherSelectedInstance in Selection:Get() do
			if selectedInstance:IsAncestorOf(otherSelectedInstance) then
				table.insert(redundancies, otherSelectedInstance)
			end
		end
	end

	Selection:Remove(redundancies)
end

function loadSerializedElementListInstance(serializedElementList, parent)
	for _, serializedElementInstance in serializedElementList do
		local elementType = serializedElementInstance:GetAttribute("BE2_TYPE")
		local elementData
		
		local name = string.gsub(serializedElementInstance.Name, " ", "_")

		if serializedElementInstance:IsA("LuaSourceContainer") then
			if elementType == ElementTypes.Snippet then
				elementData = addSnippetElement(name, parent)
			else
				elementData = addBytElement(name, parent)
			end

			if parent ~= FolderBreadcrumbs.OpenedFolder then
				elementData.Gui.Parent = nil
			end

			elementData.Script.Source = serializedElementInstance.Source
			editScriptElementSource(elementData, serializedElementInstance.Source)
		elseif serializedElementInstance:IsA("Folder") then
			local folderElementData = addFolderElement(name, parent)

			loadSerializedElementListInstance(serializedElementInstance:GetChildren(), folderElementData)
		end
	end
end

function loadSerializedElementList(serializedElementList, parent)
	local elementDataList = {}

	for _, serializedElementData in serializedElementList do
		local elementType = serializedElementData[1]
		local elementName = serializedElementData[2]
		local elementInternalData = serializedElementData[3]
		
		local elementData

		if elementType == ElementTypes.BytScript then
			elementData = addBytElement(elementName, parent)
			elementData.Script.Source = elementInternalData

			editScriptElementSource(elementData, elementInternalData)
		elseif elementType == ElementTypes.Folder then
			elementData = addFolderElement(elementName, parent)

			loadSerializedElementList(elementInternalData, elementData)
		elseif elementType == ElementTypes.Snippet then
			elementData = addSnippetElement(elementName, parent)
			elementData.Script.Source = elementInternalData

			editScriptElementSource(elementData, elementInternalData)
		else
			continue
		end

		if parent then
			elementData.Gui.Parent = nil
		end
	end

	return elementDataList
end

function loadBackup(serializedElementListInstance, parent)
	openFolder()
	removeAllElements()

	loadSerializedElementListInstance(serializedElementListInstance:GetChildren())
end

function removeAllElements(folderData)
	local elementList = table.clone(getElementList(folderData))
	
	for _, elementData in elementList do
		removeElement(elementData)
	end
end

function saveCurrentIndexPath()
	local indexPath = getIndexPathOfElement(FolderBreadcrumbs.OpenedFolder)
	plugin:SetSetting(SaveKeys.BytExecutorCurrentDirectory, indexPath)
end

function loadIndexPath(indexPath)
	local currentDirectory = nil
	
	for _, index in indexPath do
		local elementDataList = getElementList(currentDirectory)
		local folderData = elementDataList[index]
		
		if not folderData or folderData.Type ~= ElementTypes.Folder then
			Console.CriticalWarn("Failed to open index path")
			
			return
		end
		
		openFolder(folderData)
	end
	
	return true
end

function saveElementList()
	if isReplicationUsable() then
		return
	end

	local serializedElementList = serializeElementList(BytSourcesList)

	plugin:SetSetting(SaveKeys.BytExecutorList, serializedElementList)
	
	if CompiledPreferences.SaveCurrentDirectoryPositionBE and FolderBreadcrumbs.OpenedFolder and not IsRunning then
		saveCurrentIndexPath()
	end
end

function onPluginUnload()
	saveElementList()

	for _, tempFolder in TemporaryFolders do
		tempFolder:Destroy()
	end
	
	--ScriptEditorService:DeregisterAutocompleteCallback("SnippetAutocomplete")
end

function onServerClientExecutionChange(state)
	if state then
		initReplication()
		createReplicationInstances()
		updateReplicationOrdering()
	else
		removeReplication()
	end
end

function onLocalSyncAdded(localSyncFolder)
	for _, editorScript in localSyncFolder:GetChildren() do
		if localSyncFolder.Name == "BytLocalSync" and editorScript:IsA("LuaSourceContainer") and not ScriptDataListFromScript[editorScript] then
			addLocalBytElement(editorScript)
		end
	end

	localSyncFolder.ChildAdded:Connect(function(editorScript)
		if isInactive() then
			return
		end

		if localSyncFolder.Name == "BytLocalSync" and editorScript:IsA("LuaSourceContainer") and not ScriptDataListFromScript[editorScript] then
			addLocalBytElement(editorScript)
		end
	end)

	localSyncFolder.AncestryChanged:Connect(function()
		if localSyncFolder.Parent then
			return
		end

		if isInactive() then
			return
		end

		for _, localByt in localSyncFolder:GetChildren() do
			localByt.Parent = nil
		end
	end)
end

function onTooltipsEnabledBEChange(state)
	Tooltips.enabled = state
end

function onForceUniqueNamesBEChange(state)
	if not state then
		return
	end
	
	renameDuplicateNames()
end

-- temporary, move to Exestack Core later
function grabPlugin(parent)
	parent = parent or workspace

	local build = ExestackFile:Clone()
	build.Parent = parent

	return build
end

-- create return API for other apps
function returnAPI.CreateByt()
	local bytData = addBytElement(CompiledPreferences.DefaultBytName or "BytScript", FolderBreadcrumbs.OpenedFolder)

	if CompiledPreferences.AutomaticallyInsertBytLib then
		editScriptElementSource(bytData, "local bytLib = require(script.BytLib)\n\n")
	end

	if CompiledPreferences.OpenWhenCreateByt then
		openScript(bytData.Script)
	end

	if CompiledPreferences.AutoRenameElementBE then
		bytData.Gui.ElementName:CaptureFocus()
	end
end

--use as "TestingFolder/ErrorTest"
function returnAPI.FindElement(str)
	local directories = string.split(str, "/")
	local folderData = nil
	
	for _, directoryName in directories do
		local elementData = findFirstElement(folderData, directoryName)
		
		if not elementData then
			return
		end
		
		if elementData.Type == ElementTypes.Folder then
			folderData = elementData
		else
			return elementData
		end
	end
end

function returnAPI.ExecuteScript(scr, allowBytLib)
	local loadedScript = loadScript(scr)

	if allowBytLib then
		giveScriptBytLib(loadedScript)
	end

	local success, executable = convertScriptToExecutable(loadedScript)

	if not success then
		return
	end
	
	local currentThread = coroutine.running()
	
	executable.OnReturn:Connect(function(returnValue)
		coroutine.resume(currentThread, returnValue)
	end)
	
	executable.OnStatusChange:Connect(function(newStatus)
		if newStatus == ExecutionStatuses.Terminated then
			coroutine.resume(currentThread)
		elseif newStatus == ExecutionStatuses.Failed then
			coroutine.resume(currentThread)
		end
	end)

	executable:Execute()
	local returnValue = Util.YieldCurrentThread()
	
	return returnValue, executable
end

function returnAPI.AskForInput(text)
	local currentThread = coroutine.running()
	
	PromptBox.PlaceholderText = text or "Enter input..."
	PromptBox.Text = ""
	PromptContainer.Visible = true
	
	local focusLostConnection: RBXScriptConnection
	
	focusLostConnection = PromptBox.FocusLost:Connect(function(enterPressed: boolean)
		if not enterPressed then
			return
		end	
		
		local input = PromptBox.Text
		PromptContainer.Visible = false
		focusLostConnection:Disconnect()
		
		task.spawn(currentThread, input)
	end)
	
	local input = coroutine.yield()
	
	return input
end

local PreferenceChangeTable = {
	ServerClientExecution = onServerClientExecutionChange,
	TooltipsEnabledBE = onTooltipsEnabledBEChange,
	ForceUniqueNamesBE = onForceUniqueNamesBEChange
}

Preferences.OnChange:Connect(function(name, state)
	local fn = PreferenceChangeTable[name]

	if fn then
		fn(state)
	end
end)


ScriptEditorService.TextDocumentDidOpen:Connect(onScriptDocumentOpen)

FolderBreadcrumbs.PathChanged:Connect(function(oldFolderElementData, newFolderElementData)
	local oldElementList = BytSourcesList
	local newElementList = BytSourcesList

	if oldFolderElementData then
		oldElementList = oldFolderElementData.ElementList
	end

	if newFolderElementData then
		newElementList = newFolderElementData.ElementList
	end

	if oldElementList == newElementList then
		return
	end

	for _, oldElementData in oldElementList do
		oldElementData.Gui.Parent = nil
	end

	for _, elementData in newElementList do
		elementData.Gui.Parent = ElementListFrame
	end

	Searchbar.PlaceholderText = "Search for element"

	deselectAllElements()

	updateElementVisibility(newFolderElementData)
	updateScrollSize()

	DirectoryChanged = true
end)

FolderBreadcrumbs.LeftReleasedOnBreadcrumb:Connect(tryDropIntoFolder)

MouseField:RightClick(MoreElementListOptionsButton, function()
	advancedMenu:ShowAsync()
end)

ClickFieldFrame.MouseMoved:Connect(mouseMoved)

ClickFieldFrame.MouseButton1Down:Connect(startSelectionBox)

ClickFieldFrame.MouseButton1Up:Connect(function(x, y)
	if Dragging then
		onStopDragging(x, y)
	end

	if not HoldingControl then
		deselectAllElements()
	end

	if not Dragging then
		hideSelectionBox(x, y)
		reselectWithSelectionBox()
	end
end)

ExecutorBackground.MouseLeave:Connect(function()
	SelectionBox.Visible = false
end)

ClickFieldFrame.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		HoldingControl = true
	end
end)

ClickFieldFrame.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		HoldingControl = false
	end
end)

ClickFieldFrame.MouseLeave:Connect(function()
	HoldingControl = false
end)

NewBytScriptButton.MouseButton1Up:Connect(function()
	if CompiledPreferences.SwapBehaviorOfCreateElementIconBE then
		returnAPI.CreateByt()
		
		return
	end
	
	createAdvancedMenu:ShowAsync()
end)

MoreOptionsButton.MouseButton1Up:Connect(function()
	moreMenu:ShowAsync()
end)

NewBytScriptButton.MouseButton2Up:Connect(function()
	if CompiledPreferences.SwapBehaviorOfCreateElementIconBE then
		createAdvancedMenu:ShowAsync()
		
		return
	end
	
	returnAPI.CreateByt()
end)

Searchbar:GetPropertyChangedSignal("Text"):Connect(function()
	SearchWord = Searchbar.Text

	updateElementVisibility(FolderBreadcrumbs.OpenedFolder)
end)

Searchbar.Focused:Connect(function()
	Searchbar.Parent.UIStroke.Color = Theme.Neutral
end)

Searchbar.FocusLost:Connect(function()
	Searchbar.Parent.UIStroke.Color = Color3.fromRGB(0, 0, 0)
end)

PromptBox.Focused:Connect(function()
	PromptContainer.UIStroke.Color = Theme.Neutral
end)

PromptBox.FocusLost:Connect(function()
	PromptContainer.UIStroke.Color = Theme.HeavyBorder
end)

odeScriptEditor.OnEdit:Connect(function(newSource)
	local scriptElementData = ScriptDataListFromScript[odeScriptEditor.OutputScript]

	if scriptElementData then
		odeScriptEditor.OutputScript.Source = newSource
	end
end)

createBytAction.Triggered:Connect(function()
	returnAPI.CreateByt()
end)

createFolderAction.Triggered:Connect(function()
	local folderData = addFolderElement(CompiledPreferences.DefaultFolderName or "Folder", FolderBreadcrumbs.OpenedFolder)

	if CompiledPreferences.AutoRenameElementBE then
		folderData.Gui.ElementName:CaptureFocus()
	end
end)

createSnippetAction.Triggered:Connect(function()
	local snippetData = addSnippetElement(CompiledPreferences.DefaultSnippetName or "Snippet", FolderBreadcrumbs.OpenedFolder)

	if CompiledPreferences.AutoRenameElementBE then
		snippetData.Gui.ElementName:CaptureFocus()
	end
end)

advSave.Triggered:Connect(function()
	saveElementList()
end)

advCreateBackup.Triggered:Connect(function()
	local backup = createBackup()
	local backupContainer = lazyLoadTempFolder(ServerStorage, "BytBackups")
	
	backup.Parent = backupContainer
	Selection:Set({backup})
end)

advLoadBackup.Triggered:Connect(function()
	local backup = Selection:Get()[1]

	if backup and backup:GetAttribute("TimeCreated") and backup:GetAttribute("Version") then
		loadBackup(backup)
	end
end)

advLoadLastBackup.Triggered:Connect(function()
	local backupContainer = loadTempFolder(ServerStorage, "BytBackups")
	
	if not backupContainer then
		return
	end
	
	local backups = backupContainer:GetChildren()
	
	table.sort(backupContainer:GetChildren(), function(a, b)
		return a:GetAttribute("TimeCreated") > b:GetAttribute("TimeCreated")
	end)
	
	local lastBackup = backups[1]
	
	if lastBackup and lastBackup:GetAttribute("TimeCreated") and lastBackup:GetAttribute("Version") then
		loadBackup(lastBackup)
	end
end)

advExport.Triggered:Connect(function()
	local firstSelected = Selection:Get()[1]
	local parent, exportedElements = serializeElementListToInstance(ElementSelection, returnDefaultParent(firstSelected))
	
	Selection:Set(exportedElements)
end)

advImport.Triggered:Connect(function()
	removeImportRedundanciesInHierarchy()
	loadSerializedElementListInstance(Selection:Get(), FolderBreadcrumbs.OpenedFolder)
end)

addLocalBytAction.Triggered:Connect(function()
	local selectedScript = Selection:Get()[1]
	
	if selectedScript and selectedScript:IsA("LuaSourceContainer") then
		addLocalBytElement(selectedScript)
	end
end)

createLocalBytAction.Triggered:Connect(function()
	local bytLocalSync = ServerStorage:FindFirstChild("BytLocalSync")
	
	if not bytLocalSync then
		bytLocalSync = Instance.new("Folder")
		bytLocalSync.Name = "BytLocalSync"
	end
	
	task.defer(function()
		local newLocalBytScript = Instance.new("Script")
		newLocalBytScript.Name = "NewLocalByt"
		newLocalBytScript.Parent = bytLocalSync
		
		bytLocalSync.Parent = ServerStorage
	end)
end)


advExeServerByt.Triggered:Connect(function()
	if CompiledPreferences.ServerClientExecution then
		callExecuteInModel("Server", ElementLastHovered.ReplicationInstance.InternalScript)
	end
end)

advExeClientByt.Triggered:Connect(function()
	if CompiledPreferences.ServerClientExecution then
		callExecuteInModel("Client", ElementLastHovered.ReplicationInstance.InternalScript)
	end
end)


advElementRename.Triggered:Connect(function()
	ElementRightClicked.Gui.ElementName:CaptureFocus()
end)

advReload.Triggered:Connect(function()
	if CompiledPreferences.ServerClientExecution then
		initReplication()
		createReplicationInstances()
		updateReplicationOrdering()
	end
end)


OpenBytExecutor.Click:Connect(function()
	Util.ForceWidgetToggle(ExecutorWidget)
end)


moreSettings.Triggered:Connect(function()
	Util.ForceWidgetToggle(References.PreferencesWidget)
	Preferences:OpenCategory(BytExecutor2Category)
end)

moreHelp.Triggered:Connect(function()
	ScriptEditorService:OpenScriptDocumentAsync(Documents.BYTEXECUTOR_HELP)
end)

moreAbout.Triggered:Connect(function()
	ScriptEditorService:OpenScriptDocumentAsync(Documents.BYTEXECUTOR_ABOUT)
end)

buildExestack.Triggered:Connect(function()
	local build = grabPlugin(Selection:Get()[1])
	Selection:Set({build})
	
	Console.Print("Built Exestack")
end)


runDMScriptsAction.Triggered:Connect(function()
	for _, selectedScript in Selection:Get() do
		if selectedScript:IsA("LuaSourceContainer") then
			local loadedScript = loadScript(selectedScript)
			local success, executable = convertScriptToExecutable(loadedScript)

			executable:Execute()
		end
	end
end)

runSelectedScriptsAction.Triggered:Connect(function()
	for _, elementData in ElementSelection do
		if elementData.Type == ElementTypes.BytScript then
			local loadedScript

			if not isReplicationUsable() then
				loadedScript = loadScript(elementData.Script)
				giveScriptBytLib(loadedScript)
			else
				loadedScript = elementData.ReplicationInstance.InternalScript
			end

			local success, executable = convertScriptToExecutable(loadedScript)

			executable:Execute()
		end
	end
end)

runLastRanScriptsAction.Triggered:Connect(function()
	local previousByt = PreviouslyInteractedByt[CompiledPreferences.BytInteractDefinition]

	if not previousByt then
		return
	end

	local bytScript = previousByt.Script
	local loadedScript

	if not isReplicationUsable() then
		loadedScript = loadScript(previousByt.Script)
		giveScriptBytLib(loadedScript)
	else
		loadedScript = previousByt.ReplicationInstance.InternalScript
	end

	local success, executable = convertScriptToExecutable(loadedScript)

	if not success then
		return
	end

	executable:Execute()
end)

settings().Studio.ThemeChanged:Connect(function()
	changeTheme(tostring(settings().Studio.Theme))
end)

plugin.Unloading:Connect(function()
	onPluginUnload()
end)

ExecutorWidget.WindowFocusReleased:Connect(function()
	--deselectAllElements()
end)

ServerStorage.ChildAdded:Connect(function(localSyncFolder)
	if not localSyncFolder:IsA("Folder") then
		return
	end

	onLocalSyncAdded(localSyncFolder)
end)

if script:GetAttribute("ClearSaveData") then
	clearAllSaveData()
end

settings().Studio:GetPropertyChangedSignal("Script Editor Color Preset"):Connect(applyOdeTheme)

for _, propertyName in scriptEditorThemeProperties do
	settings().Studio:GetPropertyChangedSignal(propertyName):Connect(applyOdeTheme)
end

changeTheme(tostring(settings().Studio.Theme))

if isReplicationEditable() then
	initReplication()
elseif not IsRunning then
	removeReplication()
end

if not isReplicationUsable() then
	local serializedElementList = plugin:GetSetting(SaveKeys.BytExecutorList)
	if serializedElementList then
		loadSerializedElementList(serializedElementList)
		
		if CompiledPreferences.SaveCurrentDirectoryPositionBE then
			local indexPath = plugin:GetSetting(SaveKeys.BytExecutorCurrentDirectory) or {}
			
			loadIndexPath(indexPath)
		end
	end
else
	local bytReplicationFolder = loadTempFolder(ReplicatedStorage, "BytReplicationFolder")

	loadReplicatedElementList(bytReplicationFolder:GetChildren())
end

for _, localSyncFolder in ServerStorage:GetChildren() do
	if localSyncFolder:IsA("Folder") then
		onLocalSyncAdded(localSyncFolder)
	end
end

updateNoElementDisplayVisibility()
updateScrollSize()

createFeedbackForIcons(NewBytScriptButton, "Positive", "NormalIcon")
createFeedbackForIcons(MoreOptionsButton, "HoverIcon", "NormalIcon")

pcall(function()
	ScriptEditorService:DeregisterAutocompleteCallback("SnippetAutocomplete")
end)

ScriptEditorService:RegisterAutocompleteCallback("SnippetAutocomplete", 1, snippetAutocompleteCallback)

Util.DelayLoop(.5, function()
	if StateUpdated and not CompiledPreferences.FastSavingBE then
		saveElementList()

		StateUpdated = false
	end
end)

Util.DelayLoop(.25, function()
	if DirectoryChanged and CompiledPreferences.SaveCurrentDirectoryPositionBE and not IsRunning then
		saveCurrentIndexPath()
		
		DirectoryChanged = false
	end
end)

applyOdeTheme()

return returnAPI