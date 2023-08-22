local CSummonCulturePageBox = class("CSummonCulturePageBox", CBox)

-- 废弃脚本
function CSummonCulturePageBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
    self.m_CultureItemDesId = 2001
    self.m_CultureItemList = {"attack", 
							  "defense",
							  "health",
							  "mana",
							  "speed",							  
							}
    self.m_CultureToolItemId = 10034 --资质培养物品ID   
	self.m_CultureHintId_1 = 1042
	self.m_CultureHintId_2 = 1043
	self.m_CultureHintId_3 = 1044
	self.m_FirstOpen = true
    self:InitContent()
end

function CSummonCulturePageBox.InitContent(self)
    self.m_CulturePropertyGrid = self:NewUI(1, CGrid)
	self.m_CultureItemIcon = self:NewUI(2, CButton)
	self.m_CultureItemName = self:NewUI(3, CLabel)
	self.m_CultureItemCount = self:NewUI(4, CLabel)
	self.m_CultureItemDesBtn = self:NewUI(5, CButton)
	self.m_CultureItemUpgradeBtn = self:NewUI(6, CButton)
	local function Init(obj, idx)
		local go = CBox.New(obj)
		go:SetGroup(self.m_CulturePropertyGrid:GetInstanceID())
		go:AddUIEvent("click",function ()
			self.m_Index = idx
		end)
		go.number = go:NewUI(1, CLabel)
		return go
    end
	self.m_CulturePropertyGrid:InitChild(Init)
    self.m_CultureItemUpgradeBtn:AddUIEvent("click", callback(self, "OnCultureItemUpgrade"))
    g_SummonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
    self.m_CultureItemDesBtn:AddUIEvent("click",function ()
		local zContent = {title = "培养",desc = data.summondata.TEXT[self.m_CultureItemDesId].content}
    	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
	end)
end

function CSummonCulturePageBox.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Summon.Event.BagItemUpdate then
        --刷新宠物资质丹数量
	    local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_CultureToolItemId)
		--self.m_CultureItemCount:SetCountColor(count)
		local text = count > 0 and string.format("[1D8E00]%s/1[-]",count) or string.format("[D71420]%s/1[-]", count)
		self.m_CultureItemCount:SetText(text)
    end
end

function CSummonCulturePageBox.SetInfo(self, summonId)
	if summonId ~= self.m_CurSummonId then
		self.m_FirstOpen = true
	else
		self.m_FirstOpen = false	
	end
	self.m_CurSummonId = summonId
    local  dp = g_SummonCtrl:GetSummon(summonId)
	-- self.m_CultureGrowth = self.m_CulturePropertyGrid:GetChild(1)
	-- self.m_CultureGrowth.number:SetText(dp["grow"]/1000)	
	for i, v in ipairs(self.m_CultureItemList) do
		local child = self.m_CulturePropertyGrid:GetChild(i)		
		self:SetText(v, child, dp)					
		if child.isFull == false and self.m_FirstOpen then 
			self.m_Index = i 
			self.m_FirstOpen = false			
			child:SetSelected(true)
		end
	end
	if self.m_FirstOpen then 
		self.m_CulturePropertyGrid:GetChild(1):SetSelected(true)
		self.m_Index = 1
	end 
	local itemData = DataTools.GetItemData(self.m_CultureToolItemId)
	self.m_CultureItemIcon:SpriteItemShape(itemData.icon)
	self.m_CultureItemIcon:AddUIEvent("click", function ()		
		-- local config = {widget = self.m_CultureItemIcon}
		-- g_WindowTipCtrl:SetWindowItemTip(self.m_CultureToolItemId, config)
    	g_WindowTipCtrl:SetWindowGainItemTip(self.m_CultureToolItemId)
	end)
	self.m_CultureItemName:SetText(itemData.name)
	local count = g_ItemCtrl:GetBagItemAmountBySid(self.m_CultureToolItemId)
	--self.m_CultureItemCount:SetCountColor(count)
	local text = count > 0 and string.format("[1D8E00]%s/1[-]",count) or string.format("[D71420]%s/1[-]", count)
	self.m_CultureItemCount:SetText(text)
end


function CSummonCulturePageBox.SetText(self, name, type, dp)
	local info = data.summondata.INFO
	local baseValue = 23
	if dp.type == 2 or dp.type == 1 then
	 	baseValue = 23
	else
		baseValue = 27
	end
	local va = nil
	local isFull = nil
	local str = nil
	local nv = math.floor((baseValue - (dp["maxaptitude"][name] - dp["curaptitude"][name])*100/info[dp.typeid].aptitude[name])/baseValue*100)		
	--printc(name..":  "..nv.."   maxaptitude:"..dp["maxaptitude"][name].."  curaptitude:"..dp["curaptitude"][name].."   "..summonInfo.aptitude[name])
	if nv < 0 then
		nv = 0
	end
	if nv > 100 then 
		return nil
	end
	for k,v in pairs(data.summondata.APTITUFEPELLET) do			
		if nv >= v.schedule[1] and nv <= v.schedule[2] then 				
			va = v.add
			break
		end
	end
	local sub = dp["maxaptitude"][name] - dp["curaptitude"][name]
	if va[1]+dp["curaptitude"][name] > dp["maxaptitude"][name] then 		
		if sub == 0 then 
			str = string.format("%s/%s([38C81DFF]已满[-])", dp["curaptitude"][name], dp["maxaptitude"][name])
			type.isFull = true
		else
			str = string.format("%s/%s([38C81DFF]+%s[-])", dp["curaptitude"][name], dp["maxaptitude"][name], sub)
			type.isFull = false
		end		
	else
		if va[2] < sub then 
			sub = va[2]
		end 
		if va[1] == sub then 
			str = string.format("%s/%s([38C81DFF]+%s[-])", dp["curaptitude"][name], dp["maxaptitude"][name], sub)
		else
			str = string.format("%s/%s([38C81DFF]+%s~%s[-])", dp["curaptitude"][name], dp["maxaptitude"][name], va[1], sub)
		end 			
		type.isFull = false
	end	
	type.number:SetText(str)
end

function CSummonCulturePageBox.OnCultureItemUpgrade(self)
	-- if g_ItemCtrl:GetBagItemAmountBySid(self.m_CultureToolItemId) <= 0 then 
	-- 	g_NotifyCtrl:FloatSummonMsg(self.m_CultureHintId_1)
	-- 	return
	-- end
	if self.m_Index == nil then
		g_NotifyCtrl:FloatSummonMsg(self.m_CultureHintId_2)
		return
	end 
	if self.m_CulturePropertyGrid:GetChild(self.m_Index).isFull then 
		g_NotifyCtrl:FloatSummonMsg(self.m_CultureHintId_3)
		return
	end
	-- 临时去掉了
	-- self:JudgeLackList()
	-- if g_QuickGetCtrl.m_IsLackItem then
	-- 	return
	-- end

	-- 废弃脚本
	g_SummonCtrl:C2GSUseAptitudePellet(self.m_CurSummonId, self.m_Index)
end

function CSummonCulturePageBox.JudgeLackList(self)
	-- body
	local iSum = g_ItemCtrl:GetBagItemAmountBySid(self.m_CultureToolItemId)
	local itemlist = {}
	if iSum < 1 then
		local t = {sid = self.m_CultureToolItemId, count = iSum, amount = 1}
		table.insert(itemlist, t)
	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, {})
end

return CSummonCulturePageBox