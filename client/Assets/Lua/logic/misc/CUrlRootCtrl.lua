local CUrlRootCtrl = class("CUrlRootCtrl")

function CUrlRootCtrl.ctor(self)
	self:SpecityUrlReset()

	self.m_Pname = "common"
	self.m_AppVer = "1.0.0.0"

	-- 访问服务器类型（0：普通   1：审核   2：商务）
	self.m_ServerType = 0
end

function CUrlRootCtrl.SpecityUrlReset(self, csroot)
	csroot = csroot or "devh7d.demigame.com"

	self.m_CSRootUrl = "http://"..csroot.."/"
	self.m_CSRootUrlSecurity = "https://"..csroot.."/"
	self.m_CSRootUrlDomainName = csroot

	if string.find(csroot, "csh7d") then
		self.m_BSRootUrl = "http://bsh7d.demigame.com/"
		self.m_DemiPInfoUrl = "https://isdk.demigame.com/v1/sdkc/area/info.json?appId=%s&channel=%s&p=%s"
		self.m_DemiPayUrl = "https://sdk.demigame.com/v1/sdkc/pay/appstore/1001.json"
	else
		self.m_BSRootUrl = "http://devh7d.demigame.com/"
		self.m_DemiPInfoUrl = "https://devintegrationsdk.cilugame.com/v1/sdkc/area/info.json?appId=%s&channel=%s&p=%s"
		self.m_DemiPayUrl = "https://dev.sdk.cilugame.com/v1/sdkc/pay/appstore/1001.json"
	end
end

function CUrlRootCtrl.SetPName(self)
	local p = "common"
	if Utils.IsPC() then
		p = g_SdkCtrl:GetChannelId()
	else
		local subChannelId = g_SdkCtrl:GetSubChannelId()
		if subChannelId and subChannelId ~= "" then
			p = subChannelId
		end

		if Utils.IsIOS() then
			p = p .. "_ios"
		end

		local areaFlag = g_SdkCtrl:GetChannelAreaFlag()
		if areaFlag and areaFlag ~= "" then
			p = p .. "_" .. areaFlag
		end
	end
	self.m_Pname = p
	return p
end

-- Reset Url
function CUrlRootCtrl.ResetCSRootUrl(self)
	local csroot = g_GameDataCtrl:GetCSRoot()
	local p = self:SetPName()

	local function dothing(configInfo)
		csroot = configInfo.url

		if configInfo.serverIds then
			-- 这里和服务器协定：大于等于9002的都视为ios审核服
			local serverIds = string.split(configInfo.serverIds, ',')
			if serverIds then
				for _,serverId in ipairs(serverIds) do
					local id = string.match(serverId, "%w+_%a+(%d*)")
					if id >= 9002 then
						self.m_ServerType = 1
						break
					end
				end
			end
		end

		g_ResourceReplaceCtrl:SetReplaceRes(configInfo)

		if g_GameDataCtrl:GetChannel() == "demi" then
			g_DemiCtrl:SetDemiPaySwitchByConfigInfo(configInfo)
		end
	end

	if gameconfig.Issue.UseStaticUrl then
		local path = IOTools.GetPersistentDataPath("/staticconfig.txt")
		if IOTools.IsExist(path) then
			local dData = IOTools.LoadTextFile(path)
			local staticConfig = decodejson(tostring(dData))
			if staticConfig and staticConfig.centerServer then
				local domainType = g_GameDataCtrl:GetGameDomainType()
				local serverInfo = staticConfig.centerServer[domainType]

				if serverInfo then
					local fixver, framever, gamever, resver = C_api.Utils.GetAppVersion()
					resver = resver and "." .. resver or ""
					self.m_AppVer = string.format("%s.%s.%s", fixver, framever, gamever) .. resver
					local done = false
					for _,v in ipairs(serverInfo) do
						if v.name == p and v.ver == self.m_AppVer then
							dothing(v)
							done = true
							break
						end
					end
					if not done then
						-- 如果没找到则使用common的配置
						local p = "common"
						for _,v in ipairs(serverInfo) do
							if v.name == p then
								dothing(v)
								done = true
								break
							end
						end

						-- 如果还未找到则取第一个
						if not done then
							dothing(serverInfo[1])
						end
					end
				end
			end
		end
	end
	self:SpecityUrlReset(csroot)
end

function CUrlRootCtrl.GetBSRootUrl(self)
	return self.m_BSRootUrl
end

function CUrlRootCtrl.GetDemiPayUrl(self)
	return self.m_DemiPayUrl
end

return CUrlRootCtrl