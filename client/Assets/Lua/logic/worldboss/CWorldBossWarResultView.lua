local CWorldBossWarResultView = class("CWorldBossWarResultView", CViewBase)

function CWorldBossWarResultView.ctor(self, cb)
    CViewBase.ctor(self, "UI/WorldBoss/WorldBossWarResultView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CWorldBossWarResultView.OnCreateView(self)
    self.m_ComfirmBtn = self:NewUI(1, CButton)
    self.m_DescL = self:NewUI(2, CLabel)
    self.m_BgWinWgt = self:NewUI(3, CWidget)
    self.m_BgLoseWgt = self:NewUI(4, CWidget)
    self.m_ComfirmBtn:AddUIEvent("click", callback(self, "OnClkComfirm"))
end

function CWorldBossWarResultView.SetData(self, pbData)
    local point = pbData.point --获得积分
    local bout = pbData.bout --回合数
    local damage = pbData.damage --总伤害
    local dText = data.worldbossdata.TEXT[1014]
    if not dText then
        self.m_DescL:SetActive(false)
        return
    end
    self.m_DescL:SetActive(true)
    self.m_DescL:SetRichText(string.FormatString(dText.content,
        {
            amount = {[1] = bout, [2] = damage},
            point = "#G"..point.."#n",
        }, true), nil, nil, true)
end

function CWorldBossWarResultView.OnClkComfirm(self)
    nethuodong.C2GSMengzhuMainUI()
    self:OnClose()
end

return CWorldBossWarResultView