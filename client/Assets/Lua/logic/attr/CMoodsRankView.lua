local CMoodsRankView = class("CMoodsRankView", CViewBase)

function CMoodsRankView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/MoodsRankView.prefab", cb)
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
end

function CMoodsRankView.OnCreateView(self)
	self.m_RankInfo = self:NewUI(1, CRankInfoBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_Hint = self:NewUI(3, CLabel)
	self:InitContent()
end

function CMoodsRankView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CMoodsRankView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.UpdateRankInfo then 
        if next(oCtrl.m_EventData.upvote_rank) ~= nil then
            self.m_RankInfo:AddItemInfo(oCtrl.m_EventData.upvote_rank, oCtrl.m_EventData.page)
            self.m_Page = oCtrl.m_EventData.page
        end
    end 
end

function CMoodsRankView.SetInfo(self, info)
    self.m_Page = info.page
    self.m_Subid = info.idx
    if next(info.upvote_rank) == nil and info.page == 1 then
        self.m_Hint:SetActive(true)
        return
    else
        self.m_Hint:SetActive(false)       
    end
    self.m_RankInfo:InitInfo(info.idx, info.upvote_rank, info.my_rank, info.page, callback(self, "GetUpdateInfo"))
end

function CMoodsRankView.GetUpdateInfo(self)
    g_AttrCtrl:C2GSGetRankInfo(self.m_Subid, self.m_Page + 1)
end

return CMoodsRankView