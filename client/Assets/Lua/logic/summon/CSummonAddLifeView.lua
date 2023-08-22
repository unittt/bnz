local CSummonAddLifeView = class("CSummonAddLifeView", CViewBase)

function CSummonAddLifeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonAddLifeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "sub"
	-- self.m_ExtendClose = "Black"
    self.m_LifeStudyIdList = {10038, 10047}
end

function CSummonAddLifeView.OnCreateView(self)
    -- self.m_SummonPic = self:NewUI(1, CSprite)
    -- self.m_SummonName = self:NewUI(2, CLabel)
    -- self.m_SummonLevel = self:NewUI(3, CLabel)
    -- self.m_SummonLife = self:NewUI(4, CLabel)
    self.m_SummonItemGrid = self:NewUI(1, CGrid)
    self.m_SummonItem = self:NewUI(2, CBox)
    self.m_Bg = self:NewUI(3, CSprite)
    self.m_SummonCloseBtn = self:NewUI(4, CButton)  
    self:InitContent()
    self.m_SummonCloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSummonAddLifeView.OnCtrlEvent(self, oCtrl)
	-- if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and oCtrl.m_EventData.id == self.m_CurSummonId then		  		
	-- 	self:InitContent()        
	-- end	
    if oCtrl.m_EventID == define.Summon.Event.DelSummon then 
        if next(g_SummonCtrl:GetSummons()) == nil then
            self:OnClose()
		end
    end
    if oCtrl.m_EventID == define.Summon.Event.BagItemUpdate then
        for k,v in pairs(self.m_SummonItemGrid:GetChildList()) do
            self:UpdateItemAmount(v)
        end
    end
end

function CSummonAddLifeView.InitContent(self)
    -- self.m_Summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
    -- self.m_SummonCurGrade = self.m_Summon.grade
    -- self.m_SummonCurLife = self.m_Summon.life   
    -- self.m_SummonPic:SpriteAvatar(self.m_Summon.model_info.shape)
    -- self.m_SummonName:SetText(self.m_Summon.name)
    -- self.m_SummonLevel:SetText("等级: "..self.m_Summon.grade) 
    -- self.m_SummonLife:SetText("寿命: "..self.m_Summon.life)
    self.m_SummonItem:SetActive(false)
end

function CSummonAddLifeView.InitGrid(self)
    local list = self.m_SummonItemGrid:GetChildList()
    for k,v in ipairs(self.m_LifeStudyIdList) do
        local go = nil
        if k>#list then
            local amount = g_ItemCtrl:GetBagItemAmountBySid(v)
            go = self.m_SummonItem:Clone("Item")
            go:SetActive(true)
            go:SetGroup(self.m_SummonItemGrid:GetInstanceID())
            go.name = go:NewUI(1, CLabel)
            go.pic = go:NewUI(2, CSprite)
            go.des = go:NewUI(3, CLabel)
            go.count = go:NewUI(4, CLabel)
            local item = DataTools.GetItemData(v)
            go.name:SetText(item.name)   
            go.pic:SpriteItemShape(item.icon)
            go.itemId = v 
            self:UpdateItemAmount(go)
        else
            go = list[k]
        end
        if k == 1 then 
            go.des:SetText("增加500寿命")
        else
            local sFormula = DataTools.GetItemData(v).item_formula
            sFormula = string.gsub(sFormula, "quality", "品质")
            sFormula = string.gsub(sFormula, "*", "x")
            go.des:SetText(sFormula)
        end
        go:AddUIEvent("repeatpress", callback(self, "OnUseTools", go))
        go.m_RepeatDelta = 0.34
        self.m_SummonItemGrid:AddChild(go)
    end
end

function CSummonAddLifeView.UpdateItemAmount(self, oBox)
    local itemNum = g_ItemCtrl:GetBagItemAmountBySid(oBox.itemId)
    if itemNum <= 0 then
        itemNum = "[ffb398]"..itemNum
        oBox.count:SetEffectColor(Color.RGBAToColor("cd0000"))
    else
        itemNum = "[0fff32]"..itemNum
        oBox.count:SetEffectColor(Color.RGBAToColor("003C41"))
    end
    oBox.count:SetText(itemNum)
end

-- 10047具体增加数值
function CSummonAddLifeView.RefreshAddVal(self)
    if self.m_DynDescL then
        local itemId = self.m_LifeStudyIdList[2]
        if not itemId then return end
        local itemList = g_ItemCtrl:GetBagItemListBySid(itemId)
        table.sort(itemList, function(a, b)
            return a:GetSValueByKey("pos") < b:GetSValueByKey("pos")
        end)
        if next(itemList) then
            local sFormula = DataTools.GetItemData(itemId).item_formula
            if sFormula and string.len(sFormula) > 0 then
                local oItem = itemList[1]
                sFormula = string.gsub(sFormula, "quality", oItem:GetSValueByKey("itemlevel") or 0)
                local iAdd = loadstring("return " .. sFormula)()
                self.m_DynDescL:SetText(string.format("增加%d寿命", iAdd))
                return
            end
        end
        self.m_DynDescL:SetText(string.format("增加一定寿命"))
    end
end

function CSummonAddLifeView.OnUseTools(self, go, oBtn, bPress)    
    if not bPress then
        return      
	end
    local hitExtend = true
    local amount = g_ItemCtrl:GetBagItemAmountBySid(go.itemId)
    if amount <= 0 then
        g_WindowTipCtrl:SetWindowGainItemTip(go.itemId, nil, hitExtend)
        return
    end  
    self.m_CurItem = go
    g_SummonCtrl:C2GSUseLifePellet(self.m_CurSummonId,1,go.itemId)
end

function CSummonAddLifeView.SetData(self, summonid)
    self.m_CurSummonId = summonid
    -- self:InitContent()
    self:InitGrid()
end

return CSummonAddLifeView