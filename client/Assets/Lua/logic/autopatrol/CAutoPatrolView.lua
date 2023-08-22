local CAutoPatrolView = class("CAutoPatrolView", CViewBase)

function CAutoPatrolView.ctor(self, cb)
	CViewBase.ctor(self, "UI/AutoPatrol/AutoPatrolView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CAutoPatrolView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_PageGrid = self:NewUI(3, CGrid)
	self.m_PageClone = self:NewUI(4, CGrid)
	self.m_AutoBtn = self:NewUI(5, CButton)
	self.m_LeftBtn = self:NewUI(6, CButton)
	self.m_RightBtn = self:NewUI(7, CButton)
	self.m_DotGrid = self:NewUI(8, CGrid)
	self.m_DotClone = self:NewUI(9, CSprite)

	self.m_SceneDataList = {}

	self.m_SpringPanel = nil
	self.m_CurCenterObj = nil
	self.m_CurPageIdx = 1

	self.m_PageGridWidth = 613
	self:InitContent()
end

function CAutoPatrolView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_AutoBtn:AddUIEvent("click", callback(self, "AutoRunOnClick"))
	self.m_LeftBtn:AddUIEvent("click", callback(self, "ChangePage", "Reduce"))
	self.m_RightBtn:AddUIEvent("click", callback(self, "ChangePage", "Add"))
	self.m_SpringPanel = self.m_ScrollView:GetComponent(classtype.SpringPanel)
	self.m_ScrollView:InitCenterOnCompnent(self.m_PageGrid, callback(self, "OnCenter"))

	self:SetData()
	self:InstanceItem()
end

function CAutoPatrolView.OnCenter(self, oGridCenter, gameobject)
	if gameobject == self.m_CurCenterObj then
		return
	end

	local idx = self.m_PageGrid:GetChildIdx(gameobject.transform)
	self.m_CurPageIdx = idx
	self.m_CurCenterObj = gameobject
	self:RefreshDot()
end

function CAutoPatrolView.SetData(self)
	for k,v in pairs(data.autorundata.SCENEDATA) do
		table.insert(self.m_SceneDataList, v)
	end
	local function sortfunc(s1, s2)
		return s1.sort < s2.sort
	end

	table.sort(self.m_SceneDataList, sortfunc)
end

function CAutoPatrolView.InstanceItem(self)
	local oGird	= nil
	local oAutoPatrolSceneBox = nil
	local oDot = nil
	local iIndex = 0

	for i=1,(math.ceil(table.count(self.m_SceneDataList) / 3)) do
		oGird = self.m_PageClone:Clone()
		oGird:SetActive(true)
		local function Init(obj, idx)
			iIndex = (i - 1)*3 + idx
			oAutoPatrolSceneBox = CAutoPatrolSceneBox.New(obj, function()
				self:CloseView()
			end)
			if iIndex > table.count(self.m_SceneDataList) then
				oAutoPatrolSceneBox:SetActive(false)
			else
				oAutoPatrolSceneBox:SetAutoPatrolBox(self.m_SceneDataList[iIndex], iIndex)
			end			
		end
		oGird:InitChild(Init)
		self.m_PageGrid:AddChild(oGird)

		oDot = self.m_DotClone:Clone()
		oDot:SetActive(true)
		oDot:SetGroup(self.m_DotGrid:GetInstanceID())
		self.m_DotGrid:AddChild(oDot)
	end

	UITools.MoveToTarget(self.m_ScrollView, self.m_PageGrid:GetChild(self.m_CurPageIdx))
	self:RefreshDot()
end

function CAutoPatrolView.RefreshDot(self)
	local oDot = self.m_DotGrid:GetChild(self.m_CurPageIdx)
	if oDot then
		oDot:SetSelected(true)
	end
end
	
function CAutoPatrolView.AutoRunOnClick(self)
	if g_MapCtrl:IsAutoPatrolMap() then
		g_MapCtrl:SetAutoPatrol(true)
	else
		g_NotifyCtrl:FloatMsg("该场景非暗雷场景，无法自动巡逻")
	end
	self:CloseView()
end

function CAutoPatrolView.ChangePage(self, stype)
	if stype == "Reduce" then
		if self.m_CurPageIdx > 1 then
			self.m_CurPageIdx = self.m_CurPageIdx - 1  
		else
			self.m_CurPageIdx = 1 
		end		
	elseif stype == "Add" then
		if self.m_CurPageIdx < self.m_DotGrid:GetCount() then
			self.m_CurPageIdx = self.m_CurPageIdx + 1
		else
			self.m_CurPageIdx = self.m_DotGrid:GetCount()
		end
	end
	self:RefreshDot()
	self.m_SpringPanel.Begin(self.m_ScrollView.m_GameObject, Vector3.New(self.m_PageGridWidth*(-self.m_CurPageIdx + 1), 10, 0), 8)
end

return CAutoPatrolView