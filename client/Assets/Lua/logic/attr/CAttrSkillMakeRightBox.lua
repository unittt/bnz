local CAttrSkillMakeRightBox = class("CAttrSkillMakeRightBox", CBox)

function CAttrSkillMakeRightBox.ctor(self, obj)
	CBox.ctor(self, obj)
    self.m_ItemList = {}
    self.m_AutoBtn = self:NewUI(1, CSprite)
    self.m_Item_01 = self:NewUI(2, CSprite)
    self.m_Item_02 = self:NewUI(3, CSprite)
    self.m_Item_03 = self:NewUI(4, CSprite)
    self.m_Item_04 = self:NewUI(5, CSprite)
    self.m_Item_05 = self:NewUI(6, CSprite)
    self.m_CostVitality = self:NewUI(8, CLabel)
    self.m_MakeBtn = self:NewUI(7, CButton)
    self.m_des = self:NewUI(9, CLabel)

    self.m_AutoBtn:SetSelected(g_AttrCtrl.makeDragAuto)
    self.m_AutoBtn:AddUIEvent("click", callback(self, "RefreshDrag"))
    -- g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "AutoAddDrag"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent")) 

end

function CAttrSkillMakeRightBox.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.GetUseOrgSkill then
        if next(oCtrl.m_EventData) ~= nil then
            self:MakeFinish(oCtrl.m_EventData)
            g_NotifyCtrl:FloatMsg("制作成功！")
        else
            g_NotifyCtrl:FloatMsg("制作失败！")
        end
    end
    if oCtrl.m_EventID == define.Attr.Event.Change then
        --self.m_CurVitality:SetText("当前活力："..g_AttrCtrl.energy)
        self.m_CostVitality:SetText(math.min(40, self.m_CurSkill.level+10).."/"..g_AttrCtrl.energy)
    end
end

function CAttrSkillMakeRightBox.InitContent(self, skill)
    self.m_CurSkill = skill
    self.tSkill = data.skilldata.ORGSKILL[self.m_CurSkill.sk]
    for i=1, 5 do
        self["m_Item_0"..i]:SetSpriteName("")
        if i< 5 then
            self["m_Item_0"..i]:AddUIEvent("click", callback(self, "OnItemClick", i))
        end
    end
    self.m_des:SetText("有机率炼制出：\n"..self.tSkill.makeitemdes)
    --self.m_CurVitality:SetText("当前活力："..g_AttrCtrl.energy)
    self.m_CostVitality:SetText(math.min(40, skill.level+10).."/"..g_AttrCtrl.energy)
    self.m_MakeBtn:AddUIEvent("click", callback(self, "OnMake"))
    --self.m_CostHint:SetActive(true)
    self.m_ItemList = {}
    --self.m_CostHint:SetText("消耗10000银币补足药材")
    if g_AttrCtrl.makeDragAuto then
        self:AutoAddDrag()
    end
end

function CAttrSkillMakeRightBox.SetInfo(self, item)
    local count = self:CheckItemCount(item.id) --每添加到炼药界面前，先检查一次背包中剩余数量
    if count <= 0 or table.count(self.m_ItemList) >= 4 then
        return count
    end

    for i=1, 4 do
        if self.m_ItemList[i] == nil then
            self.m_ItemList[i] = item
            break
        end
    end

    count = count - 1
    self.m_NeedSilver = (4-table.count(self.m_ItemList))*2500
    if table.count(self.m_ItemList) >= 4 then
        --self.m_CostHint:SetActive(false)
        self.m_NeedSilver = 0
    end  
    --self.m_CostHint:SetText(string.format("消耗%s银币补足药材", self.m_NeedSilver)) 

    for i = 1, 4 do
        local oItem = self["m_Item_0"..i]
        local spriteName = oItem:GetSpriteName()
        if spriteName == "" then 
            local v = self.m_ItemList[i]
            if v then
                oItem:SetSpriteName(tostring(v.icon))
            end
        end
    end

    -- for k, v in ipairs(self.m_ItemList) do
    --     self["m_Item_0"..k]:SetSpriteName(tostring(v.icon))
    -- end
    return count
end

function CAttrSkillMakeRightBox.CheckItemCount(self, itemId)
    local count = g_ItemCtrl:GetBagItemAmountBySid(itemId)
    for k, v in pairs(self.m_ItemList) do
        if v.id == itemId then
             count = count - 1
        end
    end
    return count
end

function CAttrSkillMakeRightBox.MakeFinish(self, data)

    local item = DataTools.GetItemData(data[1].itemid)
    self.m_Item_05:SetSpriteName(tostring(item.icon))

    local useItem = {}

    for k, v in pairs(self.m_ItemList) do
        if not table.index(useItem, v) then
            useItem[#useItem + 1] = v
        end
    end

    for i=1, 4 do
        self["m_Item_0"..i]:SetSpriteName("")
        self.m_ItemList[i] = nil
    end
     -- 炼完一次药后根据是否自动填充进行不同的填充逻辑 --
    if g_AttrCtrl.makeDragAuto then
        self:AutoAddDrag()
        return
    end

    for i, v in ipairs(useItem) do
        local count = g_ItemCtrl:GetBagItemAmountBySid(v.id)
        if count >= 1 then
            for i=1, count do
                self:SetInfo(v)
            end
        end
    end

    -------------------------------------------------------------------
    -- self.m_ItemList= {}
    -- if #self.m_ItemList >= 4 then
    --     self.m_CostHint:SetActive(false)
    -- else
    --    self.m_CostHint:SetActive(true)
    -- end
    -- self.m_NeedSilver = (4-#self.m_ItemList)*2500
    -- self.m_CostHint:SetText(string.format("消耗%s银币补足药材", self.m_NeedSilver))
end

function CAttrSkillMakeRightBox.OnItemClick(self, i)
    local oItem = self["m_Item_0"..i]
    local spriteName = oItem:GetSpriteName()
    if spriteName == "" then 
        return
    else
        self.m_ItemList[i] = nil
        self["m_Item_0"..i]:SetSpriteName("")
    end
end

function CAttrSkillMakeRightBox.OnMake(self)
    if table.count(self.m_ItemList) < 4 then
        g_NotifyCtrl:FloatMsg("药材不足，不能炼制！")
        return
    end
    local item = {}
    for k,v in pairs(self.m_ItemList) do
        table.insert(item, v.id)
    end
    self.m_NeedSilver = (4-table.count(self.m_ItemList))*2500
    if g_AttrCtrl.silver < self.m_NeedSilver then
        g_NotifyCtrl:FloatMsg("银币不足，炼制失败！")
        g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
        return
    end
    if g_AttrCtrl.energy < g_AttrCtrl:EnergyCalculate(self.m_CurSkill) then
        g_NotifyCtrl:FloatMsg("活力不足！")
        CAttrBuyEnergyView:ShowView()
        return
    end
    netskill.C2GSUseOrgSkill(self.m_CurSkill.sk, item)
end

--自动填充药物
function CAttrSkillMakeRightBox.AutoAddDrag(self)
    for k, v in pairs(self.tSkill.make_item) do
        local count =  g_ItemCtrl:GetBagItemAmountBySid(v)
        local num = count <= 4 and count or 4
        for i=1, num do
            local item = g_AttrCtrl:GetDragItem(v)
            self:SetInfo(item)
        end
    end
end

--取消自动添加药材
-- function CAttrSkillMakeRightBox.RemoveAuto(self)
--     for k,v in pairs(self.m_ItemList) do
--         self["m_Item_0"..k]:SetSpriteName("")    
--     end
--     self.m_ItemList = {}
-- end

--刷新自动选药 
function CAttrSkillMakeRightBox.RefreshDrag(self)
    if g_AttrCtrl.makeDragAuto then
        g_AttrCtrl.makeDragAuto = false
        --self:RemoveAuto()
    else
        g_AttrCtrl.makeDragAuto = true
        self:AutoAddDrag()
        g_AttrCtrl:OnEvent(define.Attr.Event.AutoMakeDrag)
    end
end
return CAttrSkillMakeRightBox
