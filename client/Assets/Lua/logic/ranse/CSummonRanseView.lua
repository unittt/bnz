local CSummonRanseView = class("CSummonRanseView", CViewBase)

function CSummonRanseView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Ranse/SummonRanseView.prefab", cb)

	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"	

    --当前选择的染色部位
    self.m_CurPart = nil
end

function CSummonRanseView.OnCreateView(self)

    self.m_ActorTexture = self:NewUI(1, CActorTexture)
    self.m_CloseBtn = self:NewUI(2, CButton)
    self.m_ConfirmBtn = self:NewUI(3, CSprite)
    self.m_CosumeBox = self:NewUI(4, CRanseConsumeBox)
    self.m_Grid = self:NewUI(5, CGrid)
    self.m_SummonBox = self:NewUI(6, CSummonRanseBox)
    self.m_TipsBtn = self:NewUI(7, CSprite)
    self.m_Name = self:NewUI(8, CLabel)
    self.m_Slider = self:NewUI(9, CSlider)
    self.m_ProgressNode = self:NewUI(10, CWidget)
    self.m_tipNode = self:NewUI(11, CWidget)
    self.m_ModelBg = self:NewUI(12, CWidget)
    self.m_ConsumeNode = self:NewUI(13, CWidget)
 
    self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))

	self:InitContent()

end

function CSummonRanseView.OnCtrlEvent(self, oCtrl)
    
    
   if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo  then 

        self.m_SummonInfo = oCtrl.m_EventData
        self:RefreshAll()

    end   

end


function CSummonRanseView.OnCtrlItemEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
    or oCtrl.m_EventID == define.Item.Event.ItemAmount then
        self:RefreshConsumeBox()
    end

end

function CSummonRanseView.InitContent(self)

    if not next(g_SummonCtrl.m_SummonsSort) then 
        return
    end 

    self:InitSummonItems()

    self:RefreshUI()

    local item =  self.m_Grid:GetChild(1)

    if item then 
        item:SetSelected(true)
        self.m_SummonInfo = item.m_Info

        self:RefreshAll()
    end


    self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))
    self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTipsBtn"))

    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

   
end

--初始化宠物选择框
function CSummonRanseView.InitSummonItems(self)

    --获取已有宠物数据
    for k,v in pairs(g_SummonCtrl.m_SummonsSort) do
        local config = data.summondata.INFO[v.typeid]
        local t = nil
        if config then 
           t = config.type
        end 
        if v.type ~= 1 and g_SummonRanseCtrl:GetSummonRanseInfo(v.typeid) then 
            local summonItem = self.m_SummonBox:Clone()
            summonItem:SetActive(true)
            self.m_Grid:AddChild(summonItem)
            summonItem:SetInfo(v)    
            summonItem:AddUIEvent("click", callback(self, "OnClickSummonItem", v)) 
        end 
    end 
    
end


function CSummonRanseView.RefreshUI(self)
    
    if  not next(self.m_Grid:GetChildList()) then 
        self.m_tipNode:SetActive(true)
        self.m_ModelBg:SetActive(false)
        self.m_ConsumeNode:SetActive(false)
    else
        self.m_tipNode:SetActive(false)
        self.m_ModelBg:SetActive(true)
        self.m_ConsumeNode:SetActive(true)
    end 

end


--刷新消耗
function CSummonRanseView.RefreshConsumeBox(self)

    local shape = self.m_SummonInfo.model_info.shape
    local config = data.ransedata.SUMMON[shape]

    if config == nil then 
        return
    end 

    local consumeInfo = config.itemlist[1]
    local info = {}

    if consumeInfo.gold > 0 then 

        info.iconId = 10002
        info.needCount = consumeInfo.gold 
        info.hadCount =  g_AttrCtrl.gold     

    elseif string.len(consumeInfo.item) > 0 then 

        local item = string.split(consumeInfo.item,"*")
        info.iconId = DataTools.GetItemData(item[1], "OTHER").icon   
        info.needCount = tonumber(item[2])
        info.hadCount =  g_ItemCtrl:GetBagItemAmountBySid( tonumber(item[1]))
        info.id = tonumber(item[1])

    elseif consumeInfo.silver > 0 then 

         info.iconId = 10003
         info.needCount = consumeInfo.silver
         info.hadCount =  g_AttrCtrl.silver

    end 

     self.m_CosumeBox:SetInfo(info)

end

--刷新模型
function CSummonRanseView.RefreshModel(self)

    local modelDone = function ( ... )
        local colorList =  g_RanseCtrl:GetSummonColorList(self.m_SummonInfo.model_info.shape, self.m_SummonInfo.model_info.ranse_summon)
        self.m_ActorTexture:Ranse(colorList)
    end

    local model_info =  table.copy(self.m_SummonInfo.model_info)
    model_info.rendertexSize = 1.6
    model_info.pos = Vector3(0, -0.65, 3)
    self.m_ActorTexture:ChangeShape(model_info)

end

--刷新名字
function CSummonRanseView.RefreshName(self)

    self.m_Name:SetText(self.m_SummonInfo.basename)
    
end

function CSummonRanseView.OnClickConfirmBtn(self)
    self:JudgeLackList()
    if g_QuickGetCtrl.m_IsLackItem then
        return
    end
    if not self.m_CosumeBox:IsEnought() then 
        -- local id =  self.m_CosumeBox:GetConsumeId()
        -- if id then 
        --     local config = DataTools.GetItemData(id, OTHER)
        --     table.print(config, "=== In CSummonRanseView.OnClickConfirmBtn ===")
        --     local name = string.format(data.colorinfodata.ITEM[config.quality].color, config.name)
        --     local tip = data.ransedata.TEXT[2005].text
        --     tip = string.gsub(tip, "#name", name)
        --     g_NotifyCtrl:FloatMsg(tip)
        -- end 
        return
    end 
    
    local windowConfirmInfo = {
        msg = "确定染色？",
        title = "染色",
        okCallback = function ()
            self:PlayRanseAni()
        end,
        cancelCallback = function ()
        end,
    }


    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
       --todo
    end)


end

function CSummonRanseView.PlayRanseAni(self, iQuick)
    
    self.m_ProgressNode:SetActive(true)
    local x = 0
    local fun = function ()
        if x > 1 then 
            self.m_ProgressNode:SetActive(false)
            g_SummonRanseCtrl:C2GSSummonRanse(self.m_SummonInfo.id, nil, iQuick)
            return false
        end 
        x = x + 0.05
        self.m_Slider:SetValue(x)
        return true
    end

    Utils.AddTimer(fun, 0.1, 0)

end

function CSummonRanseView.OnClickTipsBtn(self)

    local id = define.Instruction.Config.SummonRanse
    if data.instructiondata.DESC[id] ~= nil then 

        local content = {
            title = data.instructiondata.DESC[id].title,
            desc  = data.instructiondata.DESC[id].desc
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(content)

    end 

end

function CSummonRanseView.OnClickSummonItem(self, info)

    self.m_SummonInfo = info
    self:RefreshAll()

end

function CSummonRanseView.RefreshAll(self)

    self:RefreshModel()
    self:RefreshName()
    self:RefreshConsumeBox()

end

function CSummonRanseView.SelectSummon(self, summonId)
    local iSel = self.m_SummonInfo and self.m_SummonInfo.id
    if iSel ~= summonId then
        local dCurSumm = g_SummonCtrl:GetSummon(summonId)
        self:OnClickSummonItem(dCurSumm)
        for i, v in ipairs(self.m_Grid:GetChildList()) do
            local id = v.m_Info and v.m_Info.id
            if id == iSel then
                v:SetSelected(false)
            elseif id == summonId then
                v:SetSelected(true)
            end
        end
    end
end

function CSummonRanseView.JudgeLackList(self)
    if self.m_CosumeBox.m_consumeInfo then
        local value = self.m_CosumeBox.m_consumeInfo
        local itemlist = {}
        if value.needCount > value.hadCount then
            local t = {sid = value.id, count = value.hadCount, amount = value.needCount }
            table.insert(itemlist, t)
        end

        local args = {
            itemlist = itemlist,
            exchangeCb = function(cost, moneytype)
                if not moneytype or moneytype == define.Currency.Type.GoldCoin then 
                    local goldcoin = g_AttrCtrl:GetGoldCoin()
                    if goldcoin < cost then
                        g_NotifyCtrl:FloatMsg("元宝不足")
                        -- CNpcShopMainView:ShowView(function(oView)
                        --     oView:ShowSubPageByIndex(3)
                        -- end)
                        g_ShopCtrl:ShowChargeView()
                    else
                        self:PlayRanseAni(1)
                    end
                elseif moneytype == define.Currency.Type.Gold then 
                    local gold = g_AttrCtrl.gold
                    if gold < cost then
                        g_NotifyCtrl:FloatMsg("金币不足")
                        -- CCurrencyView:ShowView(function(oView)
                        --     oView:SetCurrencyView(define.Currency.Type.Gold)
                        -- end)
                        g_ShopCtrl:ShowAddMoney(define.Currency.Type.Gold)
                    else
                        self:PlayRanseAni(1)
                    end
                end 
            end
        }
        g_QuickGetCtrl:CheckLackItemInfo(args)
    end
end

return CSummonRanseView