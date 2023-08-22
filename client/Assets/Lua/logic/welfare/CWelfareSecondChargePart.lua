local CWelfareSecondChargePart = class("CWelfareSecondChargePart", CPageBase)

function CWelfareSecondChargePart.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CWelfareSecondChargePart.OnInitPage(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_ItemBoxClone = self:NewUI(2, CBox)
	self.m_ExtraItemBox = self:NewUI(3, CBox)
	self.m_Btn = self:NewUI(4, CButton)

	self:InitContent()
end

function CWelfareSecondChargePart.InitContent(self)
	--初始化UI数据
	local sKey = "second_gift"
    local dConfig = DataTools.GetWelfareData("SECONDPAY", sKey)
    if not dConfig then return end
    local dRewardInfo = DataTools.GetRewardItems("WELFARE", dConfig.gift)
	self:SetRewardInfo(dRewardInfo)
	self:SetExtraRewardInfo(dRewardInfo[1])

	local iState = g_WelfareCtrl.m_ChargeInfo.second_pay_reward
	if iState == 1 then
		self.m_Btn:SetText("立刻领取")
	end

	self.m_Btn:AddUIEvent("click", callback(self, "OnBtnClick"))
end

function CWelfareSecondChargePart.SetRewardInfo(self, info)
	local dInfo = {}
	for i, v in ipairs(info) do
		if i ~= 1 then 
			table.insert(dInfo, v)
		end
	end

	for i, v in ipairs(dInfo) do
		local oItem = self.m_Grid:GetChild(i)
		if oItem == nil then
			oItem = self.m_ItemBoxClone:Clone()
			oItem:SetActive(true)
			oItem:AddUIEvent("click", callback(self, "OnItemClick", i))
			self.m_Grid:AddChild(oItem)
		end
		self:SetItemBoxInfo(oItem, v)
	end
end

function CWelfareSecondChargePart.SetExtraRewardInfo(self, info)
	local oItem = self.m_ExtraItemBox
	oItem.m_Icon = oItem:NewUI(1, CSprite)
	oItem.m_Quality = oItem:NewUI(2, CSprite)
	oItem.m_Amount = oItem:NewUI(3, CLabel)
	oItem.itemId = info.sid

	oItem:AddUIEvent("click", callback(self, "OnItemClick", 0))

	local itemdata = DataTools.GetItemData(info.sid)
	oItem.m_Icon:SpriteItemShape(itemdata.icon)
	oItem.m_Quality:SetItemQuality(itemdata.quality)
	oItem.m_Amount:SetText(info.amount)
end

function CWelfareSecondChargePart.SetItemBoxInfo(self, oItem, info)
	local oItem = oItem
	oItem.m_Icon = oItem:NewUI(1, CSprite)
	oItem.m_Quality = oItem:NewUI(2, CSprite)
	oItem.m_Amount = oItem:NewUI(3, CLabel)
	oItem.itemId = info.sid

	local itemdata = DataTools.GetItemData(info.sid)
	oItem.m_Icon:SpriteItemShape(itemdata.icon)
	oItem.m_Quality:SetItemQuality(itemdata.quality)
	oItem.m_Amount:SetText(info.amount)
end

function CWelfareSecondChargePart.OnBtnClick(self)
	local state = g_WelfareCtrl:GetChargeItemInfo("second_pay_reward")

    if state == define.WelFare.Status.Unobtainable then
        CNpcShopMainView:ShowView(function(oView)
            oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
        end)
    else
        nethuodong.C2GSRewardSecondPayGift()
    end

    CWelfareView:CloseView()
end

function CWelfareSecondChargePart.OnItemClick(self, i)
	local oItem
	if i == 0 then 
		oItem = self.m_ExtraItemBox
	else
		oItem = self.m_Grid:GetChild(i)
	end
	local config = {widget = oItem}
    g_WindowTipCtrl:SetWindowItemTip(oItem.itemId, config)
end

return CWelfareSecondChargePart