local CMarryComfirmView = class("CMarryComfirmView", CViewBase)

function CMarryComfirmView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Marry/MarryComfirmView.prefab", cb)
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
    self.m_Timer = nil
    self.m_WaitTimer = nil
    self.m_LeftTime = 0
end

function CMarryComfirmView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_AllBtn = self:NewUI(2, CButton)
    self.m_HalfBtn = self:NewUI(3, CButton)
    self.m_ActorTex = self:NewUI(4, CActorTexture)
    self.m_RingSpr = self:NewUI(5, CSprite)
    self.m_TimeL = self:NewUI(6, CLabel)
    self.m_DescL = self:NewUI(7, CLabel)
    self.m_MarryTypeL = self:NewUI(8, CLabel)
    self.m_MarryCostL = self:NewUI(9, CLabel)
    self.m_BotDescL = self:NewUI(10, CLabel)
    self.m_DescNode = self:NewUI(11, CObject)
    self.m_WaitSpr = self:NewUI(12, CSprite)
    self.m_RingL = self:NewUI(13, CLabel)
    self.m_TitleL = self:NewUI(14, CLabel)
    self.m_WaitL = self:NewUI(15, CLabel)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_AllBtn:AddUIEvent("click", callback(self, "OnClickAll"))
    self.m_HalfBtn:AddUIEvent("click", callback(self, "OnClickHalf"))
    g_MarryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMarryCtrl"))
    self.m_BotDescL:SetActive(false)
    self.m_WaitSpr:SetActive(false)

    self:InitContent()
end

function CMarryComfirmView.OnMarryCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Engage.Event.CancelMarry then
        self:CloseView()
    end
end

function CMarryComfirmView.InitContent(self)
    local dModel = g_EngageCtrl:GetNpcModelInfo()
    self.m_ActorTex:ChangeShape(dModel)
    local dConfig = DataTools.GetEngageData("TYPE", g_AttrCtrl.engageInfo.etype)
    self.m_DescNode:SetActive(dConfig and true or false)
    local sMarryType = string.format("根据你们的订婚戒指，我们将为你们举行%s", dConfig.wedding_name)
    self.m_MarryTypeL:SetText(sMarryType)
    local sName = g_EngageCtrl:GetTeamParterName()
    self.m_TitleL:SetActive(sName and true or false)
    if sName then
        self.m_TitleL:SetText(string.format("[63432c]你将与[-][1d8e00]%s[-][63432c]结为合法夫妻[-]", sName))
    end
    local sDesc = g_MarryCtrl:GetMarryText(2060)
    self.m_DescL:SetText(sDesc)
    self:RefreshRing(dConfig.type)
    local dMarry = g_MarryCtrl:GetMarryConfig()
    self.m_MarryCostL:SetText(string.format("[63432c]结婚费用为[-][1d8e00]%d万[-]", dMarry.marry_silver/10000))
end

function CMarryComfirmView.RefreshInfo(self, iSec, iMyCost)
    self:RefreshBtns(iMyCost)
    -- self.m_BotDescL:SetActive(iOtherCost and iOtherCost > 0 or false)
    self:AddComfirmTimer(iSec)
end

function CMarryComfirmView.RefreshRing(self, iType)
    if not iType then return end
    local dRing = g_EngageCtrl:GetRingConfig(iType)
    local atlas, icon = dRing.atlas, dRing.icon
    self.m_RingSpr:SetStaticSprite(atlas, icon)
    self.m_RingSpr:AddEffect(dRing.ringEffect, nil, 1)
    local t = {"银", "金", "钻石"}
    local desc = t[dRing.type].."戒指礼包"
    self.m_RingL:SetText(desc)
    self.m_RingL:SetGradientTop(Color.RGBAToColor(dRing.color.top))
    self.m_RingL:SetGradientBottom(Color.RGBAToColor(dRing.color.bottom))
    self.m_RingL:SetEffectColor(Color.RGBAToColor(dRing.color.shadow))
end

function CMarryComfirmView.RefreshBtns(self, iPay)
    local dMarry = g_MarryCtrl:GetMarryConfig()
    local bPay = iPay and iPay > 0 or false
    self.m_AllBtn:SetEnabled(not bPay)
    self.m_HalfBtn:SetEnabled(not bPay)
    self.m_AllBtn:SetBtnGrey(bPay)
    self.m_HalfBtn:SetBtnGrey(bPay)
    if bPay then
        self:ShowWaitLabel()
    end
end

function CMarryComfirmView.ShowWaitLabel(self)
    if g_AttrCtrl.pid ~= g_TeamCtrl.m_LeaderID then
        return
    end
    if self.m_WaitSpr:GetActive() then
        return
    end
    if self.m_WaitTimer then
        Utils.DelTimer(self.m_WaitTimer)
        self.m_WaitTimer = nil
    end
    self.m_WaitSpr:SetActive(true)
    local sWait = "等待对方同意"
    local list = {".", "..", "..."}
    local i = 1
    local update = function()
        self.m_WaitL:SetText(sWait..list[i])
        i = i + 1
        if i > 3 then
            i = 1
        end
        return self.m_WaitL:GetActive()
    end
    self.m_WaitTimer = Utils.AddTimer(update, 0.5, 0)
end

function CMarryComfirmView.AddComfirmTimer(self, iTime)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
    self.m_LeftTime = iTime
    self.m_Timer = Utils.AddTimer(callback(self, "UpdateTimer"), 1, 0)
end

function CMarryComfirmView.UpdateTimer(self)
    self.m_TimeL:SetText(self.m_LeftTime.."S\n后申请超时")
    self.m_LeftTime = self.m_LeftTime - 1
    if self.m_LeftTime < 0 then
        g_NotifyCtrl:FloatMsg("申请已超时，请想好再来。")
        self:CancelClose()
    end
    return self.m_LeftTime >= 0
end

function CMarryComfirmView.PayMarry(self, iFull)
    local bFull = iFull == 1
    local dMarry = g_MarryCtrl:GetMarryConfig()
    local iMoney = dMarry.marry_silver
    if not bFull then
        iMoney = iMoney/2
    end
    if g_AttrCtrl.silver < iMoney then
        g_QuickGetCtrl:CheckLackItemInfo({
            coinlist = {{sid = 1002, amount = iMoney, count = g_AttrCtrl.silver}},
            exchangeCb = function()
                netmarry.C2GSMarryPay(iFull)
            end
        })
        return
    end
    local sMsg
    if bFull then
        sMsg = string.FormatString(g_MarryCtrl:GetMarryText(2062), {count = iMoney/10000}, true)
    else
        sMsg = string.FormatString(g_MarryCtrl:GetMarryText(2061), {count = iMoney/10000}, true)
    end
    local windowConfirmInfo = {
        color = Color.white,
        msg = "#D"..sMsg,
        okCallback = function()
            netmarry.C2GSMarryPay(iFull)
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CMarryComfirmView.OnClickAll(self)
    self:PayMarry(1)
end

function CMarryComfirmView.OnClickHalf(self)
    self:PayMarry(0)
end

function CMarryComfirmView.OnClose(self)
    local sMsg = g_MarryCtrl:GetMarryText(2070)
    local windowConfirmInfo = {
        color = Color.white,
        msg = "#D"..sMsg,
        okCallback = callback(self, "CancelClose")
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CMarryComfirmView.CancelClose(self)
    netmarry.C2GSCancelMarry()
    self:CloseView()
end

function CMarryComfirmView.Destroy(self)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
    if self.m_WaitTimer then
        Utils.DelTimer(self.m_WaitTimer)
        self.m_WaitTimer = nil
    end
    CViewBase.Destroy(self)
end

return CMarryComfirmView