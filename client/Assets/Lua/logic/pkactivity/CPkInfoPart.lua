local CPkInfoPart = class("CPkInfoPart", CPageBase)


function CPkInfoPart.ctor(self , obj)
    CPageBase.ctor(self,obj)
    self.m_FloorTable = {"一","二","三","四","五","六","七","八","九","十"}
    self.m_Timer = nil
end

function CPkInfoPart.OnInitPage(self)
    self.m_Floor = self:NewUI(1, CLabel)    --层级信息
    self.m_LoseCntL = self:NewUI(2, CLabel)
    -- self.m_RemainTime = self:NewUI(2, CLabel)   --活动剩余时间
    self.m_WinCount = self:NewUI(3, CLabel) --连胜次数
    self.m_Score = self:NewUI(4, CLabel)    --评分
    self.m_Rank = self:NewUI(5, CLabel)     --排名
    self.m_LookBtn = self:NewUI(6, CButton)  --查看排行榜
    self.m_PKInfoObj = self:NewUI(7, CObject)
    self.m_PrepareL = self:NewUI(8, CLabel)
    self.m_MatchTimeL = self:NewUI(9, CLabel)
    self.m_TipsLable  = self:NewUI(10, CLabel)
    self.m_TipBtn = self:NewUI(11, CButton)

    self.m_MatchTimeL:SetActive(false)
    self.m_LookBtn:AddUIEvent("click", callback(self, "OnLookClick"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnTipBtn")) 
    g_PKCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPkEvent"))
    g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
    self:RefreshInfo()
end

--显示层级信息
function CPkInfoPart.RefreshInfo(self)
    local info = g_PKCtrl.m_MyRankInfo
    --table.print(info,"楼层信息:")
    if info then
        local bIsPrepare = info.rank == 0 and info.starttime > 0
        self.m_PKInfoObj:SetActive(not bIsPrepare)
        self.m_PrepareL:SetActive(bIsPrepare)
        if bIsPrepare then
            self.m_PrepareL:SetRichText("活动准备中", nil, nil, true)
            self:RefreshCountdownTime()
            return
        end
        if info.point <= 0 then
           info.rank = 0
        end
        self.m_Rank:SetText("当前排名："..info.rank) -- 当前
        self.m_Score:SetText("当前积分："..info.point)
        self.m_WinCount:SetText("最高连胜："..info.maxwin)
        self.m_LoseCntL:SetText("战败次数："..info.fail)
        self.m_TipsLable:SetText(data.biwutextdata.BIWUTEXT[1030].content) -- 
        -- self:RefreshReaminTime(info.lefttime)      
    end
end

function CPkInfoPart.OnPkEvent(self, oCtrl)
    if oCtrl.m_EventID == define.PkAction.Event.updateInfo then
        self:RefreshInfo()
    elseif oCtrl.m_EventID == define.PkAction.Event.PKMatchCountTime then
        self:RefreshMatchTime()
    end
end

function CPkInfoPart.OnMapEvent(self, oCtrl)
   if oCtrl.m_EventID == define.Map.Event.EnterScene then
      self:RefreshInfo()
   end
end

function CPkInfoPart.RefreshCountdownTime(self)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
    local function update()
        if Utils.IsNil(self) then
            return
        end
        local iLeftTime = g_PKCtrl.m_MyRankInfo.starttime - 1
        if iLeftTime < 0 then
            self:RefreshInfo()
            return
        end
        local sTime = g_TimeCtrl:GetLeftTimeString(iLeftTime)
        local str = data.biwutextdata.BIWUTEXT[1028]
        -- local sText = string.format("请各位大侠做好准备，活动将在#R%s#n后正式开始", sTime)
        local sText = string.format(str.content, sTime)
        self.m_PrepareL:SetRichText(sText, nil, nil, true)
        g_PKCtrl.m_MyRankInfo.starttime = g_PKCtrl.m_MyRankInfo.starttime - 1
        return true
    end
    self.m_Timer = Utils.AddTimer(update, 1, 0)
end

function CPkInfoPart.RefreshMatchTime(self)
    local bIsEndMatch = g_PKCtrl:IsEndMatch()
    local iTime = g_PKCtrl.m_PKMatchLeftTime
    local sText = bIsEndMatch and "活动即将结束，停止匹配" or string.format (data.biwutextdata.BIWUTEXT[1029].content,iTime)


    self.m_MatchTimeL:SetActive(not g_WarCtrl:IsWar() and (iTime > 0 or bIsEndMatch))
    self.m_MatchTimeL:SetRichText(sText, nil, nil, true) --  "距离下次匹配还有"..iTime.."秒" 
end

--刷新剩余时间
function CPkInfoPart.RefreshReaminTime(self,remaintime)
    -- if self.m_Timer then
    --    return
    -- end
    -- local showTime = remaintime
    -- if remaintime then
    --   local update = function() 
    --       if Utils.IsExist(self) then
    --          if remaintime <= 0 and self.m_Timer then
    --             Utils.DelTimer(self.m_Timer)
    --             self.m_Timer = nil
    --             return false
    --          end
    --          if showTime > 2700 then --大于45分钟，即还在准备阶段
    --             self.m_RemainTime:SetText("准备时间："..g_TimeCtrl:GetLeftTime(showTime - 60*45))
    --          else
    --             self.m_RemainTime:SetText("剩余时间："..g_TimeCtrl:GetLeftTime(showTime))
    --          end    
    --          showTime = showTime - 1
    --          return true
    --       end 
    --   end
    --   self.m_Timer = Utils.AddTimer(update,1,0)
    -- end
end

--点击查看排行榜
function CPkInfoPart.OnLookClick(self)
    printc("查看排行榜")
    g_PKCtrl:C2GSBWRank()
end

function CPkInfoPart.OnTipBtn(self)
    -- body
    local id = define.Instruction.Config.Biwu
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

return CPkInfoPart