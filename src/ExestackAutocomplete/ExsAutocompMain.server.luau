local Modules = script.Parent.Modules
local Services = require(Modules.Services)

local ScriptEditorService = game:GetService("ScriptEditorService")

local consideredInstances = {
	game:GetService("ReplicatedStorage"),
	game:GetService("ServerStorage"),
	game:GetService("ServerScriptService")
}

type ModulePathData = {
	Name: string,
	FullName: string,
	Path: string,
	PathType: string?,
}

type AutocompleteRequest = {
	position: {
		line: number,
		character: number,
	},
	textDocument: {
		document: ScriptDocument?,
		script: LuaSourceContainer?,
	},
}

type AutocompleteItem = {
	label: string,
	kind: Enum.CompletionItemKind?,
	tags: { Enum.CompletionItemTag }?,
	detail: string?,
	documentation: {
		value: string,
	}?,
	overloads: number?,
	learnMoreLink: string?,
	codeSample: string?,
	preselect: boolean?,
	textEdit: {
		newText: string,
		replace: {
			start: { line: number, character: number },
			["end"]: { line: number, character: number },
		},
	}?,
}

type AutocompleteResponse = {
	items: {AutocompleteItem},
}

function mergeTable(source, destination)
	return table.move(source, 1, #source, #destination + 1, destination)
end

function mergeTableKeys(source, destination)
	for k, v in source do
		destination[k] = v
	end
	
	return destination
end

function getModuleFullNamesWithin(instance: Instance)
	local fullNames = {}
	
	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("ModuleScript") then
			--local instanceRoute = string.split(descendant:GetFullName(), ".")
			--instanceRoute[1] = "game:GetService(\"" .. instanceRoute[1] .. "\")"

			--local fullName = table.concat(instanceRoute, ".")
			local fullName = descendant:GetFullName()
			local modulePathData: ModulePathData = {
				Name = descendant.Name,
				FullName = fullName,
				Path = fullName,
				PathType = "Absolute"
			}
			
			--fullNames[descendant.Name] = fullName
			
			table.insert(fullNames, modulePathData)
		end
	end
	
	return fullNames
end

function getModuleFullNames(instances)
	local fullNames = {}
	
	for _, instance: Instance in instances do
		local instanceFullNames = getModuleFullNamesWithin(instance)
		--mergeTableKeys(instanceFullNames, fullNames)
		mergeTable(instanceFullNames, fullNames)
	end
	
	return fullNames
end

local fullNamesList = getModuleFullNames(consideredInstances)

function updateModuleFullNames(instances)
	for _, instance: Instance in instances do
		instance.DescendantAdded:Connect(function(descendant: Instance)
			if descendant:IsA("ModuleScript") or descendant:FindFirstChildWhichIsA("ModuleScript", true) then
				fullNamesList = getModuleFullNames(consideredInstances)
			end
		end)
		
		instance.DescendantRemoving:Connect(function(descendant: Instance)
			fullNamesList = getModuleFullNames(consideredInstances)
		end)
	end
end

updateModuleFullNames(consideredInstances)

function simplifyGappedArray(gappedArray)
	local gaps = table.create(table.maxn(gappedArray), false)
	
	for i, v in gappedArray do
		if not v then
			gaps[i] = true
		end
	end
	
	for i = #gaps, 1, -1 do
		local isGap = gaps[i]
		
		if isGap then
			table.remove(gappedArray, i)
		end
	end
end

function getMatches(str, fullNames)
	local fullNamesCopy = table.clone(fullNames)
	
	for i, modulePathData: ModulePathData in fullNamesCopy do
		local name = modulePathData.Name
		
		local matchLength = string.len(string.match(name, "^" .. str) or "")

		if matchLength == 0 then
			fullNamesCopy[i] = nil
		end
	end
	
	simplifyGappedArray(fullNamesCopy)

	return fullNamesCopy
end

function convertFullNameIntoPath(fullName: string)
	local instanceRoute = string.split(fullName, ".")
	instanceRoute[1] = "game:GetService(\"" .. instanceRoute[1] .. "\")"

	local path = table.concat(instanceRoute, ".")
	return path
end

function getIncompleteItem(line)
	local incompleteItem = ""
	
	for match in string.gmatch(line, "[_%a][_%w]*") do
		incompleteItem = match
	end
	
	return incompleteItem
end

local requireMatch = "local [_%a][_%w]* = require%(.+%)"
local serviceMatch = "local %w+ = game:GetService%(\"%w+\"%)"

-- find a place to put the new code (for services)
function getUsableServiceScriptLine(scriptDocument: ScriptDocument)
	local totalLines = scriptDocument:GetLineCount()
	local usableLine = 0

	local previousLine = ""

	for i = 1, totalLines do
		local line = scriptDocument:GetLine(i)

		if string.match(line, serviceMatch) == line then
			usableLine = i
		end

		previousLine = line
	end

	return usableLine + 1
end

-- find a place to put the new code
function getUsableScriptLine(scriptDocument: ScriptDocument)
	local totalLines = scriptDocument:GetLineCount()
	local usableLine = 0
	
	local previousLine = ""
	
	for i = 1, totalLines do
		local line = scriptDocument:GetLine(i)
		
		if string.match(line, requireMatch) == line or string.match(line, serviceMatch) == line then
			usableLine = i
		end
		
		previousLine = line
	end
	
	return usableLine + 1
end

-- check if the incomplete item is not indexing something else
function getLastChar(scriptDocument: ScriptDocument, linePosition, charPosition)
	if charPosition == 1 then
		linePosition -= 1
		
		if linePosition == 0 then
			return ""
		end
		
		charPosition = scriptDocument:GetLine(linePosition):len()
	else
		charPosition -= 1
	end
	
	local char = scriptDocument:GetText(linePosition, charPosition, linePosition, charPosition + 1)
	
	return char
end

-- check if the incomplete item is not indexing something else
function getLastNonWhitespaceChar(scriptDocument: ScriptDocument, linePosition, charPosition)
	if charPosition == 1 then
		linePosition -= 1

		if linePosition == 0 then
			return ""
		end

		charPosition = scriptDocument:GetLine(linePosition):len()
	else
		charPosition -= 1
	end
	
	local str = scriptDocument:GetText(1, 1, linePosition, charPosition + 1):reverse()
	
	local lastNonWhitespaceChar = str:match("%S")
	
	return lastNonWhitespaceChar
end

type AutocompleteItemDescription = {
	label: string,
	preselect: boolean,
	kind: Enum.CompletionItemKind,
	tags: {Enum.CompletionItemTag},
	documentation: string?,
	detail: string?,
	newText: string?,
	
	useCustomReplace: boolean?,
	
	startLine: number,
	startChar: number,
	endLine: number,
	endChar: number,
}

function generateAutocompleteItem(itemDescription: AutocompleteItemDescription)
	local item: AutocompleteItem = {
		label = itemDescription.label,
		preselect = itemDescription.preselect,

		kind = itemDescription.kind,
		tags = itemDescription.tags or {},

		documentation = {
			value = itemDescription.documentation or ""
		},

		detail = itemDescription.detail,

		textEdit = if itemDescription.useCustomReplace then {
			newText = itemDescription.newText or itemDescription.label,

			replace = {
				["start"] = { line = itemDescription.startLine, character = itemDescription.startChar },
				["end"] = { line = itemDescription.endLine, character = itemDescription.endChar }
			}
		} else nil
	}
	
	print(item)
	
	return item
end

local invalidCharacters = { ["."] = true, [":"] = true, ["\""] = true, ["'"] = true, ["`"] = true }
local requireString = "local %s = require(%s)"

function addModules(request: AutocompleteRequest, response: AutocompleteResponse)
	if request.textDocument.script and request.textDocument.script.Name ~= "TestScript" then
		return response
	end
	
	local textDocument: ScriptDocument? = request.textDocument.document

	if not textDocument then
		error("Did not find text document")
	end

	local currentLine = request.position.line
	local currentChar = request.position.character
	
	local lineString = textDocument:GetLine(currentLine)
	local incompleteItem = getIncompleteItem(lineString:sub(1, currentChar))
	
	local lastChar = getLastChar(textDocument, currentLine, currentChar)
	local lastNonWhitespaceChar = getLastNonWhitespaceChar(textDocument, currentLine, currentChar - incompleteItem:len())

	if invalidCharacters[lastChar] or invalidCharacters[lastNonWhitespaceChar] then
		return response
	end
	
	local matchedNames = getMatches(incompleteItem, fullNamesList)
	local usableLine = getUsableScriptLine(textDocument)
	
	local scriptToModify = textDocument:GetText(usableLine, 1, currentLine, currentChar)
	local newTextWithoutItem = scriptToModify:sub(1, -incompleteItem:len() - 1)
	
	local existingItems = {}
	
	for _, existingItem in response.items do
		existingItems[existingItem.label] = true
	end
	
	for _, modulePathData: ModulePathData in matchedNames do
		local name = modulePathData.Name
		local fullName = modulePathData.FullName

		local formattedRequireString = string.format(requireString, name, convertFullNameIntoPath(fullName))
		local newText = formattedRequireString .. "\n" .. newTextWithoutItem .. name
		
		if existingItems[name] then
			continue
		end
		
		local item: AutocompleteItem = {
			label = name,
			preselect = false,
			
			kind = Enum.CompletionItemKind.Module,
			tags = {},
			
			documentation = {
				value = fullName
			},
			
			detail = name,
			
			textEdit = {
				newText = newText,
				
				replace = {
					["start"] = { line = usableLine, character = 1 },
					["end"] = { line = currentLine, character = currentChar }
				}
			}
		}
		
		table.insert(response.items, item)
	end
	
	-- redo calculations for services
	local usableLine = getUsableServiceScriptLine(textDocument)

	local scriptToModify = textDocument:GetText(usableLine, 1, currentLine, currentChar)
	local newTextWithoutItem = scriptToModify:sub(1, -incompleteItem:len() - 1)
	
	for serviceName, serviceAccessor in Services.GetServiceAccessors() do
		local newText = serviceAccessor .. "\n" .. newTextWithoutItem .. serviceName
		
		if existingItems[serviceName] or not string.match(serviceName, "^" .. incompleteItem) then
			continue
		end

		local item: AutocompleteItem = {
			label = serviceName,
			preselect = false,
			
			kind = Enum.CompletionItemKind.Class,
			tags = {},
			
			documentation = {
				value = ""
			},
			
			detail = serviceName,

			textEdit = {
				newText = newText,

				replace = {
					["start"] = { line = usableLine, character = 1 },
					["end"] = { line = currentLine, character = currentChar }
				}
			}
		}

		table.insert(response.items, item)
	end
	
	return response
end

function init()
	pcall(function()
		ScriptEditorService:DeregisterAutocompleteCallback("ExestackAutocomplete")
	end)
	
	if game.Name == "ExestackDev.rbxl" then
		ScriptEditorService:RegisterAutocompleteCallback("ExestackAutocomplete", 5, addModules)
	end
end

init()