-- local CEcononmyAuctionRecordView = class("CEcononmyAuctionRecordView", CViewBase)

-- function CEcononmyAuctionRecordView.ctor(self, cb)
-- 	CViewBase.ctor(self, "UI/Econonmy/EcononmyAuctionRecordView.prefab", cb)
-- 	self.m_ExtendClose = "Black"
-- end

-- function CEcononmyAuctionRecordView.OnCreateView(self)
-- 	self.m_BuyRecordTab = self:NewUI(1, CButton)
-- 	self.m_SaleRecordTab = self:NewUI(2, CButton)
-- 	self.m_ItemGrid = self:NewUI(3, CGrid)
-- 	self.m_BoxClone = self:NewUI(4, CBox)
-- 	self.m_ScrollView = self:NewUI(5, CScrollView)
-- 	self.m_CloseBtn = self:NewUI(6, CButton)
-- 	self.m_EmptyObj = self:NewUI(7, CObject)

-- 	self.m_Type = {
-- 		Buy = 1,
-- 		Sale = 2,
-- 	}
-- 	self.m_CurType = 0
-- 	self.m_ItemBoxs = {}

-- 	self:InitContent()
-- end

-- function CEcononmyAuctionRecordView.InitContent(self)
-- 	self.m_BoxClone:SetActive(false)
-- 	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
-- 	self.m_BuyRecordTab:AddUIEvent("click", callback(self, "ChangeTab", self.m_Type.Buy))
-- 	self.m_SaleRecordTab:AddUIEvent("click", callback(self, "ChangeTab", self.m_Type.Sale))
-- 	g_EcononmyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
-- 	self.m_BuyRecordTab:SetSelected(true)
-- 	self:ChangeTab(self.m_Type.Buy)
-- end

-- function CEcononmyAuctionRecordView.OnCtrlEvent(self, oCtrl)
-- 	if oCtrl.m_EventID == define.Org.Event.RefreshMyAuctionRecord then
-- 		self:RefreshAll()
-- 	end
-- end

-- function CEcononmyAuctionRecordView.RefreshAll(self)
-- 	self:InitRecordList()
-- 	self:RefreshGrid()
-- end

-- function CEcononmyAuctionRecordView.InitRecordList(self)
-- 	self.m_ItemList = nil
-- 	if self.m_CurType == self.m_Type.Buy then
-- 		self.m_ItemList = g_EcononmyCtrl:GetAuctionRecord()
-- 	else
-- 		local _,list = g_EcononmyCtrl:GetAuctionRecord()
-- 		self.m_ItemList = list
-- 	end
-- end

-- function CEcononmyAuctionRecordView.RefreshGrid(self)
-- 	if not self.m_ItemList then
-- 		return
-- 	end
-- 	self.m_ScrollView:ResetPosition()
-- 	for i,oBox in ipairs(self.m_ItemBoxs) do
-- 		if oBox:GetActive() then
-- 			oBox:SetActive(false)
-- 		end
-- 	end
-- 	for i,dInfo in ipairs(self.m_ItemList) do
-- 		local oBox = self.m_ItemBoxs[i]
-- 		if not oBox then
-- 			oBox = self:CreateItemBox()
-- 			self.m_ItemBoxs[i] = oBox
-- 			self.m_ItemGrid:AddChild(oBox)
-- 		end
-- 		self:UpdateItemBox(oBox, dInfo)
-- 	end
-- 	self.m_ItemGrid:Reposition()
-- 	self.m_EmptyObj:SetActive(#self.m_ItemList == 0)
-- end

-- function CEcononmyAuctionRecordView.CreateItemBox(self)
-- 	local oBox = self.m_BoxClone:Clone()
-- 	oBox.m_NameL = oBox:NewUI(1, CLabel)
-- 	oBox.m_IconSpr = oBox:NewUI(2, CSprite)
-- 	oBox.m_PriceL = oBox:NewUI(3, CLabel)
-- 	return oBox
-- end

-- function CEcononmyAuctionRecordView.UpdateItemBox(self, oBox, dInfo)
-- 	oBox:SetActive(true)
-- 	local dData = nil
-- 	if dInfo.type == define.Econonmy.AuctionType.Item then
-- 		dData = DataTools.GetItemData(dInfo.sid)
-- 		oBox.m_IconSpr:SpriteItemShape(dData.icon)
-- 	else
-- 		dData = DataTools.GetSummonInfo(dInfo.sid)
-- 		oBox.m_IconSpr:SpriteAvatar(dData.shape)
-- 	end
-- 	oBox.m_NameL:SetText(dInfo.name)
-- 	oBox.m_PriceL:SetText(dInfo.price)
-- end

-- function CEcononmyAuctionRecordView.ChangeTab(self, iTab)
-- 	self.m_CurType = iTab
-- 	self:RefreshAll()
-- end
-- return CEcononmyAuctionRecordView