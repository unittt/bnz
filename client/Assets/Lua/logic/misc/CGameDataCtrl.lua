
-- 读取本地Resources下文件配置

local CGameDataCtrl = class("CGameDataCtrl", CCtrlBase)

-- ctor
function CGameDataCtrl.ctor(self)
	self.m_GameData = nil
end

-- 初始化
function CGameDataCtrl.InitCtrl(self)
	local dData = Utils.GetResourcesData("Setting/GameSettingDataV2")
	self.m_GameData = decodejson(tostring(dData))
end

-- 是否扫码PC端
function CGameDataCtrl.IsQRPC(self)
	return self.m_GameData.qrpc
end

-- 获取渠道
function CGameDataCtrl.GetChannel(self)
	return self.m_GameData.channel
end

-- 获取游戏类型(dhxh, dhxx)
function CGameDataCtrl.GetGameType(self)
	return self.m_GameData.gameType
end

function CGameDataCtrl.GetGameDomainType(self)
	return self.m_GameData.domainType
end

-- 获取游戏名称
function CGameDataCtrl.GetGameName(self)
	local name = Utils.GetAppName()
	if name == "" then
		name = self.m_GameData.gamename
	end
	local names = string.split(name, "_")
	return names[1]
end

-- 获取httproot
function CGameDataCtrl.GetHttpRoot(self)
	return self.m_GameData.httproot
end

-- 获取csroot
function CGameDataCtrl.GetCSRoot(self)
	return self.m_GameData.csRoot
end

-- 获取resdir
function CGameDataCtrl.GetResdir(self)
	return self.m_GameData.resdir
end

-- 获取更新模式
function CGameDataCtrl.GetUpdateMode(self)
	return self.m_GameData.updateMode
end

return CGameDataCtrl