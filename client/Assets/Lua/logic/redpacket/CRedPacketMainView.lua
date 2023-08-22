local CRedPacketMainView = class("CRedPacketMainView", CViewBase)

function CRedPacketMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketMainView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_WorldPart = self:NewPage(3, CRedPacketWorldPart)
	self.m_OrgPart = self:NewPage(4, CRedPacketOrgPart)
	self:InitContent()
end

function CRedPacketMainView.InitContent(self)
	self.m_BtnGrid:InitChild(function(obj, idx)
			local oBtn = CButton.New(obj)
			oBtn:SetGroup(self:GetInstanceID())
			return oBtn
		end)
	self.m_WorldBtn = self.m_BtnGrid:GetChild(1)
	self.m_OrgBtn = self.m_BtnGrid:GetChild(2)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_WorldBtn:AddUIEvent("click", callback(self, "ShowWorldPart"))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "ShowOrgPart"))

	-- self:ShowWorldPart()
end

function CRedPacketMainView.ShowWorldPart(self)
	netredpacket.C2GSQueryAll(define.RedPacket.Channel.World)
	self:SetWorldUI()
end

function CRedPacketMainView.SetWorldUI(self)
	self.m_WorldBtn:SetSelected(true)
	self:ShowSubPage(self.m_WorldPart)
end

function CRedPacketMainView.ShowOrgPart(self)
	netredpacket.C2GSQueryAll(define.RedPacket.Channel.Org)
	self:SetOrgUI()
end

function CRedPacketMainView.SetOrgUI(self)
	self.m_OrgBtn:SetSelected(true)
	self:ShowSubPage(self.m_OrgPart)
end

return CRedPacketMainView