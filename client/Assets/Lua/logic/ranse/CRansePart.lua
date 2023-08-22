local CRansePart = class("CRansePart", CPageBase)

function CRansePart.ctor(self, cb)


    CPageBase.ctor(self, cb)

	-- CViewBase.ctor(self, "UI/Ranse/RanseView.prefab", cb)

	-- --界面设置
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"	

    --当前选择的染色部位
    self.m_CurPart = nil

    self.m_CurColorIndex = nil


    --当前选择的颜色Item对象
    self.m_ColorItem = nil

    self.m_Ranse = {}

    self.m_Gold = 0
    self.m_Silver = 0
    self.m_ConsumeItem = {}

    self.m_PartColorIndexTable = {}
end

function CRansePart.OnInitPage(self)

    self.m_ActorTexture = self:NewUI(1, CActorTexture)
    self.m_ColorPanel = self:NewUI(3, CRanseColorBox)
    self.m_Grid = self:NewUI(4, CGrid)
    self.m_HairSelect = self:NewUI(5, CSprite)
    self.m_ClotheSelect = self:NewUI(6, CSprite)
    self.m_RecoverBtn = self:NewUI(7, CSprite)
    self.m_RandomBtn = self:NewUI(8, CSprite)
    self.m_ConfirmBtn = self:NewUI(9, CSprite)
    self.m_ConsumeBox = self:NewUI(10, CRanseConsumeBox)
    self.m_TipsBtn = self:NewUI(11, CSprite)
    self.m_ConsumeBoxGrid = self:NewUI(12, CGrid)
    self.m_Name = self:NewUI(13, CLabel)
    self.m_PantSelect = self:NewUI(14, CSprite)
    self.m_Slider = self:NewUI(15, CSlider)
    self.m_ProgressNode = self:NewUI(16, CWidget)

    --self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
    self.m_HairSelect:AddUIEvent("click", callback(self, "OnClickHairSelect"))
    self.m_ClotheSelect:AddUIEvent("click", callback(self, "OnClickClotheSelect"))
    self.m_PantSelect:AddUIEvent("click", callback(self, "OnClickPantSelect"))
    self.m_RecoverBtn:AddUIEvent("click", callback(self, "OnClickRecoverBtn"))
    self.m_RandomBtn:AddUIEvent("click", callback(self, "OnClickRandomBtn"))
    self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirmBtn"))
    self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTip"))

	self:InitContent()

end

function CRansePart.InitContent(self)

    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
   
    self:InitActorTexture()

    self:InitPartColorIndex()

    self:InitColorTable()

    self:InitConsumeBox()

    self:RefreshPartSelect()

    self:InitName()

    self.m_CurPart = define.Ranse.PartType.hair
    self.m_CurColorIndex =  g_AttrCtrl.model_info_changed.ranse_hair 

    self.m_HairSelect:ForceSelected(true)

    local colorItem = self:FindColorItemById(self.m_CurColorIndex)
    colorItem:ForceSelected(true)

end

function CRansePart.InitName(self)
    
   self.m_Name:SetText(g_AttrCtrl.name ) 

end

function CRansePart.OnCtrlItemEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
    or oCtrl.m_EventID == define.Item.Event.ItemAmount then
        self:RefreshConsumeBoxs()
    end

end

function CRansePart.OnCtrlAttrEvent(self, oCtrl)
    
    if oCtrl.m_EventID == define.Attr.Event.Change then 
        self:RefreshConsumeBoxs()
     end 
end



--初始化消耗
function CRansePart.InitConsumeBox(self)
    
    local itemList = self:ParseItemConfig(define.Ranse.PartType.hair, 1)

    local item = nil
   
    if itemList.gold > 0 then 
         local info = {}
        item =  self.m_ConsumeBox:Clone()
        item:SetActive(true)
        item.type = "gold"
        self.m_ConsumeBoxGrid:AddChild(item)

        info.iconId = 10002
        info.needCount = 0
        info.hadCount =  g_AttrCtrl.gold
        item:SetInfo(info)

    end 

    if itemList.silver > 0 then 
         local info = {}
        item =  self.m_ConsumeBox:Clone()
        item:SetActive(true)
        item.type = "silver"
        self.m_ConsumeBoxGrid:AddChild(item)
        info.iconId = 10003
        info.needCount =0
        info.hadCount =  g_AttrCtrl.silver
        item:SetInfo(info)

    end 

    if  next(itemList.itemTable) then 

        for k, v in pairs(itemList.itemTable) do 

            item =  self.m_ConsumeBox:Clone()
            item:SetActive(true)
            item.type = "item"
            self.m_ConsumeBoxGrid:AddChild(item)
            local info = {}
            info.iconId = DataTools.GetItemData(k, "OTHER").icon
            info.needCount = 0
            info.hadCount =  g_ItemCtrl:GetBagItemAmountBySid( tonumber(k))
            info.id = v.id
            item:SetInfo(info)

        end 

    end 

end



--初始化颜色选择表
function CRansePart.InitColorTable(self)
    
    local config = data.ransedata.COLOR

    if config == nil then 
        return
    end

    --插入默认色
    local defaultItem = self.m_ColorPanel:Clone()
    defaultItem:SetActive(true)
    self.m_Grid:AddChild(defaultItem)
    defaultItem:SetDefaultState()
    defaultItem:AddUIEvent("click", callback(self, "ClickColorPanel", 0, defaultItem))
   
    for k , v in ipairs(config) do 

        local colorItem = self.m_ColorPanel:Clone()
        colorItem:SetActive(true)
        self.m_Grid:AddChild(colorItem)
        local  info =  g_RanseCtrl:GetShowColor(v.id)
        colorItem:SetInfo(info)
        colorItem:AddUIEvent("click", callback(self, "ClickColorPanel", v.id, colorItem))

    end 

end

--初始化部位染色表
function CRansePart.InitPartColorIndex(self)
    
    self.m_PartColorIndexTable[define.Ranse.PartType.hair] = g_AttrCtrl.model_info_changed.ranse_hair 
    self.m_PartColorIndexTable[define.Ranse.PartType.clothes] = g_AttrCtrl.model_info_changed.ranse_clothes 
    self.m_PartColorIndexTable[define.Ranse.PartType.pant] = g_AttrCtrl.model_info_changed.ranse_pant 

end


--初始化人物模型
function CRansePart.InitActorTexture(self)
    
    local model_info = table.copy(g_AttrCtrl.model_info)
    model_info.rendertexSize = 1.2
    model_info.horse = nil
    model_info.shizhuang = nil
    self.m_ActorTexture:ChangeShape(model_info)

end

--刷新部位选择颜色
function CRansePart.RefreshPartSelect(self)
    
    local id = 0

    id = self.m_PartColorIndexTable[define.Ranse.PartType.hair]
    if id == 0 then 
        self.m_HairSelect:SetSpriteName("h7_toufa_mo")
    else
        self.m_HairSelect:SetSpriteName("h7_toufa")
        self.m_HairSelect:SetColor(g_RanseCtrl:GetShowColor(id).color)
    end 
    
    id = self.m_PartColorIndexTable[define.Ranse.PartType.clothes]
    if id == 0 then 
        self.m_ClotheSelect:SetSpriteName("h7_yifu_mo")
    else
        self.m_ClotheSelect:SetSpriteName("h7_yifu_1")
        self.m_ClotheSelect:SetColor(g_RanseCtrl:GetShowColor(id).color)
    end 
   
    id = self.m_PartColorIndexTable[define.Ranse.PartType.pant] 
    if id == 0 then 
        self.m_PantSelect:SetSpriteName("h7_kuzi_mo")
    else
        self.m_PantSelect:SetSpriteName("h7_kuzi")
        self.m_PantSelect:SetColor(g_RanseCtrl:GetShowColor(id).color)
    end 
    

end

--点击染色版
function CRansePart.ClickColorPanel(self, id, item)
    
    self.m_ColorItem = item

    self.m_PartColorIndexTable[self.m_CurPart] = id

    self:RefreshModel()

    self:RefreshConsumeBoxs()


end

function CRansePart.FindColorItemById(self, colorId)
    
    for k, v in pairs(self.m_Grid:GetChildList()) do 

        if v.m_ColorIndex == colorId then 
            return v
        end 

    end 

end

--刷新模型
function CRansePart.RefreshModel(self)

    local color =  nil

    local id = 0

    self.m_Ranse = {}

 
    if self.m_PartColorIndexTable[define.Ranse.PartType.clothes] > 0 then 
        id = self.m_PartColorIndexTable[define.Ranse.PartType.clothes] 
       -- self.m_ClotheSelect:SetColor(g_RanseCtrl:GetShowColor(id).color)
        self.m_Ranse[define.Ranse.PartType.clothes] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.clothes, id, g_AttrCtrl.model_info.shape)
        self.m_Ranse[define.Ranse.PartType.other] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.other, id, g_AttrCtrl.model_info.shape)
  
    else
       -- self.m_ClotheSelect:SetColor(Color.New(1,1,1,1))
        self.m_Ranse[define.Ranse.PartType.clothes] = Color.New(1,1,1,1)
        self.m_Ranse[define.Ranse.PartType.other] = Color.New(1,1,1,1)

    end
      
    if  self.m_PartColorIndexTable[define.Ranse.PartType.hair] > 0  then 
        id = self.m_PartColorIndexTable[define.Ranse.PartType.hair] 
      --  self.m_HairSelect:SetColor(g_RanseCtrl:GetShowColor(id).color)
        self.m_Ranse[define.Ranse.PartType.hair] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.hair, id, g_AttrCtrl.model_info.shape)
    
    else
       -- self.m_HairSelect:SetColor(Color.New(1,1,1,1))
        self.m_Ranse[define.Ranse.PartType.hair] = Color.New(1,1,1,1)
 
    end
  
    if self.m_PartColorIndexTable[define.Ranse.PartType.pant] > 0 then
        id = self.m_PartColorIndexTable[define.Ranse.PartType.pant] 
     --   self.m_PantSelect:SetColor(g_RanseCtrl:GetShowColor(id).color)
        self.m_Ranse[define.Ranse.PartType.pant] =  g_RanseCtrl:GetColorValue(define.Ranse.PartType.pant, id, g_AttrCtrl.model_info.shape)

    else
       -- self.m_PantSelect:SetColor(Color.New(1,1,1,1))
        self.m_Ranse[define.Ranse.PartType.pant] = Color.New(1,1,1,1)
    end

    self:RefreshPartSelect()

    self.m_ActorTexture:Ranse(self.m_Ranse)
 

end

--判断某个部位的某个颜色是否已染
function CRansePart.IsPartHadRanse(self, part, colorIndex)
    
    --当前已染颜色    
    local curColorIndex = nil
    local iSPartHadRanse = nil

    if part == define.Ranse.PartType.clothes then 

         curColorIndex = g_AttrCtrl.model_info_changed.ranse_clothes 
         if curColorIndex == colorIndex then
            iSPartHadRanse = true
         else
            iSPartHadRanse = false
         end 

    elseif part == define.Ranse.PartType.hair then 

         curColorIndex = g_AttrCtrl.model_info_changed.ranse_hair 
         if curColorIndex == colorIndex then
            iSPartHadRanse = true
         else
            iSPartHadRanse = false
         end 

    elseif part == define.Ranse.PartType.pant then 

         curColorIndex = g_AttrCtrl.model_info_changed.ranse_pant 
         if curColorIndex == colorIndex then
            iSPartHadRanse = true
         else
            iSPartHadRanse = false
         end 

    end  

    return iSPartHadRanse

end


function CRansePart.OnClickHairSelect(self)

    self.m_CurPart = define.Ranse.PartType.hair
    self.m_CurColorIndex =  self.m_PartColorIndexTable[define.Ranse.PartType.hair]
    local colorItem = self:FindColorItemById(self.m_CurColorIndex)
    colorItem:ForceSelected(true)

end

function CRansePart.OnClickClotheSelect(self)

    self.m_CurPart = define.Ranse.PartType.clothes
    self.m_CurColorIndex =  self.m_PartColorIndexTable[define.Ranse.PartType.clothes]
    local colorItem = self:FindColorItemById(self.m_CurColorIndex)
    colorItem:ForceSelected(true)
   
end

function CRansePart.OnClickPantSelect(self)
    
    self.m_CurPart = define.Ranse.PartType.pant
    self.m_CurColorIndex =  self.m_PartColorIndexTable[define.Ranse.PartType.pant]
    local colorItem = self:FindColorItemById(self.m_CurColorIndex)
    colorItem:ForceSelected(true)

end

function CRansePart.OnClickRecoverBtn(self)
    
    self.m_CurPart = define.Ranse.PartType.hair

    self:InitPartColorIndex()

    self:RefreshModel()

    self:RefreshPartSelect()


    --刷新颜色选择
    if self.m_ColorItem then 
        self.m_ColorItem:ForceSelected(false)
        self.m_ColorItem = nil
    end 

    if self.m_HairSelect then 
       self.m_HairSelect:ForceSelected(true)
    end 

    if self.m_ClotheSelect then 
        self.m_ClotheSelect:ForceSelected(false)
    end 

    if self.m_PantSelect then 
        self.m_PantSelect:ForceSelected(false)
    end 

    --刷新消耗
    self:RefreshConsumeBoxs()

    self.m_CurColorIndex =  self.m_PartColorIndexTable[define.Ranse.PartType.hair]
    local colorItem = self:FindColorItemById(self.m_CurColorIndex)
    colorItem:ForceSelected(true)
    
end

function CRansePart.OnClickRandomBtn(self)
    
    local max = #data.ransedata.COLOR

    local value = nil
    --随机头发
    repeat 
        value = math.random(max)
    until value ~=  g_AttrCtrl.model_info_changed.ranse_hair

    self.m_PartColorIndexTable[define.Ranse.PartType.hair] = value

    --随机衣服
    repeat 
        value = math.random(max)
    until value ~=  g_AttrCtrl.model_info_changed.ranse_clothes

    self.m_PartColorIndexTable[define.Ranse.PartType.clothes] = value

    --裤子
    repeat 
        value = math.random(max)
    until value ~=  g_AttrCtrl.model_info_changed.ranse_pant

    self.m_PartColorIndexTable[define.Ranse.PartType.pant] = value


    self:RefreshModel()

    self:RefreshPartSelect()

    self:RefreshConsumeBoxs()

    self.m_CurColorIndex =  self.m_PartColorIndexTable[ self.m_CurPart]
    local colorItem = self:FindColorItemById(self.m_CurColorIndex)
    colorItem:ForceSelected(true)  

end

function CRansePart.OnClickConfirmBtn(self)
    if not self:IsCanRanse() then 
        g_NotifyCtrl:FloatMsg(data.ransedata.TEXT[2013].text)
        return
    end 
    self:JudgeLackList()
    if g_QuickGetCtrl.m_IsLackItem then
        return
    end
    --判断物品是否足够
    if not self:IsConsumeEnough() then
        -- local name = ""
        -- for k, v in pairs(self.m_ConsumeBoxGrid:GetChildList()) do
        --     if not v:IsEnought() then 
        --         local config = DataTools.GetItemData(v:GetConsumeId(), "OTHER")
        --         local name = string.format(data.colorinfodata.ITEM[config.quality].color, config.name)
        --         local tip = data.ransedata.TEXT[2005].text
        --         tip = string.gsub(tip, "#name", name)
        --         g_NotifyCtrl:FloatMsg(tip)
        --     end 
        -- end
        return
    end 

    self:PlayRanseAni()
end

function CRansePart.PlayRanseAni(self, iQuick)
    local hairColor = self.m_PartColorIndexTable[define.Ranse.PartType.hair] 
    local clothesColor = self.m_PartColorIndexTable[define.Ranse.PartType.clothes] 
    local pantColor = self.m_PartColorIndexTable[define.Ranse.PartType.pant]

    self.m_ProgressNode:SetActive(true)
    local x = 0
    local fun = function ()
        if x > 1 then 
            self.m_ProgressNode:SetActive(false)
            g_RanseCtrl:C2GSPlayerRanSe(clothesColor, hairColor, pantColor, iQuick)
            return false
        end 
        x = x + 0.05
        self.m_Slider:SetValue(x)
        return true
    end

    Utils.AddTimer(fun, 0.1, 0)

end

--解析配置物品数据
function CRansePart.ParseItemConfig(self, part, colorIndex)
    
    local itemList = {}
    

    local config = nil

    if part == define.Ranse.PartType.hair then 
        config =  data.ransedata.HAIR[g_AttrCtrl.model_info.shape]
    elseif part == define.Ranse.PartType.clothes then 
        config =  data.ransedata.CLOTHES[g_AttrCtrl.model_info.shape]
    elseif part == define.Ranse.PartType.pant then 
        config =  data.ransedata.PANT[g_AttrCtrl.model_info.shape]
    end 

    if config == nil then 
        return
    end

    local consumeItem = nil
    if colorIndex > 0 then 
        consumeItem = config.itemlist[colorIndex]
    else
         consumeItem = config.dresume[1]
    end 

   if consumeItem == nil then 
       return
   end

   itemList.gold = consumeItem.gold
   itemList.silver = consumeItem.silver
   itemList.itemTable = {}

    if string.len(consumeItem.item) > 0 then 
        if string.match(consumeItem.item, "&") then 
            local consumeItems =  string.split(consumeItem.item, "&")
            for k , v in pairs(consumeItems) do 
                local info = string.split(v, "*")
                local item = {}
                item.id = tonumber(info[1])
                item.count = tonumber(info[2])
                itemList.itemTable[item.id] = item
            end
        else
             local info =  string.split(consumeItem.item, "*")
             local item = {}
             item.id = tonumber(info[1])
             item.count = tonumber(info[2])
             itemList.itemTable[item.id] = item
         end 
    end

    return itemList

end

function CRansePart.RefreshConsumeBoxs(self)

    --遍历消耗项列表
    for k, v in ipairs(self.m_ConsumeBoxGrid:GetChildList()) do

        local itemList = nil

        if v.type == "gold" then
            
            --取头发金币
            local colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.hair]
            local hairGold = 0
            if  not self:IsPartHadRanse(define.Ranse.PartType.hair, colorIndex) then 
                itemList = self:ParseItemConfig(define.Ranse.PartType.hair, colorIndex)
                hairGold = itemList.gold 
            end  

            --取衣服金币
            colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.clothes]
            local clothesGold = 0
            if  not self:IsPartHadRanse(define.Ranse.PartType.clothes, colorIndex) then 
                itemList = self:ParseItemConfig(define.Ranse.PartType.clothes, colorIndex)
                clothesGold = itemList.gold
            end 

            --裤子
            colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.pant]
            local pantGold = 0
            if  not self:IsPartHadRanse(define.Ranse.PartType.pant, colorIndex)  then 
                itemList = self:ParseItemConfig(define.Ranse.PartType.pant, colorIndex)
                pantGold = itemList.gold
            end 


            local totalGold = hairGold + clothesGold + pantGold

            local goldInfo = {}
            goldInfo.iconId = 10002
            goldInfo.needCount = totalGold
            goldInfo.hadCount =  g_AttrCtrl.gold
            v:SetInfo(goldInfo)

        elseif v.type == "silver" then 

            --取头发银币
            local colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.hair]
            local hairSilver = 0 
            if  not self:IsPartHadRanse(define.Ranse.PartType.hair, colorIndex) then 
                itemList = self:ParseItemConfig(define.Ranse.PartType.hair, colorIndex)
                hairSilver = itemList.silver
            end 

            --取衣服银币
            colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.clothes]
            local clothesSilver = 0
            if not self:IsPartHadRanse(define.Ranse.PartType.clothes, colorIndex) then 
                itemList = self:ParseItemConfig(define.Ranse.PartType.clothes, colorIndex)
                clothesSilver = itemList.silver
            end 

            --裤子
            colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.pant]
            local pantSilver = 0
            if not self:IsPartHadRanse(define.Ranse.PartType.pant, colorIndex) then 
                itemList = self:ParseItemConfig(define.Ranse.PartType.pant, colorIndex)
                pantSilver = itemList.silver
            end 

            local totalSilver = hairSilver + clothesSilver + pantSilver

            local silverInfo = {}  
            silverInfo.iconId = 10003
            silverInfo.needCount = self.m_Silver
            silverInfo.hadCount =  g_AttrCtrl.silver
            silverBox:SetInfo(silverInfo)

        elseif v.type == "item" then

            --取头发消耗数量
            local  colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.hair]
            local hairItemCount = 0
            if colorIndex > 0  then 
                if  not self:IsPartHadRanse(define.Ranse.PartType.hair, colorIndex) then 
                    itemList = self:ParseItemConfig(define.Ranse.PartType.hair, colorIndex)
                    hairItemCount = itemList.itemTable[v:GetConsumeId()].count
                end 
            end

            
            --取衣服消耗数量
            colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.clothes]
            local clothesItemCount = 0
            if colorIndex > 0  then 
                if  not self:IsPartHadRanse(define.Ranse.PartType.clothes, colorIndex) then 
                    itemList = self:ParseItemConfig(define.Ranse.PartType.clothes, colorIndex)
                    clothesItemCount = itemList.itemTable[v:GetConsumeId()].count
                end  

            end

            --取裤子消耗数量
            colorIndex = self.m_PartColorIndexTable[define.Ranse.PartType.pant]
            local pantItemCount = 0
            if colorIndex > 0  then 
                if  not self:IsPartHadRanse(define.Ranse.PartType.pant, colorIndex) then 
                    itemList = self:ParseItemConfig(define.Ranse.PartType.pant, colorIndex)
                    pantItemCount = itemList.itemTable[v:GetConsumeId()].count
                end 
            end

            local totalItemCount = hairItemCount + clothesItemCount + pantItemCount

            local itemInfo = {}
            itemInfo.iconId = DataTools.GetItemData(v:GetConsumeId(), "OTHER").icon
            itemInfo.needCount = totalItemCount
            itemInfo.hadCount =  g_ItemCtrl:GetBagItemAmountBySid(v:GetConsumeId())
            itemInfo.id = v:GetConsumeId()
            v:SetInfo(itemInfo)

        end 

    end

end

function CRansePart.IsConsumeEnough(self)
    
    for k, v in ipairs(self.m_ConsumeBoxGrid:GetChildList()) do

        if not v:IsEnought() then 
            return false
        end 

    end 

    return true

end

function CRansePart.GetNotEnoughItemName(self)
    
    local name = ""
    for k, v in ipairs(self.m_ConsumeBoxGrid:GetChildList()) do
        if not v:IsEnought() then 
            local config = DataTools.GetItemData(v.id, "OTHER")
            table.print(config, "=== In CRansePart.GetNotEnoughItemName ===")
            local name = string.format(data.colorinfodata.ITEM[config.quality].color, config.name)

        end 
    end

    return name

end

function CRansePart.IsCanRanse(self)
    
    local hair = self.m_PartColorIndexTable[define.Ranse.PartType.hair] ~= g_AttrCtrl.model_info_changed.ranse_hair 
    local clothes = self.m_PartColorIndexTable[define.Ranse.PartType.clothes] ~= g_AttrCtrl.model_info_changed.ranse_clothes 
    local pant = self.m_PartColorIndexTable[define.Ranse.PartType.pant] ~= g_AttrCtrl.model_info_changed.ranse_pant
    return hair or clothes or pant

end

function CRansePart.OnClickTip(self)

    local id = define.Instruction.Config.RoleRanse
    if data.instructiondata.DESC[id] ~= nil then 

        local content = {
            title = data.instructiondata.DESC[id].title,
            desc  = data.instructiondata.DESC[id].desc
        }

        g_WindowTipCtrl:SetWindowInstructionInfo(content)

    end 

end

function CRansePart.JudgeLackList(self)
    -- body
    local itemlist = {}
    for i,v in ipairs(self.m_ConsumeBoxGrid:GetChildList()) do
       if v.m_consumeInfo.hadCount < v.m_consumeInfo.needCount then
            local t = {sid = v.m_consumeInfo.id, count = v.m_consumeInfo.hadCount, amount = v.m_consumeInfo.needCount}
            table.insert(itemlist, t)
       end
    end

    local args = {
        itemlist = itemlist,
        exchangeCb = function(cost, moneytype)
            if not moneytype or moneytype == define.Currency.Type.GoldCoin then 
                local goldcoin =  g_AttrCtrl:GetGoldCoin()
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
        end,
    }
    g_QuickGetCtrl:CheckLackItemInfo(args)
end

return CRansePart