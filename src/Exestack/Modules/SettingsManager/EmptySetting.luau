local FreeStringSetting = {}
FreeStringSetting.__index = FreeStringSetting

function update(self, state)
	
end

function FreeStringSetting:Set(state)
	self.State = state

	update(self, state)
end

function FreeStringSetting:ChangeTheme(theme)
	
end

function FreeStringSetting.create(self, genericSetting)
	setmetatable(self, FreeStringSetting)
	
	return self
end

return FreeStringSetting
