local LogService = game:GetService("LogService")

local Console = {
	Enabled = false,
	ReportNoncritical = false
}

function Console.GetRecentErrors(amount)
	local logHistory = LogService:GetLogHistory()
	local recentErrors = {}
	local errorsLogged = 0

	for i = #logHistory, 1, -1 do
		local logData = logHistory[i]

		if logData.messageType == Enum.MessageType.MessageError then
			table.insert(recentErrors, logData)
			
			errorsLogged += 1
		end
		
		if errorsLogged >= amount then
			return recentErrors
		end
	end
	
	return recentErrors
end

function Console.Print(...)
	if not Console.Enabled or not Console.ReportNoncritical then
		return
	end
	
	print(...)
end

function Console.Warn(...)
	if not Console.Enabled or not Console.ReportNoncritical then
		return
	end

	warn(...)
end

function Console.CriticalWarn(...)
	if not Console.Enabled then
		return
	end

	warn(...)
end

return Console
