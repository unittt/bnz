local CMiniMapPart = class("CMiniMap",CPageBase)

function CMiniMapPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMiniMapPart.OnInitPage(self)	
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SwitchBtn = self:NewUI(2, CButton)
	self.m_SearchBtn = self:NewUI(3, CButton)
	self.m_PlayerInfoOrigin = self:NewUI(4, CWidget)
	self.m_PlayerIcon = self:NewUI(5, CObject)
	self.m_TargetPoint = self:NewUI(6, CObject)
	self.m_TargetLabel = self:NewUI(7, CLabel)
	self.m_FootPointList = self:NewUI(8, CObject)
	self.m_PointClone = self:NewUI(9, CObject)
	self.m_MapTexture = self:NewUI(10, CTexture)
	self.m_MiniMapBg = self:NewUI(11, CSprite)
	self.m_NpcBoxListNode = self:NewUI(12,CSprite)
	self.m_NpcBoxListGrid = self:NewUI(13, CGrid)
	self.m_NpcSeachBoxClone = self:NewUI(14, CBox)
	self.m_TeleportShortNameNode = self:NewUI(15, CObject)
	self.m_TeleportShortNameBoxClone = self:NewUI(16, CBox)
	self.m_NpcShortNameNode = self:NewUI(17, CObject)
	self.m_NpcShortNameBoxClone = self:NewUI(18, CBox)
	self.m_MapName = self:NewUI(19, CLabel)
	self.m_MaskSprite = self:NewUI(20, CSprite)
	self.m_RightFloatSprite = self:NewUI(21, CSprite)
	self.m_LeftFloatSprite = self:NewUI(22, CSprite)
	
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapCtrl"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnSwitchMapBtn"))
	self.m_SearchBtn:AddUIEvent("click", callback(self, "OnSearchBtn"))
	self.m_MapTexture:AddUIEvent("click", callback(self, "OnClickMapTexture"))	
	g_UITouchCtrl:TouchOutDetect(self.m_NpcBoxListNode, callback(self, "OnTouchOutDetect"))
	
	self.m_PointClone:SetActive(false)
	self.m_NpcBoxListNode:SetActive(false)
	self.m_NpcSeachBoxClone:SetActive(false)
	self.m_TeleportShortNameBoxClone:SetActive(false)
	self.m_NpcShortNameBoxClone:SetActive(false)

	self.m_Distances = 3
	-- 宽高比例（默认1.33）
	self.m_MiniMapRatio = 1.33
	self.m_Scene2MapZoomX = 1
	self.m_Scene2MapZoomY = 1

	-- 路径点ObjList\总路径点\当前走过的点
	self.m_FootPointObjList = {}
	self.m_FootPointCount = 0
	self.m_FootPointIndex = 1

	self.m_FootPointTimer = nil
	self.m_PlayerPosTimer = nil
	self.m_FinishTexture = false

	-- TODO 传送点列表

	-- 场景Npc数据列表
	self.m_globalNpcList = {}
	self.m_shortNameNpcList = {}
	self.m_TeleportInfoBoxList = {}
	self.m_NpcInfoBoxList = {}

	self.m_TeleportPos = {}

	self:SetupMiniPart()
	self:InitMiniMapView()
end

function CMiniMapPart.OnTouchOutDetect(self, gameObj)
	if gameObj == self.m_SearchBtn.m_GameObject then
		return
	end
	if self.m_NpcBoxListNode:GetActive() then
		self.m_MapTexture:SetAlpha(1)
		self.m_NpcBoxListNode:SetActive(false)
	end
end

-- EventCallback
function CMiniMapPart.OnMapCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.ClearFootPoint then
		self:HideFootPoints(#self.m_FootPointObjList)
		self.m_TargetPoint:SetActive(false)
		self:OnHidePage()
	elseif oCtrl.m_EventID == define.Map.Event.UpdateMiniPos then
		self:ResetPlayerPos()
	else
		self:OnClose()
	end
end

function CMiniMapPart.OnClose(self)
	self.m_ParentView:CloseView()
end

function CMiniMapPart.OnSwitchMapBtn(self)
	self.m_ParentView:ShowMapSpecificPart(1, true)
end

function CMiniMapPart.OnSearchBtn(self)
	if self.m_NpcBoxListNode:GetActive() then
		self.m_MapTexture:SetAlpha(1)
		self.m_NpcBoxListNode:SetActive(false)
	else
		self:SetSearchInfo()
	end
end

function CMiniMapPart.OnClickMapTexture(self)
	if g_MapCtrl:IsInOrgMatchMap() then
		g_NotifyCtrl:FloatMsg("此场景插翅难飞")
		return
	end
	if g_LimitCtrl:CheckIsLimit(true, true) then
    	return
    end
	self:HideFootPoints(#self.m_FootPointObjList)

	local oNGUICamera = g_CameraCtrl:GetNGUICamera()
	local oUICamera = g_CameraCtrl:GetUICamera()
	local vTouchPos = oNGUICamera.lastEventPosition
	local vTextureWorldPos = oUICamera:ScreenToWorldPoint(Vector3.New(vTouchPos.x, vTouchPos.y, 0))
	local vTextureLocalPos = self.m_MapTexture:InverseTransformPoint(vTextureWorldPos)
	local vGlobalWorldPos = self:GetMap2ScenePos(vTextureLocalPos)

	local npcid = nil
	local close = nil
	local dis = nil
	local func = nil
	local npc = nil
	if self:CheckTeleportPos(vTextureLocalPos) then
		close = true
	else
		if g_MapCtrl:IsInHuodongMap() then 
			npc = self:CheckHuodongNpcPos(vTextureLocalPos)
		else
			npc = self:CheckGlobalNpcPos(vTextureLocalPos)
		end 
		if npc and not g_MapCtrl:GetIsGlobalNpcHideByNpcType(npc.id) then
			npcid = npc.id
			dis = define.Walker.Npc_Talk_Distance
			func = function ()
				local oNpc = g_MapCtrl:GetNpcByType(npcid)
				if oNpc and oNpc.Trigger then
					oNpc:Trigger()
				end
			end
			close = true
		end
	end

	if npc then 
		local npcWorldPos = Vector3.New(npc.x, npc.y, npc.z)
		g_MapTouchCtrl:WalkToPos(npcWorldPos, npcid, dis, func)
	else
		g_MapTouchCtrl:WalkToPos(vGlobalWorldPos, npcid, dis, func)
	end 

	if close then
		self:OnClose()
		return
	end

	local function delay()
		self:OnShowPage()
		return false
	end
	Utils.AddTimer(delay, 0.05, 0.05)
end

function CMiniMapPart.CheckTeleportPos(self, touchPos)
	for _,v in ipairs(self.m_TeleportPos) do
		local distance = (v.x - touchPos.x)^2 + (v.y - touchPos.y)^2
		if distance <= 180 then
			return true
		end
	end
	return false
end

function CMiniMapPart.CheckGlobalNpcPos(self, touchPos)
	for _,v in ipairs(self.m_globalNpcList) do
		local vWorldPos = Vector3.New(v.x, v.y, v.z)
		local vTexturePos = self:GetScene2MapPos(vWorldPos)
		local x = vTexturePos.x + v.minMapOffsetX
		local y = vTexturePos.y + v.minMapOffsetY
		local z = vTexturePos.z
		local pos = Vector3.New(x, y, z)
		local distance = (pos.x - touchPos.x)^2 + (pos.y - touchPos.y)^2
		if distance <= 300 then
			return v
		end
	end
	return nil
end

function CMiniMapPart.CheckHuodongNpcPos(self, touchPos)

	local npcInfo = g_MapCtrl:GetHuodongNpcInfo()
	if npcInfo then 
		for _,v in ipairs(npcInfo) do
			local vWorldPos = Vector3.New(v.x, v.y, v.z)
			local vTexturePos = self:GetScene2MapPos(vWorldPos)
			local x = vTexturePos.x 
			local y = vTexturePos.y
			local z = vTexturePos.z
			local pos = Vector3.New(x, y, z)
			local distance = (pos.x - touchPos.x)^2 + (pos.y - touchPos.y)^2
			if distance <= 300 then
				return v
			end
		end
		return nil
	end 

end

function CMiniMapPart.SetupMiniPart(self)
	self.m_globalNpcList = DataTools.GetGlobalNpcList(g_MapCtrl:GetMapID())
	
	for _,v in ipairs(self.m_globalNpcList) do
		-- if v.shortName and string.len(v.shortName) > 0 then
		-- end
		--没有隐藏的npc显示,只针对全局npc
		if not g_MapCtrl:GetIsGlobalNpcHideByNpcType(v.id) then
			table.insert(self.m_shortNameNpcList, v)
		end		
	end

	-- 排序
	table.sort(self.m_globalNpcList, function (a, b)
		if a.sortLetter ~= b.sortLetter then
			return a.sortLetter < b.sortLetter
		end
		return a.id < b.id
	end)
end

-- InitView
function CMiniMapPart.InitMiniMapView(self)
	self:SetActive(false)
	local resid = g_MapCtrl:GetResID()
	local pathName = string.format("Texture/Minimap/minimap_%s.jpg", resid)

	local function finishLoadMiniMap(textureRes, errcode)
		if Utils.IsNil(self) then
			return
		end
		self:SetActive(true)
		if textureRes then
			self.m_MapTexture:SetMainTexture(textureRes)
		else
			print(errcode)
			return
		end

		local map = g_MapCtrl.m_CurMapObj.m_MapCompnent
		local relativeRatio = map.width / 100
		self.m_Distances = define.Map.AdaptationView.PointSpac * relativeRatio
		local ratio = map.width / map.height

		-- local relativeRatio = textureRes.width / 1024
		-- self.m_Distances = define.Map.AdaptationView.PointSpac * relativeRatio
		-- local ratio = textureRes.width / textureRes.height
		-- printc("===========", textureRes.name, textureRes.width, textureRes.height, textureRes.texelSize)
		-- table.print(textureRes.format)

		self:SetMimiMapSize(ratio)

		if g_MapCtrl:IsInHuodongMap() then 
			self:SetHuodongNpcInfo()
		else
			self:SetNpcInfo(ratio)
		end 

		self.m_FinishTexture = true
		self:OnShowPage()
	end
	g_ResCtrl:LoadAsync(pathName, finishLoadMiniMap)
end

function CMiniMapPart.SetMimiMapSize(self, ratio)
	local finalWidth, finalHeight = 0, 0
	-- 适配(横向,定宽 \ 纵向,定高)
	if ratio >= 1 then
		finalWidth = define.Map.AdaptationView.Width
		finalHeight = finalWidth / ratio
	else
		finalHeight = define.Map.AdaptationView.Height
		finalWidth = finalHeight * ratio
	end

	self.m_MiniMapRatio = ratio
	self.m_Scene2MapZoomX = g_MapCtrl.m_CurMapObj.m_MapCompnent.width / finalWidth
	self.m_Scene2MapZoomY = g_MapCtrl.m_CurMapObj.m_MapCompnent.height / finalHeight

	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.Center)
	self.m_MapTexture:SetLocalPos(Vector3.zero)
	self.m_MapTexture:SetSize(finalWidth, finalHeight)
	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.BottomLeft)
	self.m_MapTexture.m_UIWidget:ResizeCollider()

	self.m_CloseBtn:ResetAndUpdateAnchors()
	self.m_SwitchBtn:ResetAndUpdateAnchors()
	self.m_SearchBtn:ResetAndUpdateAnchors()
	self.m_PlayerInfoOrigin:ResetAndUpdateAnchors()
	self.m_MiniMapBg:ResetAndUpdateAnchors()
	self.m_MapName:ResetAndUpdateAnchors()
	self.m_MaskSprite:ResetAndUpdateAnchors()
	self.m_RightFloatSprite:ResetAndUpdateAnchors()
	self.m_LeftFloatSprite:ResetAndUpdateAnchors()
	self.m_NpcBoxListNode:ResetAndUpdateAnchors()
end

function CMiniMapPart.SetNpcInfo(self, ratio)
	self.m_TeleportPos = {}
	self.m_MapName:SetText(g_MapCtrl:GetSceneName())

	-- 传送点
	local oTeleportBox = nil
	local mapData = DataTools.GetMapInfo(g_MapCtrl:GetMapID())
	for i,v in ipairs(mapData.transfers) do
		if i > #self.m_TeleportInfoBoxList then
			oTeleportBox = self.m_TeleportShortNameBoxClone:Clone()
			oTeleportBox.m_Name = oTeleportBox:NewUI(1, CLabel)
			oTeleportBox.m_Bg = oTeleportBox:NewUI(2, CSprite)
			oTeleportBox:SetParent(self.m_TeleportShortNameNode.m_Transform)
			table.insert(self.m_TeleportInfoBoxList, oTeleportBox)
		else
			oTeleportBox = self.m_TeleportInfoBoxList[i]
		end
		-- oTeleportBox.m_Name:SetText(v.shortName)
		local scene = DataTools.GetSceneInfo(v.target_scene)
		oTeleportBox.m_Name:SetText(("[FFF6BA]") .. scene.scene_name)
		oTeleportBox.m_Name:SetEffectColor(Color.RGBAToColor("7F6F36FF"))
		-- green-npc yellow-npc
		oTeleportBox.m_Bg:SetSpriteName("yellow-npc")

		oTeleportBox:SetName(v.target_scene .. "_" .. scene.scene_name)
		local vWorldPos = Vector3.New(v.x, v.y, 0)
		local vTexturePos = self:GetScene2MapPos(vWorldPos)
		table.insert(self.m_TeleportPos, vTexturePos)
		local nameHalfWidth = oTeleportBox.m_Name:GetSize() / 2
		if vTexturePos.x - nameHalfWidth < 0  then
			vTexturePos.x = nameHalfWidth
		elseif vTexturePos.x + nameHalfWidth > define.Map.AdaptationView.Width then
			vTexturePos.x = define.Map.AdaptationView.Width - nameHalfWidth
		end
		oTeleportBox:SetLocalPos(vTexturePos)
		oTeleportBox:SetActive(true)
	end
	for i=#mapData.transfers+1,#self.m_TeleportInfoBoxList do
		oTeleportBox = self.m_TeleportInfoBoxList[i]
		if not oTeleportBox then
			break
		end
		oTeleportBox:SetActive(false)
	end

	-- Npc
	local oNpcBox = nil
	for i,v in ipairs(self.m_shortNameNpcList) do
		if i > #self.m_NpcInfoBoxList then
			oNpcBox = self.m_NpcShortNameBoxClone:Clone()
			oNpcBox.m_Name = oNpcBox:NewUI(1, CLabel)
			oNpcBox.m_Bg = oNpcBox:NewUI(2, CSprite)
			oNpcBox.m_TitleIcon =  oNpcBox:NewUI(3, CSprite)
			oNpcBox.m_TitleIcon:SetActive(false)
			oNpcBox.m_Bg:SetActive(false)
			oNpcBox.m_Name:SetActive(false)
			oNpcBox:SetParent(self.m_NpcShortNameNode.m_Transform)
			table.insert(self.m_NpcInfoBoxList, oNpcBox)
		else
			oNpcBox = self.m_NpcInfoBoxList[i]
		end
		-- oNpcBox.m_Name:SetText(v.shortName)
		local kind = v.kind == 1
		if v.title == "" then 
			oNpcBox.m_Name:SetText((kind and "[9AFFFE]" or "[d3ffee]") .. v.nameMinMap)
			oNpcBox.m_Name:SetActive(true)

		else 
			if string.find(v.title, ":") then
				local strList = string.split(v.title, ":")
				oNpcBox.m_TitleIcon:SetSpriteName(strList[1])
				oNpcBox.m_Name:SetText((kind and "[9AFFFE]" or "[d3ffee]") .. strList[2])
				oNpcBox.m_TitleIcon:SetActive(true)
				oNpcBox.m_Name:SetActive(true)
				oNpcBox.m_TitleIcon:MakePixelPerfect()
				oNpcBox.m_TitleIcon:SetLocalScale(Vector3.New(0.84, 0.84, 0.84))

			else
				if tonumber(v.title) then 
					oNpcBox.m_TitleIcon:SetSpriteName(v.title)
					oNpcBox.m_TitleIcon:SetActive(true)
					oNpcBox.m_TitleIcon:SetLocalPos(Vector3.New(0, 0, 0))
					oNpcBox.m_TitleIcon:MakePixelPerfect()
					oNpcBox.m_TitleIcon:SetLocalScale(Vector3.New(0.84, 0.84, 0.84))
					oNpcBox.m_Name:SetActive(false)
				else
					oNpcBox.m_Name:SetText((kind and "[9AFFFE]" or "[d3ffee]") .. v.title)
					oNpcBox.m_TitleIcon:SetActive(false)
					oNpcBox.m_Name:SetActive(true)
				end 
			end 
		end 
		
		oNpcBox.m_Name:SetEffectColor(kind and Color.RGBAToColor("2B6CB1FF") or Color.RGBAToColor("28715f"))
		-- green-npc yellow-npc
		oNpcBox.m_Bg:SetSpriteName(kind and "green-npc" or "yellow-npc")
		oNpcBox.m_Bg:SetActive(true)
		oNpcBox:SetName(v.id .. "_" .. v.name)
		local vWorldPos = Vector3.New(v.x, v.y, v.z)
		local vTexturePos = self:GetScene2MapPos(vWorldPos)
		local nameHalfWidth = oNpcBox.m_Name:GetSize() / 2
		if vTexturePos.x - nameHalfWidth < 0  then
			vTexturePos.x = nameHalfWidth
		elseif vTexturePos.x + nameHalfWidth > define.Map.AdaptationView.Width then
			vTexturePos.x = define.Map.AdaptationView.Width - nameHalfWidth
		end
		local x = vTexturePos.x + v.minMapOffsetX
		local y = vTexturePos.y + v.minMapOffsetY
		local z = vTexturePos.z
		oNpcBox:SetLocalPos(Vector3.New(x, y, z))
		oNpcBox:SetActive(true)
	end
	for i=#self.m_shortNameNpcList+1,#self.m_NpcInfoBoxList do
		oNpcBox = self.m_NpcInfoBoxList[i]
		if not oNpcBox then
			break
		end
		oNpcBox:SetActive(false)
	end


end

function CMiniMapPart.SetHuodongNpcInfo(self)

	self.m_MapName:SetText(g_MapCtrl:GetSceneName())
	local npcInfo = g_MapCtrl:GetHuodongNpcInfo()
	local oNpcBox = nil
	for i,v in ipairs(npcInfo) do
		if i > #self.m_NpcInfoBoxList then
			oNpcBox = self.m_NpcShortNameBoxClone:Clone()
			oNpcBox.m_Name = oNpcBox:NewUI(1, CLabel)
			oNpcBox.m_Bg = oNpcBox:NewUI(2, CSprite)
			oNpcBox.m_TitleIcon =  oNpcBox:NewUI(3, CSprite)
			oNpcBox.m_TitleIcon:SetActive(false)
			oNpcBox.m_Bg:SetActive(false)
			oNpcBox.m_Name:SetActive(false)
			oNpcBox:SetParent(self.m_NpcShortNameNode.m_Transform)
			table.insert(self.m_NpcInfoBoxList, oNpcBox)
		else
			oNpcBox = self.m_NpcInfoBoxList[i]
		end
		local kind = true
		oNpcBox.m_Name:SetText((kind and "[9AFFFE]" or "[d3ffee]") .. v.name)
		oNpcBox.m_Name:SetActive(true)
		oNpcBox.m_Name:SetEffectColor(kind and Color.RGBAToColor("2B6CB1FF") or Color.RGBAToColor("28715f"))
		-- green-npc yellow-npc
		oNpcBox.m_Bg:SetSpriteName(kind and "green-npc" or "yellow-npc")
		oNpcBox.m_Bg:SetActive(true)
		oNpcBox:SetName(v.id .. "_" .. v.name)
		local vWorldPos = Vector3.New(v.x, v.y, v.z)
		local vTexturePos = self:GetScene2MapPos(vWorldPos)
		local nameHalfWidth = oNpcBox.m_Name:GetSize() / 2
		if vTexturePos.x - nameHalfWidth < 0  then
			vTexturePos.x = nameHalfWidth
		elseif vTexturePos.x + nameHalfWidth > define.Map.AdaptationView.Width then
			vTexturePos.x = define.Map.AdaptationView.Width - nameHalfWidth
		end
		local x = vTexturePos.x 
		local y = vTexturePos.y 
		local z = vTexturePos.z
		oNpcBox:SetLocalPos(Vector3.New(x, y, z))
		oNpcBox:SetActive(true)
	end

end 

-- Override
function CMiniMapPart.OnHidePage(self)
	if self.m_FootPointTimer then
		Utils.DelTimer(self.m_FootPointTimer)
		self.m_FootPointTimer = nil
	end
	if self.m_PlayerPosTimer then
		Utils.DelTimer(self.m_PlayerPosTimer)
		self.m_PlayerPosTimer = nil
	end
end

function CMiniMapPart.OnShowPage(self)
	if self.m_FinishTexture then
		self:ResetPlayerPos()
		self:InitPathPoint()
		self:SetMiniMapTimer()
	end
end

function CMiniMapPart.AutoUpdatePos(self)
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		self:ResetPlayerPos()
		return true
	end
	Utils.AddTimer(update, 0.1, 0.1)
end

function CMiniMapPart.ResetPlayerPos(self)
	-- 设置玩家PlayerIcon位置
	local heroLocalPos = self:GetHeroLocalPos()
	local finalLocalPos = self:GetScene2MapPos(heroLocalPos)

	if not Utils.IsNil(self.m_PlayerIcon) then
		self.m_PlayerIcon:SetLocalPos(finalLocalPos)
	end
end

function CMiniMapPart.InitPathPoint(self)
	local oHero = g_MapCtrl:GetHero()
	if not oHero then
		return
	end
	local heroPathList,heroPathLen = oHero:GetAStartPath()
	if not heroPathList or heroPathLen <= 0 then
		return
	end
	if Utils.IsNil(self) then
		return
	end
	if g_TeamCtrl:IsJoinTeam() and 
		(not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
		self:AutoUpdatePos()
		return
	end

	-- if heroPathLen == 2 then
	-- 	printc("111111111")
	-- 	table.print(heroPathList[1])
	-- 	table.print(heroPathList[2])

	-- 	local startX = math.floor(heroPathList[1].x)
	-- 	local startY = math.floor(heroPathList[1].y)
	-- 	local endX = math.floor(heroPathList[2].x)
	-- 	local endY = math.floor(heroPathList[2].y)

	-- 	local distanceX = math.floor(heroPathList[1].x - heroPathList[2].x)
	-- 	local distanceY = math.floor(heroPathList[1].y - heroPathList[2].y)
	-- 	local k = distanceY/distanceX
	-- 	local b = startY- k*startX
	-- 	for i = startX + 1, endX do
	-- 		print(i)
	-- 	end
	-- end

	self.m_FootPointCount = 0

	-- 计算当前目标点位
	local targetLocalPos = heroPathList[heroPathLen]
	local targetWorldPos = self:GetScene2MapPos(targetLocalPos)
	if not Utils.IsNil(self.m_TargetPoint) then
		self.m_TargetPoint:SetLocalPos(targetWorldPos)
	end
	self.m_TargetLabel:SetText(string.format("(%d,%d)", math.floor(targetLocalPos.x), math.floor(targetLocalPos.y)))

	local flagPos = heroPathList[1]
	if heroPathLen == 2 then
		-- heroPathLen=1为直线,路径点自行补间
		self:LinePathPoint(self.m_PlayerIcon:GetLocalPos(), self:GetScene2MapPos(heroPathList[2]))
	else
		local distance = self.m_Distances^2
		for i=1,heroPathLen do
			local v = heroPathList[i]
			if (flagPos.x-v.x)^2 + (flagPos.y-v.y)^2 > distance then
				flagPos = v
				self:CurvePathPoint(self:GetScene2MapPos(flagPos), self:GetScene2MapPos(v))
			end
		end
		-- for _,v in ipairs(heroPathList) do
		-- 	v.z = 0
		-- 	if (flagPos.x-v.x)^2 + (flagPos.y-v.y)^2 > distance then
		-- 		flagPos = v
		-- 		self:CurvePathPoint(self:GetScene2MapPos(flagPos), self:GetScene2MapPos(v))
		-- 	end
		-- end
	end

	-- 计算玩家当前位置,过多曲线会有出现获取为0的错误
	local heroWayIndex = oHero:GetWayPointIndex()

	-- heroPathLen=1代表是直线,所以路径点全部自行补间,所以iNowPos返回的是0,所以把当前路径点设置为第一个
	if heroPathLen == 1 and heroWayIndex == 0 and next(self.m_FootPointObjList) ~= nil then
		self.m_FootPointIndex = 1
	else
		-- 根据路径总长度和实际的路径点table之间的比例算出当前经过的点
		self.m_FootPointIndex = math.ceil(heroWayIndex * (#self.m_FootPointObjList / heroPathLen))
		--容错处理
		if self.m_FootPointIndex == 0 and #self.m_FootPointObjList > 0 then
			self.m_FootPointIndex = 1
		end
		self:HideFootPoints(self.m_FootPointIndex, false)

		if next(self.m_FootPointObjList) ~= nil then
			local footPoint = self.m_FootPointObjList[self.m_FootPointIndex]
			if footPoint and not footPoint:GetActive() then
				self.m_FootPointIndex = self.m_FootPointIndex + 1
			end
		end
	end
end

-- 直线点补间
function CMiniMapPart.LinePathPoint(self, startPos, endPos)
	if startPos == nil or endPos == nil then 
		return
	end
	local iRadian = math.atan2(endPos.y - startPos.y, endPos.x - startPos.x)
	local iCosRadian = math.cos(iRadian)
	local iSinRadian = math.sin(iRadian)
	local iTotalen = Vector3.Distance(startPos, endPos)
	local oPoint = nil

	for i=1,iTotalen,30 do
		self.m_FootPointCount = self.m_FootPointCount + 1
		oPoint = self:CloneFootPoint(self.m_FootPointCount)
		oPoint:SetParent(self.m_FootPointList.m_Transform)
		local x = startPos.x + iCosRadian * i
		local y = startPos.y + iSinRadian * i
		oPoint:SetLocalPos(Vector3.New(x, y, 0))
	end
end

-- 曲线点补间
function CMiniMapPart.CurvePathPoint(self, startPos, endPos)
	if not startPos or not endPos then 
		return
	end
	self.m_FootPointCount = self.m_FootPointCount + 1
	local oPoint = self:CloneFootPoint(self.m_FootPointCount)
	oPoint:SetParent(self.m_FootPointList.m_Transform)
	oPoint:SetLocalPos(Vector3.New(startPos.x, startPos.y, 0))
end

-- CloneFootPoint
function CMiniMapPart.CloneFootPoint(self, index)
	local oPoint = nil
	if index > #self.m_FootPointObjList then
		oPoint = self.m_PointClone:Clone()
		oPoint:SetName("FootPoint_" .. index)
		table.insert(self.m_FootPointObjList, oPoint)
	else
		oPoint = self.m_FootPointObjList[index]
	end
	oPoint:SetActive(true)
	return oPoint
end

function CMiniMapPart.SetMiniMapTimer(self)
	if Utils.IsNil(self) then
		return
	end
	self.m_TargetPoint:SetActive(self.m_TargetPoint:GetLocalPos().x > 0 or self.m_TargetPoint:GetLocalPos().y > 0)
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		self:ResetPlayerPos()
		if g_TeamCtrl:IsJoinTeam() and (not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave()) then
			return true
		end

		local curPoint = self.m_FootPointObjList[self.m_FootPointIndex]
		local continue = curPoint and curPoint:GetActive()
		if continue then
			if Vector3.Distance(self.m_PlayerIcon:GetLocalPos(), curPoint:GetLocalPos()) < 10 then
				curPoint:SetActive(false)
				self.m_FootPointIndex = self.m_FootPointIndex + 1
			end
			-- local direction = self.m_FootPointIndex%2 == 1
			-- local flip = direction and enum.UISprite.Flip.Horizontally or enum.UISprite.Flip.Nothing
			-- self.m_IconSprite:SetFlip(flip)
		end

		if not continue then
			local function upPlayerPos()
				if Utils.IsNil(self) then
					return false
				end
				if self.m_TargetPoint:GetActive() then
					if Vector3.Distance(self.m_PlayerIcon:GetLocalPos(), self.m_TargetPoint:GetLocalPos()) > 8 then
						self:ResetPlayerPos()
						return true
					end
				end
				self.m_TargetPoint:SetActive(false)
				return false
			end
			self.m_PlayerPosTimer = Utils.AddTimer(upPlayerPos, 0.1, 0.1)
		elseif self.m_PlayerPosTimer then
			Utils.DelTimer(self.m_PlayerPosTimer)
			self.m_PlayerPosTimer = nil
		end
		return continue
	end
	self.m_FootPointTimer = Utils.AddTimer(update, 0.1, 0.1)
end

-- Help
-- 世界场景坐标坐标转换到UIMiniMap坐标
function CMiniMapPart.GetScene2MapPos(self, keyPos)
	return Vector3.New(keyPos.x / self.m_Scene2MapZoomX, keyPos.y / self.m_Scene2MapZoomY, 0)
end
-- UIMiniMap坐标转换到世界场景坐标
function CMiniMapPart.GetMap2ScenePos(self, keyPos)
	return Vector3.New(keyPos.x * self.m_Scene2MapZoomX, keyPos.y * self.m_Scene2MapZoomY, 0)
end

function CMiniMapPart.HideFootPoints(self, count)
	for i=1,count do
		if self.m_FootPointObjList[i] then
			self.m_FootPointObjList[i]:SetActive(false)
		end
	end
end

function CMiniMapPart.GetHeroLocalPos(self)
	local oHero = g_MapCtrl:GetHero()
	return oHero and oHero:GetLocalPos() or Vector3.zero
end

-- 搜索Npc信息
function CMiniMapPart.SetSearchInfo(self)
	if not self.m_globalNpcList or #self.m_globalNpcList <= 0 then
		return
	end
	local searchList = {}
	for k,v in ipairs(self.m_globalNpcList) do
		--没有隐藏的npc显示,只针对全局npc
		if not g_MapCtrl:GetIsGlobalNpcHideByNpcType(v.id) then
			table.insert(searchList, v)
		end
	end
	if not searchList or #searchList <= 0 then
		return
	end

	self.m_MapTexture:SetAlpha(0.7)

	local npcBoxList = self.m_NpcBoxListGrid:GetChildList()
	local oNpcBox = nil
	for i,v in ipairs(searchList) do
		if i > #npcBoxList then
			oNpcBox = self.m_NpcSeachBoxClone:Clone()
			oNpcBox.m_Icon = oNpcBox:NewUI(1, CSprite)
			oNpcBox.m_Name = oNpcBox:NewUI(2, CLabel)
			self.m_NpcBoxListGrid:AddChild(oNpcBox)
		else
			oNpcBox = npcBoxList[i]
		end
		oNpcBox:AddUIEvent("click", function ()
			self.m_MapTexture:SetAlpha(1)
			self.m_NpcBoxListNode:SetActive(false)
			self:OnClose()
			if g_LimitCtrl:CheckIsLimit(true, true) then
		    	return
		    end
			local pos = Vector3.New(v.x, v.y, v.z)
			g_MapTouchCtrl:WalkToPos(pos, v.id, define.Walker.Npc_Talk_Distance, function ()
				printc("结束寻路到指定npc", v.id, v.name)
				local oNpc = g_MapCtrl:GetNpcByType(v.id)
				if oNpc and oNpc.Trigger then
					oNpc:Trigger()
				end
			end)
		end)
		oNpcBox.m_Name:SetText(v.name)
		local figureInfo = ModelTools.GetModelConfig(v.figureid)
		oNpcBox.m_Icon:SpriteAvatar(figureInfo.model)
		oNpcBox:SetName(v.id .. "_" .. v.name)
		oNpcBox:SetActive(true)
	end

	for i=#searchList+1,#npcBoxList do
		oNpcBox = npcBoxList[i]
		if not oNpcBox then
			break
		end
		oNpcBox:SetActive(false)
	end
	self.m_NpcBoxListNode:SetActive(true)
end

return CMiniMapPart