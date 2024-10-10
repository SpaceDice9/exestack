local LogService = game:GetService("LogService")

local MicroTerminal = {}
local commands = {}

type Token = {
	token: string,
	flags: {string},
}
type Tokens = {Token}


function splitCommand(command)
	local currentToken = ""
	local rawTokens = {}
	local charList = string.split(command, "")

	local isInString = false
	local escaping = false

	for _, char in charList do
		if char == "\\" then
			escaping = true

			continue
		elseif char == "\"" and not escaping then
			isInString = not isInString

			if not isInString then
				table.insert(rawTokens, currentToken)
				currentToken = ""
			end
		elseif char == " " and not isInString then
			if currentToken ~= "" then
				table.insert(rawTokens, currentToken)
				currentToken = ""
			end
		else
			currentToken ..= char
		end

		escaping = false
	end

	if currentToken ~= "" then
		table.insert(rawTokens, currentToken)
	end

	return rawTokens
end

function cacheFlags(flagsList)
	local flagCache = {}
	
	for _, flag in flagsList do
		flagCache[flag] = true
	end
	
	return flagCache
end

function lexCommand(command)
	local rawTokens = splitCommand(command)
	local removeArgumentCache = {}

	--Removes reduntant space
	for order, argument in rawTokens do
		if argument == "" then
			table.insert(removeArgumentCache, order)
		else
			string.lower(argument)
		end
	end

	for i = #removeArgumentCache, 1, -1 do
		local order = removeArgumentCache[i]

		table.remove(rawTokens, order)
	end

	table.clear(removeArgumentCache)

	--Separate flags
	local flags = {}
	local totalFlags = 0

	for order, argument in rawTokens do
		if argument:match("%-%a+") then
			table.insert(removeArgumentCache, order)

			local argFlagList = flags[order - 1 - totalFlags] or {}
			flags[order - 1 - totalFlags] = argFlagList

			table.insert(argFlagList, argument)

			totalFlags = totalFlags + 1
		end
	end

	for i = #removeArgumentCache, 1, -1 do
		local order = removeArgumentCache[i]

		table.remove(rawTokens, order)
	end

	local tokens = table.create(#rawTokens)

	for i, token in rawTokens do
		local tokenData = {
			token = token,
			flags = cacheFlags(flags[i] or {}),
		}

		tokens[i] = tokenData
	end

	return tokens
end

function MicroTerminal.RegisterCommand(commandName: string, commandFunc: (Tokens) -> ())
	commands[commandName] = commandFunc
end

function MicroTerminal.CallCommand(command: string)
	print(`> --{command}`)
end

function MicroTerminal.ProcessCommand(command: string)
	local tokens = lexCommand(command)

	if not tokens[1] or not tokens[1].token then
		return
	end

	local commandFunc = commands[tokens[1].token]

	if commandFunc then
		commandFunc(tokens)
	else
	end
end

function MicroTerminal.HasFlags(flagCache, ...)
	local flags = {...}
	
	for _, flag in flags do
		if flagCache[flag] then
			return true
		end
	end
	
	return false
end

function MicroTerminal.InitOutputHook()
	LogService.MessageOut:Connect(function(message: string, messageType: Enum.MessageType)
		if messageType ~= Enum.MessageType.MessageOutput then
			return
		end

		local prefix = string.sub(message, 1, 4)

		if prefix ~= "> --" then
			return
		end

		local decommentedMessage = string.sub(message, 5)
		MicroTerminal.ProcessCommand(decommentedMessage)
	end)
end

return MicroTerminal
