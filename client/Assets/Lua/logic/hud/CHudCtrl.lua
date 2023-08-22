local CHudCtrl = class("CHudCtrl")
CHudCtrl.g_MaxCached = 100
CHudCtrl.g_TransList = {"Waist", "Head", "Foot"}
CHudCtrl.g_Layer = UnityEngine.LayerMask.NameToLayer("HudLayer")

function CHudCtrl.ctor(self)
	self.m_Root = nil
	self.m_UsedCache = {}
	self.m_UnusedCache = {}
	self.m_LoadingList = {}
	self.m_HudNodesPool = {}
	self.m_CloneHudNode = nil
end

--初始化，生成HudRoot的GameObject
function CHudCtrl.InitRoot(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Hud/HudRoot.prefab")
	self.m_Root = CPanel.New(obj)
	local oUIRoot = UITools.GetUIRoot()
	self.m_Root:SetParent(oUIRoot.transform)
	self.m_Root.m_UIPanel.sortingOrder = -3

	local layerPrefab = g_ResCtrl:GetCloneFromCache("UI/Hud/UIHudLayers.prefab")
	self.m_UIHudLayer = CObject.New(layerPrefab)
	self.m_UIHudLayer:SetName("UIHudLayers")
	self.m_LayerRootCom = layerPrefab:GetComponent(classtype.UIRoot)
	self.m_LayerManualHeight = self.m_LayerRootCom.manualHeight

    local mainCam = g_CameraCtrl:GetMainCamera()
	self.m_CamMask = mainCam.m_Camera.cullingMask

	Utils.AddTimer(callback(self, "InitCloneHudNode"), 0, 0)
end

function CHudCtrl.InitCloneHudNode(self)
	local function cb(node)
		self.m_CloneHudNode = node
	end
	CHudNode.New(nil, cb)
end

function CHudCtrl.ScaleHudLayer(self, height, ani)
		
	if not self.m_LayerRootCom then 
		return
	end 

	height = height or self.m_LayerManualHeight

	if ani then 
		local fun = function ( arg)
			self.m_LayerRootCom.manualHeight = arg
		end
		DOTween.DoFloat(self.m_LayerRootCom.manualHeight, height, define.Fly.Data.FlyTime, fun)
	else
		self.m_LayerRootCom.manualHeight = height
	end 

end

--监听战斗开始和结束事件,摄像hudlayer的角度
function CHudCtrl.SceneChangeEvent(self, isWaring)
	if self.m_UIHudLayer ~= nil then
		local warCam = g_CameraCtrl:GetWarCamera()
		local warUICam = g_CameraCtrl:GetWarUICamera()
		local mainCam = g_CameraCtrl:GetMainCamera()
		if isWaring then
			-- 保持相机角度一致
			local warCameraAngle = g_CameraCtrl:GetWarCamera():GetEulerAngles()
			self.m_UIHudLayer:SetLocalEulerAngles(warCameraAngle)
			self.isWaring = true	
			warCam:SetEnabled(true)
			warUICam:SetEnabled(true)
			local mask = self.m_CamMask
			local mask = mask - 2^define.Layer.HudLayer
			mainCam.m_Camera.cullingMask = mask
	    else 
			self.m_UIHudLayer:SetLocalEulerAngles(Vector3.zero)
			self.isWaring = false
			warCam:SetEnabled(false)
			warUICam:SetEnabled(false)
			mainCam.m_Camera.cullingMask = self.m_CamMask
	    end 
	end 
end

------------以下的函数是缓存的HudObj的管理---------------

--这里是HudNode节点的Obj
function CHudCtrl.GetHudNodeFromPool(self, mountHud)
	local oHudNode = nil
	if #self.m_HudNodesPool > 0 then
		oHudNode = self.m_HudNodesPool[1]
		oHudNode:ResetHudNode(mountHud)
		table.remove(self.m_HudNodesPool, 1)
		oHudNode:SetPosHide(false)
	else
		oHudNode = CHudNode.New(mountHud)  -- 每个模型对应一个 HudNode
		-- CObject.SetLayer(oHudNode, UnityEngine.LayerMask.NameToLayer("HudLayer"), true)
		--oHudNode:SetParent(self.m_Root.m_Transform)
	end

	-- oHudNode:SetParent(self.m_UIHudLayer.m_Transform)


	-- for _,v in ipairs(CHudCtrl.g_TransList) do
	-- 	oHudNode["m_"..v.."SubHud"]:SetAutoUpdate(true)
	-- end
	
	return oHudNode
end

function CHudCtrl.SetHudNode2Pool(self, oHudNode)
	if true or #self.m_HudNodesPool >= CHudCtrl.g_MaxCached then
		oHudNode:Destroy()
		-- g_ResCtrl:PutCloneInCache(oHudNode:GetCacheKey(), oHudNode.m_GameObject)
		return
	end
	for _,v in ipairs(CHudCtrl.g_TransList) do
		oHudNode["m_"..v.."SubHud"]:SetAutoUpdate(false)
	end
	oHudNode:SetPosHide(true)
	oHudNode:SetName("UnusedHudNode")
	table.insert(self.m_HudNodesPool, oHudNode)
end

function CHudCtrl.GetLoadFunc(self, cls, cb)
	return function(oHud)
		--oHud:SetParent(self.m_Root.m_Transform)
		oHud:SetParent(self.m_UIHudLayer.m_Transform)	
		self:SetUsed(cls, oHud)
		cb(oHud)
		local idx = table.index(self.m_LoadingList, oHud)
		if idx then
			table.remove(self.m_LoadingList, idx)
		end
	end
end

--这里是一个某个具体Hud的Obj
function CHudCtrl.AddHudByCls(self, cls, cb)
	local oCached = self:GetUnused(cls)
	local f = self:GetLoadFunc(cls, cb)
	if oCached then
		f(oCached)
	else
		local oLoading = cls.New(f)
		table.insert(self.m_LoadingList, oLoading)
	end
end

function CHudCtrl.SetUsed(self, cls, oHud)
	local list = self.m_UsedCache[cls.classname]
	if not list then
		list = {}
	end
	oHud:SetPosHide(false)
	list[oHud:GetInstanceID()] = oHud
	self.m_UsedCache[cls.classname] = list
end

function CHudCtrl.GetUnused(self, cls)
	local list = self.m_UnusedCache[cls.classname]
	if self.m_UnusedCache[cls.classname] then
		local oHud = list[1]
		table.remove(list, 1)
		self.m_UnusedCache[cls.classname] = list
		return oHud
	end
end

function CHudCtrl.SetUnused(self, oHud)
	local clsname = oHud.classname
	local list = self.m_UnusedCache[clsname]
	if not list then
		list = {}
	end
	self.m_UsedCache[clsname][oHud:GetInstanceID()] = nil
	if #list >= CHudCtrl.g_MaxCached * 3 then
		oHud:Destroy()
		-- g_ResCtrl:PutCloneInCache(oHud:GetCacheKey(), oHud.m_GameObject)
		return
	end
	oHud:Recycle()
	oHud:SetOwner(nil)
	-- 暂时放到根目录下
	--oHud:SetParent(self.m_Root.m_Transform)
	oHud:SetParent(self.m_UIHudLayer.m_Transform)
	oHud:SetPosHide(true)
	table.insert(list, oHud)
	self.m_UnusedCache[clsname] = list
end
return CHudCtrl