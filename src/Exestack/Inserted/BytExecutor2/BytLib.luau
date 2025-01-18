local API = {
	_Apps = nil,
}

local function literalize(str)
	return string.gsub(str, "\"", "\\\"")
end

local function isValidKey(key: string)
	return string.match(key, "^[%a_][%w_]*$") == key
end

local function isValidArrayGapless(array)
	local largest = 0

	for i, _ in array do
		if typeof(i) ~= "number" or i > largest + 1 then
			return false
		end

		largest = i
	end

	return true
end

function tokenize(data, tabs)
	tabs = tabs or 0
	local tokenizedData

	if typeof(data) == "string" then
		tokenizedData = "\"" .. literalize(data) .. "\""
	elseif typeof(data) == "boolean" or typeof(data) == "number" or typeof(data) == "EnumItem" then -- NOTE: unravel when necessary
		tokenizedData = tostring(data)
	elseif typeof(data) == "table" then
		tokenizedData = exportTable(data, tabs + 1)
	elseif typeof(data) == "Vector3" then
		tokenizedData = "Vector3.new(" .. data.X .. ", " .. data.Y .. ", " .. data.Z .. ")"
	elseif typeof(data) == "Vector2" then
		tokenizedData = "Vector2.new(" .. data.X .. ", " .. data.Y .. ")"
	elseif typeof(data) == "Color3" then
		tokenizedData = "Color3.fromRGB(" .. math.round(data.R*255) .. ", " .. math.round(data.G*255) .. ", " .. math.round(data.B*255) .. ")"
	elseif typeof(data) == "BrickColor" then
		tokenizedData = "BrickColor.new(\"" .. data.Name .. "\")"
	elseif typeof(data) == "CFrame" then
		tokenizedData = "CFrame.new(" .. tostring(data) .. ")"
	elseif typeof(data) == "UDim2" then
		tokenizedData = "UDim2.new(" .. data.X.Scale .. ", " .. data.X.Offset .. ", " .. data.Y.Scale .. ", " .. data.Y.Offset .. ")"
	elseif typeof(data) == "UDim" then
		tokenizedData = "UDim.new(" .. data.Scale .. ", " .. data.Offset .. ")"
	elseif typeof(data) == "NumberSequence" then
		tokenizedData = "NumberSequence.new(" .. exportTable(data.Keypoints, tabs + 1) .. ")"
	elseif typeof(data) == "NumberSequenceKeypoint" then
		tokenizedData = "NumberSequenceKeypoint.new(" .. data.Time .. ", " .. data.Value .. ", " .. data.Envelope .. ")"
	elseif typeof(data) == "NumberRange" then
		tokenizedData = "NumberRange.new(" .. data.Min .. ", " .. data.Max .. ")"
	elseif typeof(data) == "ColorSequence" then
		tokenizedData = "ColorSequence.new(" .. exportTable(data.Keypoints, tabs + 1) .. ")"
	elseif typeof(data) == "ColorSequenceKeypoint" then
		tokenizedData = "ColorSequenceKeypoint.new(" .. data.Time .. ", " .. tokenize(data.Value) .. ")"
	else
		error("Could not export malformed data", 4)
	end

	return tokenizedData
end

function exportTable(data, tabs)
	tabs = tabs or 0

	local str = "{\n"
	local indentation = string.rep("\9", tabs)

	local isGaplessArray = isValidArrayGapless(data)

	for key, value in data do
		local tokenizedValue = tokenize(value)

		if isGaplessArray then
			str ..= indentation .. "\9" .. tokenizedValue .. ",\n"
		elseif typeof(key) == "string" and isValidKey(key) then
			str ..= indentation .. "\9" .. key .. " = " .. tokenizedValue .. ",\n"
		else
			local tokenizedKey = tokenize(key)

			str ..= indentation .. "\9[" .. tokenizedKey .. "] = " .. tokenizedValue .. ",\n"
		end
	end

	str ..= indentation .. "}"

	return str
end

function API.ExportToModule(t: {[any]: any}, name: string?): ModuleScript
	local folderName = "LTMJSON_Folder"

	local module = Instance.new("ModuleScript")
	module.Name = name or "ModuleScript"
	module.Source = "return " .. exportTable(t)

	local moduleFolder = game:GetService("ServerStorage"):FindFirstChild(folderName)

	if not moduleFolder then
		moduleFolder = Instance.new("Folder")
		moduleFolder.Name = folderName
		moduleFolder.Parent = game:GetService("ServerStorage")
	end

	module.Parent = moduleFolder

	return module
end

function API.Require(module: ModuleScript | string): any
	if typeof(module) == "Instance" and module:IsA("ModuleScript") then
		local freshModule = module:Clone()

		return require(freshModule)
	elseif typeof(module) == "string" then
		local bytData = API._Apps.BytExecutor2.FindElement(module)
		
		if bytData.Type ~= "BytScript" then
			warn("Could not require Byt")
			
			return
		end
		
		local returnValue = API._Apps.BytExecutor2.ExecuteScript(bytData.Script, false)
		
		return returnValue
	else
		error("module argument given was not a ModuleScript or string")
	end
end

function API.Perf(amount: number, funcList: {() -> ()})
	local funcTimesList = {}
	
	local success = pcall(function()
		for key, func in funcList do
			local times = {}

			for i = 1, amount do
				local timeStart = os.clock()
				func()
				local timeEnd = os.clock()

				table.insert(times, timeEnd - timeStart)
			end

			funcTimesList[key] = times
		end
	end)
	
	if success then
		API._Apps.PerformanceProfiler.graph(funcTimesList)
	else
		warn("Failed to benchmark provided functions")
	end
end

function API.PerfSlow(amount: number, funcList: {() -> ()})
	local funcTimesList = {}
	
	if amount > 100 then
		warn("Amount can not be greater than 100")
		
		amount = 100
	end

	local success = pcall(function()
		for key, func in funcList do
			local times = {}

			for i = 1, amount do
				print((i - 1) .. "/" .. amount)
				task.wait()
				
				local timeStart = os.clock()
				func()
				local timeEnd = os.clock()

				table.insert(times, timeEnd - timeStart)
			end

			funcTimesList[key] = times
		end
	end)

	if success then
		API._Apps.PerformanceProfiler.graph(funcTimesList)
	else
		warn("Failed to benchmark provided functions")
	end
end

function API.Input(prompt: string)
	local input = API._Apps.BytExecutor2.AskForInput(prompt)
	return input
end

return API
