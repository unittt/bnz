local CRedPacketSelfRecordView = class("CRedPacketSelfRecordView", CViewBase)

function CRedPacketSelfRecordView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketSelfRecordView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketSelfRecordView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ContentLbl1 = self:NewUI(2, CLabel)
	self.m_MoneyLbl1 = self:NewUI(3, CLabel)
	self.m_ContentLbl2 = self:NewUI(4, CLabel)
	self.m_MoneyGoldIconLbl2 = self:NewUI(5, CLabel)
	self.m_ContentObj = self:NewUI(6, CObject)
	self.m_EmptyGo = self:NewUI(7, CObject)
	self.m_EmptyLbl = self:NewUI(8, CLabel)
	self.m_MoneyGoldLbl2 = self:NewUI(9, CLabel)
	self.m_ContentLbl3 = self:NewUI(10, CLabel)
	self.m_MoneyGoldIconLbl3 = self:NewUI(11, CLabel)
	self.m_MoneyGoldLbl3 = self:NewUI(12, CLabel)
	self.m_MoneyIcon1 = self:NewUI(13, CSprite)
	self.m_MoneyIcon2 = self:NewUI(14, CSprite)
	self.m_MoneyIcon3 = self:NewUI(15, CSprite)

	self:InitContent()
end

function CRedPacketSelfRecordView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_RedPacketCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CRedPacketSelfRecordView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RedPacket.Event.GetRedPacketSelfRecord then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

--m_ContentLbl1是抢红包 m_ContentLbl2是发红包
function CRedPacketSelfRecordView.RefreshUI(self, pbdata)
	if pbdata.rob_org_cnt <= 0 and pbdata.rob_world_cnt <= 0 and pbdata.sent_org_cnt <= 0 and pbdata.sent_world_cnt <= 0 then
		self.m_EmptyGo:SetActive(true)
		self.m_EmptyLbl:SetText(data.redpacketdata.TEXT[define.RedPacket.Text.NoSelfRecord].content)
		self.m_ContentObj:SetActive(false)
	else
		self.m_EmptyGo:SetActive(false)
		self.m_ContentObj:SetActive(true)
		local getStr = "抢到帮派红包"..pbdata.rob_org_cnt.."个,".."世界红包"..pbdata.rob_world_cnt.."个"
		self.m_ContentLbl1:SetText(getStr)
		self.m_MoneyLbl1:SetText(pbdata.rob_gold) --..define.Money.Icon.Gold
		self.m_MoneyIcon1:SetSpriteName(g_RedPacketCtrl:GetCommonAtlasMoneyIcon(3))

		local getStr = "发放帮派红包"..pbdata.sent_org_cnt.."个"  --.."发世界红包"..pbdata.sent_world_cnt.."个"
		self.m_ContentLbl2:SetText(getStr)
		self.m_MoneyGoldIconLbl2:SetText(pbdata.send_org_goldcoin) --..define.Money.Icon.GoldCoin
		self.m_MoneyGoldLbl2:SetText(pbdata.send_org_gold..define.Money.Icon.Gold)
		self.m_MoneyIcon2:SetSpriteName(g_RedPacketCtrl:GetCommonAtlasMoneyIcon(1))

		local getStr = "发放世界红包"..pbdata.sent_world_cnt.."个"
		self.m_ContentLbl3:SetText(getStr)
		self.m_MoneyGoldIconLbl3:SetText(pbdata.send_world_goldcoin) --..define.Money.Icon.GoldCoin
		self.m_MoneyGoldLbl3:SetText(pbdata.send_world_gold..define.Money.Icon.Gold)
		self.m_MoneyIcon3:SetSpriteName(g_RedPacketCtrl:GetCommonAtlasMoneyIcon(1))
	end
end

return CRedPacketSelfRecordView