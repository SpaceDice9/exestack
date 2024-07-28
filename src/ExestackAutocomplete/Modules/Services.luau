local Services = {}

local nontrivialServices = {
	"AvatarEditorService", -- avatar editor service
	"AvatarCreationService",
	"CaptureService", -- manages screenshot stuff
	"ExperienceNotificationService", -- manages notifications for 13+ users
	"GroupService",
	"IncrementalPatchBuilder", -- ???
	
	"MessagingService",
	"MemoryStoreService",
	"NetworkServer",
	"NetworkClient",
	"OpenCloudService",
	"PlayerViewService",
	
	"ScriptEditorService",
	"SocialService",
	"ScriptProfilerService",
	
	"UserService",
	
	"VoiceChatService",
}

function Services.GetServices()
	local services = {}
	
	for _, service in game:GetChildren() do
		table.insert(services, service.ClassName)
	end
	
	return services
end

function Services.GetServiceAccessors()
	local serviceAccessors = {}

	for _, service in game:GetChildren() do
		local serviceName = service.ClassName
		
		serviceAccessors[serviceName] = `local {serviceName} = game:GetService("{serviceName}")`
	end
	
	for _, serviceName in nontrivialServices do
		if not serviceAccessors[serviceName] then
			serviceAccessors[serviceName] = `local {serviceName} = game:GetService("{serviceName}")`
		end
	end

	return serviceAccessors
end

return Services
