local CSummonAddExpView = class("CSummonAddExpView", CViewBase)

function CSummonAddExpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonAddExpView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "sub"
	-- self.m_ExtendClose = "Black"
    self.g_SummonCtrl = g_SummonCtrl
    self.m_ExpStudyToolsList = {10033}
end

function CSummonAddExpView.OnCreateView(self)
    -- self.m_SummonPic         = self:NewUI(1, CSprite)
    -- self.m_SummonName        = self:NewUI(2, CLabel)
    -- self.m_SummonLevel       = self:NewUI(3, CLabel)
    -- self.m_SummonExpSlider   = self:NewUI(4, CSlider)
    self.m_SummonExpItemGrid = self:NewUI(1, CGrid)
    self.m_SummonExpCloseBtn = self:NewUI(2, CButton)    
    -- self.m_SummonExpNumber   = self:NewUI(7, CLabel)
    self.m_SummonExpItem     = self:NewUI(3, CBox)
    self.m_Bg = self:NewUI(4, CSprite)
    self:InitContent()

    self.m_SummonExpCloseBtn:AddUIEvent("click", callback(self,"OnClose"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CSummonAddExpView.OnCtrlEvent(self, oCtrl)
	-- if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and oCtrl.m_EventData.id == self.m_CurSummonId then
 --        self:InitContent()
	-- end
    if oCtrl.m_EventID == define.Summon.Event.DelSummon then
        self.m_Summons = g_SummonCtrl:GetSummons()		
		if next(self.m_Summons) == nil then
            self:OnClose()
		end
    end
    if oCtrl.m_EventID == define.Summon.Event.BagItemUpdate then
        for k,v in pairs(self.m_SummonExpItemGrid:GetChildList()) do
            self:UpdateItemAmount(v)
        end       
    end 	
end

function CSummonAddExpView.InitContent(self)
    -- self.m_Data = data.upgradedata.DATA
    -- self.m_Summon = self.g_SummonCtrl.m_SummonsDic[self.m_CurSummonId]
    -- self.m_SummonCurExp = self:GetCurGradeExp(self.m_Summon)
    -- self.m_SummonCurGrade = self.m_Summon.grade   
    -- self.m_SummonPic:SpriteAvatar(self.m_Summon.model_info.shape)
    -- self.m_SummonName:SetText(self.m_Summon.name)
    -- self.m_SummonLevel:SetText("等级: "..self.m_Summon.grade)
    -- local info = self.m_Data[self.m_SummonCurGrade + 1]
    -- if info ~= nil then 
    --     self.m_SummonExpSlider:SetValue(self.m_SummonCurExp/info.summon_exp)    
    --     self.m_SummonExpNumber:SetText(self.m_SummonCurExp.."/"..info.summon_exp) 
    -- end
    self.m_SummonExpItem:SetActive(false)
end

function CSummonAddExpView.InitGrid(self)
    self.m_SummonExpItemGrid:Clear()
    for k,v in pairs(self.m_ExpStudyToolsList) do      
        local go = self.m_SummonExpItem:Clone("Item")
        go:SetActive(true)
        go:SetGroup(self.m_SummonExpItemGrid:GetInstanceID())
        go.name = go:NewUI(1, CLabel)
        go.pic = go:NewUI(2, CSprite)
        go.exp = go:NewUI(3, CLabel)
        go.count = go:NewUI(4, CLabel)
        go.quality = go:NewUI(5, CSprite)
        local item = DataTools.GetItemData(v)
        go.name:SetText(item.name)   
        go.pic:SpriteItemShape(item.icon)
        go.itemId = v
        self:UpdateItemAmount(go)
        go.exp:SetText(string.format("增加%s经验", item.item_formula))
        -- go.exp:SetLocalPos(Vector3.New(-10, -14.1, 0))
        go.quality:SetItemQuality(g_ItemCtrl:GetQualityVal( item.id, item.quality or 0 ) )
        go:AddUIEvent("repeatpress",callback(self,"OnUseTools",go))
        go.m_RepeatDelta = 0.34
        self.m_SummonExpItemGrid:AddChild(go)
    end   
end

function CSummonAddExpView.UpdateItemAmount(self, oBox)
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

function CSummonAddExpView.OnUseTools(self, go, oBtn, bPrees)    
    if not bPrees then       
		return
	end	   
    local amount = g_ItemCtrl:GetBagItemAmountBySid(go.itemId)
    if amount <= 0 then
        g_WindowTipCtrl:SetWindowGainItemTip(go.itemId)
        return
    end 
    self.m_CurItem = go
    self.g_SummonCtrl:C2GSUseSummonExpBook(self.m_CurSummonId, 1)
end

function CSummonAddExpView.GetCurGradeExp(self, data)
	return data["exp"]
end

function CSummonAddExpView.SetData(self, summonid)
    self.m_CurSummonId = summonid
    -- self:InitContent()
    self:InitGrid()
end

return CSummonAddExpView