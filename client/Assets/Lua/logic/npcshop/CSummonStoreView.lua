local CSummonStoreView = class("CSummonStoreView", CViewBase)

function CSummonStoreView.ctor(self, cb)
	CViewBase.ctor(self, "UI/NpcShop/SummonStoreView.prefab", cb)
    --界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
    self.m_ItemId = 10031
end

function CSummonStoreView.OnCreateView(self)
	self.m_BuyBtn = self:NewUI(1, CButton)
    self.m_CoinsLabel = self:NewUI(2, CLabel)
    self.m_AddCoinsBtn = self:NewUI(3, CButton)
    self.m_RItemGrid = self:NewUI(4, CGrid)
    self.m_RItemClone = self:NewUI(5, CBox)
    self.m_ScrollView = self:NewUI(6, CScrollView)
    self.m_LItemGrid = self:NewUI(7, CGrid)
    self.m_LItemClone = self:NewUI(8, CBox)
    self.m_HintLabel = self:NewUI(9, CLabel)
    self.m_CoinName = self:NewUI(10, CLabel)
    self.m_CostLabel = self:NewUI(11, CLabel)
    self.m_CloseBtn = self:NewUI(12, CButton)
    self.m_AddCoinsBtn = self:NewUI(13, CButton)

    self.m_SelectGrade = nil

	self:InitContent()
    self:InitLGird()
    self:OnSelectUseGrade(self.m_UseGradeList[1])  --默认显示携带等级最低级的宠物
    self.m_LItemGrid:GetChild(1):SetSelected(true)

    self:SetTaskSelectSummon()
end

function CSummonStoreView.InitContent(self)
    self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuySummon"))
	self.m_AddCoinsBtn:AddUIEvent("click", callback(self, "OnSilverAddBtn"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_AddCoinsBtn:AddUIEvent("click", callback(self, "OnAddCoins"))

    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSummonEvent"))
    self.m_CoinsLabel:SetCommaNum(g_AttrCtrl.silver)
    self.m_CostLabel:SetText(0)
end

function CSummonStoreView.InitLGird(self)
    self.m_UseGradeList = {}
    for k,v in pairs(data.summondata.USEGRADE) do
        table.insert(self.m_UseGradeList, k)
    end
    table.sort(self.m_UseGradeList, function (v1, v2)
        return v1 < v2
    end)
    for k,v in ipairs(self.m_UseGradeList) do 
        local summonid = data.summondata.USEGRADE[v][1]
        local slv = data.summondata.STORE[summonid].slv
        if g_AttrCtrl.grade >= v and g_AttrCtrl.server_grade >= slv then
            -- local item = self.m_LItemClone:Clone()
            local item = self.m_LItemGrid:GetChild(k)
            if item == nil then
                item = self.m_LItemClone:Clone()
                item:SetGroup(self.m_LItemGrid:GetInstanceID())
                item.textLbl = item:NewUI(1, CLabel)
                item.needSp = item:NewUI(2, CSprite)
                item.name = item:NewUI(3, CLabel)
                self.m_LItemGrid:AddChild(item)
            end
            item:SetActive(true)
           
            item.textLbl:SetText("携带等级"..v)
             item.name:SetText("携带等级"..v)
            if self:CheckLItemCloneNeedSp(v) then
                item.needSp:SetActive(true)
            else
                item.needSp:SetActive(false)
            end
            item.carry = v
            item:AddUIEvent("click", callback(self, "OnSelectUseGrade", v))           
        end
    end
end

function CSummonStoreView.CheckLItemCloneNeedSp(self, grade)
    for k,v in ipairs(data.summondata.USEGRADE[grade]) do
        if g_TaskCtrl:GetIsTaskNeedSum(v) then
            return true
        end
    end
    return false
end

function CSummonStoreView.SetTaskSelectSummon(self)
     if CTaskHelp.GetClickTaskShopSelect() then
        local needsum = g_TaskCtrl:GetTaskNeedSumList(CTaskHelp.GetClickTaskShopSelect(), true)[1]
        
        local summonid = needsum
        local grade
        for k,v in ipairs(self.m_UseGradeList) do
            for g,h in pairs(data.summondata.USEGRADE[v]) do
                if needsum and h == needsum then
                    grade = v
                    break
                end
            end
        end
        if summonid and grade then
            self:SetSelectSummon(summonid, grade)
        end
        -- CTaskHelp.SetClickTaskShopSelect(nil)          
    end
end

function CSummonStoreView.OnSelectUseGrade(self, grade)
    for k,v in ipairs(data.summondata.USEGRADE[grade]) do
        local item = self.m_RItemGrid:GetChild(k)
        if item == nil then
            item = self.m_RItemClone:Clone()
            item:SetGroup(self.m_RItemGrid:GetInstanceID())
            item.name = item:NewUI(1, CLabel)
            item.icon = item:NewUI(2, CSprite)
            item.price = item:NewUI(3, CLabel)
            item.needSp = item:NewUI(4, CSprite)
            self.m_RItemGrid:AddChild(item)
        end
        item:SetActive(true)
        local summonInfo = DataTools.GetSummonInfo(v)
        item.name:SetText(summonInfo.name)
        item.price:SetCommaNum(data.summondata.STORE[v].price)
        item.icon:SetSpriteName(tostring(summonInfo.shape))
        if g_TaskCtrl:GetIsTaskNeedSum(v) then
            item.needSp:SetActive(true)
        else
            item.needSp:SetActive(false)
        end
        item.id = summonInfo.id
        item:ForceSelected(false)
        item:AddUIEvent("click", callback(self, "OnSelectSummon", v))
    end
    local count = #data.summondata.USEGRADE[grade]
    for i = count + 1, self.m_RItemGrid:GetCount() do
        self.m_RItemGrid:GetChild(i):SetActive(false)               
    end
    self.m_RItemGrid:Reposition()
    self.m_ScrollView:ResetPosition()
    self.m_CoinsLabel:SetCommaNum(g_AttrCtrl.silver)
    -- self.m_CurSummonId = nil
    -- self.m_CostLabel:SetText(0)
    for k,v in pairs(self.m_RItemGrid:GetChildList()) do
        if data.summondata.USEGRADE[grade][1] == v.id then
            v:SetSelected(true)
            self:OnSelectSummon(data.summondata.USEGRADE[grade][1])
        end
    end
end

function CSummonStoreView.OnSelectSummon(self, id)
    self.m_CostLabel:SetCommaNum(data.summondata.STORE[id].price)
    self.m_CurSummonId = id
end

function CSummonStoreView.SetSelectSummon(self, id, carry)
    for k,v in pairs(self.m_LItemGrid:GetChildList()) do
        if v.carry == carry then
            self:OnSelectUseGrade(v.carry)
            v:SetSelected(true)    
        end
    end
    for k,v in pairs(self.m_RItemGrid:GetChildList()) do
        if id == v.id then
            --UITools.MoveToTarget(self.m_ScrollView, v)  --策划说取消滚动到选中的宠物
            v:SetSelected(true)
            self:OnSelectSummon(id)
        end
    end
end

function CSummonStoreView.OnAttrEvent(self, oCtrl)
   self.m_CoinsLabel:SetCommaNum(g_AttrCtrl.silver)
end

function CSummonStoreView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Task.Event.AddTask or oCtrl.m_EventID == define.Task.Event.DelTask then
        --self:InitGridBox()
        self:InitLGird()
        local grade
        for k,v in ipairs(self.m_UseGradeList) do
            for g,h in pairs(data.summondata.USEGRADE[v]) do
                if self.m_CurSummonId and h == self.m_CurSummonId then
                    grade = v
                    break
                end
            end
        end
        self:SetSelectSummon(self.m_CurSummonId, grade)
    end
end

function CSummonStoreView.OnCtrlSummonEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.AddSummon or oCtrl.m_EventID == define.Summon.Event.DelSummon then
       -- self:InitGridBox()
        self:InitLGird()
        local grade
        for k,v in ipairs(self.m_UseGradeList) do
            for g,h in pairs(data.summondata.USEGRADE[v]) do
                if self.m_CurSummonId and h == self.m_CurSummonId then
                    grade = v
                    break
                end
            end
        end
        self:SetSelectSummon(self.m_CurSummonId, grade)

        if oCtrl.m_EventID == define.Summon.Event.AddSummon then
            if CTaskHelp.GetClickTaskShopSelect() then
                local taskNeedList = g_TaskCtrl:GetTaskNeedSumList(CTaskHelp.GetClickTaskShopSelect(), true)
                if (not taskNeedList or not next(taskNeedList)) then
                    if g_TaskCtrl.m_OpenShopForTaskSessionidx then
                        g_TaskCtrl:SendOpenShopForTaskSessionidx()
                    elseif g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb then
                        g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb()
                    else
                        CTaskHelp.ClickTaskLogic(CTaskHelp.GetClickTaskShopSelect())
                    end
                    self:OnClose()
                end
            end
        end
    end
end

function CSummonStoreView.OnBuySummon(self)
    if self.m_CurSummonId == nil then
        g_NotifyCtrl:FloatMsg("请选择宠物")
        return
    end
    if g_AttrCtrl.grade < data.summondata.STORE[self.m_CurSummonId].usegrade then
        g_NotifyCtrl:FloatMsg("等级不足")
        return
    end
    local iPrice = self:GetSummonPrice(self.m_CurSummonId)
    if (g_AttrCtrl.silver < iPrice) then
        g_QuickGetCtrl:CheckLackItemInfo({
            coinlist = {{sid = 1002, amount = iPrice, count = g_AttrCtrl.silver}},
            exchangeCb = function()
                netsummon.C2GSBuySummon(self.m_CurSummonId)
            end
        })
        -- g_NotifyCtrl:FloatMsg("银币不足，购买失败")
        return
    end
    netsummon.C2GSBuySummon(self.m_CurSummonId)
end

function CSummonStoreView.GetSummonPrice(self, summonId)
    if data.summondata.STORE[summonId] then
        return data.summondata.STORE[summonId].price
    end
end

function CSummonStoreView.GetSummonName(self, summonId)
    if data.summondata.STORE[summonId] then
        return data.summondata.STORE[summonId].name
    end
end

function CSummonStoreView.OnSilverAddBtn(self)
    -- CCurrencyView:ShowView(
    --     function(oView)
    --         oView:SetCurrencyView(define.Currency.Type.Silver)
    --     end
    -- )
    g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
end

function CSummonStoreView.OnClose(self)
    CTaskHelp.SetClickTaskShopSelect(nil)
    g_TaskCtrl.m_HelpOtherTaskData = {}
    g_TaskCtrl.m_OpenShopForTaskSessionidx = nil
    g_YibaoCtrl.m_OpenShopForHelpOtherYibaoCb = nil
    self:CloseView()
end

function CSummonStoreView.OnAddCoins(self)
    -- CCurrencyView:ShowView(function(oView)
    --     oView:SetCurrencyView(define.Currency.Type.Silver)
    -- end)
    g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
end

function CSummonStoreView.SetSummonList(self)
    local tSortedIds = self:GetSortedSummonIds()
    local optionCount = #tSortedIds
    local GridList = self.m_ItemGrid:GetChildList() or {}
    local oItem
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oItem = self.m_ItemClone:Clone(function()
                    self:ItemCallBack(tSortedIds[i])
                end)
            else
                oItem = GridList[i]
                self:ItemCallBack(tSortedIds[i])
            end
            self:SetSummonBox(oItem, tSortedIds[i], i)
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
    -- self.m_ItemGrid:Reposition()
    -- self.m_ScrollView:ResetPosition()
end

function CSummonStoreView.SetSummonBox(self, oItem, oData, index)
    local summonId = oData
    oItem:SetActive(true)
    oItem:SetBoxInfo(summonId)
    self.m_ItemGrid:AddChild(oItem)
    oItem:SetGroup(self.m_ItemGrid:GetInstanceID())
    if CTaskHelp.GetClickTaskShopSelect() then
        local needsum = g_TaskCtrl:GetTaskNeedSumList(CTaskHelp.GetClickTaskShopSelect(), true)[1]
        if needsum and summonId == needsum then
            
            CTaskHelp.SetClickTaskShopSelect(nil)
        end            
    end
end

function CSummonStoreView.InitGridBox(self)
    self:SetSummonList()
end

function CSummonStoreView.OnHideView(self)
    g_TaskCtrl.m_HelpOtherTaskData = {}
end

return CSummonStoreView