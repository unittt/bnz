local CSummonLAttrPart = class("CSummonLAttrPart", CBox)

function CSummonLAttrPart.ctor(self, obj)
    CBox.ctor(self, obj)

    self:InitContent()
end

function CSummonLAttrPart.InitContent(self)
    self.m_SummonNameBtn = self:NewUI(1, CSprite)
    self.m_EquipedBox = self:NewUI(2, CSummonViewEquipBox)
    self.m_SummonInfoBox = self:NewUI(3, CSummonViewBox)
    self.m_FollowBtn = self:NewUI(4, CButton)
    self.m_FightBtn = self:NewUI(5, CButton)
    self.m_FreeBtn = self:NewUI(6, CButton)
    self.m_WareHouseBtn = self:NewUI(7, CSprite)
    self.m_RanseBtn = self:NewUI(8, CSprite)

    self.m_SummonNameBtn:AddUIEvent("click",callback(self,"OpenRenameWindow"))
    self.m_FollowBtn:AddUIEvent("click", callback(self, "OnClickFollow"))
    self.m_FreeBtn:AddUIEvent("click", callback(self, "OnClickFree"))
    self.m_FightBtn:AddUIEvent("click", callback(self, "OnClickFight"))
    self.m_WareHouseBtn:AddUIEvent("click", callback(self, "OnClickWareHouse"))
    self.m_RanseBtn:AddUIEvent("click", callback(self, "OnClickRanse"))
    g_GuideCtrl:AddGuideUI("pet_fight_btn", self.m_FightBtn)
end

function CSummonLAttrPart.SetInfo(self, info)
    self.m_CurSummonId = info and info.id
    self.m_SummonInfo = info
    self.m_SummonInfoBox:SetInfo(info)
    self.m_EquipedBox:SetInfo(info, true)
    self.m_EquipedBox:RefreshRedDot()
    self:SetBtnInfo()
end

------------- Rename -----------------
function CSummonLAttrPart.OpenRenameWindow(self)
    local sDesc = SummonDataTool.GetText(1034) 
    local iSummon = self.m_CurSummonId
    sDesc = string.format("[63432c]%s[-]", sDesc)
    local comfirmCb = function(input)
        local name = input:GetText()
        if input:GetInputLength() < 1 or input:GetInputLength() > 12 then 
            g_NotifyCtrl:FloatSummonMsg(1035)
            return
        end
        if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
            g_NotifyCtrl:FloatSummonMsg(1036)
            return
        end
        g_SummonCtrl:ChangeName(iSummon, name)
        CWindowInputView:CloseView()
    end
    local windowInputInfo = {
        des             = sDesc,
        title           = "宠物改名",
        inputLimit      = 12,
        okCallback      = comfirmCb,
        isclose         = false,
        defaultText     = "请输入新的宠物名",
    }
    g_WindowTipCtrl:SetWindowInput(windowInputInfo)
end

-------------------- free ------------------------
--放生宠物
function CSummonLAttrPart.OnClickFree(self)
    if not self.m_CurSummonId then
        g_NotifyCtrl:FloatSummonMsg(1045)
        return
    end
    if self.m_CurSummonId == g_SummonCtrl.m_FightId then 
        g_NotifyCtrl:FloatSummonMsg(1028)
        return
    end
    if self.m_CurSummonId == g_SummonCtrl.m_FollowId then 
        g_NotifyCtrl:FloatSummonMsg(1048)
        return
    end
    local iType = self.m_SummonInfo.type
    if iType >= 5 then
        g_NotifyCtrl:FloatSummonMsg(2028)
        return
    end
    self:WildFree()
    -- local summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
    -- if summon.type >= 3 then 
    --  self:WildFree()
    -- else
    --  g_SummonCtrl:ReleaseSummon(self.m_CurSummonId)
    -- end
end

function CSummonLAttrPart.WildFree(self)
    if g_SummonCtrl:GetSummonAmount() <= 1 then
        g_NotifyCtrl:FloatMsg("只携带#G1个#n宠物时不能进行放生")
        return
    end
    local summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
    local sDesc = data.summondata.TEXT[2037].content
    sDesc = "[63432C]"..sDesc
    sDesc = string.FormatString(sDesc, {summon = "#R"..summon.name.."#n"})
    local windowConfirmInfo = {
        msg = sDesc,
        title = "提示",
        color = Color.white,
        okCallback = function ()                                
            g_SummonCtrl:ReleaseSummon(self.m_CurSummonId)
        end,
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

----------------------Set fight------------------------
function CSummonLAttrPart.OnClickFight(self)
    if not self.m_CurSummonId then
        g_NotifyCtrl:FloatSummonMsg(1045)
        return
    end
    if self.m_CurSummonId == g_SummonCtrl.m_FightId then 
        g_SummonCtrl:SetFight(self.m_CurSummonId, 0)
    else        
        g_SummonCtrl:SetFight(self.m_CurSummonId, 1)
    end 
end

-------------------- Set Follow ----------------------
function CSummonLAttrPart.OnClickFollow(self)
    if not self.m_CurSummonId then
        g_NotifyCtrl:FloatSummonMsg(1045)
        return
    end

    -- if g_HorseCtrl:IsUsingFlyRide() then 
    --  g_NotifyCtrl:FloatSummonMsg(1053)
    --  return
    -- end 

    if self.m_CurSummonId == g_SummonCtrl.m_FollowId then 
        g_SummonCtrl:SendIsFollow(self.m_CurSummonId, 2)        
    elseif (not g_TeamCtrl:IsJoinTeam()) or (g_TeamCtrl:IsLeader()) then
        g_SummonCtrl:SendIsFollow(self.m_CurSummonId, 1)        
    elseif g_TeamCtrl:IsLeave(g_AttrCtrl.pid) then
        g_SummonCtrl:SendIsFollow(self.m_CurSummonId, 1)
    else
        g_NotifyCtrl:FloatSummonMsg(1029)
    end
end

----------------------- Set Btn --------------------------
function CSummonLAttrPart.SetBtnInfo(self)
    local summonId = self.m_CurSummonId
    local g_SummonCtrl = g_SummonCtrl
    if summonId == g_SummonCtrl.m_FightId then 
        self.m_FightBtn:SetText("休息")
    else
        self.m_FightBtn:SetText("参战")
    end
    if summonId == g_SummonCtrl.m_FollowId then 
        self.m_FollowBtn:SetText("收回")          
    else        
        self.m_FollowBtn:SetText("跟随")
    end         
end

function CSummonLAttrPart.OnSetFollow(self, iSummon)
    if iSummon == self.m_CurSummonId then
        self.m_FollowBtn:SetText("收回")
        g_NotifyCtrl:FloatSummonMsg(1047)
    else
        self.m_FollowBtn:SetText("跟随")
        g_NotifyCtrl:FloatSummonMsg(1046)  
    end
end

function CSummonLAttrPart.OnSetFight(self, iSummon)
    self.m_SummonInfoBox:RefreshIsFight()
    if g_WarCtrl:IsWar() then
        g_NotifyCtrl:FloatSummonMsg(1049)
    end
    if iSummon == 0 then
        self.m_FightBtn:SetText("参战")  
    else
        self.m_FightBtn:SetText("休息")
    end
end

function CSummonLAttrPart.OnClickWareHouse(self)
    g_SummonCtrl:ShowCKView()
end

function CSummonLAttrPart.OnClickRanse(self)
    local iCurSumm = self.m_CurSummonId
    CSummonRanseView:ShowView(function(oView)
        oView:SelectSummon(iCurSumm)
    end)
end

return CSummonLAttrPart