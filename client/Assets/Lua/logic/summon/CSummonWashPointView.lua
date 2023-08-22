local CSummonWashPointView = class("CSummonWashPointView", CViewBase)

function CSummonWashPointView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Summon/SummonWashPointView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "sub"
	self.m_ExtendClose = "Black"
    self.m_WashToolsId = 10036
    self.m_AllWashToolsId = 10037
    self.m_DesId = 2007
    self.m_WashPointToolsDesId = 2008
end

function CSummonWashPointView.OnCreateView(self)
    self.m_SummonPic = self:NewUI(1, CSprite)
    self.m_SummonName = self:NewUI(2, CLabel)
    self.m_SummonLevel = self:NewUI(3, CLabel)
    self.m_SummonWashPointToolsPic = self:NewUI(4, CSprite)
    self.m_SummonWashPointToolsName = self:NewUI(5, CLabel)
    self.m_SummonWashPointToolsCount = self:NewUI(6, CLabel)
    self.m_SummonWashPointToolsDes = self:NewUI(7, CLabel)
    self.m_SummonWashPointItemGrid = self:NewUI(8, CGrid)
    self.m_SummonAllWashPointToolsPic = self:NewUI(9, CSprite)
    self.m_SummonAllWashPointToolsName = self:NewUI(10, CLabel)
    self.m_SummonAllWashPointToolsCount = self:NewUI(11, CLabel)
    self.m_SummonAllWashPointToolsDesBtn = self:NewUI(12, CButton)
    self.m_SummonAllWashPointBtn = self:NewUI(13, CButton)
    self.m_SummonCloseBtn = self:NewUI(14, CButton)
    self.m_SummonAllWashPointTools = self:NewUI(15, CBox)
    self.m_SummonAllWashPointHint = self:NewUI(16, CLabel)
    self.m_SummonPotentialPoint = self:NewUI(17, CLabel)    
    self:InitContent()
end

function CSummonWashPointView.InitEvent(self)
    self.m_SummonCloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_SummonAllWashPointToolsDesBtn:AddUIEvent("click",function ()
		local zContent = {title = "加点重置",desc = data.summondata.TEXT[self.m_DesId].content}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end)
    self.m_SummonAllWashPointBtn:AddUIEvent("click", callback(self, "OnAllWashPoint"))
    self.m_SummonWashPointToolsPic:AddUIEvent("click",function ()
  --       local config = {widget = self.m_SummonWashPointToolsPic}
		-- g_WindowTipCtrl:SetWindowItemTip(self.m_WashToolsId, config)
        g_WindowTipCtrl:SetWindowGainItemTip(self.m_WashToolsId)
     end)
    self.m_SummonAllWashPointToolsPic:AddUIEvent("click",function ()
  --       local config = {widget = self.m_SummonAllWashPointToolsPic}
		-- g_WindowTipCtrl:SetWindowItemTip(self.m_AllWashToolsId, config)
        g_WindowTipCtrl:SetWindowGainItemTip(self.m_AllWashToolsId)
    end)
end

function CSummonWashPointView.InitContent(self)     
    self:InitGrid()
    self:InitEvent()
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CSummonWashPointView.InitGrid(self)
    local function Init(obj,idx)
        local go = CBox.New(obj)        
        go.repoint = go:NewUI(1,CLabel)
        go.btn = go:NewUI(2,CButton)
        go.curpoint = go:NewUI(3,CLabel)
        go.btn:AddUIEvent("click", callback(self, "OnWashPoint", idx))
        go.btn.m_ClkDelta = 0.34
        return go
    end
    self.m_SummonWashPointItemGrid:InitChild(Init)
    local list = {"Physique", "Magic", "Strength", "Endurance", "Agility"}
    for k,v in pairs(list) do
        self["m_Summon" .. v] = self.m_SummonWashPointItemGrid:GetChild(k)
    end
end

function CSummonWashPointView.OnCtrlEvent(self, oCtrl)
 --    self.m_Summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
 --    if self.m_Summon == nil then 
	-- 	return
	-- end
	if oCtrl.m_EventID == define.Summon.Event.UpdateSummonInfo and self.m_CurSummonId == oCtrl.m_EventData.id then     
	    g_NotifyCtrl:FloatMsg("潜力点已重置")
        self:SetInfo()
	end
    if oCtrl.m_EventID == define.Summon.Event.BagItemUpdate then 
        local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_AllWashToolsId)
        local text = count > 0 and string.format("[1D8E00]%s/1[-]",count) or string.format("[D71420]%s/1[-]", count)					
        self.m_SummonAllWashPointToolsCount:SetText(text)
        count = g_ItemCtrl:GetBagItemAmountBySid(self.m_WashToolsId)
        --self.m_SummonWashPointToolsCount:SetCountColor(count)
        text = count > 0 and string.format("[1D8E00]%s[-]",count) or string.format("[D71420]%s[-]", count)
        self.m_SummonWashPointToolsCount:SetText(count)       
	end
    if oCtrl.m_EventID == define.Summon.Event.DelSummon then
		local summons = g_SummonCtrl:GetSummons()	
		if next(summons) == nil then
			self:OnClose()
			return
		end		
		if summons[self.m_CurSummonId] == nil then
			self.m_CurSummonId = g_SummonCtrl:GetSummonIdByIndex(1)
			self:SetPropertyInfo(self.m_CurSummonId)
		end
	end
end

function CSummonWashPointView.SetInfo(self)
    self.m_SummonPic:SpriteAvatar(self.m_Summon.model_info.shape)
    self.m_SummonName:SetText(self.m_Summon.name)    
    self.m_SummonLevel:SetText("等级: "..self.m_Summon.grade) 
    self.m_SummonPotentialPoint:SetText("未分潜力点\n"..self.m_Summon.point)
    local item = DataTools.GetItemData(self.m_WashToolsId)
    self.m_SummonWashPointToolsPic:SpriteItemShape(item.icon)
    self.m_SummonWashPointToolsName:SetText(item.name)
    self.m_SummonWashPointToolsDes:SetText(data.summondata.TEXT[self.m_WashPointToolsDesId].content)
    local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_WashToolsId)
    --self.m_SummonWashPointToolsCount:SetCountColor(count)
    local text = count > 0 and string.format("[1D8E00]%s[-]",count) or string.format("[D71420]%s[-]", count)
    self.m_SummonWashPointToolsCount:SetText(text)
    local sum = self.m_Summon.grade + 10  
    if self.m_Summon.freepoint == 0 then 
        self.m_SummonAllWashPointHint:SetActive(true)
        self.m_SummonAllWashPointTools:SetActive(false)
    else
        self.m_SummonAllWashPointHint:SetActive(false)
        self.m_SummonAllWashPointTools:SetActive(true)
        item = DataTools.GetItemData(self.m_AllWashToolsId)
        self.m_SummonAllWashPointToolsPic:SpriteItemShape(item.icon)
        self.m_SummonAllWashPointToolsName:SetText(item.name)
        count = g_ItemCtrl:GetBagItemAmountBySid(self.m_AllWashToolsId)
        --self.m_SummonAllWashPointToolsCount:SetCountColor(count)  
        local text = count > 0 and string.format("[1D8E00]%s/1[-]",count) or string.format("[D71420]%s/1[-]", count)     
        self.m_SummonAllWashPointToolsCount:SetText(text)
    end
    local physique = self.m_Summon.attribute.physique
    local magic = self.m_Summon.attribute.magic
    local strength = self.m_Summon.attribute.strength
    local endurance = self.m_Summon.attribute.endurance
    local agility = self.m_Summon.attribute.agility
    self.m_SummonPhysique.curpoint:SetText("体质 "..physique)
    self.m_SummonMagic.curpoint:SetText("魔力 "..magic)
    self.m_SummonStrength.curpoint:SetText("力量 "..strength)
    self.m_SummonEndurance.curpoint:SetText("耐力 "..endurance)
    self.m_SummonAgility.curpoint:SetText("敏捷 "..agility)
    physique = (physique - sum) > 0 and (physique - sum) or 0
    magic = (magic - sum) > 0 and (magic - sum) or 0
    strength = (strength - sum) > 0 and (strength - sum) or 0
    endurance = (endurance - sum) > 0 and (endurance - sum) or 0
    agility = (agility - sum) > 0 and (agility - sum) or 0  
    self.m_SummonPhysique.repoint:SetText("可重置 "..physique)
    self.m_SummonMagic.repoint:SetText("可重置 ".. magic)
    self.m_SummonStrength.repoint:SetText("可重置 "..strength)
    self.m_SummonEndurance.repoint:SetText("可重置 "..endurance)
    self.m_SummonAgility.repoint:SetText("可重置 "..agility)
end

function CSummonWashPointView.OnWashPoint(self,idx)
    g_SummonCtrl:C2GSUsePointPellet(self.m_CurSummonId, idx)
end

function CSummonWashPointView.OnAllWashPoint(self)
    g_SummonCtrl:C2GSUsePointPellet(self.m_CurSummonId, 6)
end

function CSummonWashPointView.SetData(self, summonid)
    self.m_CurSummonId = summonid 
    self.m_Summon = g_SummonCtrl:GetSummon(self.m_CurSummonId)
    self:SetInfo()
end

return CSummonWashPointView