local CMarrySharedView = class("CMarrySharedView", CViewBase)

function CMarrySharedView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Marry/MarrySharedView.prefab", cb)

    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CMarrySharedView.OnCreateView(self)
    self.m_TitleL = self:NewUI(1, CLabel)
    self.m_CloseBtn = self:NewUI(2, CButton)
    self.m_ScreenShotTex = self:NewUI(3, CTexture)
    self.m_ShareObj = self:NewUI(4, CObject)
    self.m_CloseBtn2 = self:NewUI(5, CButton)
    self.m_WestObj = self:NewUI(6, CObject)
    self.m_ChinaObj = self:NewUI(7, CObject)
    self.m_GroomName = self:NewUI(8, CLabel)
    self.m_BrideName = self:NewUI(9, CLabel)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_CloseBtn2:AddUIEvent("click", callback(self, "OnClose"))
    self.m_GroomName:SetText(g_MarryCtrl:GetProtagonistName(1))
    self.m_BrideName:SetText(g_MarryCtrl:GetProtagonistName(2))
    self:SetMarryType()
    self:SetActive(false)
end

function CMarrySharedView.SetMarryType(self)
    local bWest = false--g_MarryCtrl:GetMarryType() == 3
    self.m_WestObj:SetActive(bWest)
    self.m_ChinaObj:SetActive(not bWest)
    if bWest then
        self.m_ScreenShotTex:SetLocalPos(Vector3(4,8,0))
    else
        -- self.m_ScreenShotTex:SetLocalPos(Vector3(0,-33,0))
    end
    self:SetActive(true)
end

function CMarrySharedView.SetMarryTexture(self)
    local width, height = self:GetTextureSize()
    local key = g_MarryCtrl:GetMyWeddingPicKey() --self:GetMyTextureKey()
    if not key then
        self:OnClose()
        return
    end
    local oTex = g_MarryCtrl:GetLocalWeddingTexture(key, width, height)
    if oTex then
        self.m_ScreenShotTex:SetMainTexture(oTex)
        self:SetActive(true)
    else
        g_MarryCtrl:FetchWeddingTexture(key, function(oTex)
            if Utils.IsNil(self) then
                return
            end
            self.m_ScreenShotTex:SetMainTexture(oTex)
            self:SetActive(true)
        end)
    end
end

function CMarrySharedView.ScreenShot(self)
    local oCam = g_CameraCtrl:GetMainCamera()
    local width, height = self:GetTextureSize()
    local key = g_MarryCtrl:GetMyWeddingPicKey() --self:GetMyTextureKey()
    if not key then return end
    local shotTex = Utils.ScreenShoot(oCam, width, height)
    self:UIScreenShot(shotTex)

    local oTex2D = UnityEngine.Texture2D.New(width, height)
    local oRt = UnityEngine.RenderTexture.active
    UnityEngine.RenderTexture.active = shotTex
    oTex2D:ReadPixels(UnityEngine.Rect.New(0,0,width,height),0,0)
    oTex2D:Apply()
    UnityEngine.RenderTexture.active = oRt
    self.m_ScreenShotTex:SetMainTexture(oTex2D)
    self:SetActive(true)

    -- Utils.AddTimer(function()
        -- if Utils.IsNil(self) then return end
    g_MarryCtrl:SaveLocalWeddingTexture(oTex2D, key, true)
    g_MarryCtrl:PushWeddingTexture(key)
    -- end, 0, 0)
end

function CMarrySharedView.UIScreenShot(self, oRenderTex)
    local oCam = g_CameraCtrl:GetUICamera()
    local effMask = UnityEngine.LayerMask.GetMask("TransparentFX")
    local originMask = oCam:GetCullingMask()
    oCam:SetCullingMask(effMask)
    oCam:SetTargetTexture(oRenderTex)
    oCam:Render()
    oCam:SetTargetTexture(nil)
    oCam:SetCullingMask(originMask)
end

function CMarrySharedView.GetTextureSize(self)
    local height = math.min(UnityEngine.Screen.height, 768)
    local texW, texH = self.m_ScreenShotTex:GetSize()
    local width = height * texW/texH
    return width, height
end

function CMarrySharedView.GetMyTextureKey(self)
    if not self.m_MyTexKey then
        self.m_MyTexKey = g_AttrCtrl.pid.."Wedding"
    end
    return self.m_MyTexKey
end

function CMarrySharedView.CloseView(self)
    if g_MarryPlotCtrl:IsPlayingWeddingPlot() then
        return
    end
    CViewBase.CloseView(self)
end

return CMarrySharedView