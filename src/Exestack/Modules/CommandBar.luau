--!strict

-- Functions to interface with command bar.

local ScriptEditorService = game:GetService("ScriptEditorService")

local CommandBar = {}

function CommandBar.getScriptDocument(): ScriptDocument?
	for _, doc: ScriptDocument in ScriptEditorService:GetScriptDocuments() do
		if doc:IsCommandBar() then
			return doc
		end
	end
	return nil
end

-- @return -- Source if possible.
-- @return -- Error message if no source.
function CommandBar.getSource(): (string?, string?)
	local doc = CommandBar.getScriptDocument()
	if not doc then
		return nil, "Command bar not found."
	end
	return doc:GetText(), nil
end

return CommandBar