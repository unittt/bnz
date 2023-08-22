local CSummonWashComfirmView = class("CSummonWashComfirmView", CViewBase)

function CSummonWashComfirmView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Summon/SummonWashComfirmView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Shelter"
end

function CSummonWashComfirmView.OnCreateView(self)
    self.m_SkGrid = self:NewUI(1, CGrid)
    self.m_MsgL = self:NewUI(2, CLabel)
    self.m_CloseBtn = self:NewUI(3, CButton)
    self.m_CancelBtn = self:NewUI(4, CButton)
    self.m_OkBtn = self:NewUI(5, CButton)
    self.m_SkItemBox = self:NewUI(6, CSummonSkillItemBox)
    self.m_SkItemBox:SetActive(false)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_OkBtn:AddUIEvent("click", callback(self, "OnComfirm"))
    self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CSummonWashComfirmView.SetSummonId(self, iSummonId)
    self.m_SummonId = iSummonId
    local dSummon = g_SummonCtrl:GetSummon(iSummonId)
    if not dSummon then
        printc("找不到宠物 -------------- ", iSummonId)
        self:OnClose()
        return
    end
    local dSummonConfig = SummonDataTool.GetSummonInfo(dSummon.typeid)
    self.m_MsgL:SetText(string.format("再进行一次宠物洗练，你将获得满技能的%s", dSummonConfig.name))
    local skList = SummonDataTool.GetConfigSkillInfo(dSummonConfig)
    self:SetSkills(skList)
end

function CSummonWashComfirmView.SetSkills(self, info)
    for i, v in ipairs(info) do
        local oBox = self.m_SkGrid:GetChild(i)
        if not oBox then
            oBox = self:CreateSkItem()
        end
        v.sure = false
        oBox:SetActive(true)
        oBox:SetInfo(v)
    end
end

function CSummonWashComfirmView.CreateSkItem(self)
    local oItem = self.m_SkItemBox:Clone()
    oItem:SetGroup(self.m_SkGrid:GetInstanceID())
    oItem:SetActive(true)
    self.m_SkGrid:AddChild(oItem)
    return oItem
end

function CSummonWashComfirmView.OnComfirm(self)
    local iQuick = g_SummonCtrl.m_IsQuickWash and 1 or nil
    g_SummonCtrl.m_ShowWashEff = true
    netsummon.C2GSWashSummon(self.m_SummonId, iQuick)
    self:OnClose()
end

return CSummonWashComfirmView