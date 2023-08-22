local CPartnerAddExpBox = class("CPartnerAddExpBox", CBox)

function CPartnerAddExpBox.ctor(self, obj, boxType)
	CBox.ctor(self, obj)

	self.m_ItemBoxClone = self:NewUI(1, CBox)
	self.m_ItemGrid = self:NewUI(2, CGrid)

	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false))
end

function CPartnerAddExpBox.RefreshAll(self)
	self:RefreshGrid()
end

function CPartnerAddExpBox.RefreshGrid(self)
	local itemBoxList = self.m_ItemGrid:GetChildList()
	local lExpItem = g_PartnerCtrl:GetPartnerExpItem()

	for i,dItem in ipairs(lExpItem) do
		local oBox = nil
		if i > #itemBoxList then
			oBox = self:AddItemBox()
		else
			oBox = itemBoxList[i]
		end
		self:UpdateItemBox(oBox, dItem)
	end
	self.m_ItemGrid:Reposition()
end

function CPartnerAddExpBox.AddItemBox(self)
	local oBox = self.m_ItemBoxClone:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_ExpL = oBox:NewUI(3, CLabel)
	oBox.m_AmountL = oBox:NewUI(4, CLabel)
	oBox.m_BgSpr = oBox:NewUI(5, CSprite)
	oBox.m_ItemBgSpr = oBox:NewUI(6, CSprite)

	oBox:SetActive(true)
	oBox.m_ItemBgSpr:AddUIEvent("click", function()
		g_WindowTipCtrl:SetWindowGainItemTip(oBox.m_ItemId)
	end)
	oBox.m_BgSpr:AddUIEvent("click", callback(self, "OnClickAddExp", oBox))
	oBox.m_BgSpr:AddUIEvent("press", callback(self, "OnLongClickAddExp", oBox))
	oBox.m_ItemBgSpr:AddUIEvent("press", callback(self, "OnLongClickAddExp", oBox))
	
	self.m_ItemGrid:AddChild(oBox)
	return oBox
end

function CPartnerAddExpBox.UpdateItemBox(self, oBox, dItem)
	local dExp = data.partnerdata.EXP[dItem.info.id]
	oBox.m_IconSpr:SpriteItemShape(dItem.info.icon)
	oBox.m_NameL:SetText(dItem.info.name)
	oBox.m_AmountL:SetText(dItem.amount)
	oBox.m_ExpL:SetText("伙伴经验"..dExp.expadd)
	oBox.m_ItemId = dItem.info.id
	oBox.m_ItemInfo = dItem.info
	oBox.m_Amount = dItem.amount
end

function CPartnerAddExpBox.RequestAddExp(self, oBox)
	self.m_PartnerInfo = CPartnerMainView:GetView():GetPartnerBoxNodeInfo()
	self.m_PartnerSData = g_PartnerCtrl:GetRecruitPartnerDataByID(self.m_PartnerInfo.id)

	local amount = g_ItemCtrl:GetBagItemAmountBySid(oBox.m_ItemId)
	if amount < 1 then
		local tipStr = string.gsub(DataTools.GetPartnerTextInfo(1001).content, "#item", oBox.m_ItemInfo.name)
		g_NotifyCtrl:FloatMsg(tipStr)
		return false
	end
	local expInfo = data.upgradedata.DATA[self.m_PartnerSData.grade + 1]
	local curExp = g_PartnerCtrl:GetPartnerCurExp(self.m_PartnerSData.sid)
	if (self.m_PartnerSData.grade == g_AttrCtrl.grade and curExp >= expInfo.partner_exp) or self.m_PartnerSData.grade > g_AttrCtrl.grade then
		local tipStr = DataTools.GetPartnerTextInfo(1002).content
		g_NotifyCtrl:FloatMsg(tipStr)
		return false
	end
	local function upgrade()
		local itemList = g_ItemCtrl:GetBagItemListBySid(oBox.m_ItemId)
		if itemList and #itemList > 0 then
			local svrItemID = itemList[1]:GetSValueByKey("id")
			netpartner.C2GSUseUpgradeProp(self.m_PartnerSData.id, svrItemID)
			if g_WarCtrl:IsWar() then
				g_NotifyCtrl:FloatMsg("战斗结束后生效")
			end
		end
	end
	local expState = DataTools.GetPartnerExpInfo(oBox.m_ItemId).expadd > (expInfo.partner_exp - curExp)
	if self.m_PartnerSData.grade == g_AttrCtrl.grade and curExp < expInfo.partner_exp and expState then
		local args = {
			msg = DataTools.GetPartnerTextInfo(1010).content,
			title = "伙伴升级", 
			okCallback = function()
				upgrade()
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
		return false
	else
		upgrade()
	end
	return true
end

function CPartnerAddExpBox.OnClickAddExp(self, oBox)
	self:RequestAddExp(oBox)
end

function CPartnerAddExpBox.OnLongClickAddExp(self, oBox)
	self.m_IsRequest = not self.m_IsRequest 
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	local function progress()
		if not self.m_IsRequest then
			return false
		end
		return self:RequestAddExp(oBox)
	end
	self.m_Timer = Utils.AddTimer(progress, 0.1, 0.5)
end

return CPartnerAddExpBox