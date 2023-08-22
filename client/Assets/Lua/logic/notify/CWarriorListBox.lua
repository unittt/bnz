local CWarriorListBox = class("CWarriorListBox", CBox)

function CWarriorListBox.ctor(self, obj)
    CBox.ctor(self, obj)

    self.m_Scroll = self:NewUI(1, CScrollView)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_Box = self:NewUI(3, CBox)
    self.m_BgSprite = self:NewUI(4, CSprite)
    self.m_ContentAnchor = self:NewUI(5, CWidget)
    
    self:SetActive(false)
    self.m_Box:SetActive(false)
    
    g_UITouchCtrl:TouchOutDetect(self.m_BgSprite, callback(self, "SetActive", false))
end

function CWarriorListBox.InitWarriorList(self, warriorIdList)
    if not warriorIdList or #warriorIdList == 0 then
        return
    end
    self:SetTouchPos()
    local maxlen = math.min(4, #warriorIdList)
    local h = 24 + 81 * maxlen
    self.m_BgSprite:SetHeight(h)

    local boxList = self.m_Grid:GetChildList()
    local oBox = nil
    local idx = 1
    for i,v in ipairs(warriorIdList) do
        local oWarrior = g_WarCtrl:GetWarrior(v)
        if oWarrior then
            if idx > #boxList then
                oBox = self.m_Box:Clone()
                oBox.m_Icon = oBox:NewUI(1, CSprite)
                oBox.m_Name = oBox:NewUI(2, CLabel)
                self.m_Grid:AddChild(oBox)
            else
                oBox = boxList[idx]
            end
            oBox:AddUIEvent("click", callback(self, "OnClickWarrior", v))
            local sName = oWarrior:GetName()
            oBox.m_Name:SetText(sName)
            oBox.m_Icon:SpriteAvatar(oWarrior.m_Actor.m_Shape)
            oBox:SetName("Box_" .. sName)
            oBox:SetActive(true)
            idx = idx + 1
        end
    end

    for i=#warriorIdList+1,#boxList do
        oBox = boxList[i]
        if not oBox then
            break
        end
        oBox:SetActive(false)
    end
    self:SetActive(true)
    self.m_Scroll:ResetPosition()
    self.m_BgSprite.m_UIWidget:ResizeCollider()
    UITools.NearTarget(self.m_ContentAnchor, self.m_BgSprite, enum.UIAnchor.Side.Center)
    local function delay()
        self.m_Scroll:ResetPosition()
        return false
    end
    Utils.AddTimer(delay, 0, 0.1) 
end

function CWarriorListBox.SetTouchPos(self)
    local oNGUICamera = g_CameraCtrl:GetNGUICamera()
    local oUICamera = g_CameraCtrl:GetWarUICamera()
    local vTouchPos = oNGUICamera.lastEventPosition
    local vTouchWorldPos = oUICamera:ScreenToWorldPoint(Vector3.New(vTouchPos.x, vTouchPos.y, 0))
    local vTouchLocalPos = self:InverseTransformPoint(vTouchWorldPos)
    self.m_ContentAnchor:SetLocalPos(vTouchLocalPos)
end

function CWarriorListBox.OnClickWarrior(self, iWid)
    self:SetActive(false)
    local oWarrior = g_WarCtrl:GetWarrior(iWid)
    if oWarrior then
        if oWarrior:IsOrderTarget() then
            g_WarOrderCtrl:SetTargetID(iWid)
        elseif oWarrior:IsAlly() then
            g_WarOrderCtrl:SetCurOrderWid(iWid)
        end
    end
end

return CWarriorListBox