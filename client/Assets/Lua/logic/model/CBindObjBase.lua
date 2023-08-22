local CBindObjBase = class("CBindObjBase", CGameObjContainer)

function CBindObjBase.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_Footshadow = self:GetContainTransform(1) or self.m_Transform
	self.m_HeadTrans = self:GetContainTransform(2) or self.m_Transform
	self.m_WaistTrans = self:GetContainTransform(3) or self.m_Transform
	self.m_FootOrgTrans = self:GetContainTransform(4) or self.m_Transform
	self.m_FootTrans = self:GetContainTransform(5) or self.m_Transform
	if not (self.m_WaistTrans and self.m_HeadTrans and self.m_FootTrans) then
		print("使用 CBindObjBase,至少保证有3个挂载transform")
	end
	self.m_FootshadowObj = CObject.New(self.m_Footshadow.gameObject)
	--self.m_FootshadowObj:SetActive(false)
	self.m_FootTransObj = CObject.New(self.m_FootOrgTrans.gameObject)

	self.m_HudNode = g_HudCtrl:GetHudNodeFromPool(self)  -- self 就是继承 CBindObjBase 的类，如 CHero, CNpc 等
	self.m_Huds = {}   -- 每个模型一个表，管理他的所有 HUD
	self.m_Effects = {}
	self.m_BindData = {}
	self.m_CacheHudData = {}
	self.m_CacheCbList = {}
	self.m_HeartShow = nil

	self:AddInitHud("chat")
	self:AddInitHud("name")
	self:AddInitHud("warname")
	self:AddInitHud("blood")
	self:AddInitHud("float_tip")
end

--常用函数start
function CBindObjBase.SetBindData(self, data)
	self.m_BindData = data
end

--这里是初始化管理具体Hud的数据
function CBindObjBase.AddInitHud(self, sType, initFunc)
	self.m_Huds[sType] = {init_func = initFunc, obj=nil, loading=false, done_cb_list={}, valid=false, trans= nil}
end

function CBindObjBase.AddBindObj(self, sType, func)
	local dEffectInfo = self.m_BindData[sType]
	if not dEffectInfo then
		return
	end
	if dEffectInfo.type == "hud" then
		local trans = self:GetBindTable(dEffectInfo.body)
		local cls = _G[dEffectInfo.hud]
		self:AddHud(sType, cls, trans, func)
	elseif dEffectInfo.type == "effect" then
		local trans = self:GetBindTrans(dEffectInfo.body)
		self:AddEffect(dEffectInfo.path, dEffectInfo.cached, trans, dEffectInfo.offset, func, dEffectInfo.rotate)
	end
end

function CBindObjBase.AddBindObjInActorNode(self, sType, func, oActorNode)
	local dEffectInfo = self.m_BindData[sType]
	if not dEffectInfo then
		return
	end
	if dEffectInfo.type == "effect" then
		self:AddEffect(dEffectInfo.path, dEffectInfo.cached, oActorNode, dEffectInfo.offset, func, dEffectInfo.rotate)
	end
end

function CBindObjBase.DelBindObj(self, sType, bNoRepos)
	local dEffectInfo = self.m_BindData[sType]
	if dEffectInfo then
		if dEffectInfo.type == "hud" then
			self:DelHud(sType, bNoRepos)
		elseif dEffectInfo.type == "effect" then
			self:DelEffect(dEffectInfo.path, dEffectInfo.cached)
		end
	else
		self:DelHud(sType, bNoRepos)
	end
end

function CBindObjBase.ClearBindObjs(self)
	self:ClearEffect()
	self:ClearHud()
end

function CBindObjBase.SetHudRootName(self, name)
	if name and string.len(name) > 0 and string.find(name, "]") then
		name = string.split(name, ']')[2]
	end
	name = name or "默认名"
	self.m_HudNode:SetName(name .. "_HudRoot")  -- 每个模型对应一个 HudNode
end

function CBindObjBase.GetBindTrans(self, sType)
	if sType == "head" then
		return self.m_HeadTrans
	elseif sType == "waist" then
		return self.m_WaistTrans
	elseif sType == "foot" then
		return self.m_FootOrgTrans
	else
		return self.m_Transform
	end
end

function CBindObjBase.GetBindTable(self, sType)
	if sType == "head" then
		return self.m_HudNode.m_HeadHudTable
	elseif sType == "waist" then
		return self.m_HudNode.m_WaistHudTable
	elseif sType == "foot" then
		return self.m_HudNode.m_FootHudTable
	elseif sType == "waist_sub" then
		return self.m_HudNode.m_WaistSubHud
	elseif sType == "head_sub" then
		return self.m_HudNode.m_HeadSubHud
	elseif sType == "foot_sub" then
		return self.m_HudNode.m_FootSubHud
	else
		return self.m_HudNode
	end
end

function CBindObjBase.GetHudCamera(self)
	return g_CameraCtrl:GetMainCamera()
end

--常用函数end

--------------下边的函数是HudNode和某个具体Hud Obj的创建删除管理-----------------
function CBindObjBase.ClearHud(self)
	for sType, dHudInfo in pairs(self.m_Huds) do
		self:DelHud(sType, true)
	end
	self.m_Huds = {}
	g_HudCtrl:SetHudNode2Pool(self.m_HudNode)
	--self.m_HudNode = nil
end

function CBindObjBase.AddHud(self, sType, cls, mountTrans, donecb, bSaveCbInList)
	-- 屏幕外不加载，只保存数据
	if self.m_IsCacheHudData then
		self.m_CacheHudData[sType] = setmetatable({cls=cls,mountTrans=mountTrans,donecb=donecb,bSaveCbInList=bSaveCbInList}, {__mode="v"})
		if donecb then
			table.insert(self.m_CacheCbList, donecb)
		end
		return
	end

	if not self.m_Huds[sType] then
		self:AddInitHud(sType)
	end

	local oHud = self.m_Huds[sType].obj
	if oHud then
		if donecb then
			donecb(oHud)
			self:HandleHudLevel(oHud, sType)
		end
		local bValid = self.m_Huds[sType].valid
		if bValid then
			local trans = self.m_Huds[sType].trans
			if trans and trans.m_Transform then
				if trans.classname == "CTable" then
					trans:RepositionLater()
				end
			end
		end
	else
		if bSaveCbInList then
			table.insert(self.m_Huds[sType].done_cb_list, donecb)
		else
			self.m_Huds[sType].done_cb_list = {donecb}
		end
		self.m_Huds[sType].valid = true
		if not self.m_Huds[sType].loading then
			self.m_Huds[sType].loading = true
			self.m_Huds[sType].trans = mountTrans
			g_HudCtrl:AddHudByCls(cls, self:GetLoadDoneFunc(sType))
		end
	end
end

-- bNoRepos 不重排table，回收时候不需要重排
function CBindObjBase.DelHud(self, sType, bNoRepos)
    local dHudInfo = self.m_Huds[sType]
    local dCache = self.m_CacheHudData[sType]
    local bReposition = false
    if dCache then
    	self.m_CacheHudData[sType] = nil
    end
    if dHudInfo then
        if dHudInfo.obj then
            g_HudCtrl:SetUnused(dHudInfo.obj)
            bReposition = not bNoRepos
        end
        self:AddInitHud(sType)
    end
    if bReposition then
	    self.m_HudNode.m_HeadHudTable:RepositionLater()
    	self.m_HudNode.m_FootHudTable:RepositionLater()
    end
end

function CBindObjBase.TryHideAllHud(self, hide)

	for k, v in pairs(self.m_Huds) do 
		if v.obj then 
			v.obj:SetActive(not hide)
		end 
	end 

end 

function CBindObjBase.HideHudByType(self, type, hide)

	local hudInfo = self.m_Huds[type]
	if hudInfo then 
		if hudInfo.obj then 
			hudInfo.obj:SetActive(not hide)
		end 
	end 

end 

function CBindObjBase.GetHudObj(self, sType)
	local dHud = self.m_Huds[sType]
	return dHud and dHud.obj
end

function CBindObjBase.GetLoadDoneFunc(self, sType)
	return function(oHud)
		if Utils.IsExist(self) then 
			self:OnHudLoadDone(sType, oHud)
			self:HandleHudLevel(oHud, sType)
		else
			g_HudCtrl:SetUnused(oHud)
			self:AddInitHud(sType)
		end
	end
end

--hud和模型之间的层级处理,这里不同的类型，它们的z层级不一样，而且战斗时也会重新调整
-- 层次 负 ---> 正 表示从前到后
function CBindObjBase.HandleHudLevel(self, oHud, sType)
	
	local lp = oHud:GetLocalPos()
	lp.z = 0
	lp.x = 0
	lp.y = 0
	oHud:SetLocalPos(lp)

	local hudPos =  lp

	if not g_HudCtrl.isWaring then
		if  sType == "npcName"  then 
			hudPos.z = hudPos.z - 1000
		elseif sType == "float_tip" or sType == "chat" then 
			hudPos.z = hudPos.z - 1100
		elseif sType == "team_leader" then 
			hudPos.z = hudPos.z - 500
		else 
			hudPos.z = 0
		end
	else
		if sType == "warrior_teamCmd" then 
			hudPos.z = hudPos.z - 500
		elseif sType == "warrior_order" then 
			hudPos.z = hudPos.z - 700
			hudPos.y = hudPos.y + 60
		elseif sType == "warrior_tip" then
			hudPos.z = hudPos.z - 100
		elseif sType == "blood" then 
			hudPos.z = hudPos.z - 600
		elseif sType == "warrior_damage" then 
			hudPos.z = hudPos.z - 800
		elseif sType == "warrior_magicPoint" then
			hudPos.z = hudPos.z - 800
		elseif sType == "warrior_select" then 
			hudPos.z = hudPos.z - 500
		elseif sType == "npcName" then 
			hudPos.z = hudPos.z + 800
		elseif sType == "warrior_passive" then
			hudPos.z = hudPos.z - 900
		elseif sType == "float_tip" or sType == "chat" then 
			hudPos.z = hudPos.z - 1000
		elseif sType == "lv_school" then
			hudPos.z = hudPos.z - 500
			hudPos.y = hudPos.y + 20
		end
	end

	oHud:SetLocalPos(hudPos)	

end

function CBindObjBase.OnHudLoadDone(self, sType, oHud)
    -- 给 HUD GameObject 名字加上序号，用于 table 自动排序
    local hudOrder = CHudNode.HudOrder[sType]
    if hudOrder then
    	-- 不重复添加 hudOrder 到 name 头
        if hudOrder ~= string.sub(oHud.m_GameObject.name, 1, #hudOrder) then
            oHud.m_GameObject.name = hudOrder .. oHud.m_GameObject.name
        end
    end

	local bValid = self.m_Huds[sType].valid and self.m_Huds[sType].obj == nil
	if bValid then
		local trans = self.m_Huds[sType].trans
		if trans and trans.m_Transform then
			oHud:SetParent(trans.m_Transform)
			if trans.classname == "CTable" then
				trans:RepositionLater()
			end
		else
			bValid = false
			local s = string.format("%s, %s 挂载的节点已被释放", self:GetName(), sType)
			print(s)
		end
	end
	self.m_Huds[sType].loading = false
	if bValid then
		--local oCam = self:GetHudCamera()
		--oHud:SetGameCamera(oCam.m_Camera)
		-- oHud:SetOwner(self)
		if self.m_Huds[sType].init_func then
			self.m_Huds[sType].init_func(oHud)
		end
		for i, func in ipairs(self.m_Huds[sType].done_cb_list) do
			if func and func(oHud) == false then
				bValid = false
			end
		end
		self.m_Huds[sType].done_cb_list = {}
		self.m_Huds[sType].obj = oHud
	else
		g_HudCtrl:SetUnused(oHud)
--		self:AddInitHud(sType)
	end

	if self.m_HudDoneListener then 
		self.m_HudDoneListener(sType)
	end 

end

function CBindObjBase.ClearEffect(self)
	for sType, oEff in pairs(self.m_Effects) do
		oEff:Destroy()
	end
	self.m_Effects = {}
end

function CBindObjBase.AddEffect(self, path, bCached, trans, offset, cb, rotate)
	if self.m_Effects[path] then
		return
	end
	local function onEffLoad(oEffect)
		if cb then
			cb(oEffect)
		end
		oEffect:SetParent(trans)
		if offset then
			oEffect:SetLocalPos(offset)
		end
		if rotate then
			oEffect:SetLocalEulerAngles(rotate)
		end
	end
	local oEffect = CEffect.New(path, self:GetLayer(), bCached, onEffLoad)
	
	self.m_Effects[path] = oEffect
end

function CBindObjBase.DelEffect(self, path, bCached)
	local oEffect = self.m_Effects[path]
	if oEffect then
		oEffect:Destroy()
	end
	self.m_Effects[path] = nil
end

----------------下边的函数是要被调用的接口，设置某个具体的Hud-------------

-- 血条 HUD
function CBindObjBase.SetBlood(self, percent)
	self:AddHud("blood", CBloodHud, self.m_HudNode.m_HeadHudTable, function(oHud)
		oHud:SetHP(percent)
	end, false)
end

-- 名字 HUD
function CBindObjBase.SetNameHud(self, name, color, namecolorindex) -- self, name, style, outlineColor, blod
	local dColorData = data.namecolordata.DATA[namecolorindex]
	self:SetHudRootName(name)
	self:AddHud("name", CNameHud, self.m_HudNode.m_FootHudTable, function(oHud)
		oHud:SetName(name, color, dColorData)
		if self.m_HeartShow then
			oHud:ShowHeart(self.m_HeartShow.idx, self.m_HeartShow.show)
			self.m_HeartShow = nil
		end
		-- oHud.m_NameLabel:SetEffectStyle(dColorData.style)
		-- if dColorData.style and dColorData.style > 0 then
			-- oHud.m_NameLabel:SetEffectColor(Color.RGBAToColor(dColorData.style_color))
		-- end
	end, true)
end

-- 战斗内单位名字
function CBindObjBase.SetWarNameHud(self, name, style, outlineColor, blod)
	self:SetHudRootName(name)
	self:AddHud("warname", CWarNameHud, self.m_HudNode.m_FootHudTable, function(oHud)
		oHud:SetName(name, blod)
		-- oHud.m_NameLabel:SetEffectStyle(style)
		-- if style and style > 0 then
		-- 	outlineColor = outlineColor or Color.white
			-- oHud.m_NameLabel:SetEffectColor(outlineColor)
		-- end
	end, false)
end

--订婚后的心形图标
function CBindObjBase.SetNameHeart(self, idx, bShow)
	-- self:AddHud("name", CNameHud, self.m_HudNode.m_FootHudTable, function(oHud)
	-- 	oHud:ShowHeart(idx, bShow)
	-- end, true)
	local oNameHud = self:GetHudObj("name")
	if oNameHud then
		oNameHud:ShowHeart(idx, bShow)
	else
		self.m_HeartShow = {idx = idx, show = bShow}
	end
end

--头衔 title
function CBindObjBase.SetTitleHud(self, badgeId)

	if not badgeId or badgeId == 0 then 
		return
	end 

	local info = data.touxiandata.DATA[badgeId]

	if not info then 
		return
	end 

	if not info.icon or info.icon == "" then 
		return
	end

	self:AddHud("title", CTitleHud, self.m_HudNode.m_HeadHudTable, function(oHud)

		oHud:SetTitleIcon(badgeId)

	end, false)

end

-- npc名字 HUD
function CBindObjBase.SetNpcNameHud(self, name, color, namecolorindex)--self, name, style, outlineColor, blod
	local dData = data.namecolordata.DATA[namecolorindex]
	self:SetHudRootName(name)
	self:AddHud("npcName", CNpcNameHud, self.m_HudNode.m_FootHudTable, function(oHud)
		oHud:SetName(name, color, dData)
		-- oHud.m_NameLabel:SetEffectStyle(dData.style)
		-- if dData.style and dData.style > 0 then
		-- 	oHud.m_NameLabel:SetEffectColor(Color.RGBAToColor(dData.style_color))
		-- end
	end, false)
end

-- 聊天 HUD(文字内容)
-- 2、 战斗中喊话(文字内容)
function CBindObjBase.ChatMsg(self, oMsg, time)
	self:AddHud("chat", CChatHud, self.m_HudNode.m_HeadHudTable, function(oHud)
		oHud:AddMsg(oMsg, time)
	end, true)
end

-- tip HUD
function CBindObjBase.AddFloatTip(self, sText)
	self:AddHud("float_tip", CFloatTipHud, self.m_HudNode.m_HeadHudTable, function(oHud)
		oHud:AddTipText(sText)
	end, true)
end

-- 战斗中Boss喊话
function CBindObjBase.BossShotMsg(self, icon, msg, time)
	self:AddHud("chat", CBossShotHud, self.m_HudNode.m_WaistHudTable, function(oHud)
		oHud:AddMsg(icon, msg, time)
	end, true)
end

function CBindObjBase.ShowHudSwitch(self, sType, bShow)
	local oHud = self.m_Huds[sType].obj
	if oHud then
		oHud:SetActive(bShow)
		local bValid = self.m_Huds[sType].valid
		if bValid then
			local trans = self.m_Huds[sType].trans
			if trans and trans.m_Transform then
				if trans.classname == "CTable" then
					trans:RepositionLater()
				end
			end
		end
	end
end

-- 没用时隐藏，关闭ui follow target
function CBindObjBase.SetUsing(self, isUsing)
	self.m_IsUsing = isUsing
	self.m_HudNode:SetPosHide(not isUsing)
	self.m_HudNode:SetUsing(isUsing)
	if not isUsing then
		self.m_CacheHudData = {}
		self.m_CacheCbList = {}
		self.m_HeartShow = nil
	end
end

function CBindObjBase.CheckCacheHuds(self)
	if next(self.m_CacheHudData) then
		for sType, dCache in pairs(self.m_CacheHudData) do
			if not Utils.IsNil(dCache.mountTrans) then
				self:AddHud(sType, dCache.cls, dCache.mountTrans, dCache.donecb, dCache.bSaveCbInList)
			end
		end
		self.m_CacheHudData = {}
		self.m_CacheCbList = {}
	end
end

return CBindObjBase