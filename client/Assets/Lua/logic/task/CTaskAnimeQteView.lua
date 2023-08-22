local CTaskAnimeQteView = class("CTaskAnimeQteView", CViewBase)

function CTaskAnimeQteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskAnimeQteView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondTop"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CTaskAnimeQteView.OnCreateView(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_Container = self:NewUI(2, CWidget)
	self.m_LeftTimeLbl = self:NewUI(3, CLabel)
	self.m_ItemClone = self:NewUI(4, CBox)

	self.m_ScreenWidth = UnityEngine.Screen.width
	self.m_ScreenHeight = UnityEngine.Screen.height

	self.m_Test = false
	self.m_ItemBoxList = {}
	self.m_ItemsLineList = {}
	self.m_AnimeQteDone = false
	self.m_PlotCharacterPosList = {}
	
	self:InitContent()
end

function CTaskAnimeQteView.InitContent(self)
	self.m_ItemClone:SetActive(false)
	--暂时屏蔽剩余时间显示，需要可开启
	self.m_LeftTimeLbl:SetActive(false)

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTaskAnimeQteView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.AnimeQteTime then
		if g_TaskCtrl.m_AnimeQteTime > 0 then
			self.m_LeftTimeLbl:SetText("剩余时间:"..os.date("%M:%S", g_TaskCtrl.m_AnimeQteTime))
		else
			self.m_LeftTimeLbl:SetText("")
		end
	elseif oCtrl.m_EventID == define.Task.Event.AnimeQteFailTime then
		if g_TaskCtrl.m_AnimeQteFailTime > 0 then
			for k,v in ipairs(self.m_ItemBoxList) do
				if not self:GetIsItemDoneById(k) then
					local iconSp = v:NewUI(1, CSprite)
					local clickWidget = v:NewUI(2, CWidget)
					local successSp = v:NewUI(3, CSprite)
					local failSp = v:NewUI(4, CSprite)

					iconSp:SetActive(false)
					clickWidget:SetActive(false)
					failSp:SetActive(true)
					successSp:SetActive(false)
					failSp:SetAlpha(1)

					local function onEnd()
						local tween = failSp:GetComponent(classtype.TweenAlpha)
						tween.enabled = true
						tween:ResetToBeginning()
						tween.from = 1
						tween.to = 0
						tween.delay = 0.5
						tween.duration = 1
						tween:Play(true)
					end
					failSp:SetLocalPos(Vector3.New(0, 0, 0))
					local tween = DOTween.DOLocalMoveY(failSp.m_Transform, 80, 0.7)
					DOTween.SetEase(tween, 1)
					DOTween.OnComplete(tween, onEnd)
				end
			end
		else
			self:CloseView()
		end
	end
end

function CTaskAnimeQteView.RefreshUI(self)
	if self.m_Test then
		g_TaskCtrl.m_AnimeQteSetTime = 10
	else
		if g_TaskCtrl.m_AnimeQteTotalTime then
			g_TaskCtrl.m_AnimeQteSetTime = g_TaskCtrl.m_AnimeQteTotalTime
		else
			if g_TaskCtrl.m_AnimeQteConfig then
				g_TaskCtrl.m_AnimeQteSetTime = g_TaskCtrl.m_AnimeQteConfig.lasts
			else
				g_TaskCtrl.m_AnimeQteSetTime = 10
			end
		end
	end

	g_TaskCtrl:SetAnimeQteTime()

	self:InitItemsLineList()
	self:SetItemUIInfo()
end

function CTaskAnimeQteView.SetItemUIInfo(self)
	if next(self.m_ItemBoxList) then
		for k,v in pairs(self.m_ItemBoxList) do
			self.m_ItemBoxList.m_GameObject:Destroy()
		end
		self.m_ItemBoxList = {}
	end
	local oData = self:GetItemsPos()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddItemUIBox(k, Vector3.New(v[1], v[2], 0))
		end
	end
end

function CTaskAnimeQteView.AddItemUIBox(self, oItem, oScreenPos)
	local oItemBox = self.m_ItemClone:Clone()

	table.insert(self.m_ItemBoxList, oItemBox)

	oItemBox:SetParent(self.m_Widget.m_Transform)
	oItemBox:SetActive(true)
	
	local iconSp = oItemBox:NewUI(1, CSprite)
	local clickWidget = oItemBox:NewUI(2, CWidget)
	local successSp = oItemBox:NewUI(3, CSprite)
	local failSp = oItemBox:NewUI(4, CSprite)
	iconSp:SetActive(true)
	clickWidget:SetActive(true)
	successSp:SetActive(false)
	failSp:SetActive(false)
	successSp:SetAlpha(1)
	successSp:SetLocalPos(Vector3.New(0, 0, 0))
	successSp:GetComponent(classtype.TweenAlpha).enabled  = false
	failSp:SetAlpha(1)
	failSp:SetLocalPos(Vector3.New(0, 0, 0))
	failSp:GetComponent(classtype.TweenAlpha).enabled  = false
	clickWidget:AddUIEvent("click", callback(self, "OnClickItemBox", oItem))
	local pos = g_CameraCtrl:GetUICamera():ScreenToWorldPoint(oScreenPos)
	oItemBox:SetPos(pos)
end

function CTaskAnimeQteView.InitItemsLineList(self)
	self.m_ItemsLineList = {}
	for i=1, #self:GetItemsPos() do
		local list = {}
		list.point = i
		list.hasbeendrag = false
		table.insert(self.m_ItemsLineList, list)
	end
end

--点击后即成功后才会调用这个接口
function CTaskAnimeQteView.SetItemsLineList(self, point)	
	for k,v in ipairs(self.m_ItemsLineList) do
		if v.point == point and v.hasbeendrag == false then
			local iconSp = self.m_ItemBoxList[v.point]:NewUI(1, CSprite)
			local clickWidget = self.m_ItemBoxList[v.point]:NewUI(2, CWidget)
			local successSp = self.m_ItemBoxList[v.point]:NewUI(3, CSprite)
			local failSp = self.m_ItemBoxList[v.point]:NewUI(4, CSprite)

			iconSp:SetActive(false)
			clickWidget:SetActive(false)
			failSp:SetActive(false)
			successSp:SetActive(true)
			successSp:SetAlpha(1)

			local function onEnd()
				local tween = successSp:GetComponent(classtype.TweenAlpha)
				tween.enabled = true
				tween:ResetToBeginning()
				tween.from = 1
				tween.to = 0
				tween.delay = 0.5
				tween.duration = 1
				tween:Play(true)
			end
			successSp:SetLocalPos(Vector3.New(0, 0, 0))
			local tween = DOTween.DOLocalMoveY(successSp.m_Transform, 80, 0.7)
			DOTween.SetEase(tween, 1)
			DOTween.OnComplete(tween, onEnd)

		   	v.hasbeendrag = true
		   	break
		end
	end

	self:CheckItemDone()
end

function CTaskAnimeQteView.CheckItemDone(self)
	local isItemLineFinish = true
	-- table.print(self.m_ItemsLineList, "self.m_ItemsLineList")
	for k,v in pairs(self.m_ItemsLineList) do
		if v.hasbeendrag == false then
			isItemLineFinish = false
			break
		end
	end

	if isItemLineFinish and not self.m_AnimeQteDone then
		-- self.m_DragWidget:GetComponent(classtype.BoxCollider).enabled = false

		--剧情qte的总计时停止
		g_TaskCtrl:ResetAnimeQteTimer()
		self.m_LeftTimeLbl:SetText("")

		local function delay()
			if Utils.IsNil(self) then
				return false
			end
			self:CloseView()
			return false
		end
		Utils.AddTimer(delay, 0, 1)
		
		self.m_AnimeQteDone = true
	end
end

function CTaskAnimeQteView.GetIsItemDoneById(self, id)
	for k,v in pairs(self.m_ItemsLineList) do
		if v.point == id and v.hasbeendrag == true then
			return true
		end
	end
end

function CTaskAnimeQteView.GetItemsPos(self)
	if self.m_Test then
		-- local list = {{20,20}, {430,200}, {830,200}, {1240,720}}
		local list = {{430,400}, {430, 200}, {830, 200}, {830, 400}, }
		-- local list = {{430,400}, {630,200}, {830,400}}
		-- local list = {{20,20}, {430,400}, {630,200}, {430, 200}, {830, 200}, {830, 400}, {1240,720}}
		-- local list = { {430, 200}, {630,200}, {20,20}, {1240,720}, {430,400}, {830, 400},{830, 200}, {576, 45}, {130, 600} }
		return list
	else
		local list = {}
		if g_TaskCtrl.m_AnimeQteConfig then
			for k,v in ipairs(g_TaskCtrl.m_AnimeQteConfig.pointlist) do
				local item = {}
				item[1] = self.m_ScreenWidth/2 + v.posx
				item[2] = self.m_ScreenHeight/2 + v.posy
				table.insert(list, item)
			end
		end
		if next(self.m_PlotCharacterPosList) then
			for k,v in pairs(self.m_PlotCharacterPosList) do
				table.insert(list, v)
			end
		end
		return list
	end
end

--小游戏(qte)根据人物位置的坐标列表
function CTaskAnimeQteView.SetPlotCharacterPos(self, posList)
	self.m_PlotCharacterPosList = {}
	for k,v in pairs(posList) do
		local screenPos = g_CameraCtrl:GetMainCamera():WorldToScreenPoint(v)
		table.insert(self.m_PlotCharacterPosList, {screenPos.x, screenPos.y+100})
	end
end

function CTaskAnimeQteView.OnClickItemBox(self, point)
	self:SetItemsLineList(point)
	if not self.m_Test then
		nettask.C2GSAnimeQteEnd(g_TaskCtrl.m_AnimeQteid, point, 1)
	end
end

function CTaskAnimeQteView.CloseView(self)
	g_PlotCtrl:Resume()
	CViewBase.CloseView(self)
end

return CTaskAnimeQteView