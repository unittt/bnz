local CCardLikeListView = class("CCardLikeListView", CViewBase)

function CCardLikeListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/CardLikeListView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CCardLikeListView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_LikeItemGrid = self:NewUI(2, CGrid)
    self.m_LikeItem = self:NewUI(3, CBox)
    self.m_HintText = self:NewUI(4,CLabel)
	self:BindButtonEvent()
end

function CCardLikeListView.BindButtonEvent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CCardLikeListView.InitGrid(self,data)
    for k,v in pairs(data) do
       local item = self.m_LikeItem:Clone("item")
       item:SetActive(true)
       item:NewUI(1, CSprite):SetSpriteName(tostring(v.model_info.shape))
       item:NewUI(2, CLabel):SetText(v.grade)
       item:NewUI(3, CLabel):SetText(v.name)
       item:AddUIEvent("click",callback(self, "OnCardTips", v.pid))
       self.m_LikeItemGrid:AddChild(item)
    end
end

function CCardLikeListView.SetData(self, data)
    if data == nil then 
        self.m_HintText:SetActive(true)
        return 
    end
    self.m_HintText:SetActive(false) 
    self:InitGrid(data)
end

function CCardLikeListView.OnCardTips(self,pid)
    netplayer.C2GSGetPlayerInfo(pid)
end

return CCardLikeListView

