local CPromoteCtrl = class("CPromoteCtrl", CCtrlBase)


function CPromoteCtrl.ctor(self)
    CCtrlBase.ctor(self)

    self.m_PromoteList = {} 
    self.m_CurArray = nil  --当前拥有阵法列表
    self.m_CurChoose = nil --当前选择阵法序号
    self.m_CurFomation = nil
    self.m_SysMarkInfo = nil --系统评分信息
    self.m_FinishEventDic = {} --成长信息
    self.m_GrowRedPoint  = false -- 控制主界面,成长页签红点
    --self.m_PromoteType = {1,2,3,4,5}
    self.m_GrowEffRecord = {} --记录红点特效
    self.m_GrowMinLevelIdx = 10000 --可以领取奖励的最小下标

    self.m_SourceList = {
        [1]="SOURCE_CAMBAT_SKILL", --战斗技能
        [2]="SOURCE_EQUIP", -- 装备资料
        [3]="SOURCE_GAME_TECH", -- 游戏技巧
        [4]="SOURCE_HELP_SKILL", -- 辅助技能
        [5]="SOURCE_PVE", -- 玩法大全
        [6]="SOURCE_SUMMON", -- 宠物说明
        [7]="SOURCE_UPGRADE_TECH", -- 升级攻略
        [8]="SOURCE_PARTNER", -- 伙伴说明
    }

    self.m_SourceEventDic = {
        SOURCE_CAMBAT_SKILL = define.Promote.Event.RefreshCamBatSkillInfo,
        SOURCE_EQUIP = define.Promote.Event.RefreshSourceEquipInfo,
        SOURCE_GAME_TECH = define.Promote.Event.RefreshGameTechInfo,
        SOURCE_HELP_SKILL = define.Promote.Event.RefreshHelpSkillInfo,
        SOURCE_SUMMON = define.Promote.Event.RefreshSourceSummonInfo,
        SOURCE_UPGRADE_TECH = define.Promote.Event.RefreshSourceUpgroupInfo,
    }
end

function CPromoteCtrl.GetSourceEvent(self, stype)
    return self.m_SourceEventDic[stype]
end

--获取可以提升的系统
function CPromoteCtrl.GetPromoteSys(self)
    return self.m_PromoteList
end

function CPromoteCtrl.GetPromoteDataBySysId(self, oSysId)
    for k,v in pairs(self.m_PromoteList) do
        if v.sysId == oSysId then
            return v
        end
    end
end

--点击删除提升提示
function CPromoteCtrl.DelSys(self, oSysId)
    for k,v in pairs(self.m_PromoteList) do
        if v.sysId == oSysId then
            table.remove(self.m_PromoteList, k)
            break
        end
    end
    table.sort(self.m_PromoteList, function(a, b) return a.sortIndex < b.sortIndex end)
    self:OnEvent(define.Promote.Event.DelSys)
    self:OnEvent(define.Promote.Event.UpdatePromoteData)
    self:OnEvent(define.Promote.Event.RedPoint)
end

function CPromoteCtrl.CheckIsSysIdExist(self, oSysId)
    for k,v in pairs(self.m_PromoteList) do
        if v.sysId == oSysId then
            return true
        end
    end
end

function CPromoteCtrl.CheckIsHasRedPoint(self)
    for k,v in pairs(self.m_PromoteList) do
        if v.isRedPoint then
            return true
        end
    end
end

--更新可以进行提升的数据列表,1更新SKILL_ZD ，2 SKILL_BD，3 ROLE_ADDPOINT，4 SUMMON_SYS，5 FMT_SYS
function CPromoteCtrl.UpdatePromoteData(self, oIndex)
    if oIndex == 1 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.SkillZD) and g_SkillCtrl:GetIsActiveSkillCouldUp() then  --主动技能
            if not self:CheckIsSysIdExist("SKILL_ZD") then
                table.insert(self.m_PromoteList, {sysId = "SKILL_ZD", name = "招式升级", icon = "h7_zhudong", sortIndex = 1, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("SKILL_ZD")
        end
    elseif oIndex == 2 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.SkillBD) and g_SkillCtrl:GetIsPassiveSkillCouldUp() then --被动技能
            if not self:CheckIsSysIdExist("SKILL_BD") then
                table.insert(self.m_PromoteList, {sysId = "SKILL_BD", name = "心法升级", icon = "h7_beidong", sortIndex = 2, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("SKILL_BD")
        end
    elseif oIndex == 3 then
        local remainPoint = g_AttrCtrl:GetRemainPoint()
        if remainPoint and remainPoint > 0 and g_OpenSysCtrl:GetOpenSysState(define.System.RoleAddPoint) then  --人物加点
            if not self:CheckIsSysIdExist("ROLE_ADDPOINT") then
                table.insert(self.m_PromoteList, {sysId = "ROLE_ADDPOINT", name = "人物加点", icon = "h7_renwujia", sortIndex = 3, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("ROLE_ADDPOINT")
        end
    elseif oIndex == 4 then
        local isSummon, summonId = self:JudgeSummon()   --宠物加点
        if g_OpenSysCtrl:GetOpenSysState(define.System.Summon) and isSummon then
            self.m_SummonId = summonId
            if not self:CheckIsSysIdExist("SUMMON_SYS") then
                table.insert(self.m_PromoteList, {sysId = "SUMMON_SYS", name = "宠物加点", icon = "h7_chongwujia", sortIndex = 4, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("SUMMON_SYS")
        end
    elseif oIndex == 5 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.Formation) and self:JudgeUpArray() then --阵法升级
            if not self:CheckIsSysIdExist("FMT_SYS") then
                table.insert(self.m_PromoteList, {sysId = "FMT_SYS", name = "阵法升级", icon = "h7_zhenfa", sortIndex = 6, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("FMT_SYS")
        end
    elseif oIndex == 6 then
        if g_AttrCtrl.energy/g_AttrCtrl:GetMaxEnergy() >= 0.8 then --活力使用
            if not self:CheckIsSysIdExist("ENERGY") then
                table.insert(self.m_PromoteList, {sysId = "ENERGY", name = "活力使用", icon = "h7_huoli_1", sortIndex = 7, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("ENERGY")
        end
    elseif oIndex == 7 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.EquipStrengthen) and g_PromoteCtrl:JudgeEquipStrength() then --装备强化
            if not self:CheckIsSysIdExist("EQUIP_QH") then
                table.insert(self.m_PromoteList, {sysId = "EQUIP_QH", name = "装备强化", icon = "h7_qianghua", sortIndex = 8, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("EQUIP_QH")
        end
    elseif oIndex == 8 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.Partner) and g_PromoteCtrl:JudgeUnlockPartner() then --新伙伴招募
            if not self:CheckIsSysIdExist("PARTNER_ZM") then
                table.insert(self.m_PromoteList, {sysId = "PARTNER_ZM", name = "伙伴招募", icon = "h7_huoban_2", sortIndex = 9, isRedPoint = true})
            end
            self.m_IsHasNewPartnerCouldUnLock = true
        else
            g_PromoteCtrl:DelSys("PARTNER_ZM")
            self.m_IsHasNewPartnerCouldUnLock = false
        end
    elseif oIndex == 9 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.Partner) and g_PromoteCtrl:JudgeUpgradePartner() then --伙伴进阶
            if not self:CheckIsSysIdExist("PARTNER_JJ") then
                table.insert(self.m_PromoteList, {sysId = "PARTNER_JJ", name = "伙伴进阶", icon = "h7_huoban_2", sortIndex = 10, isRedPoint = true})
            end
            self.m_IsHasNewPartnerCouldUpgrade = true
        else
            g_PromoteCtrl:DelSys("PARTNER_JJ")
            self.m_IsHasNewPartnerCouldUpgrade = false
        end
    elseif oIndex == 10 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.Summon) and g_SummonCtrl.m_IsHasNewSummon then --获得新宠物
            g_SummonCtrl.m_IsHasNewSummon = false
            if not self:CheckIsSysIdExist("SUMMON_NEW") then
                table.insert(self.m_PromoteList, {sysId = "SUMMON_NEW", name = "宠物获得", icon = "h7_chongwujia", sortIndex = 11, isRedPoint = true})
            end
        end
    elseif oIndex == 11 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.Cultivation) and g_SkillCtrl:GetIsCultivateCouldUp() then --修炼技能
            if not self:CheckIsSysIdExist("XIU_LIAN_SYS") then
                table.insert(self.m_PromoteList, {sysId = "XIU_LIAN_SYS", name = "修炼升级", icon = "h7_xiulian", sortIndex = 12, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("XIU_LIAN_SYS")
        end
    elseif oIndex == 12 then
        local oCount = g_FightOutsideBuffCtrl:GetBaoShiRemainCount()
        if oCount and oCount <= 10 then --增加饱食度
            if not self:CheckIsSysIdExist("BAOSHIDU") then
                table.insert(self.m_PromoteList, {sysId = "BAOSHIDU", name = "饱食补充", icon = "h7_baoshi_1", sortIndex = 13, isRedPoint = true})
            end
        elseif (oCount and oCount > 30) or not oCount then
            g_PromoteCtrl:DelSys("BAOSHIDU")
        end
    elseif oIndex == 13 then
        if g_OpenSysCtrl:GetOpenSysState(define.System.Formation) and self:JudgeLearnFormation() then --阵法学习
            if not self:CheckIsSysIdExist("FMT_LEARN") then
                table.insert(self.m_PromoteList, {sysId = "FMT_LEARN", name = "阵法学习", icon = "h7_zhenfa", sortIndex = 5, isRedPoint = true})
            end
        else
            g_PromoteCtrl:DelSys("FMT_LEARN")
        end
    end
    table.sort(self.m_PromoteList, function(a, b) return a.sortIndex < b.sortIndex end)
    self:OnEvent(define.Promote.Event.UpdatePromoteData)
    self:OnEvent(define.Promote.Event.RedPoint)
end

--获取某类型提升显示的数据
function CPromoteCtrl.GetPromrteTypeData(self, typeId)
    local dataInfo = data.promotedata.DATA[typeId]
    return dataInfo
end

--判断宠物是否可以提升
function CPromoteCtrl.JudgeSummon(self)
    local tAllSummon = g_SummonCtrl:GetSummons()
    local curSummonId = g_SummonCtrl.m_FightId
    --table.print(tAllSummon,"-----宠物表----")
    if tAllSummon then
       for k,v in pairs(tAllSummon) do
           --printc(v.id,"chongwu",v.point)
           if v.id == curSummonId and v.point > 0 then 
              return true, v.id
           end
       end
       return false
   end
end

--判断阵法升级
function CPromoteCtrl.JudgeUpArray(self)
    if g_FormationCtrl:GetCurrentFmt() == 0 then
        netformation.C2GSAllFormationInfo()
        return false
    end

    local oFormationList = g_FormationCtrl:GetAllFormationInfo()
    for k,v in pairs(oFormationList) do
        local config = data.formationdata.BASEINFO[v.fmt_id]
        if v.fmt_id >= 2 and v.grade < #config.exp and ( g_ItemCtrl:GetBagItemAmountBySid(self:GetFormationNeedItem(v.fmt_id).id) > 0 
        or g_ItemCtrl:GetBagItemAmountBySid(self:GetFormationNeedItem(10).id) > 0 ) then
            self.m_PromoteFmtid = v.fmt_id
            return true
        end
    end
    return false
end

--判断一些提升的所需要的物品sid列表
function CPromoteCtrl.CheckNeedItemList(self, oIndex)
    local oItemList = {}
    if oIndex == 1 then
        table.insert(oItemList, data.skilldata.CONFIG[1].active_itemid)
    elseif oIndex == 5 then
        local oFormationList = g_FormationCtrl:GetAllFormationInfo()
        for k,v in pairs(oFormationList) do
            if v.fmt_id >= 2 then
                table.insert(oItemList, self:GetFormationNeedItem(v.fmt_id).id)
            end
        end
        table.insert(oItemList, self:GetFormationNeedItem(10).id)
    elseif oIndex == 7 then
        for pos=1, define.Equip.Pos.Shoes do
            if g_ItemCtrl:GetEquipedByPos(pos) then
                local iStrengthLv = g_ItemCtrl:GetStrengthenLv(pos)
                if iStrengthLv < g_AttrCtrl.grade then
                    local dBreakData = DataTools.GetEquipStrengthBreak(pos, g_ItemCtrl:GetStrengthenBreakLv(pos))
                    local dNextEffData = DataTools.GetEquipStrengthData(pos, iStrengthLv + 1) 
                    local bIsMax = dBreakData.max_lv == iStrengthLv or not dNextEffData
                    if not bIsMax then
                        local dMaterialData = DataTools.GetEquipStrengthMaterial(pos, iStrengthLv + 1)
                        if dMaterialData then
                            table.insert(oItemList, dMaterialData.sid)                            
                        end 
                    else
                        -- printc("已满级", pos)
                    end   
                end
            end
        end
    elseif oIndex == 8 then
        for i,dPartner in pairs(data.partnerdata.INFO) do
            local iCostItem = dPartner.cost.id
            table.insert(oItemList, iCostItem)            
        end
    elseif oIndex == 9 then
        for i,dSPartner in ipairs(g_PartnerCtrl.m_SvrPartnerList) do
            local dInfo = DataTools.GetPartnerQualityInfo(dSPartner.quality + 1)  
            if dInfo then
                local cultureItemInfo = g_PartnerCtrl:GetPartnerCultureItemInfo(dSPartner.sid, 3)
                for i,dItem in ipairs(cultureItemInfo.itemList) do
                    table.insert(oItemList, dItem.info.id) 
                end
            end 
        end
    elseif oIndex == 11 then
        table.insert(oItemList, define.Skill.CultivationNeedItem.Player)
        table.insert(oItemList, define.Skill.CultivationNeedItem.Partner)
    elseif oIndex == 13 then
        for k,v in pairs(data.formationdata.ITEMINFO) do
            table.insert(oItemList, v.id)
        end
    end
    return oItemList
end

function CPromoteCtrl.CheckIsFormationExist(self, oFormationList, oId)
    for k,v in pairs(oFormationList) do
        if v.fmt_id == oId then
            return true
        end
    end
end

function CPromoteCtrl.JudgeLearnFormation(self)
    if g_FormationCtrl:GetCurrentFmt() == 0 then
        netformation.C2GSAllFormationInfo()
        return false
    end

    if g_FormationCtrl.m_LeftCouldLearnNum <= 0 then
        return false
    end
    
    local oFormationList = g_FormationCtrl:GetAllFormationInfo()

    for k,v in pairs(data.formationdata.BASEINFO) do
        if v.id ~= 1 then
            if not self:CheckIsFormationExist(oFormationList, v.id) and g_ItemCtrl:GetBagItemAmountBySid(self:GetFormationNeedItem(v.id).id) > 0 then
                self.m_PromoteLearnFmtid = v.id
                return true
            end
        end
    end
    return false
end

--伙伴可招募
function CPromoteCtrl.JudgeUnlockPartner(self)
    -- for i,dPartner in pairs(data.partnerdata.INFO) do
    --     local dSPartner = g_PartnerCtrl:GetRecruitPartnerDataByID(dPartner.id)
    --     local iCostItem = dPartner.cost.id
    --     local iItemAmount = g_ItemCtrl:GetBagItemAmountBySid(iCostItem)
    --     if not dSPartner and iItemAmount > 0 then
    --         -- printerror("可招募伙伴id"..dPartner.id)
    --         return true
    --     end
    -- end
    -- return false
    for i,dPartner in pairs(data.partnerdata.INFO) do
        local iStatus = g_PartnerCtrl:GetRedPointStatus(dPartner.id)
        if iStatus == define.Partner.RedPoint.Recruit then
            return true
        end
    end
    return false
end

--伙伴进阶
function CPromoteCtrl.JudgeUpgradePartner(self)
    -- -- printerror("JudgeUpgradePartner")
    -- for i,dSPartner in ipairs(g_PartnerCtrl.m_SvrPartnerList) do
    --     local dInfo = DataTools.GetPartnerQualityInfo(dSPartner.quality + 1)  
    --     if dInfo then
    --         local cultureItemInfo = g_PartnerCtrl:GetPartnerCultureItemInfo(dSPartner.sid, 3)
    --         local bIsUpgrade = true
    --         for i,dItem in ipairs(cultureItemInfo.itemList) do
    --             if dItem.amount < dItem.cost then
    --                 bIsUpgrade = false
    --                 -- printc("材料不足不可进阶",dSPartner.name)
    --             end
    --         end
    --         if bIsUpgrade then
    --             -- printc("可进阶",dSPartner.name)
    --             return true
    --         end
    --     else
    --         -- printc("已满级不可进阶",dSPartner.name)
    --     end 
    -- end
    -- return false
    for i,dSPartner in ipairs(g_PartnerCtrl.m_SvrPartnerList) do
        local iStatus = g_PartnerCtrl:GetRedPointStatus(dSPartner.sid)
        if iStatus == define.Partner.RedPoint.Upgrade then
            return true
        end
    end
end

--判断装备是否可以强化
function CPromoteCtrl.JudgeEquipStrength(self)
    -- printerror("JudgeEquipStrength")
    for pos=1, define.Equip.Pos.Shoes do
        if g_ItemCtrl:GetEquipedByPos(pos) then
            local iStrengthLv = g_ItemCtrl:GetStrengthenLv(pos)
            local iSilverCost = iStrengthLv * 500 + 100
            if iStrengthLv < g_AttrCtrl.grade and iSilverCost <= g_AttrCtrl.silver then
                local dBreakData = DataTools.GetEquipStrengthBreak(pos, g_ItemCtrl:GetStrengthenBreakLv(pos))
                local dNextEffData = DataTools.GetEquipStrengthData(pos, iStrengthLv + 1) 
                local bIsMax = dBreakData.max_lv == iStrengthLv or not dNextEffData
                if not bIsMax then
                    local dMaterialData = DataTools.GetEquipStrengthMaterial(pos, iStrengthLv + 1)
                    if dMaterialData then
                        local iAmount = g_ItemCtrl:GetBagItemAmountBySid(dMaterialData.sid)
                        iAmount = iAmount + g_ItemCtrl:CalculateStrengthItemCnt(dMaterialData.sid)
                        if iAmount >= dMaterialData.amount then
                            -- printc("可强化位置", pos, iAmount)
                            return true
                        end
                        -- printc("强化石不足", pos)
                    end 
                else
                    -- printc("已满级", pos)
                end   
            end
        end
    end
    return false
end

function CPromoteCtrl.GetFormationNeedItem(self, fmtid)
    for k,v in pairs(data.formationdata.ITEMINFO) do
        if v.fmt_id == fmtid then
            return v
        end
    end
end

function CPromoteCtrl.GS2CPromote(self, pbdata)
     self.m_SysMarkInfo = pbdata
     
     -- 战斗失败，打开提示界面(已用 CPromoteCtrl.GS2CWarFail 替代)
     -- if pbdata.open == 1 then
     --    CWarFailPromoteView:ShowView()
     -- end
     -- if pbdata.open == 3 then   --打开界面
    self:OnEvent(define.Promote.Event.Refresh)
     -- end
end

function CPromoteCtrl.GS2CWarFail(self, gameplay)
    if data.promotedata.WARFAIL.jjc and gameplay == data.promotedata.WARFAIL.jjc.flag then
        -- 竞技场特殊处理（jjc.GS2CJJCFightEndInfo）
        return
    end

    local failInfo = DataTools.GetWarFailInfo(g_AttrCtrl.grade)
    if failInfo == nil then
        return
    end

    local showidList = table.copy(failInfo.showlist)
    if gameplay == data.promotedata.WARFAIL.story.flag then
        if not table.index(failInfo.showlist, 7) then
            table.insert(showidList, 7)
        end
    end

    local configList = self:GetWarFailConfigList(showidList)
    CWarFailPromoteView:ShowView(function (oView)
        oView:SetContent(configList)
    end)
end

function CPromoteCtrl.GetWarFailConfigList(self, showidList)
    local configList = {}
    local guidInfo = self:GetPromrteTypeData(1)

    for _,showid in ipairs(showidList) do
        local needInsert = true

        local config = data.warfailconfigdata.WARFAILCONFIG[showid]
        --TODO:写法有误，战败指引单按钮同时允许多个tab跳转，应该给config赋一个临时的tab值
        if config.logic.tabname then
            for i,v in ipairs(guidInfo) do
                if v.go[2] == config.logic.tabname then
                    local sysRadio = g_PromoteCtrl.m_SysMarkInfo.radio[i]
                    if sysRadio and sysRadio >= data.promotedata.JUDGE[1].radio then
                        needInsert = false
                    end
                    break
                end
            end
        end

        if needInsert then
            table.insert(configList, config)
        end
    end
    if next(configList) == nil then
        local config = data.warfailconfigdata.WARFAILCONFIG[1]
        table.insert(configList, config)
    end
    return configList
end

function CPromoteCtrl.C2GSGetPromote()
    netplayer.C2GSGetPromote()
end

-----成长部分------
function CPromoteCtrl.GS2CAllGrowInfo(self, growinfo)
    -- body
    self.m_FinishEventDic  =  growinfo
    for i,v in ipairs(self.m_FinishEventDic) do
        if v.reward == 1  then
            table.insert(self.m_GrowEffRecord, {id = v.index , effect = true})
        end
    end
    self:RefreshGrowRedPoint()
    self:SetMinLevelIdx()
end


function CPromoteCtrl.GS2CRefreshGrow(self, pbdata)
    local sign = true
    for i,v in ipairs(self.m_FinishEventDic) do
        if pbdata.index == v.index then
            v.reward = pbdata.reward
            v.finish = pbdata.finish
            sign = false
            break
        end
    end
    if sign then
        table.insert(self.m_FinishEventDic, pbdata)
    end
    sign = true
    for i,v in pairs(self.m_GrowEffRecord) do
        if pbdata.index == v.id then
            sign = false
            if pbdata.reward == 1 then
                v.effect =true
            end
        end 
    end
    if sign and pbdata.reward == 1 then
        table.insert(self.m_GrowEffRecord, {id = pbdata.index, effect = true} )
    end
    self:RefreshGrowRedPoint()
    self:SetMinLevelIdx()
    self:OnEvent(define.Promote.Event.RefreshGrow, pbdata)
end

function CPromoteCtrl.JudgeGrowDataTypeByID(self, id)
    if next(self.m_FinishEventDic) then
        for _, v in pairs(self.m_FinishEventDic)  do
            if id == v.index then
                if v.reward == 1 then
                    return define.Promote.Type.Reward
                elseif v.reward == 2 then
                    return define.Promote.Type.Finish
                else 
                    return define.Promote.Type.ToDoTask
                end
            end
        end  
        return define.Promote.Type.ToDoTask 
    else
        return define.Promote.Type.ToDoTask 
    end
end

function CPromoteCtrl.JudgeRewardByLevel(self, level)
    local wholeinfo = data.promotedata.GROW
    local partinfo = {}
    for i, v in pairs(wholeinfo) do
        if level == v.level then
            table.insert(partinfo, v)
        end
    end

    for i, v in ipairs(partinfo) do
        local result = self:JudgeGrowDataTypeByID(v.id)
        if result == define.Promote.Type.Reward then
            return true
        end
    end

    return false
end

--用于成长左侧按钮红点显示
function CPromoteCtrl.JudgeCanGetRewardByList(self, list)
    local sign = false
    for i,v in ipairs (self.m_GrowEffRecord) do
        for x,y in ipairs(list) do
            if v.id == y.id then
                sign =  v.effect
            end 
        end
    end
    return sign
end
-- 点击之后隐藏红点，无论是否领取奖励
function CPromoteCtrl.ClickHideRedDot(self, list)
    for i,v in ipairs(self.m_GrowEffRecord) do
        for x,y in ipairs(list) do
            if v.id == y.id  then
                v.effect = false
            end
        end
    end
end

function CPromoteCtrl.PlayerLevelSction(self)
    -- body
    local maxlevel = 7
    local section
    if g_AttrCtrl.grade%10 ~= 0 then
        section =  math.ceil (g_AttrCtrl.grade/10)
    else
        section =  math.ceil (g_AttrCtrl.grade/10) + 1
    end
    if section > maxlevel then
        section = maxlevel - 1 
    end
    return section + 1
end
-- 控制主界面红点显示
function CPromoteCtrl.RefreshGrowRedPoint(self)
    self.m_GrowRedPoint = false

    local section  = self:PlayerLevelSction()

    if  next(self.m_FinishEventDic) then
        for _,v in ipairs(self.m_FinishEventDic) do
            local dGrow = DataTools.GetGrowLevelInfo(v.index)
            for i=1,section do
                if v.reward == 1 and v.index == dGrow.id then
                    self.m_GrowRedPoint = true
                end
            end
        end
    end

    self:OnEvent(define.Promote.Event.RefreshGrowRedPoint)
end

-- 如有奖励将打开最小的页签
function CPromoteCtrl.SetMinLevelIdx(self)
    self.m_GrowMinLevelIdx = 10000
    local section = self:PlayerLevelSction()

    if next(self.m_FinishEventDic) then
        for i,v in ipairs(self.m_FinishEventDic) do
           local dGrow = DataTools.GetGrowLevelInfo(v.index)
            if v.reward == 1 and  v.index <  self.m_GrowMinLevelIdx and dGrow.level<=section then
                self.m_GrowMinLevelIdx = v.index 
            end
        end
    end
end


function CPromoteCtrl.C2GSGrowReward(self, id)
    nethuodong.C2GSGrowReward(id)
end

---资料大全

function CPromoteCtrl.GetSysOpenSourceBook(self)
    local OpenSourceList = {}
    for i,v in ipairs(self.m_SourceList) do
        local OpenState = g_OpenSysCtrl:GetOpenSysState(v)
        if OpenState then
            local openInfo = DataTools.GetViewOpenData(v)
            table.insert(OpenSourceList, openInfo)
        end
    end
    return OpenSourceList
end

function CPromoteCtrl.GetSourceBookByStype(self, stype)
    local info = {}
    if stype == "SOURCE_CAMBAT_SKILL" then --战斗技能
        local combatinfo = data.sourcebookdata.CAMBATSKILL
        local skillkind = {}
        for i,v in ipairs(combatinfo) do
            local skill = {cat_id = v.cat_id, name = v.cat_name, sort = v.sort}
            local exist = false
            for j, k in ipairs(skillkind) do
                if skill.cat_id == k.cat_id and skill.name == k.name then
                    exist = true
                    break
                end
            end
            if not exist  then
                table.insert(skillkind, skill)
            end
        end
        table.sort(skillkind, function (a,b)
            return a.sort < b.sort
        end)
        info = skillkind
    elseif stype == "SOURCE_EQUIP" then --装备说明
        info = {
            [1] = {name = "装备查看"},
            [2] = {name = "装备介绍"},
        }
    elseif stype == "SOURCE_GAME_TECH" then --游戏技巧
        local techInfo = data.sourcebookdata.GAMETECH
        for i, v in ipairs(techInfo) do
            table.insert(info, {name = v.title, cat_id = v.cat_id})
        end
    elseif stype == "SOURCE_HELP_SKILL" then --帮派技能
        local helpInfo = data.sourcebookdata.HELPSKILL
        for i, v in ipairs(helpInfo) do
            table.insert(info, {name = v.cat_name, cat_id = v.cat_id})
        end
    elseif stype == "SOURCE_PARTNER" then --伙伴说明
        return info
    elseif stype == "SOURCE_PVE" then -- 玩法大全
        --忽略--
    elseif stype == "SOURCE_SUMMON" then --宠物说明
        info = {
            [1] = {name = "宠物介绍"},
            [2] = {name = "宠物类型"},
        }
    elseif stype == "SOURCE_UPGRADE_TECH" then --升级攻略
        local levelInfo = data.sourcebookdata.UPGRADE
        for i, v in ipairs(levelInfo) do
            table.insert(info, {name = v.name, levelid = v.levelid})
        end 
    end

    return info
end

return CPromoteCtrl