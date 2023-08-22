local CFuyuanTreasureView = class("CFuyuanTreasureView", CViewBase)

function CFuyuanTreasureView.ctor(self, cb)
	CViewBase.ctor(self, "UI/FuyuanTreasure/FuyuanTreasureView.prefab", cb)

	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"

    self.m_id = nil
    self.m_rewardList = nil	
    self.m_BoxItemList = {}
    self.m_R = 204
    self.m_IsRotating = false
    self.m_OpenOne = nil

end

function CFuyuanTreasureView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CSprite)
    self.m_OpenOneBtn = self:NewUI(2, CSprite)
    self.m_OpenTenBtn = self:NewUI(3, CSprite)
    self.m_Grid = self:NewUI(4, CWidget)
    self.m_RewardBox = self:NewUI(5, CFuyuanRewardBox)
    self.m_Des = self:NewUI(6, CLabel)
    self.m_RewardItemBox = self:NewUI(7, CBox)
    self.m_ConsumeItemIconBox = self:NewUI(8, CBox)
    self.m_TurnNode = self:NewUI(9, CWidget)
    self.m_UseYuanBao = self:NewUI(10, CWidget)
    self.m_ConfirmTipView = self:NewUI(11, CFuyuanTreasureTipBox)
    self.m_YuanBaoNode = self:NewUI(12, CObject)
    self.m_YuanBaoLeft = self:NewUI(13, CLabel)
    self.m_YuanBaoRight = self:NewUI(14, CLabel)

    self:InitRewardItemBox()
    self:InitConsumeItemBox()

    self.m_ConfirmTipView:SetActive(false)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
    self.m_OpenOneBtn:AddUIEvent("click", callback(self, "OnClickOpenOne"))
    self.m_OpenTenBtn:AddUIEvent("click", callback(self, "OnClickOpenTen"))
    self.m_RewardItemBox:AddUIEvent("click", callback(self, "OnClickRewardItemBox"))
    self.m_ConsumeItemIconBox:AddUIEvent("click", callback(self, "OnClickConsumeItemBox"))
    self.m_UseYuanBao:AddUIEvent("click", callback(self, "OnClickUseYuanBaoBtn"))

    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

end

function CFuyuanTreasureView.CloseView(self)
    
    self:TryGrantRewardAni()
    CViewBase.CloseView(self)
    
end

function CFuyuanTreasureView.InitRewardItemBox(self)

    self.m_RewardItemBox.m_Icon = self.m_RewardItemBox:NewUI(1, CSprite)
    self.m_RewardItemBox.m_Count = self.m_RewardItemBox:NewUI(2, CLabel)
    self.m_RewardItemBox.m_Border = self.m_RewardItemBox:NewUI(3, CSprite)
    self.m_RewardItemBox.m_Name = self.m_RewardItemBox:NewUI(4, CLabel)

end

function CFuyuanTreasureView.InitConsumeItemBox(self)
    
    self.m_ConsumeItemIconBox.m_Icon = self.m_ConsumeItemIconBox:NewUI(1, CSprite)
    self.m_ConsumeItemIconBox.m_Count = self.m_ConsumeItemIconBox:NewUI(2, CLabel)
    self.m_ConsumeItemIconBox.m_Border = self.m_ConsumeItemIconBox:NewUI(3, CSprite)
    self.m_ConsumeItemIconBox.m_Name = self.m_ConsumeItemIconBox:NewUI(4, CLabel)

end


function CFuyuanTreasureView.SetData(self, id, rewardList)
    
    self.m_id = id 
    self.m_rewardList = rewardList
    self:RefreshAll()

end

function CFuyuanTreasureView.RefreshAll(self)
    
    self:RefreshRewardList()
    self:RefreshDes()
    self:RefreshRewardItem()
    self:RefreshConsumeItem()
    self:RefreshUseYuanBaoBtn()
    self:RefreshYuanBao()

end

function CFuyuanTreasureView.RefreshUseYuanBaoBtn(self)
    
    local isUse = g_FuyuanTreasureCtrl:IsUseYuanBao()

    self.m_IsUseYuanBao = isUse

    self.m_UseYuanBao:ForceSelected(isUse)

end

function CFuyuanTreasureView.TryGrantRewardAni(self)

    if not self.m_IsRotating then 
        return
    end 

    local getRewardList = g_FuyuanTreasureCtrl:GetRewardList()

    if not getRewardList then 
        return
    end 
    
    local quuickIDList = g_ItemCtrl:GetQuickUseItemIDList(getRewardList)
    for k, id in pairs(quuickIDList) do 
        g_ItemCtrl:ItemQuickUse(id)
    end 
    
    for k, v in pairs(getRewardList) do 
        local itemData = DataTools.GetItemData(v.id)
        g_NotifyCtrl:FloatItemBox(itemData.icon)
    end 

end

function CFuyuanTreasureView.OnClickUseYuanBaoBtn(self)

    if not self.m_IsUseYuanBao then 
        self.m_UseYuanBao:ForceSelected(false)
        local windowConfirmInfo = {
            title = "提示",
            msg = "是否使用元宝替代钥匙开启福缘宝箱？",
            okCallback = function()
                self.m_IsUseYuanBao = not self.m_IsUseYuanBao
                self.m_UseYuanBao:ForceSelected(self.m_IsUseYuanBao)
                g_FuyuanTreasureCtrl:UseYuanBao(self.m_IsUseYuanBao)
                self:RefreshAll() 
            end,  
            pivot = enum.UIWidget.Pivot.Center,
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)

    else
        self.m_IsUseYuanBao = not self.m_IsUseYuanBao
        self.m_UseYuanBao:ForceSelected(self.m_IsUseYuanBao)
        g_FuyuanTreasureCtrl:UseYuanBao(self.m_IsUseYuanBao)
        self:RefreshAll()
    end 

end

function CFuyuanTreasureView.RefreshDes(self)
    
    self.m_Des:SetText(data.fuyuanboxdata.TEXT_DES[1].des)

end

function CFuyuanTreasureView.RefreshRewardItem(self)
   
    local config = data.fuyuanboxdata.FUYUAN_REWARD[1]
    local id = config.sid
    local amount = config.amount

    local itemData = DataTools.GetItemData(id)
    self.m_RewardItemBox.m_Icon:SpriteItemShape(itemData.icon)
    self.m_RewardItemBox.m_Count:SetText("数量:" .. tostring(amount))
    self.m_RewardItemBox.m_Name:SetText(itemData.name)
    local quality = g_ItemCtrl:GetQualityVal(itemData.id, itemData.quality or 0 )
    self.m_RewardItemBox.m_Border:SetItemQuality(quality)
    self.m_RewardItemData = itemData

end


function CFuyuanTreasureView.RefreshConsumeItem(self)
   
    local config = data.fuyuanboxdata.CONFIG[1]
    local id = config.open_item

    local itemData = DataTools.GetItemData(id)
    self.m_ConsumeItemIconBox.m_Icon:SpriteItemShape(itemData.icon)
    local itemNum = g_ItemCtrl:GetBagItemAmountBySid(id)
    if itemNum >= 1 then
        self.m_ConsumeItemIconBox.m_Count:SetText("[0fff32]"..itemNum)
        self.m_ConsumeItemIconBox.m_Count:SetEffectColor(Color.RGBAToColor("003C41"))
    else
        self.m_ConsumeItemIconBox.m_Count:SetText("[ffb398]"..itemNum)
        self.m_ConsumeItemIconBox.m_Count:SetEffectColor(Color.RGBAToColor("cd0000"))
    end
    -- self.m_ConsumeItemIconBox.m_Count:SetText("数量:" .. tostring(itemNum) .. "/1")
    self.m_ConsumeItemIconBox.m_Name:SetText(itemData.name)
    local quality = g_ItemCtrl:GetQualityVal(itemData.id, itemData.quality or 0 )
    self.m_ConsumeItemIconBox.m_Border:SetItemQuality(quality)
    self.m_ConsumeItemData = itemData

end

function CFuyuanTreasureView.RefreshYuanBao(self)
    
    if self.m_IsUseYuanBao then 
        self.m_YuanBaoNode:SetActive(true)

        local hadCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ConsumeItemData.id)
        local disCount = data.fuyuanboxdata.CONFIG[1].ten_discount
        local storeid = data.fuyuanboxdata.CONFIG[1].store_id
        local shopdata = DataTools.GetNpcStoreInfo(storeid)
        local yuanBaoCount = 0
        if shopdata then 
            yuanBaoCount = shopdata.virtual_coin[1003].count
        end 

        local ybRightCount = 0
        --right
        if hadCount == 0 then 
            ybRightCount = yuanBaoCount
        end     
        self.m_YuanBaoRight:SetText(ybRightCount)

        --left
        local needCount = disCount
        local diff = needCount - hadCount
        if diff < 0 then
            diff = 0
        end
        local disCountConsume = yuanBaoCount  * diff
        self.m_YuanBaoLeft:SetText(disCountConsume)

    else
        self.m_YuanBaoNode:SetActive(false)
    end 

end

function CFuyuanTreasureView.OnClickRewardItemBox(self)
    
    local id = self.m_RewardItemData.id 
    local config = {widget = self.m_RewardItemIcon}
    g_WindowTipCtrl:SetWindowItemTip(id, config)

end

function CFuyuanTreasureView.OnClickConsumeItemBox(self)
    
    local id = self.m_ConsumeItemData.id 
    g_WindowTipCtrl:SetWindowGainItemTip(id)

end

function CFuyuanTreasureView.RefreshRewardList(self)
    
    local getPos = function (i)
        
        local angle = 30 * (i - 1) + 15
        local rad = math.pi * angle/180
        local x =  self.m_R  * math.cos(rad)
        local y =  self.m_R  * math.sin(rad)
        return Vector3.New(x, y, 0)
    end

    for k , v in ipairs( self.m_rewardList) do 
        local box = self.m_BoxItemList[k]
        if box == nil then 
            box = self.m_RewardBox:Clone()
            box:SetActive(true)
            self.m_BoxItemList[k] = box
            box:SetParent(self.m_Grid.m_Transform)
        end
        box:SetData(v)
        box:SetLocalPos(getPos(k))
    end

end

--开始动画
function CFuyuanTreasureView.DoAnimation(self, rewardId)

    local index = nil
    for k, v in ipairs( self.m_BoxItemList) do 
        if v.m_ItemData.id == rewardId then 
            index = k
        end 
    end 

    if not index then 
        printc("--------can not find the index. id:", rewardId)
        return
    end 

    self:ChooseItemAni(index, callback(self, "FinishAni"))

end


function CFuyuanTreasureView.GetEndDegree(self, index)
   
    return 15 + 30 * (index - 1)

end

function CFuyuanTreasureView.ChooseItemAni(self, endIndex, endCb)

    local endDegree = self:GetEndDegree(endIndex)
    local tween = DOTween.DORotate(self.m_TurnNode.m_Transform, Vector3.New(0, 0, endDegree + (-360 *4)), 2, 1)
    self.m_IsRotating = true
    local function onEnd()
        self.m_IsRotating = false
        if endCb then
            endCb()
        end
    end
    DOTween.OnComplete(tween, onEnd)

end

function CFuyuanTreasureView.FinishAni(self)

    if not Utils.IsNil(self) then 
        local oview = CFuyuanTreasureView:GetView()
        if not oview then
           return
        end

        local rewardList = g_FuyuanTreasureCtrl:GetRewardList()

        local colorConfig = data.colorinfodata.ITEM

        if rewardList then 
            local count = #rewardList

            if count == 1 then 
                --奖励提示
                local reward = rewardList[1]
                local id = reward.id
                local count = reward.amount

                local itemData = DataTools.GetItemData(id)
                if itemData then
                    g_NotifyCtrl:FloatItemBox(itemData.icon)
                    g_NotifyCtrl:FloatMsg("获得"..string.format(colorConfig[itemData.quality].color,itemData.name).."×"..string.format(colorConfig[itemData.quality].color, count))
                end 

                itemData = nil
                count = nil
                local config = data.fuyuanboxdata.FUYUAN_REWARD[1]
                count = config.amount
                itemData = DataTools.GetItemData(config.sid)
                if itemData then
                    g_NotifyCtrl:FloatItemBox(itemData.icon)
                    g_NotifyCtrl:FloatMsg("获得"..string.format(colorConfig[itemData.quality].color,itemData.name).."×"..string.format(colorConfig[itemData.quality].color, count))
                end 
            else
                CFuyuanTreasureRewardView:ShowView(function (oView)
                    oView:SetData(rewardList)
                end)
            end 
            
            self:CloseView()

        end
    end 
    
end


function CFuyuanTreasureView.OnClickOpenOne(self)
    
    self.m_OpenOne = true
    local send = function ( ... )
       g_FuyuanTreasureCtrl:C2GSOpenFuYuanBox(self.m_id, 1, self.m_IsUseYuanBao and 1 or 0)
    end
    self:CheckConsumeEnought(send)

end

function CFuyuanTreasureView.OnClickOpenTen(self)
    
    self.m_OpenOne = false
    local send = function ( ... )
       g_FuyuanTreasureCtrl:C2GSOpenFuYuanBox(self.m_id, 10, self.m_IsUseYuanBao and 1 or 0)
    end

    self:CheckConsumeEnought(send)
    
end

function CFuyuanTreasureView.CheckConsumeEnought(self, cb)
  
    local hadCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ConsumeItemData.id)
    local disCount = data.fuyuanboxdata.CONFIG[1].ten_discount
    local storeid = data.fuyuanboxdata.CONFIG[1].store_id
    local shopdata = DataTools.GetNpcStoreInfo(storeid)
    local yuanBaoCount = 0
    if shopdata then 
        yuanBaoCount = shopdata.virtual_coin[1003].count
    end 

    if self.m_IsUseYuanBao then
        if self.m_OpenOne then 
            if hadCount >= 1 then 
               cb()
            else
                local curGoldCoin = g_AttrCtrl:GetGoldCoin()
                if curGoldCoin >= yuanBaoCount then 
                    cb()
                else
                    g_NotifyCtrl:FloatMsg("元宝不足")
                end 

            end 
        else
            local needCount = disCount
            if hadCount >= needCount then 
                cb()
            else
                local diff = needCount - hadCount
                local disCountConsume = yuanBaoCount  * diff
                local curGoldCoin = g_AttrCtrl:GetGoldCoin()
                if curGoldCoin >= disCountConsume then 
                    cb()
                else
                    g_NotifyCtrl:FloatMsg("元宝不足")
                end 
            end 

        end 
    else
        if self.m_OpenOne then 
            if hadCount >= 1 then 
                cb()
            else
                self:OnClickUseYuanBaoBtn()
               -- g_NotifyCtrl:FloatMsg(self.m_ConsumeItemData.name .. "不足")
            end 
        else
            local needCount = disCount 
            if hadCount >= needCount then 
                cb()
            else
                self:OnClickUseYuanBaoBtn()
                --g_NotifyCtrl:FloatMsg(self.m_ConsumeItemData.name .. "不足")
            end 
        end 
    end 

end

function CFuyuanTreasureView.SubString(self, text, subTable)
    
    local str = text
    for k, v in ipairs(subTable) do 
        local pattern = v.pattern
        local tex = v.text
        str = string.gsub(str, pattern, tex)
    end 
    return str
   
end

function CFuyuanTreasureView.ShowConfirmTip(self, text, cb)
    
    self.m_ConfirmTipView:SetData(text, cb)

end

function CFuyuanTreasureView.OnCtrlItemEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
    or oCtrl.m_EventID == define.Item.Event.ItemAmount then
        self:RefreshAll()
    end

end


return CFuyuanTreasureView