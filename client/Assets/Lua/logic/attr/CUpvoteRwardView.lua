local CUpvoteRwardView = class("CUpvoteRwardView", CViewBase)

function CUpvoteRwardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/UpvoteRwardView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
    self.m_Items = {}
end

function CUpvoteRwardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_GridItem = self:NewUI(2, CGrid)
    self.m_Item =  self:NewUI(3, CBox)
	self:InitContent()
end

function CUpvoteRwardView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    self:InitGrid()
end

function CUpvoteRwardView.OnCtrlEvent(self,oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.UpdateReward then 
        self:UpdateReward(oCtrl.m_EventData)
    end 
end

function CUpvoteRwardView.InitGrid(self)
    self.m_GridItem:Clear()
    self.m_Items = {}
    for k,v in pairs(data.upvotedata.DATA) do
        local item = self.m_Item:Clone()
        item:SetActive(true)
        item.name = item:NewUI(1, CLabel)
        item.title = item:NewUI(2, CLabel)
        item.reward = item:NewUI(3, CSprite)
        item.getbtn = item:NewUI(4, CButton)
        item.hint = item:NewUI(5, CLabel)
        item.name:SetText(v.name)      
        if g_AttrCtrl.upvote_amount < v.upvote then 
            --item.getbtn:SetActive(false)
            item.getbtn:SetSpriteName("h7_an_5")
            item.getbtn:SetText("[5C6163FF]领取奖励[-]")
            item.hint:SetActive(true)
            item.hint:SetText("人气不足")
            item.isget = true
        else
            --item.getbtn:SetActive(true)
            item.getbtn:SetSpriteName("h7_an_2")
            item.getbtn:SetText("[EEFFFBFF]领取奖励[-]")
            item.hint:SetText("可以领取奖励")
            item.isget = false
        end
        item.title:SetText(data.titledata.INFO[v.titleid].name)
        item.reward:SetSpriteName(tostring(v.itemid))
        item.getbtn:AddUIEvent("click", callback(self, "GetReward", k))
        self.m_Items[k] = item
        self.m_GridItem:AddChild(item)
    end
    self:UpdateReward()
end

function CUpvoteRwardView.UpdateReward(self, info)
    if info ~= nil and next(info) ~= nil then 
        local item = self.m_Items[info.idx]        
        if info.success == 1 then 
            --item.getbtn:SetActive(false)
            item.getbtn:SetSpriteName("h7_an_5")
            item.getbtn:SetText("[5C6163FF]领取奖励[-]")
            item.hint:SetActive(true)
            item.hint:SetText("已领取")
            item.isget = true
        else
            item.hint:SetText("可以领取奖励")
            --item.getbtn:SetActive(true)
            item.getbtn:SetSpriteName("h7_an_2")
            item.getbtn:SetText("[EEFFFBFF]领取奖励[-]")            
            item.isget = false
        end
        table.insert(g_AttrCtrl.upvoteRewardInfo, info) 
        return 
    end 
    for k,v in pairs(g_AttrCtrl.upvoteRewardInfo) do
        local item = self.m_Items[v.idx]
        if v.success == 1 then 
            --item.getbtn:SetActive(false)
            item.getbtn:SetSpriteName("h7_an_5")
            item.getbtn:SetText("[5C6163FF]领取奖励[-]")
            item.hint:SetActive(true)
            item.hint:SetText("已领取")
            item.isget = true
        else
            item.hint:SetText("可以领取奖励")
            item.getbtn:SetText("[EEFFFBFF]领取奖励[-]")
            item.getbtn:SetSpriteName("h7_an_2")
            item.isget = false
        end 
    end
end

function CUpvoteRwardView.GetReward(self, id)
    if g_AttrCtrl.upvote_amount < data.upvotedata.DATA[id].upvote then 
        g_NotifyCtrl:FloatMsg("人气不足!")
        return
    end 
    if  self.m_Items[id].isget == true then 
        g_NotifyCtrl:FloatMsg("您已经领取过了哦!")
        return
    end 
    netplayer.C2GSUpvoteReward(id)
end

return CUpvoteRwardView