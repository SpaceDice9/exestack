--disable
function onCall(internalScript)
	local success, routine = pcall(require, internalScript)
	
	if not success then
		warn("failed")
		
		return
	end
	
	local executionSuccess, msg = pcall(task.defer, routine)
	
	if not executionSuccess then
		warn(msg)
	end
end

function yield()
	coroutine.yield(coroutine.running())
end

if not game:GetService("RunService"):IsStudio() then
	yield()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BytEventFolder = ReplicatedStorage:FindFirstChild("BytEventFolder")

if not BytEventFolder then
	yield()
end

local InternalEvent = BytEventFolder:FindFirstChild("InternalEvent")
local ExternalEvent = BytEventFolder:FindFirstChild("ExternalEvent")

if not InternalEvent or not ExternalEvent then
	yield()
end

ExternalEvent.OnServerEvent:Connect(function(player, internalScript)
	onCall(internalScript)
end)

InternalEvent.Event:Connect(function(internalScript)
	onCall(internalScript)
end)