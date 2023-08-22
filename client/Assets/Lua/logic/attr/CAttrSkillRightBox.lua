local CAttrSkillRightBox = class("CAttrSkillRightBox", CBox)

function CAttrSkillRightBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_GradeLabel = self:NewUI(2, CLabel)
	self.m_GradeLimit = self:NewUI(3, CLabel)
    self.m_SkillDes = self:NewUI(4, CLabel)
    self.m_ItemGrid = self:NewUI(5, CGrid)
    self.m_ItemClone = self:NewUI(6, CBox)
    self.m_MakeDes = self:NewUI(7, CLabel)
    self.m_Slider = self:NewUI(8, CSlider)
    self.m_OwnSilverCoin = self:NewUI(11, CLabel)
    self.m_CostOrgContribute = self:NewUI(9, CLabel)
   -- self.m_OwnContribute = self:NewUI(10, CLabel)
    self.m_CostVitality = self:NewUI(10, CLabel)
    self.m_UpgradeBtn = self:NewUI(12, CSprite)
    self.m_MakeBtn = self:NewUI(13, CSprite)
    self.m_QuickMakeBtn = self:NewUI(14, CSprite)
    self.m_MakeLabel = self:NewUI(15, CLabel)
    self.m_SliderLabel = self:NewUI(16, CLabel)
    self.m_SkillIcon = self:NewUI(17, CSprite)
    self.m_scroll = self:NewUI(18, CScrollView)
    self.m_NoskillUI = self:NewUI(19,CObject)
    self.m_curLabel = self:NewUI(20,CLabel)
    self.m_NextLabel = self:NewUI(21,CLabel)
    self.m_Huoli = self:NewUI(23,CSkillOtherPromotePtBox)
    self.m_banggong = self:NewUI(22,CSkillOtherPromotePtBox)
    self.m_yinbi = self:NewUI(24,CSkillOtherPromotePtBox)
    self.m_DragScroll = self:NewUI(25, CObject)
    self.m_DragGrid = self:NewUI(26,CGrid)
    self.m_DragClone = self:NewUI(27,CBox)
    self.m_tipLabel = self:NewUI(28,CLabel)
    self.m_SliderEff = self:NewUI(29,CObject)
    self.m_StoryNode = self:NewUI(30, CSkillOtherPromotePtBox)
    self.m_StoryCostL = self:NewUI(31, CLabel)
    self.m_CostGrid = self:NewUI(32, CGrid)
    self.m_SkillTipL = self:NewUI(33, CLabel)
    self.m_MakeSilver = self:NewUI(34,CSkillOtherPromotePtBox)
    self.m_MidEdgeSpr = self:NewUI(35, CSprite)

    self.m_CostNode = {
        [1] = self.m_banggong,
        [2] = self.m_yinbi,
        [3] = self.m_StoryNode,
    }

    self.m_ItemList = nil 

    -- self.m_scroll:InitCenterOnCompnent(self.m_ItemGrid, callback(self, "OnCenter"))
    self.skillType = {[1]={"max_hp","nextlv_max_hp"},[2]={"max_mp","nextlv_max_mp"}}
    self.m_MakeButtonName = {nil,nil,"烹饪食物","炼药","制作符纸","制作符纸","制作符纸"}

    self.m_banggong:SetPromotePtData(define.Currency.OtherVirtual.BangGong)
    self.m_Huoli:SetPromotePtData(define.Currency.OtherVirtual.HuoLi)
    self.m_yinbi:SetPromotePtData(define.Currency.Type.Silver)
    self.m_StoryNode:SetPromotePtData(define.Currency.OtherVirtual.JuQingDian)
    self.m_MakeSilver:SetPromotePtData(define.Currency.Type.Silver)

    self.m_CurCenterObj = nil
    self.m_Timer = nil
    self.m_CurSkillID = nil
    self.m_SelectDrag = nil
    self:SetInfo()
end

function CAttrSkillRightBox.SetInfo(self)
    self.m_MakeBtn:AddUIEvent("click", callback(self, "OnShowMakePart"))
    self.m_QuickMakeBtn:AddUIEvent("click", callback(self, "OnQuickMake"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CAttrSkillRightBox.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        self:RefreshSpend()
        self:RefreshBtn()
    end
end

function CAttrSkillRightBox.OnShowMakePart(self)
    local skillData = data.skilldata.ORGSKILL[self.m_CurSkill.sk]
    if self.m_CurSkill.level < skillData.effect_lv then
        g_NotifyCtrl:FloatMsg("需要等级达到"..skillData.effect_lv.."级才能制作，请去提升技能等级")
        return
    end
    if self.m_CurSkill.sk == 4102 then
        if g_AttrCtrl.silver < 10000 then
           -- g_NotifyCtrl:FloatMsg("银币不足，炼制失败！") 
           g_QuickGetCtrl:OnCurrLackCoinInfo({
                {sid = 1002, amount = 10000, count = g_AttrCtrl.silver}
            })
           return
        end
    end
    if g_AttrCtrl.energy < g_AttrCtrl:EnergyCalculate(self.m_CurSkill) then
        g_NotifyCtrl:FloatMsg("活力不足")
        CAttrBuyEnergyView:ShowView()
        return
    end
    if self.m_CurSkill.sk == 4103 or self.m_CurSkill.sk == 4104 then
       netskill.C2GSUseOrgSkill(self.m_CurSkill.sk,{self.m_SelectDrag})
    else
        netskill.C2GSUseOrgSkill(self.m_CurSkill.sk)
    end
end


function CAttrSkillRightBox.OnQuickMake(self)
    CAttrSkillMakePart:ShowView(function (view)
        view:InitContent(self.m_CurSkill)
    end)
end

function CAttrSkillRightBox.RefreshSpend(self, skill_type, gradeData)
    local skill_type = skill_type or data.skilldata.ORGSKILL[self.m_CurSkill.sk].type
    local gradeData = gradeData or data.skilldata.ORGUPGRADE[self.m_CurSkill.level+1]
    if skill_type == 1 then -- 生活技能
        self.m_OwnSilverCoin:SetText(self:ShowSpendInColor(g_AttrCtrl.silver,gradeData.pro_silver))
        self.m_CostOrgContribute:SetText(g_AttrCtrl.org_offer.."/"..gradeData.pro_offer)
        self.m_CostVitality:SetText(g_AttrCtrl.energy.."/"..g_AttrCtrl:EnergyCalculate(self.m_CurSkill))
        self.m_StoryCostL:SetText(g_AttrCtrl.storypoint.."/"..gradeData.lj_point)
        self.m_MakeSilver.m_Value:SetText(self:ShowSpendInColor(g_AttrCtrl.silver,10000))
    else
        self.m_OwnSilverCoin:SetText(self:ShowSpendInColor(g_AttrCtrl.silver,gradeData.pass_silver))
        self.m_CostOrgContribute:SetText(g_AttrCtrl.org_offer.."/"..gradeData.pass_offer)
    end
end

function CAttrSkillRightBox.SetCallBack(self, v)
    self.m_CurSkill = v
    local skillData = data.skilldata.ORGSKILL[v.sk]
    self.m_TitleLabel:SetText(skillData.name.."技能")
    self.m_GradeLabel:SetText(v.level.."级")
    --self.m_GradeLimit:SetText("上限等级："..(v.level+10))
    self.m_SkillDes:SetText(self:TransformDes(skillData,v.level))
    self.m_SkillIcon:SetSpriteName(skillData.icon)
    self.m_SliderLabel:SetText(v.level.."/"..skillData.max_lv)
    self.m_Slider:SetValue(v.level/skillData.max_lv)
    local isEff = v.level > 0 and true or false
    self.m_SliderEff:SetActive(isEff)
    local makeDescribe = skillData.makedes
    if skillData.id == 4104 or skillData.id == 4103 then
        makeDescribe = makeDescribe..math.max(40,math.floor(v.level/10)*10).."级"
    elseif skillData.id == 4107 then
        makeDescribe = makeDescribe..v.level.."级"
    end
    self.m_MakeDes:SetText(makeDescribe)
    if self.m_MakeButtonName[skillData.id] then
       self.m_MakeLabel:SetText(self.m_MakeButtonName[skillData.id])
    end
    local gradeData = data.skilldata.ORGUPGRADE[v.level+1]
    if skillData.id == 4102 then 
       self.m_MakeBtn:SetSpriteName("h7_an_1")
    else
       self.m_MakeBtn:SetSpriteName("h7_an_2") 
    end  
    if gradeData then
        self.m_ItemList = skillData.item
        self:ShowSkillInfo(skillData)
        
        self:RefreshSpend(skillData.type,gradeData)
        if skillData.type == 2 then
            local effctValue = self:TransformEffect(skillData,v.level)
            self.m_curLabel:SetText(effctValue[self.skillType[skillData.sort][1]])
            self.m_NextLabel:SetText(effctValue[self.skillType[skillData.sort][2]])
        end

        self:InitItemGrid(self.m_ItemList,skillData)
        self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnUpgradeSkill", v.sk, gradeData))
        self:RefreshBtn(skillData,gradeData)
    else
        printc("该技能以已达到学习上限")
    end
    
    self.m_QuickMakeBtn:SetActive(false)
    self.m_MakeBtn:SetLocalPos(Vector3.New(605,-490,0))
    if self.m_CurSkill.sk == 4102 then
       self.m_QuickMakeBtn:SetActive(true)
       self.m_MakeBtn:SetLocalPos(Vector3.New(555,-490,0))
    end
end

function CAttrSkillRightBox.RefreshBtn(self,skillData,gradeData)
    local skillData = skillData or data.skilldata.ORGSKILL[self.m_CurSkill.sk]
    local gradeData = gradeData or data.skilldata.ORGUPGRADE[self.m_CurSkill.level+1]
    if skillData.type == 1 then -- 生活技能
        self.m_MakeBtn:SetActive(true)
        local iMaxGrade = math.min((g_AttrCtrl.grade+10), skillData.max_lv)
        self.m_GradeLimit:SetText("当前等级上限"..iMaxGrade.."级")
        local bEnoughSilver = true
        local bEnoughOrgOffer = true
        local bEnoughStoryPoint = true

        if self.m_CostType[define.Skill.OrgCostType.Silver] then
            bEnoughSilver = g_AttrCtrl.silver >= gradeData.pro_silver
        end 
        if self.m_CostType[define.Skill.OrgCostType.OrgOffer] then
            bEnoughOrgOffer = g_AttrCtrl.org_offer >= gradeData.pro_offer 
        end
        if self.m_CostType[define.Skill.OrgCostType.StoryPoint] then
            bEnoughStoryPoint = g_AttrCtrl.storypoint >= gradeData.lj_point
        end
        if bEnoughSilver and bEnoughOrgOffer and bEnoughStoryPoint 
           and self.m_CurSkill.level <= g_AttrCtrl.grade+10 and self.m_CurSkill.level < skillData.max_lv then
            self.m_UpgradeBtn:SetGrey(false)
        else
            self.m_UpgradeBtn:SetGrey(true)
        end
        self.m_MidEdgeSpr:SetActive(true)
    else
        self.m_MakeBtn:SetActive(false)
        self.m_GradeLimit:SetText("当前等级上限"..(g_AttrCtrl.grade+10).."级")
        if g_AttrCtrl.silver >=  gradeData.pass_silver and g_AttrCtrl.org_offer >= gradeData.pass_offer
        and self.m_CurSkill.level < skillData.max_lv then
            self.m_UpgradeBtn:SetGrey(false)
        else
            self.m_UpgradeBtn:SetGrey(true)
        end
        self.m_MidEdgeSpr:SetActive(false)
    end
end

function CAttrSkillRightBox.InitItemGrid(self, itemlist, skill_data)
    local grid = skill_data.id == 4102 and self.m_DragGrid  or self.m_ItemGrid --  --
    -- grid:Clear()
    local cloneObj = self.m_ItemClone
    local nextMake = nil
    if self.m_CurSkillID == nil then
       self.m_CurSkillID = skill_data.id
    end
    if self.m_CurSkillID ~= skill_data.id then
       self.m_CurCenterObj = nil
       self.m_CurSkillID = skill_data.id
    end
    if skill_data.id == 4103 or skill_data.id == 4104 then
       --cloneObj = self.m_DragClone
       nextMake = self:ChooseMaxItem(itemlist)
    end
    -- local skill_type = skill_data.sort
    for k,v in ipairs(itemlist) do     
        local itemData = DataTools.GetItemData(v.id)
        local item = grid:GetChild(k)
        if item == nil then
            item = cloneObj:Clone()
            item.icon = item:NewUI(1, CSprite)
            item.level = item:NewUI(2, CLabel)
            item.bg = item:NewUI(3,CSprite)
            item.select = item:NewUI(4,CObject)
            item.selectspr = item:NewUI(5,CObject)
            item.drag = item:GetComponent(classtype.UIDragScrollView)
            grid:AddChild(item)
            item:SetGroup(self:GetInstanceID())
        end
        --item:AddUIEvent("dragend",callback(self,"SetCenterOn",skill_type))
        if v.level > self.m_CurSkill.level and skill_data.id ~= 4107 then
           item.icon:SetGrey(true)
        else
           item.icon:SetGrey(false)
        end  
        item:SetActive(true)
        item.bg:SetActive(false)
        item.select:SetActive(false)
        item.icon:SetSpriteName(tostring(itemData.icon))
        item.selectspr:SetActive(false)
        local stext = nil
        if  skill_data.id == 4107 or skill_data.id ==4101 or skill_data.id == 4102 then 
           stext = itemData.name
           item.drag.enabled = false
        elseif skill_data.id ==4103 or skill_data.id == 4104 then
            stext = v.level.."级"
            item.bg:SetActive(true)
            --item.drag.enabled = true
            if nextMake and nextMake.id == v.id then
               if self.m_CurCenterObj then
                  self.m_CurCenterObj.select:SetActive(false)
               end
               item.select:SetActive(true)
               self.m_CurCenterObj = item
               self.m_PreIndex = k
               self.m_SelectDrag = v.id
               self:SetCenterObj()
            end
        end
        item.level:SetText(stext) 
        item:AddUIEvent("click", callback(self, "OnShowItemTip",k,skill_data.sort,v, skill_data.id))  
    end
    for i = #itemlist+1, grid:GetCount() do
        grid:GetChild(i):SetActive(false)
    end
    if not nextMake  then
       grid:Reposition()
       self.m_scroll:ResetPosition()
    end
end

function CAttrSkillRightBox.SetCenterObj(self,delayTime)
    delayTime = delayTime or 0.1
    if self.m_Timer then
       Utils.DelTimer(self.m_Timer)
       self.m_Timer = nil
    end
    local function delay()
        --self.m_CurCenterObj.select:SetActive(true)
        self.m_scroll:CenterOn(self.m_CurCenterObj.m_Transform)
    end
    self.m_Timer = Utils.AddTimer(delay,0,delayTime)
end

function CAttrSkillRightBox.OnUpgradeSkill(self, id, gradeData)
    local skillData = data.skilldata.ORGSKILL[id]
    if skillData.type == 1 then -- 生活技能
        if self.m_CurSkill.level >= skillData.max_lv then
           g_NotifyCtrl:FloatMsg("技能已达到学习上限")
           return 
        end
        if self.m_CurSkill.level >= g_AttrCtrl.grade+10 then
            g_NotifyCtrl:FloatMsg("技能已达到当前等级学习上限")
            return
        end
        if g_AttrCtrl.silver < gradeData.pro_silver and self.m_CostType[define.Skill.OrgCostType.Silver] then
            -- g_NotifyCtrl:FloatMsg("银币不足，学习失败")
         --    CCurrencyView:ShowView(function(oView)
		       --  oView:SetCurrencyView(define.Currency.Type.Silver)
	        -- end)
            local coinlist = {}
            local t = {sid = 1002, count = g_AttrCtrl.silver, amount = gradeData.pro_silver }
            table.insert(coinlist, t)
            CQuickGetCtrl:CurrLackItemInfo({}, coinlist)
            return
        end
        if g_AttrCtrl.org_offer < gradeData.pro_offer and self.m_CostType[define.Skill.OrgCostType.OrgOffer] then
            g_NotifyCtrl:FloatMsg("帮贡不足，学习失败")
            return
        end   
        if g_AttrCtrl.storypoint < gradeData.lj_point and self.m_CostType[define.Skill.OrgCostType.StoryPoint] then
            g_NotifyCtrl:FloatMsg("剧情点不足，学习失败")
            return
        end 
    else
        -- if g_WarCtrl:IsWar() then
        --     g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
        --    return
        -- end
        
        if self.m_CurSkill.level >= skillData.max_lv then
            g_NotifyCtrl:FloatMsg("技能已达到学习上限")
            return
        end
        if self.m_CurSkill.level >= g_AttrCtrl.grade+10 then
            g_NotifyCtrl:FloatMsg("技能已达到当前等级学习上限")
            return
        end
        if g_AttrCtrl.silver < gradeData.pass_silver then         
            -- g_NotifyCtrl:FloatMsg("银币不足，学习失败")
            local coinlist = {}
            local t = {sid = 1002, count = g_AttrCtrl.silver, amount = gradeData.pass_silver }
            table.insert(coinlist, t)
            CQuickGetCtrl:CurrLackItemInfo({}, coinlist)
         --    CCurrencyView:ShowView(function(oView)
		       --  oView:SetCurrencyView(define.Currency.Type.Silver)
	        -- end)
            return
        end
        if g_AttrCtrl.org_offer < gradeData.pass_offer then
            g_NotifyCtrl:FloatMsg("帮贡不足，学习失败")
            return
        end        
    end
    netskill.C2GSLearnOrgSkill(id)
end

function CAttrSkillRightBox.OnShowItemTip(self, index, skillType,itemInfo, skillid)
    local grid = skillType == 4 and self.m_DragGrid or self.m_ItemGrid
    local oitemBox = grid:GetChild(index)
    for i, box in ipairs(grid:GetChildList()) do
        if skillid == 4103 or skillid == 4104 then
            if i == index then  
                box.selectspr:SetActive(true)
            else
                box.selectspr:SetActive(false)
            end
        end
    end
    local oitemData = self.m_ItemList[index]
    local preCenterObj = grid:GetChild(self.m_PreIndex)
    if oitemData then 
       g_WindowTipCtrl:SetWindowItemTip(oitemData.id,{widget= oitemBox, side = enum.UIAnchor.Side.Top}) 
    end
    if skillType == 1 or skillType == 2 or skillType == 3 then
        return
    end
    if itemInfo.level > self.m_CurSkill.level then
        return
    end
    self.m_SelectDrag = itemInfo.id
    self.m_PreCenterObj = self.m_CurCenterObj
    oitemBox.select:SetActive(true)            
    self.m_CurCenterObj = oitemBox
    self.m_PreIndex = index
    self:SetCenterObj()
    if preCenterObj and preCenterObj ~= self.m_CurCenterObj then
       preCenterObj.select:SetActive(false)
    end
end

--获取道具等级最高的
function CAttrSkillRightBox.ChooseMaxItem(self,itemList)
    local temp_lv = math.floor(self.m_CurSkill.level/10)*10
    for i=1, #itemList do
        if itemList[i].level >= temp_lv  then
           return itemList[i]
        end
    end 
end

--技能描述公式替换
function CAttrSkillRightBox.TransformDes(self,skill_data,skill_lv)
    local skill_des = skill_data.des
    local num = 0
    local tem_des = nil
    local skill_eff = self:TransformEffect(skill_data,skill_lv)
    if next(skill_eff) == nil then
       return skill_des
    end
    local _,n = string.gsub(skill_data.des,"#+","")
    if n > 0 then
        for k,v in pairs(skill_eff) do
            tem_des , num = string.gsub(skill_des,"#"..k,v)
            if num > 0 then
               skill_des = tem_des
               n = n - 1
            end
            if n == 0 then
               return tem_des
             end
        end
    else
        return skill_des
    end
end
--转化技能表达式
function CAttrSkillRightBox.TransformEffect(self,skill_data,skill_lv)
    local attConfig = {}
    for i,v in ipairs(skill_data.skill_effect) do
       local temp = string.split(v,"=")
       local formula = string.gsub(temp[2], "level", skill_lv)
       local func = loadstring("return " .. formula)
       local val = func()
       attConfig[temp[1]] = val
    end
    for key,value in ipairs(skill_data.nextlv_effect) do
       local temp = string.split(value,"=")
       local strval = string.gsub(temp[2], "level", skill_lv)
       local funb = loadstring("return " .. strval)
       local val = funb()
       attConfig[temp[1]] = val
    end
    return attConfig
end

function CAttrSkillRightBox.ShowSkillInfo(self, skill_data)
    if skill_data.type == 1 then
        self.m_scroll:SetActive(true)
        self.m_NoskillUI:SetActive(false)
        self.m_Huoli:SetActive(true)
        -- self.m_banggong:SetLocalPos(Vector3.New(325,-383,0))
        -- self.m_yinbi:SetLocalPos(Vector3.New(325,-427,0))
        self.m_CostGrid:SetLocalPos(Vector3.New(346, -380, 0))
        self.m_UpgradeBtn:SetLocalPos(Vector3.New(275,-490,0))
    else
        self.m_scroll:SetActive(false)
        self.m_NoskillUI:SetActive(true)
        self.m_Huoli:SetActive(false)

        local text = ""
        if skill_data.id == 4105 then
            text = "[244B4E]技能效果: [-][1D8E00]提高气血上限[-]"
        elseif skill_data.id == 4106 then
            text = "[244B4E]技能效果: [-][1D8E00]提高法力上限[-]"
        end
        self.m_SkillTipL:SetText(text)
        -- self.m_banggong:SetLocalPos(Vector3.New(464,-383,0))
        -- self.m_yinbi:SetLocalPos(Vector3.New(464,-427,0))
        self.m_CostGrid:SetLocalPos(Vector3.New(495, -380, 0))
        self.m_UpgradeBtn:SetLocalPos(Vector3.New(458,-490,0))
    end
    self.m_CostType = {}
    for i=1,3 do
        local iType = skill_data.up_cost_type[i]
        if iType then
            self.m_CostType[iType] = true
        end
    end
    for i,v in ipairs(self.m_CostNode) do
        v:SetActive(self.m_CostType[i] or false)
    end
    self.m_CostGrid:Reposition()

    if skill_data.id == 4102 then
        self.m_scroll:SetActive(false)
        self.m_DragScroll:SetActive(true)
    else
        self.m_scroll:SetActive(true)
        self.m_DragScroll:SetActive(false)
    end
    if skill_data.id == 4101  then
       self.m_tipLabel:SetActive(true)
        local upData = self:GetCookTip(self.m_ItemList)
        if upData then 
           local itemData = DataTools.GetItemData(upData.id)
           self.m_tipLabel:SetText("[63432C]技能[-]".."[A64E00]"..upData.level.."级[-]".."[63432C]后可解锁[-]".."[1D8E00]"..itemData.name.."[-]")
       else
          self.m_tipLabel:SetActive(false)
       end
    else
       self.m_tipLabel:SetActive(false)
    end
    self.m_MakeSilver:SetActive(skill_data.id == 4102)
end

function CAttrSkillRightBox.GetCookTip(self,item)
    for k,v in ipairs(item) do
        if self.m_CurSkill.level < v.level then
           return v
        end
    end
end

function CAttrSkillRightBox.ShowSpendInColor(self,curValue,needVlaue)
    if curValue < needVlaue then
       return "[AF302A]"..string.AddCommaToNum(needVlaue).."[-]"
    else
       return "[63432C]"..string.AddCommaToNum(needVlaue).."[-]"
    end
end

return CAttrSkillRightBox
