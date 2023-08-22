local CHudNode = class("CHudNode", CObject, CGameObjContainer)

CHudNode.Sorting = {
	None 	   = 0,
	Alphabetic = 1,
	Horizontal = 2,
	Vertical   = 3,
	Custom     = 4,
}

CHudNode.HudOrder = {	-- 用于 HUD 的排序
					    -- 两个 HUD 数字相同表示不会同时显示
    -- 头（数字越小，位置越下）
	auto_find 	  = "40",
    autopatrol 	  = "40",
    chat 		  = "40",
    float_tip 	  = "40",
    treasure 	  = "40",
	
    warrior_passive = "30",
	fight 		  = "30",

	warrior_damage = "20",
	warrior_magicPoint = "20",
	team_leader   = "20",
    taskmark 	  = "20",
    blood 		  = "20",

	special_title = "10",
	npcspecialtitle = "10",

	title         = "1",

	-- 腰（数字越小，位置越上）
    touch 		  = "20",

	-- 脚（数字越小，位置越上）
	normal_title  = "01",
	npctitle      = "02",
	lv_school	= "00",
	name 		  = "04",
	npcName       = "05",
}

function CHudNode.ctor(self, mountHudInfo, cb)
	self.m_MountHudInfo = mountHudInfo
	self.m_IsLoading = true
	self.m_CacheActionList = {}
	self.m_LoadDoneCb = cb

	--LoadCloneAsync需要等待回调回来才能获取CHudNode的成员变量，故直接HudCtrl预加载一个clone避免等待
	if g_HudCtrl.m_CloneHudNode then
		local obj = g_HudCtrl.m_CloneHudNode.m_GameObject:Instantiate()
		self:OnCreateHudNode(obj)
	else
		local sPath = "UI/Hud/HudNode.prefab"
		g_ResCtrl:LoadCloneAsync(sPath, callback(self, "OnCreateHudNode"), true)
	end
end

function CHudNode.OnCreateHudNode(self, obj)
	self.m_IsLoading = false
	CObject.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)

	self.m_WaistSubHud = self:NewUI(1, CHud)	
	self.m_HeadSubHud = self:NewUI(2, CHud)
	self.m_FootSubHud = self:NewUI(3, CHud)
	self.m_WaistHudTable = self:NewUI(4, CTable)
	self.m_HeadHudTable = self:NewUI(5, CTable)
	self.m_FootHudTable = self:NewUI(6, CTable)

	self:InitHudNode(self.m_MountHudInfo)
	self.m_MountHudInfo = nil
	self:ExcuteAction()
	if self.m_LoadDoneCb then
		self.m_LoadDoneCb(self)
	end
end

--一个CHudNode下边有三个HudObj，根据CHudCtrl.g_TransList
function CHudNode.InitHudNode(self, mountHudInfo)
	self:SetParent(g_HudCtrl.m_UIHudLayer.m_Transform)

	for _,v in ipairs(CHudCtrl.g_TransList) do
		local subHud = self["m_"..v.."SubHud"]
		if Utils.IsEditor() then
			subHud:SetName(v .. "Hud")
		end
		subHud:SetAutoUpdate(true)
		--subHud对应如公户如佑_HudRoot/WaistHud，HeadHud，FootHud，公户如佑_HudRoot是个空的GameObject

		-- 每个模型对应一个 HudNode，三个挂载点各有一个 CTable
		local hudTable = self["m_"..v.."HudTable"]
		if Utils.IsEditor() then
			hudTable:SetName(v .. "HudTable")
		end
		--hudTable对应如公户如佑_HudRoot/WaistHud/WaistHudTable，HeadHud/HeadHudTable，FootHud/FootHudTable
	end

	self:ResetHudNode(mountHudInfo)
end

function CHudNode.ScaleHue(self, scale, ani, time)
	
	if ani then 
		local wh = DOTween.DOScale(self.m_WaistSubHud.m_Transform, scale, time)
		local hh = DOTween.DOScale(self.m_HeadSubHud.m_Transform, scale, time)
		local fh = DOTween.DOScale(self.m_FootSubHud.m_Transform, scale, time)
		DOTween.SetEase(wh, 2)
	    DOTween.SetEase(hh, 2) 
	    DOTween.SetEase(fh, 2)
	else
		self.m_WaistSubHud:SetLocalScale(scale)
		self.m_HeadSubHud:SetLocalScale(scale)
		self.m_FootSubHud:SetLocalScale(scale)
	end 

end

function CHudNode.ResetHudNode(self, mountHudInfo)
	if not mountHudInfo then
		return
	end
	local isWarrior = mountHudInfo.classtype.classname == "CWarrior"
	for _,v in ipairs(CHudCtrl.g_TransList) do	
		local subHudTrans = mountHudInfo["m_"..v.."Trans"]
		--subHudTrans对应角色model身上的一个Obj位置，head_node，waist_node，foot_node
		self["m_"..v.."SubHud"]:SetTarget(subHudTrans)
		--mountHudInfo:GetHudCamera()是主相机
		self["m_"..v.."SubHud"]:SetGameCamera(mountHudInfo:GetHudCamera())
	end
end

--延迟处理异步加载导致的函数调用无效
function CHudNode.AddCacheAction(self, funcName, ...)
	local dAction = {}
	dAction.name = funcName
	dAction.args = {...}

	table.insert(self.m_CacheActionList, dAction)
end

function CHudNode.ExcuteAction(self)
	for i,dAction in ipairs(self.m_CacheActionList) do
		local sFuncName = dAction.name
		self[sFuncName](self, unpack(dAction.args))
	end
end

function CHudNode.SetUsing(self, isUsing)
	if self.m_IsLoading then
		self:AddCacheAction("SetUsing", isUsing)
		return
	end
	for _,v in ipairs(CHudCtrl.g_TransList) do
		local subHud = self["m_"..v.."SubHud"]
		if subHud then
			subHud.m_HudHandler.enabled = isUsing
		end
	end
end

function CHudNode.SetPosHide(self, b)
	if self.m_IsLoading then
		self:AddCacheAction("SetPosHide", b)
		return
	end
	CObject.SetPosHide(self, b)
end

function CHudNode.SetName(self, sName)
	if self.m_IsLoading then
		self:AddCacheAction("SetName", sName)
		return
	end
	CObject.SetName(self, sName)
end

return CHudNode