local CSummonDetailInfoPart = class("CSummonDetailInfoPart", CPageBase)

function CSummonDetailInfoPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
    self.m_AptitudeList = {"attack", "defense", "health", "mana", "speed"}
    self.m_SummonNormalList = {}
    self.m_SummonSpecialList = {}
    self.m_SelectBox = nil
    self.m_NormalSummon = 1
    self.m_SpecialSummon = 2
end

function CSummonDetailInfoPart.OnInitPage(self)
	self.m_SummonGrid = self:NewUI(1, CGrid)
    self.m_SummonItem = self:NewUI(2, CBox)
    self.m_NormalBtn = self:NewUI(3, CButton)
    self.m_SpecialBtn = self:NewUI(4, CButton)
    self.m_SummonTexture = self:NewUI(5, CActorTexture)
    self.m_SummonName = self:NewUI(6, CLabel)
    self.m_SummonDesBtn = self:NewUI(7, CButton)
    self.m_SummonType = self:NewUI(8, CSprite)
    self.m_GetGrade = self:NewUI(9, CLabel)
    self.m_TalentLabel = self:NewUI(10, CLabel)
    self.m_AptitudeGrid = self:NewUI(11, CGrid)
    self.m_SkillGrid = self:NewUI(12, CGrid)
    self.m_SkillItem = self:NewUI(13, CBox)
    self.m_GoGetSummonBtn = self:NewUI(14, CButton)
    self.m_SummonScrollView = self:NewUI(15, CScrollView)
    self.m_GetItemBox = self:NewUI(16, CBox)
    self.m_GetCompoundBox = self:NewUI(17, CBox)
    self.m_SummonIcon_1 = self:NewUI(18, CSprite)
    self.m_SummonIcon_2 = self:NewUI(19, CSprite)
    self.m_SummonIcon_3 = self:NewUI(20, CSprite)
    self.m_GetItemIcon = self:NewUI(21, CSprite)
    self.m_GetItemName = self:NewUI(22, CLabel)
    self.m_GetItemBtn = self:NewUI(23, CButton)
    self.m_GetItemTips = self:NewUI(24, CButton, true, false)
    self.m_GetItemCount = self:NewUI(25, CLabel)
    self.m_SkillScrollView = self:NewUI(26 , CScrollView)
    self.m_PathBtn = self:NewUI(27, CButton)
    self.m_PathLable = self:NewUI(28, CLabel)
    self.m_DuDuDesLabel = self:NewUI(29, CLabel)
	self:InitContent()
end

function CSummonDetailInfoPart.InitContent(self)
    self.m_NormalBtn:AddUIEvent("click", callback(self, "OnSelNormal"))
    self.m_SpecialBtn:AddUIEvent("click", callback(self, "OnSelSpecial"))
    self.m_SummonDesBtn:AddUIEvent("click", callback(self, "OnDes"))
    self.m_GoGetSummonBtn:AddUIEvent("click", callback(self, "OnGoBuySummon"))
    self.m_GetItemTips:AddUIEvent("click", callback(self, "OnItemTips"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    self.m_NormalBtn:SetGroup(self:GetInstanceID())
    self.m_SpecialBtn:SetGroup(self:GetInstanceID())
    self.m_NormalBtn:SetSelected(true)
    self:CalculateList()
    self:InitAptitude()
    self:InitSummonGrid(self.m_NormalSummon)
    if not self.m_ParentView.m_NotShowDetailDefault then
        local info = data.summondata.INFO[self.m_SummonNormalList[1].id]
        self:OnSelSummon(info)
    end
end

function CSummonDetailInfoPart.CalculateList(self)
    self.m_SummonSpecialList = {}
    self.m_SummonNormalList = {}
    for k,v in pairs(data.summondata.INFO) do                     --暂时屏蔽携带90级以上的宠物
        if (v.type == 3 or v.type == 4 or v.type == 5) and v.carry <= g_AttrCtrl.grade + 10 and v.carry < 90 then
            table.insert(self.m_SummonSpecialList, v)
        end
        --(v.type == 1 or v.type == 2) and -- 全部宠物
        if  v.carry <= g_AttrCtrl.grade+10 and v.carry < 90 then --暂时屏蔽携带90级以上的宠物
            table.insert(self.m_SummonNormalList, v)
        end
    end

    local function Rank(v1, v2)
        if v1.carry == v2.carry then
            local val1 = self:CalculateScore(v1)
            local val2 = self:CalculateScore(v2)
            return  val1 < val2
        else
            return v1.carry < v2.carry
        end 
    end
    table.sort(self.m_SummonSpecialList, Rank)
    table.sort(self.m_SummonNormalList, Rank)
end

function CSummonDetailInfoPart.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        if oCtrl.m_EventData.dAttr and oCtrl.m_EventData.dAttr.grade then
            self:CalculateList()
            self:InitSummonGrid(self.CurSelType)
            self:OnSelSummon(self.m_CurSummonInfo)
        end
	end
end

function CSummonDetailInfoPart.OnRefreshItem(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.AddBagItem or 
	oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
        if self.m_ItemInfo ~= nil then
            local itemInfo = DataTools.GetItemData(self.m_ItemInfo.id)
            local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemInfo.id)
            self.m_GetItemCount:SetText(string.format("%s/%s", count, self.m_ItemInfo.cnt))
            if count < self.m_ItemInfo.cnt then
                self.m_GetItemCount:SetColor(Color.red)
            else
                self.m_GetItemCount:SetColor(Color.black)
            end
        end
	end
end

function CSummonDetailInfoPart.SetInfo(self, summonInfo)
    self.m_ItemInfo = nil
    
    local model_info =  table.copy(summonInfo)
    model_info.rendertexSize = 0.8
    self.m_SummonTexture:ChangeShape(model_info)

    self.m_SummonName:SetText(summonInfo.name)
    self.m_SummonType:SetSpriteName(data.summondata.SUMMTYPE[summonInfo.type].icon)
    self.m_GetGrade:SetText("人物"..summonInfo.carry.."级可携带")
    self.m_CurSummonId = summonInfo.id
    if g_AttrCtrl.grade < summonInfo.carry then
        self.m_GetGrade:SetColor(Color.red)
        self.m_GoGetSummonBtn:SetGrey(true)
    else
        self.m_GetGrade:SetColor(Color.New(99/255, 67/255, 44/255, 1))
         self.m_GoGetSummonBtn:SetGrey(false)
    end
    if next(summonInfo.item) then
        self.m_GetItemBox:SetActive(true)
        local itemInfo = DataTools.GetItemData(summonInfo.item.id)
        local count = g_ItemCtrl:GetBagItemAmountBySid(summonInfo.item.id)
        self.m_ItemInfo = summonInfo.item
        self.m_GetItemName:SetText(string.format("个%s兑换", itemInfo.name))
        self.m_GetItemCount:SetText(string.format("%s/%s", count, summonInfo.item.cnt))
        if count < summonInfo.item.cnt then
            self.m_GetItemCount:SetColor(Color.red)
        else
            self.m_GetItemCount:SetColor(Color.black)
        end
        self.m_GetItemIcon:SetSpriteName(tostring(itemInfo.icon))
        self.m_GetItemBtn:AddUIEvent("click", callback(self, "OnGetItemBtn", summonInfo.item))
    else
        self.m_GetItemBox:SetActive(false)                   
    end
    if self:GetCopoundData()[summonInfo.id] then

        self.m_GetCompoundBox:SetActive(true)
        if summonInfo.id == 1003 then
            self.m_PathBtn:SetActive(true)
            self.m_PathBtn:AddUIEvent("click", callback(self, "OnPathClick"))
            self.m_PathLable:SetText("合\n成\n方\n案\n一")
        else
            self.m_PathBtn:SetActive(false)
        end
        local compoundData = self:GetCopoundData()[summonInfo.id]

        local summon1 = data.summondata.INFO[compoundData.sid1]
        self.m_SummonIcon_1:SetSpriteName(tostring(summon1.shape))
        self.m_SummonIcon_1:AddUIEvent("click", callback(self, "OnClickIcon",summon1.id))

        local summon2 = data.summondata.INFO[compoundData.sid2]
        self.m_SummonIcon_2:SetSpriteName(tostring(summon2.shape))
        self.m_SummonIcon_2:AddUIEvent("click", callback(self, "OnClickIcon",summon2.id))


        self.m_SummonIcon_3:SetSpriteName(tostring(summonInfo.shape))
    else
        self.m_GetCompoundBox:SetActive(false)
    end
    self.m_DuDuDesLabel:SetActive(false)
    if summonInfo.id == 2028 then --嘟嘟 做特殊处理
        self.m_DuDuDesLabel:SetActive(true)
    end
    if summonInfo.store == 1 or summonInfo.store == 2 or summonInfo.store == 3 then
        if summonInfo.store == 1 then
           self.m_GoGetSummonBtn:SetText("前往宠物商店购买")
           self.m_GoGetSummonBtn:SetActive(true)
        elseif summonInfo.store == 2 then
           self.m_GoGetSummonBtn:SetText("前往合成")
           self.m_GoGetSummonBtn:SetActive(false)
        elseif summonInfo.store == 3 then
           self.m_GoGetSummonBtn:SetText("前往商会购买")
           self.m_GoGetSummonBtn:SetActive(true)
        end
    else
        self.m_GoGetSummonBtn:SetActive(false) 
    end
end

function CSummonDetailInfoPart.OnPathClick(self)
    -- body
    local sprname = self.m_SummonIcon_1:GetSpriteName()
    if sprname == "5111" then
        self.m_PathLable:SetText("合\n成\n方\n案\n二")
        self.m_SummonIcon_1:SetSpriteName(5101)
        self.m_SummonIcon_1:AddUIEvent("click", callback(self, "OnClickIcon", 1000))
    elseif sprname =="5101" then
        self.m_SummonIcon_1:SetSpriteName(5111)
        self.m_SummonIcon_1:AddUIEvent("click", callback(self, "OnClickIcon", 1001))
        self.m_PathLable:SetText("合\n成\n方\n案\n一")
    end
end

function CSummonDetailInfoPart.CalculateScore(self, summonInfo)
    local aptitudeScore = 0  --资质评分
    local maxAptitudeScore = 0
    for k,v in pairs(summonInfo.aptitude) do
        aptitudeScore = aptitudeScore + v  
        maxAptitudeScore = math.floor(v*125/100) + maxAptitudeScore
    end
    local skillScore = 0 --技能评分
    for k,v in pairs(summonInfo.skill1) do
        skillScore = data.summondata.SKILL[v].score +1*30 + skillScore
    end
    for k,v in pairs(summonInfo.skill2) do
        skillScore = data.summondata.SKILL[v].score +1*30 + skillScore
    end
    for k,v in pairs(summonInfo.talent) do
        skillScore = data.summondata.SKILL[v].score + skillScore
    end
    local grownScore = 0
    local maxGrownScore = 0
    if summonInfo.type == 1 then
        grownScore = summonInfo.grow * 95/100
        maxGrownScore = summonInfo.grow * 100/100
    else
        grownScore = summonInfo.grow * 95/100
        maxGrownScore = summonInfo.grow * 125/100
    end
    local sumScore = math.floor(aptitudeScore + grownScore + skillScore) 
    local sumMaxScore = math.floor(maxAptitudeScore + maxGrownScore + skillScore)
    return sumScore+3700,sumMaxScore+3700
end

function CSummonDetailInfoPart.InitAptitude(self)
    local function init(obj, idx)
		local oBox = CBox.New(obj)
		oBox.val = oBox:NewUI(1, CLabel)
		return oBox
	end
	self.m_AptitudeGrid:InitChild(init)
end

function CSummonDetailInfoPart.SetAptitude(self, summonInfo)
    for k,v in ipairs(self.m_AptitudeList) do
        local item = self.m_AptitudeGrid:GetChild(k)
        local maxVal = 0
        if summonInfo.type < 3 then
            maxVal = math.floor(summonInfo.aptitude[v]*125/100)
        else
            maxVal = math.floor(summonInfo.aptitude[v]*1.30)
        end
        local val = math.floor(summonInfo.aptitude[v]*1.03)
        item.val:SetText(val.."~"..maxVal)
    end

    local maxtb = {}
    local mintb = {}
    local num = #data.summondata.GROW
    for i,v in ipairs(data.summondata.GROW) do 
        table.insert(maxtb,v.max)
        table.insert(mintb,v.min)
    end

    table.sort(maxtb)
    local GrowMax 
    for i,v in ipairs(maxtb) do
        if num == i then
            GrowMax= v
        end
    end

    local GrowMin
    GrowMin =mintb[1]

    local minGrow = string.format("%0.4f", GrowMin * summonInfo.grow * 0.00001)
    local num1 = string.sub(tostring(minGrow),0,-2)
    local maxGrow = string.format("%0.4f", GrowMax * summonInfo.grow * 0.00001)
    local num2 = string.sub(tostring(maxGrow),0,-2)
    self.m_AptitudeGrid:GetChild(6).val:SetText(num1.."~"..num2)
end



function CSummonDetailInfoPart.InitSkill(self, summonInfo)
    local index = 1
    for k,v in pairs(summonInfo.talent) do
        self:AddSkillItem(index, v, true)
        index = index + 1
    end
    for k,v in pairs(summonInfo.skill1) do
        self:AddSkillItem(index, v, false, 1)
        index = index + 1
    end
    for k,v in pairs(summonInfo.skill2) do
        self:AddSkillItem(index, v, false, 2)
        index = index + 1
    end
    local sum = self.m_SkillGrid:GetCount()
    if sum < 7 then
        sum = 7
    end
    for i = index, sum do
        if i <= 7 then
            self:AddEmptySkillItem(i)
        else
            self.m_SkillGrid:GetChild(i):SetActive(false)
        end      
    end
    self.m_SkillScrollView:ResetPosition()
end

function CSummonDetailInfoPart.AddEmptySkillItem(self, index)
    local item = self.m_SkillGrid:GetChild(index)
    if item == nil then
        item = self.m_SkillItem:Clone()
        item.icon = item:NewUI(1, CSprite)
        item.isTalent = item:NewUI(2, CSprite)
        item.sureSpr = item:NewUI(3, CSprite)
        self.m_SkillGrid:AddChild(item)
    end
    item.isTalent:SetActive(false)
    item.icon:SetActive(false)
    item.sureSpr:SetActive(false)
    item:AddUIEvent("click", nil)
    item:SetActive(true)
end

function CSummonDetailInfoPart.AddSkillItem(self, index, skillid, isTalent, skillIndex)
    local item = self.m_SkillGrid:GetChild(index)
    if item == nil then
        item = self.m_SkillItem:Clone()
        item.icon = item:NewUI(1, CSprite)
        item.isTalent = item:NewUI(2, CSprite)
        item.sureSpr = item:NewUI(3, CSprite)
        self.m_SkillGrid:AddChild(item)
    end
    item.isTalent:SetActive(isTalent)
    item.icon:SetActive(true)
    item.sureSpr:SetActive(skillIndex == 1)

    local skill = data.summondata.SKILL[skillid]
    item.icon:SpriteAdvancedSkill(skill.iconlv)
    item:AddUIEvent("click", callback(self, "OnSkillTips", item, skillid, isTalent, skillIndex))
    item:SetActive(true)
end

function CSummonDetailInfoPart.OnSkillTips(self, item, skillid, istalent, skillIndex)
    local summon = self:GetSummonBysid(self.m_CurSummonId)
    local info = {sk = skillid ,level = 1}
    -- table.print(summon, "PPPPPPPPPPPPPPPPP")
    -- if summon and skillIndex and summon.skill[skillIndex] then
    --    info = summon.skill[skillIndex]
    -- end

    CSummonSkillItemTipsView:ShowView(function (oView)
        oView:SetData(info, item:GetPos(), istalent, nil)  
    end)
 --    local skill = data.summondata.SKILL[skillid]
 --    local formula1 = string.gsub(skill.formula1, "level", g_HorseCtrl.grade)
	-- local val1 = loadstring("return "..formula1)
	-- local cur = string.gsub(skill.des, "#1", val1)
	-- local formula2 = string.gsub(skill.formula2, "level", g_HorseCtrl.grade)	
	-- local val2 = loadstring("return "..formula2)
 --    cur = string.gsub(cur, "#2", val2)
    -- local args = {
    --     widget= item,
    --     side = enum.UIAnchor.Side.Top,
    --     icon = skill.icon,
    --     name = skill.name,
    --     introduction = "",
    --     description = cur,
    -- }
    --g_WindowTipCtrl:SetWindowSkillTip(args)
end

function CSummonDetailInfoPart.InitSummonGrid(self, type)
    self.CurSelType = type
    local list = nil
    if type == 1 then
        list = self.m_SummonNormalList
    elseif type == 2 then
        list = self.m_SummonSpecialList
    end
    for k,v in ipairs(list) do
       -- local info = data.summondata.INFO[v]
        local item = self.m_SummonGrid:GetChild(k)
        if item == nil then
            item = self.m_SummonItem:Clone()
            item:SetActive(true)
            item:SetGroup(self.m_SkillGrid:GetInstanceID())
            item.icon = item:NewUI(1, CSprite)
            self.m_SummonGrid:AddChild(item)
        end
        item:SetActive(true)
        item.icon:SetSpriteName(tostring(v.shape))
        if v.carry > g_AttrCtrl.grade and v.carry <= g_AttrCtrl.grade+10 then
            item.icon:SetGrey(true)
        else
            item.icon:SetGrey(false)
        end
        item.data = v
        item:AddUIEvent("click", callback(self, "OnSelSummon", v, item)) 
        self.m_SummonGrid:GetChild(1):SetSelected(true)  
    end
    for i = #list + 1, self.m_SummonGrid:GetCount() do
        self.m_SummonGrid:GetChild(i):SetActive(false)
    end
    self.m_SummonScrollView:ResetPosition()
end


function CSummonDetailInfoPart.OnSelSummon(self, info, box)
    self.m_CurSummonInfo = info
    --这是设置的box是因为活动界面点击宠物碎片可以跳转进来
    if box then
        self.m_SelectBox = box
    else
        local list = self.m_SummonGrid:GetChildList()
        for i,box in ipairs(list) do
            if box.data== info  then
                box:SetSelected(true)
            end
        end
    end
    self:SetInfo(info)
    self:SetAptitude(info)
    self:InitSkill(info)
end

function CSummonDetailInfoPart.OnClickIcon(self, summonid)
    local summoninfo = nil
    local infoDic = data.summondata.INFO
    for _,info in pairs(infoDic) do
        if summonid == info.id then
            summoninfo = info 
            break 
        end
    end
    if not summoninfo  then
        return
    end
    self.m_NormalBtn:SetSelected(true)
    self.m_SpecialBtn:SetSelected(false)
    self:InitSummonGrid(self.m_NormalSummon)

    local Pos 
    for i, v in ipairs(self.m_SummonNormalList) do
        if summonid == v.id then
            Pos = i
            break
        end
    end
    self.m_SummonGrid:GetChild(Pos):SetSelected(true)
    self:OnSelSummon(summoninfo)
end

function CSummonDetailInfoPart.OnSelNormal(self)
    self:InitSummonGrid(self.m_NormalSummon)
    if self.m_SummonNormalList[1] == nil then
        return
    end
    local info = data.summondata.INFO[self.m_SummonNormalList[1].id]
    self.m_SummonGrid:GetChild(1):SetSelected(true)
    self:OnSelSummon(info)
end

function CSummonDetailInfoPart.OnSelSpecial(self)
    self:InitSummonGrid(self.m_SpecialSummon)
    if self.m_SummonSpecialList[1] == nil then
        return
    end
    local info = data.summondata.INFO[self.m_SummonSpecialList[1].id]
    self.m_SummonGrid:GetChild(1):SetSelected(true)
    self:OnSelSummon(info)
end

function CSummonDetailInfoPart.OnGoBuySummon(self)
    local info = data.summondata.INFO[self.m_CurSummonId]
    if info.store == 1 then
        if g_AttrCtrl.grade < info.carry then
            g_NotifyCtrl:FloatMsg("需要达到可携带等级才能购买")
            return
        end
        CSummonStoreView:ShowView(function (oView)
            oView:SetSelectSummon(self.m_CurSummonId, info.carry)
        end)
    elseif info.store == 2 then
        if g_AttrCtrl.grade < info.carry then
            g_NotifyCtrl:FloatMsg("需要达到可携带等级才能合成")
            return
        end
        local oView = CSummonMainView:GetView()
        if oView then
           oView:ShowSubPageByIndex(2)
           oView.m_AdjustPart:OnCompoundShow()
        end
    elseif info.store == 3 then
        if g_AttrCtrl.grade < info.carry then
            g_NotifyCtrl:FloatMsg("需要达到可携带等级才能购买")
            return
        end
        local summonItemID = DataTools.GetSummonItem(info.id)
        g_ViewCtrl:ShowViewBySysName("交易所", "商会", function(oView)
            --TODO:写死第二页跳转 宠物-元灵或者指定一个物品跳转
            -- oView.m_GuildPart:JumpToTargetCatalog(2, 2)
            oView:JumpToTargetItem(summonItemID)
        end)

    end
end

function CSummonDetailInfoPart.OnGetItemBtn(self, item)
    local itemInfo = DataTools.GetItemData(item.id)
    local count = g_ItemCtrl:GetBagItemAmountBySid(item.id)
    if count < item.cnt then
        g_NotifyCtrl:FloatMsg(itemInfo.name.."不足！")
        return 
    end
    --兑换协议
    g_SummonCtrl:C2GSExchangeSummon(self.m_CurSummonId)
end

function CSummonDetailInfoPart.OnDes(self)
    local zContent = {title = data.instructiondata.DESC[10005].title,desc = data.instructiondata.DESC[10005].desc}
    g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CSummonDetailInfoPart.OnItemTips(self)
    g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemInfo.id)
end

function CSummonDetailInfoPart.GetCopoundData(self)
    local CopoundData = data.summondata.XIYOU
    local tempData = {}
    for i,v in ipairs(CopoundData) do
        tempData[v.sid3] = v
    end
    return tempData
    -- return CopoundData
end

function CSummonDetailInfoPart.GetSummonBysid(self, sid)
    return data.summondata.INFO[sid]
end

return CSummonDetailInfoPart