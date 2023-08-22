local CSoccerWorldCupMainView = class("CSoccerWorldCupMainView", CViewBase)

function CSoccerWorldCupMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/WorldCupGuess/WorldCupMainView.prefab", cb)
	
	self.m_ExtendClose = "Black"
end

function CSoccerWorldCupMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_BtnGrid = self:NewUI(2, CTabGrid)
    self.m_GuessPart = self:NewPage(3, CSoccerWorldCupGuessPart)
    self.m_TeamSupportPart = self:NewPage(4, CSoccerTeamSupportPart)

	self:InitContent()
end

function CSoccerWorldCupMainView.Destroy(self)
    CViewBase.Destroy(self)
end

function CSoccerWorldCupMainView.InitContent(self)
	self.m_BtnGrid:InitChild(function(obj, idx)
        local oBtn = CButton.New(obj)
        oBtn:SetGroup(self:GetInstanceID())
        return oBtn
    end)
    
    for i, oTab in ipairs(self.m_BtnGrid:GetChildList()) do
        oTab:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i, true))
    end
    self:ShowSubPageByIndex(1)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CSoccerWorldCupMainView.ShowSubPageByIndex(self, iIndex, bClk)
    local oTab = self.m_BtnGrid:GetChild(iIndex)
    oTab:SetSelected(true)
    CGameObjContainer.ShowSubPageByIndex(self, iIndex)
end

--事件
function CSoccerWorldCupMainView.OnCtrlEvent(self, oCtrl)
	
end


function CSoccerWorldCupMainView.RefreshUI(self)

end


return CSoccerWorldCupMainView