local CFuyuanTreasureRewardView = class("CFuyuanTreasureRewardView", CViewBase)

function CFuyuanTreasureRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/FuyuanTreasure/FuyuanTreasureRewardView.prefab", cb)

	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"

end

function CFuyuanTreasureRewardView.OnCreateView(self)

    self.m_Item = self:NewUI(1, CBox)
    self.m_Grid = self:NewUI(2, CGrid)
    self.m_ConfirmBtn = self:NewUI(3, CSprite)
    self.m_TreasureTexture = self:NewUI(4, CActorTexture)
    self.m_Node = self:NewUI(5, CObject)

    self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirmBtn"))

end


function CFuyuanTreasureRewardView.SetData(self, data, msgcb)
    
    self.m_RewardList = data
    if msgcb then
        msgcb()
    end
    self:RefreshRewardItems()
    self:InitTreasureBox()

end

function CFuyuanTreasureRewardView.InitTreasureBox(self)
    
    local model_info =  {shape = 8236}
    model_info.rendertexSize = 0.5
    model_info.pos = Vector3.New(0, -0.4, 3)
    self.m_TreasureTexture:ChangeShape(model_info, function ()
        self.m_Node:SetActive(true)
        self.m_TreasureTexture:CrossFade("show3", 0, 1)
    end)
   

end

function CFuyuanTreasureRewardView.RefreshRewardItems(self)
    
    for k , v in ipairs( self.m_RewardList) do 
        local box = self.m_Grid:GetChild(k)
        if box == nil then 
            box = self.m_Item:Clone()
            box:SetActive(true)
            self.m_Grid:AddChild(box)
        end
        self:InitRewardItemBox(box)
        self:SetRewardItemData(box, v)
    end

end

function CFuyuanTreasureRewardView.InitRewardItemBox(self, item)

    item.m_Icon = item:NewUI(1, CSprite)
    item.m_Count = item:NewUI(2, CLabel)
    item.m_Border = item:NewUI(3, CSprite)
    item.m_BaojiIcon = item:NewUI(4, CSprite)
    item.m_Icon:AddUIEvent("click", function ()
        if item.m_Id then 
            local config = {widget = item}
            g_WindowTipCtrl:SetWindowItemTip(item.m_Id, config)
        end 

    end)

end

function CFuyuanTreasureRewardView.SetRewardItemData(self, item, data)

    local id = data.id
    local count = data.amount
    --元宝狂欢相关，特殊处理
    if data.id == "yuanbaojoy1" then
        item.m_Count:SetText(count)
        item.m_BaojiIcon:SetActive(false)
        item.m_Icon:SetStaticSprite("MiscAtlas", "h7_50jc")
        item.m_InonID = "yuanbaojoy1"
        return
    elseif data.id == "yuanbaojoy2" then
        item.m_Count:SetText(count)
        item.m_BaojiIcon:SetActive(false)
        item.m_Icon:SetStaticSprite("MiscAtlas", "h7_30jc")
        item.m_InonID = "yuanbaojoy2"
        return
    elseif data.id == "yuanbaojoy3" then
        item.m_Count:SetText(count)
        item.m_BaojiIcon:SetActive(false)
        item.m_Icon:SetStaticSprite("MiscAtlas", "h7_20jc")
        item.m_InonID = "yuanbaojoy3"
        return
    end
    local itemData = DataTools.GetItemData(id)
    item.m_Icon:SpriteItemShape(itemData.icon)
    local quality = g_ItemCtrl:GetQualityVal(itemData.id, itemData.quality or 0 )
    item.m_Border:SetItemQuality(quality)
    item.m_Count:SetText(count)
    item.m_Id = id
    item.m_InonID =  itemData.icon
    local baoji = data.baoji
    if baoji and baoji > 0 then 
        item.m_BaojiIcon:SetActive(true)
        item.m_BaojiIcon:SetSpriteName("h7_x" .. tostring(baoji))

    else
        item.m_BaojiIcon:SetActive(false)
    end  

end

function CFuyuanTreasureRewardView.OnConfirmBtn(self)
    
    local function tweemCB()
        local quuickIDList = g_ItemCtrl:GetQuickUseItemIDList(self.m_RewardList)
        for k, id in pairs(quuickIDList) do 
            g_ItemCtrl:ItemQuickUse(id)
        end 
    end

    if self.m_RewardList then
        local floatitemlist = {}
        local boxlist =  self.m_Grid:GetChildList()
        for i,box in ipairs(boxlist) do
            table.insert(floatitemlist, {worldpos = box:GetPos(), icon = box.m_InonID})
        end
        g_NotifyCtrl:FloatMultipleItemBox(floatitemlist, false, tweemCB)
    end

    g_ViewCtrl:CloseView(self)
end

return CFuyuanTreasureRewardView