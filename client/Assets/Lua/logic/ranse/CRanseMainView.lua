local CRanseMainView = class("CRanseMainView", CViewBase)

function CRanseMainView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Ranse/RanseMainView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"	

end

function CRanseMainView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_BtnGrid = self:NewUI(2, CTabGrid)
    self.m_WaiGuanTitle = self:NewUI(3, CSprite)
    self.m_RanseTitle = self:NewUI(4, CSprite)
    self.m_WaiGuanPart = self:NewPage(5, CWaiGuanPart)
    self.m_RansePart = self:NewPage(6, CRansePart)
    self:InitContent()

end

function CRanseMainView.InitContent(self)

    self.m_BtnGrid:InitChild(function(obj, idx)
        local oBtn = CButton.New(obj, false)
        oBtn:SetGroup(self:GetInstanceID())
        return oBtn
    end)
    self.m_WaiGuanBtn = self.m_BtnGrid:GetChild(1)
    self.m_RanseBtn = self.m_BtnGrid:GetChild(2)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

    self.m_TitleIcon = {
        [1] = self.m_WaiGuanTitle,
        [2] = self.m_RanseTitle,
    }
    for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
        oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
    end

    self:ShowSubPageByIndex(1)

end

function CRanseMainView.ShowSubPageByIndex(self, iIndex)

    for k, v in ipairs(self.m_TitleIcon) do 
        if k == iIndex then 
            v:SetActive(true)
        else
            v:SetActive(false)
        end 
    end 
    local oTab = self.m_BtnGrid:GetChild(iIndex)
    oTab:SetSelected(true)
    CGameObjContainer.ShowSubPageByIndex(self, iIndex)

end

function CRanseMainView.ShowWaiGuan(self)

    self:ShowSubPageByIndex(1)

end

function CRanseMainView.ShowRanse(self)
    
    self:ShowSubPageByIndex(2)

end

return CRanseMainView