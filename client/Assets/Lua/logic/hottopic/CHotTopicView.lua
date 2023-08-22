local CHotTopicView = class("CHotTopicView", CViewBase)

function CHotTopicView.ctor(self, cb)
	CViewBase.ctor(self, "UI/HotTopic/HotTopicView.prefab", cb)

	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"

	self.m_SelIdx = 0
end

function CHotTopicView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_RecommendPart = self:NewPage(2, CRecommendPart)
	self.m_HotTopicPart = self:NewPage(3, CHotTopicPart)

	self.m_RecommendBtn = self:NewUI(4, CButton, false, false)
	self.m_HottopicBtn = self:NewUI(5, CButton, false, false)

	self:InitContent()
end

function CHotTopicView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RecommendBtn:AddUIEvent("click", callback(self, "OnBtn", 1))
	self.m_HottopicBtn:AddUIEvent("click", callback(self, "OnBtn", 2))

	self.m_RecommendBtn:SetGroup(self:GetInstanceID())
	self.m_HottopicBtn:SetGroup(self:GetInstanceID())
	
	local bRecommendOpen = g_RecommendCtrl:IsRecommendOpen()
	local bHottopicOpen = g_HotTopicCtrl:IsHotTopicOpen()

	self.m_RecommendBtn:SetActive(bRecommendOpen)
	self.m_HottopicBtn:SetActive(bHottopicOpen)

	if not bRecommendOpen and bHottopicOpen then
		self.m_HottopicBtn:SetLocalPos(Vector3(0, -83, 0))  --原Y位置 -216
	end

	if bRecommendOpen then
		self:OnBtn(1) --默认打开精彩推荐
	elseif bHottopicOpen then
		self:OnBtn(2) --默认打开热门活动
	end
end

function CHotTopicView.OnBtn(self, idx)
	if self.m_SelIdx == idx then
		return 
	end
	self.m_SelIdx = idx

	if idx == 1 then
		self.m_RecommendBtn:SetSelected(true)
	else
		self.m_HottopicBtn:SetSelected(true)
	end
	CGameObjContainer.ShowSubPageByIndex(self, idx)
end

function CHotTopicView.OnClose(self)
    self:CloseView()
    if g_HotTopicCtrl.m_SignCallback then
        g_HotTopicCtrl:m_SignCallback()
        g_HotTopicCtrl.m_SignCallback = nil
    end
end

return CHotTopicView
