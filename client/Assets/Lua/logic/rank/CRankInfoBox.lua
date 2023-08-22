local CRankInfoBox = class("CRankInfoBox", CBox)

function CRankInfoBox.ctor(self, obj, cb)
    CBox.ctor(self, obj)   
    self.m_HeadList = {}
    self.m_ItemList = {}
    self.m_HeadText = self:NewUI(1, CLabel)
    self.m_ScrollView = self:NewUI(2, CScrollView)
    self.m_GridItem = self:NewUI(3, CGrid)
    self.m_ItemClone = self:NewUI(4, CBox)
    self.m_TitlBox = self:NewUI(6, CLabel)
    self.m_CurSubId = nil
    self.m_CurInfo = {}
    self.m_OldTime = 0   
    self.m_RankList = {
        [101]={"sort","name","school","grade"},
        [102]={"sort","name","school","upvote"},
        [106]={"sort","name","touxian","school","score"},
        [107]={"sort","name","touxian","school","score"},
        [108]={"sort","name","ownername","score"},
        [109]={"sort","name","school","friend_degree"},
        [115]={"sort","name","school","grade","point"},
        [116]={"sort","orgname","name","orglv","prestige"},
        [117]={"sort","name","school","grade","point"},
        [201]={"sort","name","school","grade"},
        [202]={"sort","name","touxian","school","score"},
        [203]={"sort","name","ownername","score"},
        [204]={"sort","orgname","name","orglv","prestige"},
        [205]={"sort","name", "orgname", "score"},
        [206]={"sort","name", "orgname", "score"},
        [207]={"sort","name", "orgname", "score"},
        [208]={"sort","name", "orgname", "score"},
        [209]={"sort","name", "orgname", "score"},
        [210]={"sort","name", "orgname", "score"},
        [211]={"sort","name","school","cnt","score"},
        [212]={"sort","name","cnt","score"},
        [213]={"sort","name","cnt","score"},
        [214]={"sort","name","cnt","score"},
        [215]={"sort","name","cnt","score"},
        [216]={"sort","name","cnt","score"},
        [217]={"sort","name","cnt","score"},
        [218]={"sort","name","cnt","score"},
        [219]={"sort","name","cnt","score"},
        [220]={"sort","name","cnt","score"},
        [221]={"sort","name","grade","score"},
        [222]={"sort","name","usetime"},
        [223]={"sort","name","usetime"},
        [225]={"sort","name","suc_rate","suc_count"},
    }

    self.m_Style = {
        Default = {
            Bg_1 = "h7_di_4",
            Bg_2 = "h7_di_3",
            SelfBg = "h7_di_5",
            FriendColor = "[a64e00]",
            RankColor = "[244B4EFF]",
        },
        EverydayRank = {
            Bg_1 = "h7_1di",
            Bg_2 = "h7_2di",
            SelfBg = "h7_cb",
            FriendColor = "[a64e00]",
            RankColor = "[63432CFF]",
        }
    }

    self.m_CurStyle = self.m_Style.Default
    self.m_Top3 = {"jin","yin","tong"}
    self.m_IsLook = false
    self.m_ClickIndex = 0
    self.m_MemberBoxs = {} --保存,数据与UI粘连在一起
    self.m_CurRank = 0
    self.m_CurPoint = 0

    g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshRankInfo"))
    self.m_ScrollView:AddMoveCheck("down",  self.m_GridItem, callback(self, "ShowNewInfo"))
end

function CRankInfoBox.SetStyle(self, sStyle)
    self.m_CurStyle = self.m_Style[sStyle]
end

function CRankInfoBox.RefreshRankInfo(self, oCtrl)
    if oCtrl.m_EventID == define.Friend.Event.Add or oCtrl.m_EventID == define.Friend.Event.Del then
        local lPidList = oCtrl.m_EventData
        local dFriendPid = {}
        for _, iPid in ipairs(lPidList) do
            dFriendPid[iPid] = true
        end

        for i,item in ipairs(self.m_MemberBoxs) do
            if item:GetActive() and item.m_Pid and dFriendPid[item.m_Pid] then
                self:RefreshNameColor(item, oCtrl.m_EventID)
            end
        end
    end
end

function CRankInfoBox.RefreshNameColor(self, item, eventID)
    -- body
    local text = ""
    if  eventID ==  define.Friend.Event.Add then
        text = self.m_CurStyle.FriendColor..item.data.name.."[-]"
    elseif eventID ==define.Friend.Event.Del then
        text = self.m_CurStyle.RankColor..item.data.name.."[-]"
    end
    item.namelab:SetText(text)

end

function CRankInfoBox.InitInfo(self, subid, info, myrank, page, cb)
    --table.print(info,"----初始化榜单InitInfo---")
    if self.m_CurSubId == subid then
        --self:UpdateInfo(info)
        return
    end
    self:SetStartPosX()
    self.m_Callback = cb
    self.m_CurSubId = subid
    self.m_RankData = data.rankdata.INFO[subid]
    self.m_CurInfo = info
    self.m_MyRank = myrank
    self.m_CurPage = page
    self.m_TitleReward = data.rankdata.REWARD[subid]
    self:Clear()
    self.m_TitlBox:SetActive(false)
    self:SetHeadInfo(subid)
    self:InitGrid(info,subid)
end

function CRankInfoBox.Clear(self)
    for i = 2, #self.m_HeadList do
       self.m_HeadList[i]:Destroy()
    end
    self.m_HeadList = {}
    self.m_GridItem:Clear()
    for k, v in pairs(self.m_ItemList) do
        for j, c in pairs(v) do
            c:Destroy()
        end
    end
     self.m_ItemList = {}
end

function CRankInfoBox.SetHeadInfo(self, subid)
    local head = nil
    local pos = self.m_HeadText:GetPos()
    local pos2 = Vector3(self.m_StartPosX, 0, 0)
    local widthList = self.m_RankData.width
    local pos2 = self.m_GridItem:TransformPoint(pos2)
    pos.x = pos2.x
    local localPos = self.m_HeadText:GetParent():InverseTransformPoint(pos)
    for k, v in ipairs(self.m_RankData.head) do
        local width = 0
        if next(self.m_HeadList) == nil then
            head = self.m_HeadText
        else
            head = self.m_HeadText:Clone()
            if k == 2 then
                width = 51 + widthList[k]/2
            else
                width = (widthList[k-1]+widthList[k])/2
            end
            head:SetParent(self.m_HeadText:GetParent())
            localPos.x = localPos.x + width
        end
        head.m_UIWidget:SetAnchor(nil,0,0,0,0)
        head:SetLocalPos(localPos)
        head.width = width
        head:SetActive(true)
        head:SetText(v)
        table.insert(self.m_HeadList, head)
    end
end

function CRankInfoBox.InitGrid(self, info, subid)
    if self.m_CurPage <= 1 then
        self.m_CurRank = 0 --三界斗法 idx == 115需要排名合并,不直接使用服务器排名
        self.m_CurPoint = -1
        self.m_ScrollView:ResetPosition()
    end
    self.m_ItemList = {}
    
    local iRewardNum = 0
    if self.m_TitleReward then
        iRewardNum = #self.m_TitleReward.title_list
    end

    self.m_MemberBoxs = {}
    for k,v in pairs(info) do
        if self.m_GridItem:GetCount() >= self.m_RankData.count then 
            return
        end

        local item = self.m_ItemClone:Clone()
        item.sortlab = item:NewUI(2, CLabel)
        self.m_GridItem:AddChild(item)
        item:SetGroup(self.m_GridItem:GetInstanceID())

        table.insert(self.m_MemberBoxs, item)
        if not item.m_BgSprite then
            item.m_BgSprite = item:NewUI(10, CSprite)
        end
        if math.floor(k/2) < k/2 then
            item.m_BgSprite:SetSpriteName(self.m_CurStyle.Bg_1)
        else
            item.m_BgSprite:SetSpriteName(self.m_CurStyle.Bg_2)
        end
        if v.pid then
            item.m_Pid =v.pid
        end
        item.data = v 

        if not item.m_Title then
            item.m_Title = item:NewUI(11, CSprite)
        end
        item.m_Title:SetActive(false)
        if not item.m_DiSpr then
            item.m_DiSpr = item:NewUI(12, CSprite)
        end
        item:SetActive(true)
        self:CheckPromote(item, v.rank_shift)
        if self.m_CurSubId == 115 then
            if v.point < self.m_CurPoint or self.m_CurPoint == -1 then
                self.m_CurPoint = v.point
                self.m_CurRank = self.m_CurRank + 1
            end
            if self.m_CurPage == 1 then
                self:CheckTop3(self.m_CurRank, item)
            end
        else
            if k <= 3 and self.m_CurPage == 1 then
                self:CheckTop3(k, item)
            end
        end
        
        local count = self.m_GridItem:GetCount()
        item.m_SchoolSprite = item:NewUI(7, CSprite)
    
        if not table.index(g_RankCtrl.m_SummonRankList, subid) then
           item.m_SchoolSprite:SetSpriteName(tostring(v.school))
           item:AddUIEvent("click", callback(self, "ShowPlayerInfo", v.pid)) 
        else
            item.m_SchoolSprite:SetSpriteName("")
            item:AddUIEvent("click", callback(self, "ShowPlayerInfo", count)) 
        end
        self.m_ItemList[count] = {}

        if #self.m_RankList[self.m_CurSubId] < 5 then
           item:NewUI(6, CLabel):SetActive(false)
        end

        if #self.m_RankList[self.m_CurSubId] < 4 then
           item:NewUI(5, CLabel):SetActive(false)
        end

        if self.m_Top3[count] and iRewardNum >= k then
           item.m_Title:SetSpriteName(self.m_Top3[count])
           item.m_Title:SetActive(true)
           item.m_Title:AddUIEvent("click", callback(self, "OnTitle",count))
           g_UITouchCtrl:TouchOutDetect(item.m_Title, callback(self, "OnTouchOutDetect", count))
        end
        -- 综合实力 106  [106]={"sort","name","touxian","school","score"}
        -- 角色等级 101  [101]={"sort","name","school","grade"}
        -- 人物     107  [107]={"sort","name","touxian","school","score"}
        -- 宠物     108  [108]={"sort","name","ownername","score"},
        -- subid
        local pos = nil
        for j,c in ipairs(self.m_RankList[self.m_CurSubId]) do
            -- printc(self.m_HeadList[j]:GetLocalPos())
            local width = self.m_HeadList[j].width
            local label = item:NewUI(j+1, CLabel)
            label.m_UIWidget:SetAnchor(nil,0,0,0,0)
            label:SetOverflow(enum.UILabel.Overflow.ResizeFreely)
            if j == 1 then
                pos = label:GetLocalPos()
                pos.x = self.m_StartPosX
            else
                pos.x = pos.x + width
            end
            label:SetLocalPos(pos)
            local text = ""
            if c == "school" then
                text = v[c] and data.schooldata.DATA[v[c]].name or ""
            elseif c == "sort" then
                text = count
            elseif c == "time" then 
                text = ""   
            elseif c == "name" then
                item.namelab = label
                text = v[c] or ""
                if g_AttrCtrl.pid == v.pid then
                    item.m_DiSpr:SetActive(true)
                    item.m_DiSpr:SetSpriteName(self.m_CurStyle.SelfBg)
                end
                local bIsFriend = g_FriendCtrl:IsMyFriend(v.pid)
                if bIsFriend then
                    text = self.m_CurStyle.FriendColor..text.."[-]"
                end
            elseif c == "touxian" then
                if v.touxian ~= 0 then
                    text = v[c] and data.touxiandata.DATA[v[c]].name or "无"
                else
                    text = "无"
                end
            elseif c == "usetime" then
                text = g_TimeCtrl:GetLeftTimeString(v[c] or 0)
            else
                text = v[c] or ""
            end 
            
            if self.m_CurSubId == 115 and j == 1 then
                text = self.m_CurStyle.RankColor..self.m_CurRank.."[-]" 
                label:SetText(text)
            else
                text = self.m_CurStyle.RankColor..text.."[-]" 
                label:SetText(text)
            end

            if self.m_CurSubId == 225 and c == "suc_rate" then
                text = self.m_CurStyle.RankColor..text.."%".."[-]" 
                label:SetText(text)
            end
            self.m_ItemList[count][c] = label      
        end   
    end

    self.m_ScrollView:SetCullContent(self.m_GridItem, callback(self, "ShowNewInfo"), self.m_GridItem:GetCount())
end

function CRankInfoBox.OnTouchOutDetect(self, count)
    self.m_TitlBox:SetActive(false)
    if self.m_ClickIndex == count then
       self.m_IsLook = false
    end
end

function CRankInfoBox.CheckTop3(self, index, item)
    local icon = item:NewUI(8, CSprite)
    if item.sortlab and index <= 3 then
        item.sortlab:SetActive(false)
    end
    local pos = icon:GetLocalPos()
    pos.x = self.m_StartPosX
    icon:SetLocalPos(pos)
    icon:SetActive(true)
    icon:SetSpriteName("h7_no"..index)

end

function CRankInfoBox.SetStartPosX(self)
    local x = nil
    if self.m_CurSubId == 101 or self.m_CurSubId ==108 then
        x = 66.5
    elseif self.m_CurSubId == 115 then
        x = 54.8
    elseif self.m_CurSubId == 109 then
        x = 64.5
    end
    if x then
        self.m_StartPosX = x
    else
        local obj = self.m_ItemClone:NewUI(8, CSprite)
        self.m_StartPosX = obj:GetLocalPos().x
    end
end

function CRankInfoBox.CheckPromote(self, item, info)
    local text = ""
    local icon = ""
    if info > self.m_RankData.count then 
        text = ""
        icon = "h7_bq_1"
    elseif info < 0 then 
        text = math.abs(info)
        icon = "h7_sheng"
    elseif info > 0 then
        text = info
        icon = "h7_jiang"
    end
    if icon == "" then
        item:NewUI(9, CSprite):SetActive(false)
    else
        item:NewUI(9, CSprite):SetSpriteName(icon)
        item:NewUI(1, CLabel):SetText(text)
    end
   
end

function CRankInfoBox.UpdateInfo(self, info)
    if next(self.m_ItemList) == nil then
        return
    end
    for k,v in pairs(info) do
        for j,c in pairs(self.m_RankList[self.m_CurSubId]) do
            local text = nil
            if c == "school" then
                text = data.schooldata.DATA[v[c]].name
            elseif c == "sort" then
                text = k   
            else
                text = v[c]         
            end
        end    
    end
end

function CRankInfoBox.AddItemInfo(self, info, page, subid)
    if self.m_CurSubId ~= subid then
        return
    end
    self.m_CurInfo = info
    self.m_CurPage = page
    if self.m_GridItem:GetCount() >= self.m_RankData.count or info == nil or next(info) == nil then 
        return
    end
    self:InitGrid(info,subid)
    self.m_GridItem:Reposition()
end

function CRankInfoBox.ShowNewInfo(self)
     if self.m_OldTime == 0 or g_TimeCtrl:GetTimeS() - self.m_OldTime > 0.2 then        
        self.m_OldTime = g_TimeCtrl:GetTimeS() 
        if self.m_Callback then
            self.m_Callback()
        end    
    end
end

function CRankInfoBox.ShowPlayerInfo(self, pid)
    if not table.index(g_RankCtrl.m_SummonRankList, self.m_CurSubId) then 
        netplayer.C2GSGetPlayerInfo(pid)
    else
        netrank.C2GSGetRankSumInfo(pid, self.m_CurSubId)
    end
end

function CRankInfoBox.OnTitle(self, index)
    --printc("点击称谓：",index,self.m_IsLook)
    if not self.m_IsLook or self.m_ClickIndex ~= index then
        self.m_IsLook = true
        self.m_ClickIndex = index
        self.m_TitlBox:SetActive(true)

        local timestr = data.rankdata.INFO[self.m_CurSubId].titlerefreshtime
        local iTitleId = self.m_TitleReward.title_list[index]
        if iTitleId > 10000 then --大于10000代表是称谓卡，低于10000代表是称谓id
            local dItemData = DataTools.GetItemData(iTitleId)
            iTitleId = tonumber(dItemData.item_formula)
        end
        local name = data.titledata.INFO[iTitleId].name

        self.m_TitlBox:SetText(string.format(timestr, index, name))
    else
        self.m_IsLook = false
        self.m_TitlBox:SetActive(false)
    end
end

return CRankInfoBox
