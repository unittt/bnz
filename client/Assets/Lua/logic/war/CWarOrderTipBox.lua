local CWarOrderTipBox = class("CWarOrderTipBox", CBox)

function CWarOrderTipBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_CancelBtn = self:NewUI(1, CButton)
	self.m_TipLabel = self:NewUI(2, CLabel)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
end

function CWarOrderTipBox.RefreshTip(self)
	local dInfo = g_WarOrderCtrl:GetOrderInfo()
	local dGlobalInfo = g_WarOrderCtrl:GetGlobalOrderInfo()

	local sText = "请选择目标"
	if dGlobalInfo.name == "TeamAppoint" then
		sText = sText .. "\n\r委任指挥"
	elseif dGlobalInfo.name == "ClearTeamCmd" then
		sText = sText .. "\n\r指令清除"
	elseif dGlobalInfo.name == "AddTeamCmd" then
		sText = sText .. "\n\r"..dGlobalInfo.extral
	elseif dInfo.name == "Attack" then
		sText = sText .. "\n\r攻击"
	elseif dInfo.name == "Magic" then
		local dMagic = DataTools.GetMagicData(dInfo.orderID)
		sText = sText .. "\n\r"..dMagic.name
	elseif dInfo.name == "Protect" then
		sText = sText .. "\n\r保护"
	elseif dInfo.name == "WarItem" then
		local oItem = g_ItemCtrl.m_BagItems[dInfo.orderID]
		sText = sText .. "\n\r"..oItem:GetItemName()	
	end
	self.m_CancelBtn:SetActive(true)
	self.m_TipLabel:SetText(sText)
end

function CWarOrderTipBox.RefreshTipBefore(self)
	if g_WarOrderCtrl.m_IsHero then
		self.m_TipLabel:SetText("请下达人物指令")
	elseif not g_WarOrderCtrl:IsOrderDone("summon") then
		self.m_TipLabel:SetText("请下达宠物指令")
	else
		return
	end
	self.m_CancelBtn:SetActive(false)
end

function CWarOrderTipBox.OnCancel(self)
	g_WarOrderCtrl:CancelSelectTarget()
end

return CWarOrderTipBox