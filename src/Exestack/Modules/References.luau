type References = {
	ExestackToolbar: PluginToolbar,
	PreferencesWidget: DockWidgetPluginGuiInfo,
	Preferences: any,
	
	PluginSaveKeys:  {
		Preferences: "Preferences",
		ExestackMetadata: "ExestackMetadata",

		BytExecutorList: "BytExecutorList",
		BytExecutorCurrentDirectory: "BytExecutorCD",
	}
}

local References = {} :: References

References.PluginSaveKeys = {
	Preferences = "Preferences",
	ExestackMetadata = "ExestackMetadata",
	
	BytExecutorList = "BytExecutorList",
	BytExecutorCurrentDirectory = "BytExecutorCD",
}

return References
