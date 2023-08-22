local CMiBaoTaskView = class("CMiBaoTaskView", CViewBase)

function CMiBaoTaskView.ctor(self, cb)

	CViewBase.ctor(self, "UI/MiBao/MiBaoTaskView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CMiBaoTaskView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_ItemBox = self:NewUI(3, CBox)

    self:InitContent()

end

function CMiBaoTaskView.InitContent(self)
    
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

    self.m_Data = {
        {
            iconName = "h7_qinglongbaoxiang",
            name = "普通秘宝",
            des = "普通秘宝任务相对稳定，被劫损失也不大",
            costList = {
                {
                name = "押金",
                iconName = "10003",
                count = g_MiBaoConvoyCtrl:GetDeposit(define.MiBaoConvoy.Type.normal),
                },
                {
                name = "奖励",
                iconName = "10003",
                count = g_MiBaoConvoyCtrl:GetTotalReward(define.MiBaoConvoy.Type.normal),
                },
            },
            mibaoType = define.MiBaoConvoy.Type.normal,
        },
        {
            iconName = "h7_zhuquebaoxiang",
            name = "高级秘宝",
            des = "高级秘宝任务被劫风险大，但回报也高",
            costList = {
                {
                name = "押金",
                iconName = "10002",
                count = g_MiBaoConvoyCtrl:GetDeposit(define.MiBaoConvoy.Type.advance),
                },
                {
                name = "奖励",
                iconName = "10002",
                count = g_MiBaoConvoyCtrl:GetTotalReward(define.MiBaoConvoy.Type.advance),
                },
            },
            mibaoType = define.MiBaoConvoy.Type.advance,
        },
    }

    self:CreateMiBaoItem()

end

function CMiBaoTaskView.InitMiBaoItem(self, box, info)
    
    local initCost = function (costItem, costInfo)        
        costItem.name = costItem:NewUI(1, CLabel)
        costItem.icon = costItem:NewUI(2, CSprite)
        costItem.count = costItem:NewUI(3, CLabel)

        costItem.name:SetText(costInfo.name)
        costItem.icon:SetSpriteName(costInfo.iconName)
        costItem.count:SetText(costInfo.count)

    end

    box.icon = box:NewUI(1, CSprite)
    box.name = box:NewUI(2, CLabel)
    box.des = box:NewUI(3, CLabel)
    box.cost = box:NewUI(4, CBox)
    box.btn = box:NewUI(5, CSprite)
    box.grid = box:NewUI(6, CGrid)

    box.icon:SetSpriteName(info.iconName)
    box.name:SetText(info.name)
    box.des:SetText(info.des)
    box.btn:AddUIEvent("click", callback(self, "OnClickGetBtn", box))
    box.mibaoType = info.mibaoType
    for k, v in ipairs(info.costList) do 
        local costBox = box.cost:Clone()
        costBox:SetActive(true)
        box.grid:AddChild(costBox)
        initCost(costBox, v)
    end 

end

function CMiBaoTaskView.CreateMiBaoItem(self)
    
    for k, v in ipairs(self.m_Data) do 
        local item = self.m_Grid:GetChild(k)
        if not item then 
            item = self.m_ItemBox:Clone()
            item:SetActive(true)
            self.m_Grid:AddChild(item)
        end 
        self:InitMiBaoItem(item, v)
    end 

end

function CMiBaoTaskView.OnClickGetBtn(self, box)
    
    if g_MiBaoConvoyCtrl:IsEnoughDeposit(box.mibaoType) then 
         g_MiBaoConvoyCtrl:C2GSTreasureConvoySelectTask(box.mibaoType)
         self:OnClose()
    else
        local tip = g_MiBaoConvoyCtrl:GetTextTip(1008)
        g_NotifyCtrl:FloatMsg(tip)
        local currencyType = nil
        if box.mibaoType == define.MiBaoConvoy.Type.advance then 
            currencyType = define.Currency.Type.Gold
        elseif box.mibaoType == define.MiBaoConvoy.Type.normal then 
            currencyType = define.Currency.Type.Silver
        end 
        CCurrencyView:ShowView(function(oView)
            oView:SetCurrencyView(currencyType)
        end)
    end
       
end

return CMiBaoTaskView