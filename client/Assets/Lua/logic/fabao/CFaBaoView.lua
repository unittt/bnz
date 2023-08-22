local CFaBaoView = class("CFaBaoView", CViewBase)

function CFaBaoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/FaBao/FaBaoView.prefab", cb)

	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"

	self.m_SelectIndex = 1 --初始化
end

function CFaBaoView.OnCreateView(self)
	
	self.m_TitleSpr = self:NewUI(1, CSprite)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TabBtnGrid = self:NewUI(3, CGrid)

	self.m_WearPart = self:NewPage(4, CFaBaoWearPart)
	self.m_PromotePart = self:NewPage(5, CFaBaoPromotePart)
	self.m_AwakenPart = self:NewPage(6, CFaBaoAwakenPart)

	self:InitContent()
end

function CFaBaoView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	-- 分页信息
	self.m_PartTitleList = {"h7_fabaopeidai", "h7_fabaopeiyang", "h7_fabaojuexing"}

	--分页按钮
	local groupId = self.m_TabBtnGrid:GetInstanceID()
	local function Init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(groupId)
		oBtn:AddUIEvent("click", callback(self, "OnTabSelect", idx))
		return oBtn  
	end

	self.m_TabBtnGrid:InitChild(Init)
	
	self:ShowSubPageByIdx(self.m_SelectIndex)
	self:RefreshRedPoint()
end

function CFaBaoView.RefreshRedPoint(self)
	
	local bPromoteRed = g_FaBaoCtrl:GetFaBaoAwakenRedPot()
	if bPromoteRed then
		local oBtn = self.m_TabBtnGrid:GetChild(2)
		oBtn:AddEffect("RedDot", 22)
	end

	
	local bAwakenRed = g_FaBaoCtrl:GetFaBaoAwakenRedPot()
	if bAwakenRed then
		local oBtn = self.m_TabBtnGrid:GetChild(3)
		oBtn:AddEffect("RedDot", 22)
	end
end

function CFaBaoView.OnTabSelect(self, i)

	if self.m_SelectIndex == i then
		return
	end
	
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	if i > 1 and #fabaolist == 0 then 
		g_NotifyCtrl:FloatMsg("目前没有佩戴的法宝")
		return
	end

	self.m_SelectIndex = i

	self:ShowSubPageByIdx(self.m_SelectIndex)
end

function CFaBaoView.ShowSubPageByIdx(self, idx)
	local oBtn = self.m_TabBtnGrid:GetChild(idx)
	if oBtn then
		oBtn:SetSelected(true)
	end

	self:ShowSubPageByIndex(idx)
	self.m_TitleSpr:SetSpriteName(self.m_PartTitleList[idx])
	self.m_SelectIndex = idx
end

function CFaBaoView.OnHideView(self)
	CViewBase.OnHideView(self)

	local oView = CFaBaoMakeView:GetView()
	if oView then
		oView:CloseView()
	end
end

return CFaBaoView