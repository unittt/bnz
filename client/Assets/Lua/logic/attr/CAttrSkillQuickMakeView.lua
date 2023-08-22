local CAttrSkillQuickMakeView = class("CAttrSkillQuickMakeView", CViewBase)

function CAttrSkillQuickMakeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Skill/AttrSkillQuickMakeView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CAttrSkillQuickMakeView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_EnergySlider = self:NewUI(2,CSlider)
    self.m_EnergyLabel = self:NewUI(3,CLabel)
    self.m_SkillGrid = self:NewUI(4,CGrid)
    self.m_GainGrid = self:NewUI(5,CGrid)
    self.m_GainClone = self:NewUI(7,CBox)
    self.m_SliderEff = self:NewUI(8,CObject)
    self.m_TipBtn = self:NewUI(9, CButton)
    self.m_HuoliScrollView = self:NewUI(10, CScrollView)
    self.m_HuoliBoxClone = self:NewUI(11, CBox)

    self.m_BoxDict = {}
    self:InitContent()
end

function CAttrSkillQuickMakeView.InitContent(self)
    self.m_HuoliBoxClone:SetActive(false)
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "ShowTipView"))

    self:SetHuoliUseList()

    self:RefreshEnergy()
    self:ShowLeft()
    g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnScheduleCtrlEvent"))
end

function CAttrSkillQuickMakeView.GetRightList(self)
    local oList = {}

     -- 打工兑换银币(显示在最前)
    table.insert(oList, {data = 4121, type = 3}) 

    if g_OpenSysCtrl:GetOpenSysState(define.System.OrgSkill) then
        local orgList = {4103, 4104, 4102, 4101, 4120}
        for k,v in ipairs(orgList) do
            table.insert(oList, {data = v, type = 1})
        end
    end
    local oFuZhuanList = g_SkillCtrl:GetOpenFuZhuanList()
    for k,v in ipairs(oFuZhuanList) do
        table.insert(oList, {data = v, type = 2})
    end
    return oList
end

function CAttrSkillQuickMakeView.SetHuoliUseList(self)
    local oList = self:GetRightList()
    local optionCount = #oList
    local GridList = self.m_SkillGrid:GetChildList() or {}
    local oHuoliBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oHuoliBox = self.m_HuoliBoxClone:Clone(false)
                -- self.m_SkillGrid:AddChild(oOptionBtn)
            else
                oHuoliBox = GridList[i]
            end
            self:SetHuoliBox(oHuoliBox, oList[i])
        end

        if #GridList > optionCount then
            for i=optionCount+1,#GridList do
                GridList[i]:SetActive(false)
            end
        end
    else
        if GridList and #GridList > 0 then
            for _,v in ipairs(GridList) do
                v:SetActive(false)
            end
        end
    end

    self.m_SkillGrid:Reposition()
    self.m_HuoliScrollView:ResetPosition()
end

function CAttrSkillQuickMakeView.SetHuoliBox(self, oHuoliBox, oData)
    oHuoliBox:SetActive(true)
    oHuoliBox.m_IconSp = oHuoliBox:NewUI(1, CSprite)
    oHuoliBox.m_LevelLbl = oHuoliBox:NewUI(2, CLabel)
    oHuoliBox.m_NameLbl = oHuoliBox:NewUI(3, CLabel)
    oHuoliBox.m_TitleLbl = oHuoliBox:NewUI(4, CLabel)
    oHuoliBox.m_Makebtn = oHuoliBox:NewUI(5, CButton)

    if oData.type == 1 then
        local skillData = data.skilldata.ORGSKILL[oData.data]
        -- table.print(skillData, "CAttrSkillQuickMakeView.InitContent 制作道具")
        if oData.data == 4120 then
            oHuoliBox.m_IconSp:SpriteItemShape(tostring(skillData.icon))
        else
            oHuoliBox.m_IconSp:SetStaticSprite("OrgSkillAtlas", tostring(skillData.icon)) --:SetSpriteName(tostring(skillData.icon))
        end
        if oData.data ~= 4120 then
            oHuoliBox.m_LevelLbl:SetText(g_AttrCtrl.org_skill[oData.data].level.."级")       
        end
        if oData.data == 4103 or oData.data == 4104 then
            local makeLevel = math.max(40,math.floor(g_AttrCtrl.org_skill[oData.data].level/10)*10)
            oHuoliBox.m_NameLbl:SetText("制作"..makeLevel.."级 "..skillData.name.."符")
        elseif oData.data ==  4120 then
            local makeLevel = "0"
            oHuoliBox.m_NameLbl:SetText("制作"..skillData.name)
            oHuoliBox.m_LevelLbl:SetActive(false)
        elseif oData.data ==  4102 then
            oHuoliBox.m_NameLbl:SetText("炼制药品")
        elseif oData.data ==  4101 then
            oHuoliBox.m_NameLbl:SetText("烹饪食物")
        else
            oHuoliBox.m_NameLbl:SetText("制作"..skillData.name)
        end
        local energy 
        if oData.data == 4120 then
            energy  = data.skilldata.ORGSKILL[4120].cost_energy
            oHuoliBox.m_TitleLbl:SetText(energy)
        else
            energy = g_AttrCtrl:EnergyCalculate(g_AttrCtrl.org_skill[oData.data])
            oHuoliBox.m_TitleLbl:SetText(energy)
        end
        if oData.data == 4102 then
            oHuoliBox.m_Makebtn:SetText("炼制")
        elseif oData.data == 4101 then
            oHuoliBox.m_Makebtn:SetText("烹饪")
        else
            oHuoliBox.m_Makebtn:SetText("制作")
        end
    elseif oData.type == 2 then
        oHuoliBox.m_LevelLbl:SetText(oData.data.level.."级")
        local oConfig = data.skilldata.FUZHUAN[oData.data.sk]
        if oConfig then
            oHuoliBox.m_NameLbl:SetText("制作"..oConfig.name)
            oHuoliBox.m_IconSp:SpriteSkill(oConfig.icon)
            local oNumStr2 = string.gsub(oConfig.huoli, "lv", tostring(oData.data.level))
            local oHuoLi = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr2))()))
            oHuoliBox.m_TitleLbl:SetText(oHuoLi)
        end
        oHuoliBox.m_Makebtn:SetText("制作")
    elseif oData.type == 3 then --打工
        local skilldata = data.skilldata.ORGSKILL[oData.data]
        oHuoliBox.m_IconSp:SpriteItemShape(skilldata.icon)
        oHuoliBox.m_LevelLbl:SetText("")
        oHuoliBox.m_NameLbl:SetText(skilldata.des)
        oHuoliBox.m_TitleLbl:SetText(skilldata.cost_energy)
        oHuoliBox.m_Makebtn:SetText(skilldata.name)
    end

    oHuoliBox.m_Makebtn:AddUIEvent("click", callback(self, "OnMake", oData))

    self.m_SkillGrid:AddChild(oHuoliBox)
    self.m_SkillGrid:Reposition()
end

function CAttrSkillQuickMakeView.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.GetUseOrgSkill then
        if next(oCtrl.m_EventData) ~= nil then
            g_NotifyCtrl:FloatMsg("制作成功！")
        else
            g_NotifyCtrl:FloatMsg("制作失败！")
        end
    end
    if oCtrl.m_EventID == define.Attr.Event.Change then
       self:RefreshEnergy()
    end
end

--显示活力说明面板
function CAttrSkillQuickMakeView.ShowTipView(self)
    local zId = define.Instruction.Config.AttrSkillQuickMakeIns
    local titleStr = data.instructiondata.DESC[zId].title
    local Descstr = data.instructiondata.DESC[zId].desc
    local zContent = {title = titleStr, desc = Descstr, isAttrTip = false}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CAttrSkillQuickMakeView.OnScheduleCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Schedule.Event.RefreshMainUI then
        for id, info in pairs(oCtrl.m_EventData) do
            local oBox = self.m_BoxDict[id]
            if oBox then
                self:UpdateBox(oBox,info)
            end
        end
    end
end

function CAttrSkillQuickMakeView.RefreshEnergy(self)
    local maxEnergy = g_AttrCtrl:GetMaxEnergy()
    if g_AttrCtrl.energy <= 0 then
       self.m_SliderEff:SetActive(false)
    end
    self.m_EnergySlider:SetValue(g_AttrCtrl.energy/maxEnergy)
    self.m_EnergyLabel:SetText(g_AttrCtrl.energy.."/"..maxEnergy)
end

function CAttrSkillQuickMakeView.ShowLeft(self)
    local scheduleData = data.scheduledata.SCHEDULE
    local gainData = {}
    for k, v in pairs(scheduleData) do 
        if v.maxpoint > 0 and v.open == 1 then
            gainData[#gainData+1] = v
        end
    end
    --local scheduleType = g_ScheduleCtrl:GetScheduleTabInfo(1)
    --local scheduleDataList = g_ScheduleCtrl:GetScheduleByType(scheduleType)
    local i = 1
    for k,v in pairs(gainData) do
        if v.type == 1 or v.type == 2 then
            local oBox = self.m_GainGrid:GetChild(i)
            if oBox == nil then
               oBox = self.m_GainClone:Clone()
               oBox.icon = oBox:NewUI(1, CSprite)
               --oBox.level = oBox:NewUI(2, CLabel)
               oBox.name = oBox:NewUI(2, CLabel)
               oBox.times = oBox:NewUI(3, CLabel)
               oBox.makebtn = oBox:NewUI(4, CButton)
               self.m_GainGrid:AddChild(oBox)
               oBox.makebtn:AddUIEvent("click", callback(self, "OnMakeThing", v))
               self.m_BoxDict[v.id] = oBox
            end
            self:UpdateBox(oBox, v)
            i = i + 1
            self.m_GainGrid:Reposition()
        end
    end
end

function CAttrSkillQuickMakeView.UpdateBox(self, oBox, info)
    oBox:SetName(tostring(info.id))
    oBox:SetActive(true)
    oBox.name:SetText(info.name)
    oBox.icon:SpriteItemShape(info.icon)
    local energyInfo = "0".."/"..info.perpoint*info.maxtimes
    local refreshValue,num = self:RefreshScheduleBox(info)
    if refreshValue then
       energyInfo = refreshValue
    end
    if num == info.maxtimes and info.maxtimes ~= 0 then
       oBox.makebtn:SetGrey(true)
       oBox.makebtn:EnableTouch(false)
       oBox:SetName("2"..info.id)
    elseif num > 0 then
        oBox:SetName("0"..info.id)
    end
    oBox.times:SetText(energyInfo)
end

function CAttrSkillQuickMakeView.RefreshScheduleBox(self, v)
    local scheduleInfo = g_ScheduleCtrl:GetScheduleData(v.id)
    local energyInfo = "不限"
    local num = 0
    if v.maxpoint > 0 then
        --printc("已完成次数：",num)
        local iActivePt = 0
        if scheduleInfo then
            iActivePt = scheduleInfo.activepoint or iActivePt
        end
        energyInfo = iActivePt.."/"..v.maxpoint
    end
    return energyInfo,num
end

function CAttrSkillQuickMakeView.OnMakeThing(self, goInfo)
    if g_AttrCtrl.grade < goInfo.level then
        g_NotifyCtrl:FloatMsg(string.format("等级不足#G%s[-],无法参加#G%s[-]", goInfo.level, goInfo.name))
        return
    end
    -- 请求协议参加活动 RequestServer（1、寻人 2、跳转 3、任务 4、UI）
    if goInfo.opentype == 1 then
        self:CloseUI()
        g_MapTouchCtrl:WalkToGlobalNpc(goInfo.openid)
    elseif goInfo.opentype == 2 then
        local mapID = goInfo.openid
        if goInfo.id == 1003 or goInfo.id == 1014 then
            local sealNpcMapInfo = DataTools.GetSealNpcMapInfo(g_AttrCtrl.grade)
            if not sealNpcMapInfo then
                return
            end
            mapID = sealNpcMapInfo.mapid
        end
        self:CloseUI()
        g_MapCtrl:C2GSClickWorldMap(mapID)
    elseif goInfo.opentype == 3 then
        self:CloseUI()
        CTaskHelp.ScheduleTaskLogic(goInfo.openid)
    elseif goInfo.opentype == 4 then
        -- UI(打开UI界面，具体做法待定（1、传入功能ID，通过if判断|维护一个View表，id对应view名称，直接showview）)
        if goInfo.id == 1007 then
            --跳舞允许操作
            -- if g_DancingCtrl.m_StateInfo then
            --    g_NotifyCtrl:FloatMsg("你正在舞会中，不可挑战")
            --    return
            -- end
            if g_BonfireCtrl.m_IsBonfireScene and (g_BonfireCtrl.m_CurActiveState == 2 or g_BonfireCtrl.m_CurActiveState == 1) then
               g_NotifyCtrl:FloatMsg("你正在帮派篝火活动中，不可挑战")
               return
            end
            g_JjcCtrl:OpenJjcMainView()
        elseif goInfo.id == 1017 then -- 摇骰子
            nethuodong.C2GSShootCrapOpen()
        elseif goInfo.id == 1019 then
            nethuodong.C2GSMengzhuMainUI()
        elseif goInfo.id == 1012 then
            g_PKCtrl:C2GSBWClickShiZhe()  --三界斗法寻路
        elseif goInfo.id == 1016 then --跳舞寻路
            nethuodong.C2GSDanceAuto()
        elseif goInfo.id == 1021 then
            g_BaikeCtrl:ShowView()
        elseif goInfo.id == 1027 then
            nethuodong.C2GSTrialOpenUI()
        end
    elseif goInfo.opentype == 5 then
        if g_AttrCtrl.org_id == 0 then
            g_NotifyCtrl:FloatMsg("您当前没有帮派，快去加入一个帮派吧！")
            g_OrgCtrl:OpenOrgView()
            return
        end
        g_OrgCtrl:C2GSEnterOrgScene()
    elseif goInfo.opentype == 0 then
        nethuodong.C2GSSchoolPassClickNpc()
    end
    --self:CloseUI()
end

function CAttrSkillQuickMakeView.OnMake(self, oData)
    if oData.type == 1 then
        if oData.data == 4102 then
            if g_AttrCtrl.silver < 10000 then
               g_NotifyCtrl:FloatMsg("银币不足，炼制失败！") 
               return
            end
        end
        if oData.data == 4120 then
            if g_AttrCtrl.energy < tonumber(data.skilldata.ORGSKILL[4120].cost_energy) then
                g_NotifyCtrl:FloatMsg("活力不足")
                CAttrBuyEnergyView:ShowView()
                return
            end
            netstore.C2GSExChangeDanceBook()
            return
        end
        local skillData = data.skilldata.ORGSKILL[oData.data]
        if g_AttrCtrl.org_skill[oData.data].level < skillData.effect_lv then
            g_NotifyCtrl:FloatMsg("需要等级达到"..skillData.effect_lv.."级才能制作，请去提升技能等级")
            return
        end
        if g_AttrCtrl.energy < g_AttrCtrl:EnergyCalculate(g_AttrCtrl.org_skill[oData.data]) then
            g_NotifyCtrl:FloatMsg("活力不足")
            CAttrBuyEnergyView:ShowView()
            return
        end

        netskill.C2GSUseOrgSkill(oData.data)
    elseif oData.type == 2 then
        if not g_SkillCtrl.m_FuZhuanDataHashList[oData.data.sk] then
            return
        end
        if g_SkillCtrl.m_FuZhuanDataHashList[oData.data.sk].level <= 0 then
            g_NotifyCtrl:FloatMsg(string.gsub(data.skilldata.TEXT[1013].content, "#skill", "[0fff32]"..data.skilldata.FUZHUAN[oData.data.sk].name.."[-]"))
            return
        end
        local oConfig = data.skilldata.FUZHUAN[oData.data.sk]
        local oSkillData = g_SkillCtrl.m_FuZhuanDataHashList[oData.data.sk]
        local oNumStr2 = string.gsub(oConfig.huoli, "lv", tostring(oSkillData.level))
        local oHuoLi = math.ceil(tonumber(load(string.format([[return (%s)]], oNumStr2))()))
        if g_AttrCtrl.energy < oHuoLi then
            g_NotifyCtrl:FloatMsg("活力不足")
            CAttrBuyEnergyView:ShowView()
            return
        end
        netskill.C2GSProductFuZhuanSkill(oData.data.sk)
    elseif oData.type == 3 then
        local skillData = data.skilldata.ORGSKILL[oData.data]
        if g_AttrCtrl.energy < tonumber(skillData.cost_energy) then
            g_NotifyCtrl:FloatMsg("活力不足")
            return
        end
        netskill.C2GSEnergyExchangeSilver()
    end
end

function CAttrSkillQuickMakeView.CloseUI(self)
    self:CloseView()
    local oview = CAttrMainView:GetView()
    if oview then
       oview:CloseView()
    end
end

return CAttrSkillQuickMakeView