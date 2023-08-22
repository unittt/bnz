local CMarryAcceptView = class("CMarryAcceptView", CViewBase)

function CMarryAcceptView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Marry/MarryAcceptView.prefab", cb)
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
    self.m_Timer = nil
    self.m_LeftTime = 0
end

function CMarryAcceptView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_YesBtn = self:NewUI(2, CButton)
    self.m_NoBtn = self:NewUI(3, CButton)
    self.m_ActorTex = self:NewUI(4, CActorTexture)
    self.m_RingSpr = self:NewUI(5, CSprite)
    self.m_TimeL = self:NewUI(6, CLabel)
    self.m_TitleL = self:NewUI(7, CLabel)
    self.m_MarryL = self:NewUI(8, CLabel)
    self.m_PayL = self:NewUI(9, CLabel)
    self.m_BotDescL = self:NewUI(10, CLabel)
    self.m_RingL = self:NewUI(11, CLabel)
    self.m_MarryTypeL = self:NewUI(12, CLabel)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_YesBtn:AddUIEvent("click", callback(self, "OnClickYes"))
    self.m_NoBtn:AddUIEvent("click", callback(self, "OnClickNo"))
    g_MarryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMarryCtrl"))
    self.m_Full = 1

    self:InitContent()
end

function CMarryAcceptView.OnMarryCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Engage.Event.CancelMarry then
        self:CloseView()
    end
end

function CMarryAcceptView.InitContent(self)
    local dModel = g_EngageCtrl:GetNpcModelInfo()
    self.m_ActorTex:ChangeShape(dModel)
    local dConfig = DataTools.GetEngageData("TYPE", g_AttrCtrl.engageInfo.etype)
    local sMarryType = string.format("根据你们的订婚戒指，我们将为你们举行%s", dConfig.wedding_name)
    self.m_MarryTypeL:SetText(sMarryType)
    self:RefreshRing(dConfig.type)

    local sName = g_EngageCtrl:GetTeamParterName()
    self.m_TitleL:SetActive(sName and true or false)
    if sName then
        -- self.m_TitleL:SetText(string.format("[63432c]你准备好和[-][1d8e00]%s[-][63432c]结婚了吗[-]", sName))
        self.m_MarryL:SetText(string.format("[1d8e00]%s[-][63432c]想和你结婚\n你是否愿意？", sName))
    end
    self.m_PayL:SetActive(false)
end

function CMarryAcceptView.RefreshInfo(self, iSec, iFull)
    self.m_Full = iFull
    if iFull == 1 then
        local dMarry = g_MarryCtrl:GetMarryConfig()
        self.m_PayL:SetText((dMarry.marry_silver/10000/2).."万")
    end
    self.m_PayL:SetActive(iFull == 1)
    self:AddComfirmTimer(iSec)
end

function CMarryAcceptView.RefreshRing(self, iType)
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

function CMarryAcceptView.AddComfirmTimer(self, iTime)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
    self.m_LeftTime = iTime
    self.m_Timer = Utils.AddTimer(callback(self, "UpdateTimer"), 1, 0)
end

function CMarryAcceptView.UpdateTimer(self)
    self.m_TimeL:SetText(self.m_LeftTime.."S\n后申请超时")
    self.m_LeftTime = self.m_LeftTime - 1
    if self.m_LeftTime < 0 then
        self:RefuseClose()
    end
    return self.m_LeftTime >= 0
end

function CMarryAcceptView.OnAcceptMarry(self, iFlag, bFull, iMoney)
    if not bFull then
        if not iMoney then
            iMoney = dMarry.marry_silver/2
        end
        if g_AttrCtrl.silver < iMoney then
            g_QuickGetCtrl:CheckLackItemInfo({
                coinlist = {{sid = 1002, amount = iMoney, count = g_AttrCtrl.silver}},
                exchangeCb = function()
                    netmarry.C2GSMarryConfirm(iFlag)
                end
            })
            return
        end
    end
    netmarry.C2GSMarryConfirm(iFlag)
end

function CMarryAcceptView.ComfirmMarry(self, iFlag)
    local bFull = self.m_Full == 2
    if iFlag == 1 then
        local sMsg
        local dMarry = g_MarryCtrl:GetMarryConfig()
        local iMoney = dMarry.marry_silver/2
        local sName = g_EngageCtrl:GetTeamParterName()
        if bFull then
            sMsg = string.FormatString(g_MarryCtrl:GetMarryText(2069), {role = sName}, true)
        else
            sMsg = string.FormatString(g_MarryCtrl:GetMarryText(2068), {count = (iMoney/10000).."万", role = sName}, true)
        end
        local windowConfirmInfo = {
            color = Color.white,
            msg = "#D"..sMsg,
            okCallback = callback(self, "OnAcceptMarry", iFlag, bFull, iMoney)
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    else
        netmarry.C2GSMarryConfirm(iFlag)
        self:RefuseClose()     
    end
end

function CMarryAcceptView.OnClickYes(self)
    self:ComfirmMarry(1)
end

function CMarryAcceptView.OnClickNo(self)
    self:ComfirmMarry(0)
end

function CMarryAcceptView.OnClose(self)
    local sMsg = g_MarryCtrl:GetMarryText(2071)
    local windowConfirmInfo = {
        color = Color.white,
        msg = "#D"..sMsg,
        okCallback = callback(self, "RefuseClose")
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CMarryAcceptView.RefuseClose(self)
    netmarry.C2GSMarryConfirm(0)
    self:CloseView()
end

function CMarryAcceptView.Destroy(self)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
    CViewBase.Destroy(self)
end

return CMarryAcceptView