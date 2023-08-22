local CWingShapeBox = class("CWingShapeBox", CBox)

function CWingShapeBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_ActorTex = self:NewUI(1, CActorTexture)
    self.m_NameL = self:NewUI(2, CLabel)
    self.m_ScoreL = self:NewUI(3, CLabel)
    self.m_LevelL = self:NewUI(4, CLabel)
    self.m_StarGrid = self:NewUI(5, CGrid)
    self.m_StarSpr = self:NewUI(6, CSprite)
    self.m_InfoObj = self:NewUI(7, CObject)
    self:InitContent()
end

function CWingShapeBox.InitContent(self)
    self.m_StarSpr:SetActive(false)
    self.m_InfoObj:SetActive(false)
end

function CWingShapeBox.RefreshInfo(self)
    local dModelInfo = table.copy(g_AttrCtrl.model_info)
    local oCtrl = g_WingCtrl
    local bActive = oCtrl:HasActiveWing()
    local dWing = oCtrl:GetShowWingInfo()
    local dConfig = oCtrl:GetCurWingConfig()
    if not bActive then
        dWing = dConfig
    end
    dModelInfo.show_wing = dWing and dWing.wing_id
    dModelInfo.horse = nil
    dModelInfo.rendertexSize = 1.2
    dModelInfo.pos = Vector3(0, -0.83, 3)
    self.m_ActorTex:ChangeShape(dModelInfo)
    self.m_InfoObj:SetActive(bActive)
    self.m_NameL:SetText(dConfig and dConfig.name or "")
    if bActive then
        self.m_ScoreL:SetText(oCtrl.score)
        self.m_LevelL:SetText(oCtrl.level.."阶")
        local iMaxStar = g_WingCtrl:GetMaxStar()
        for i = 1, iMaxStar do
            local o = self.m_StarGrid:GetChild(i)
            if not o then
                o = self.m_StarSpr:Clone()
                self.m_StarGrid:AddChild(o)
            end
            o:SetActive(true)
            o:SetGrey(i > oCtrl.star)
        end
    end
end

return CWingShapeBox