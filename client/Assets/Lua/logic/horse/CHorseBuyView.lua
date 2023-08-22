local CHorseBuyView = class("CHorseBuyView", CViewBase)
function CHorseBuyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Horse/HorseBuyView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CHorseBuyView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Name = self:NewUI(2, CLabel)
    self.m_ActorTexture = self:NewUI(3, CActorTexture)
    self.m_RemainTime = self:NewUI(4, CLabel)
    self.m_BuyBox = self:NewUI(5, CHorseBuyBox)
    self.m_Grid = self:NewUI(6, CGrid)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHorseCtrlEvent"))

    g_HorseCtrl:C2GSGetRideInfo()

end

function CHorseBuyView.SetInfo(self, id)
    
    self.m_CurHorseId = id

    self:RefreshModel()
    self:RefreshTime()
    self:RefreshBuyItems()

end

function CHorseBuyView.RefreshModel(self)

    if self.m_CurHorseId then 
        self.m_ActorTexture:ChangeShape({horse = self.m_CurHorseId, rendertexSize = 1.5})
    end 

end 

function CHorseBuyView.RefreshTime(self)

    if not self.m_CurHorseId then 
        return
    end

    local horseData = data.ridedata.RIDEINFO[self.m_CurHorseId]
    self.m_Name:SetText(horseData.name)

    local horse = g_HorseCtrl:GetHorseById(self.m_CurHorseId)

    if not horse then
        self.m_RemainTime:SetActive(false)
        return
    end 

    self.m_RemainTime:SetActive(true)

    if  horse.left_time == -1 then 
        g_TimeCtrl:DelTimer(self)
        self.m_RemainTime:SetText("[244B4EFF]剩余时间:[-][63432CFF]永久[-]")

    else

        local cb = function (time)
            
            if not time then 
                self.m_RemainTime:SetText("[244B4EFF]剩余时间:[-][63432CFF]过期[-]")
            else
                self.m_RemainTime:SetText("[244B4EFF]剩余时间:[-][63432CFF]" .. time .. "[-]")
            end 

        end
        g_TimeCtrl:StartCountDown(self, horse.left_time, 1, cb)

    end

end 

function CHorseBuyView.RefreshBuyItems(self)

    if not self.m_CurHorseId then 
        return
    end 

    local id = self.m_CurHorseId
    
    local buyinfo = data.ridedata.BUYINFO[id]

    if buyinfo then 

        table.sort(buyinfo, function (a, b)
            if a.id < b.id then 
                return true
            else
                return false 
            end 
        end)

        for k, v in ipairs(buyinfo) do 

            local item = self.m_Grid:GetChild(k) 
            if not item then 
                item = self.m_BuyBox:Clone()
                item:SetActive(true)
                self.m_Grid:AddChild(item)
            end 

            item:SetName(tostring(v.id))

            local info = {}
            info.id = v.id
            if v.valid_day == -1 then 
                info.timeType = "永久"
                info.validDay = -1
            else
                info.timeType = tostring(v.valid_day) .. "天"
                info.validDay = 1
            end 

            info.itemList = {}

            if v.cost_item[1] and next(v.cost_item[1]) then
                local consume = {}
                local itemData = DataTools.GetItemData(v.cost_item[1].itemid)
                consume.name = itemData.name
                consume.needCount = v.cost_item[1].cnt
                consume.hadCount = g_ItemCtrl:GetBagItemAmountBySid(v.cost_item[1].itemid)
                consume.itemId = v.cost_item[1].itemid
                table.insert(info.itemList, consume)
            end
            if v.cost_money[1] and next(v.cost_money[1]) then
                local consume = {}
                local typeConsume = v.cost_money[1].type
                consume.needCount = v.cost_money[1].cnt
                consume.icon = v.cost_money[1].icon
                consume.type = typeConsume

                if typeConsume == 1 then 
                    consume.hadCount = g_AttrCtrl.gold
                    consume.name = "金币"
                elseif typeConsume == 2 then 
                    consume.hadCount = g_AttrCtrl.silver
                    consume.name = "银币"
                elseif typeConsume == 3 then
                    consume.hadCount = g_AttrCtrl:GetGoldCoin()
                    consume.name = "元宝"
                elseif typeConsume == 6 then 
                    consume.hadCount = g_AttrCtrl.wuxun
                    consume.name = "武勋"
                end 
                table.insert(info.itemList, consume)
            end

            item:SetInfo(info, callback(self, "OnBuy"))

        end 

        self.m_Grid:Reposition()

    end 


end

function CHorseBuyView.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then

        self:RefreshBuyItems()

    end
end

function CHorseBuyView.OnHorseCtrlEvent(self, oCtrl )
    
    if oCtrl.m_EventID == define.Horse.Event.HorseAttrChange or  oCtrl.m_EventID == define.Horse.Event.UpdateRideInfo or 
        oCtrl.m_EventID == define.Horse.Event.AddHorse then
        self:RefreshTime()
    end

end



function CHorseBuyView.OnBuy(self, info)

    if info.itemList.item then
        local count = info.itemList.item.needCount
        local hadCount =  info.itemList.item.hadCount
        if count > hadCount then
            g_NotifyCtrl:FloatMsg(info.itemList.item.name.."不足！")
            -- g_WindowTipCtrl:SetWindowGainItemTip(info.itemList.item.itemId, function ()
            --     local view = CHorseMainView:GetView()
            --    -- view:OnClose()
            -- end)
            return
        end
    end
    if info.itemList.money then
        local moneyData = info.itemList.money
        if moneyData.needCount >  moneyData.hadCount then
            g_NotifyCtrl:FloatMsg(moneyData.name.."不足！")
            if moneyData.moneyType == 3 then
                g_ShopCtrl:ShowChargeView()
                -- CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end) 
            elseif moneyData.moneyType == 1 then
                CCurrencyView:ShowView(function(oView) oView:SetCurrencyView(define.Currency.Type.Gold) end)
            elseif moneyData.moneyType == 2 then
                CCurrencyView:ShowView(function(oView) oView:SetCurrencyView(define.Currency.Type.Silver) end)
            end
            return
        end
    end
    g_HorseCtrl:C2GSBuyRideUseTime(info.id)
end

return CHorseBuyView
