local CWelfareBigProfitPart = class("CWelfareBigProfitPart", CPageBase)

function CWelfareBigProfitPart.ctor(self,cb)
    CPageBase.ctor(self, cb)

    self.m_BuyButtonLabel = self:NewUI(1,CLabel)
    self.m_TopGetLabel = self:NewUI(2,CLabel)
    self.m_BuyButton = self:NewUI(3,CButton)
    self.m_Grid = self:NewUI(4,CGrid)
    self.m_Item = self:NewUI(5,CBox)
    self.m_FirstItem = self:NewUI(6,CBox)
    self.m_DragWidget = self:NewUI(7,CWidget)
    self.m_BtnRimImg = self:NewUI(8,CSprite)
    self.m_BgPriceSpr = self:NewUI(9,CSprite)
    self.m_BgBackSpr = self:NewUI(10,CSprite)
    self.m_BgTimeL = self:NewUI(11,CLabel)
    self.m_ScrollView = self:NewUI(12,CScrollView)
    self.m_RebateCntL = self:NewUI(13,CLabel)

    self.m_BtnLabelColor = self.m_BuyButtonLabel:GetColor()
    self.m_ItemDict = {}
    self.m_ForceLv = nil -- 强制指定类型(一本万利1/2)
end

function CWelfareBigProfitPart.OnInitPage(self)
    -- self.m_FirstItem:SetActive(false)
    self.m_Item:SetActive(false)
    self.m_CurLv = self:GetChargeLv()    --2指一本万利2
    self:RefreshAll()
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnCtrlEvent"))
end

function CWelfareBigProfitPart.RefreshAll(self)
    self:UpdateGridItems()
    self:RefreshTopPart()
end

function CWelfareBigProfitPart.RefreshTopPart(self)
    self.m_IsPay = g_BigProfitCtrl:IsBigProfitPay(self.m_ForceLv)
    self:SetBuyBtnEnable(not self.m_IsPay)
    self:SetBgInfo()
    self.m_BuyButton:AddUIEvent("click", callback(self,"OnClickBuy"))
end

function CWelfareBigProfitPart.InitFirstGridItem(self, info)
    local iTopId = 1
    self.m_FirstItem.getButton = self.m_FirstItem:NewUI(1, CButton)
    self.m_FirstItem.getMark = self.m_FirstItem:NewUI(2, CSprite)
    self.m_FirstItem.cntLabel = self.m_FirstItem:NewUI(4, CLabel)
    self.m_FirstItem.getBtnLabel = self.m_FirstItem:NewUI(6,CLabel)
    self.m_FirstItem.dragCpn = self.m_FirstItem.getButton:GetComponent(classtype.UIDragScrollView)
    self.m_FirstItem.getButton:AddUIEvent("click", callback(self, "OnClickGet", self.m_FirstItem))
    self.m_FirstItem:SetGroup(self.m_Grid:GetInstanceID())
    self.m_Grid:AddChild(self.m_FirstItem)
end

function CWelfareBigProfitPart.CreateGridItem(self, id, info)
    local oBox = self.m_Item:Clone()
    oBox.getButton = oBox:NewUI(1, CButton)
    oBox.getMark = oBox:NewUI(2, CSprite)
    oBox.lvLabel = oBox:NewUI(4, CLabel)
    oBox.cntLabel = oBox:NewUI(5, CLabel)
    oBox.bottomImg = oBox:NewUI(6, CSprite)
    oBox.getBtnLabel = oBox:NewUI(7, CLabel)
    oBox.dragCpn = oBox.getButton:GetComponent(classtype.UIDragScrollView)
    oBox:SetGroup(self.m_Grid:GetInstanceID())
    if id%2 == 0 then
        oBox.bottomImg:SetSpriteName("h7_2di")
    end
    self.m_Grid:AddChild(oBox)
    oBox.getButton:AddUIEvent("click", callback(self, "OnClickGet", oBox))
    return oBox
end

function CWelfareBigProfitPart.UpdateItemBox(self, oBox, info)
    oBox.openLv = info.grade
    oBox.itemKey = info.key
end

function CWelfareBigProfitPart.UpdateGridItems(self)
    local lConfig = {}
    local iGrade = 60
    self.m_Grid:HideAllChilds()
    self.m_CurLv = self:GetChargeLv()
    for k, info in pairs(DataTools.GetChargeData("BIGPROFIT")) do
        local bInc = false
        if self.m_CurLv == 1 then
            if info.grade <= iGrade and k ~= "grade_gift2_0" then
                bInc = true
            end
        elseif self.m_CurLv == 2 then
            if info.grade > iGrade or k == "grade_gift2_0" then
                bInc = true
            end
        end
        if bInc then
            table.insert(lConfig, info)
        end
    end
    if #lConfig > 1 then
        table.sort(lConfig, function(a, b)
            return a.grade < b.grade
        end)
    end
    for id, info in ipairs(lConfig) do
        local oBox = self.m_Grid:GetChild(id)
        if not oBox then
            if id == 1 then
                self:InitFirstGridItem()
                oBox = self.m_FirstItem
            else
                oBox = self:CreateGridItem(id)
            end
        end
        self:UpdateItemBox(oBox, info)
        local btnState = g_WelfareCtrl:GetChargeItemInfo(info.key)
        oBox.grade = info.grade
        self:UpdateItemBtn(oBox, btnState)
        if oBox.lvLabel then
            oBox.lvLabel:SetText(info.grade .. "级")
        end
        self.m_ItemDict[info.key] = oBox
        oBox.cntLabel:SetRichText(string.ConvertToArt(info.goldcoin))
        oBox:SetActive(true)
    end
    Utils.AddTimer(callback(self.m_ScrollView, "ResetPosition"), 0, 0)
end

function CWelfareBigProfitPart.UpdateItemBtn(self, oItem, state)
    local iGrade = g_AttrCtrl.grade
    if iGrade < oItem.grade then
        state = define.WelFare.Status.Unobtainable
    end
    local bHasGot = state == define.WelFare.Status.Got
    if state == define.WelFare.Status.Unobtainable then
        oItem.getButton:SetEnabled(false)
        oItem.getBtnLabel:SetColor(Color.RGBAToColor("50585B"))
    elseif state == define.WelFare.Status.Get then
        oItem.getButton:SetEnabled(true)
        oItem.getBtnLabel:SetColor(Color.white)
    end
    oItem.getButton:SetActive(not bHasGot)
    oItem.getMark:SetActive(bHasGot)
end

function CWelfareBigProfitPart.UpdateItemBtnByKey(self, key, state)
    local oItem = self.m_ItemDict[key]
    if oItem then
        self:UpdateItemBtn(oItem, state)
    end
end

function CWelfareBigProfitPart.OnClickGet(self, oBox)
    -- printc("on click get ----------- " .. id)
    local iLv = oBox.openLv
    local sType = self.m_CurLv == 1 and "grade_gift1" or "grade_gift2"
    nethuodong.C2GSChargeRewardGradeGift(sType, iLv)
end

function CWelfareBigProfitPart.OnClickBuy(self)
    if not g_OpenSysCtrl:GetOpenSysState("GIFT_GRADE") then
        g_NotifyCtrl:FloatMsg("等级未达到")
        return
    end
    printc("on click buy ------------ ", self.m_ForceLv)
    local iPayid = g_BigProfitCtrl:GetBigProfitPayId(self.m_ForceLv)
    if iPayid and string.len(iPayid) > 0 then
        printc("一本万利充值回调数据信息 ----- ", iPayid)
        g_PayCtrl:Charge(iPayid)
    end
end

function CWelfareBigProfitPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateBigProfitPnl then
        local iGradeLv = self:GetChargeLv()
        if iGradeLv ~= self.m_CurLv then
            self:RefreshAll()
            if not self.m_ForceLv then
                g_BigProfitCtrl:UpdateBigProfitTab()
            end
        elseif oCtrl.m_EventData then
            for _, lChargeInfo in ipairs(oCtrl.m_EventData) do
                self:UpdateItemBtnByKey(lChargeInfo.key, lChargeInfo.val)
            end
        end
        local bPay = g_BigProfitCtrl:IsBigProfitPay(self.m_ForceLv)
        if self.m_IsPay ~= bPay then
            self.m_IsPay = bPay
            self:SetBuyBtnEnable(not bPay)
        end
    end
end

function CWelfareBigProfitPart.SetBuyBtnEnable(self, bEnable)
    do
        self.m_BuyButton:SetActive(bEnable)
        return
    end
    local labelColor = bEnable and self.m_BtnLabelColor or Color.RGBAToColor("50585B")
    self.m_BuyButton:SetEnabled(bEnable)
    self.m_BuyButtonLabel:SetColor(labelColor)
    self.m_BtnRimImg:SetGrey(not bEnable)
end

function CWelfareBigProfitPart.SetBgInfo(self)
    local iGradeLv = self:GetChargeLv()
    local bLvOne = iGradeLv == 1
    self.m_BgBackSpr:SetActive(not bLvOne)
    self.m_RebateCntL:SetActive(bLvOne)
    if bLvOne then
        self.m_BgPriceSpr:SetSpriteName("h7_88")
        -- self.m_BgBackSpr:SetSpriteName("h7_7040")
        self.m_BgTimeL:SetText(string.ConvertToArt(8))
        self.m_RebateCntL:SetText(string.ConvertToArt(5456))
    else
        self.m_BgPriceSpr:SetSpriteName("h7_98")
        self.m_BgBackSpr:SetSpriteName("h7_7840")
        self.m_BgTimeL:SetText(string.ConvertToArt(8))
    end
end

function CWelfareBigProfitPart.GetChargeLv(self)
    if self.m_ForceLv then
        return self.m_ForceLv
    else
        return g_BigProfitCtrl:GetGradePnlLevel()
    end
end

-- 强制显示充值类型
function CWelfareBigProfitPart.ShowForceLv(self, iLv)
    self.m_ForceLv = iLv
    if self.m_ForceLv ~= self.m_CurLv then
        self:RefreshAll()
    end 
end

return CWelfareBigProfitPart