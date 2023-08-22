local CHorseForgetSkillView = class("CHorseForgetSkillView", CViewBase)

function CHorseForgetSkillView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Horse/HorseForgetSkillView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CHorseForgetSkillView.OnCreateView(self)

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Skill = self:NewUI(2, CBox)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_ConsumeItem = self:NewUI(4, CBox)
	self.m_ForgetBtn = self:NewUI(5, CSprite)
	self.m_SkillPoint = self:NewUI(6, CLabel)

	self.m_SkillList = {}
	self:InitContent()

end


function CHorseForgetSkillView.InitContent(self)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_ForgetBtn:AddUIEvent("click", callback(self, "OnClickForgetBtn"))
	self:InitConsumeItem()

end

function CHorseForgetSkillView.RefreshAll(self)

	self:RefreshSkills()
	self:RefreshConsumeItem()
	self:RefreshSkillPoint()
	
end

function CHorseForgetSkillView.InitSkillItem(self, oItem)
	
	oItem.icon = oItem:NewUI(1, CSprite)
	oItem.type = oItem:NewUI(2, CLabel)
	oItem.name = oItem:NewUI(3, CLabel)
	oItem.lv = oItem:NewUI(4, CLabel)
	return oItem

end

function CHorseForgetSkillView.InitConsumeItem(self)
	
	self.m_ConsumeItem.icon = self.m_ConsumeItem:NewUI(1, CSprite)
	self.m_ConsumeItem.name = self.m_ConsumeItem:NewUI(2, CLabel)
	self.m_ConsumeItem.count = self.m_ConsumeItem:NewUI(3, CLabel)
	self.m_ConsumeItem.icon:AddUIEvent("click", callback(self, "OnClickConsumeItem"))

end

function CHorseForgetSkillView.OnClickConsumeItem(self)
	
	local config = data.ridedata.OTHER[1].forget_adv_cost
	g_WindowTipCtrl:SetWindowGainItemTip(config[1].sid)

end

function CHorseForgetSkillView.RefreshSkillPoint(self)
	
	--技能点计算
	if not next(self.m_SkillLvList) then 
		return
	end 

	local point = 0

	for k, v in ipairs(self.m_SkillLvList) do 
		local lvCnt = v.lvCnt
		point = point + lvCnt
	end	

	self.m_SkillPoint:SetText(point)

end

function CHorseForgetSkillView.RefreshSkills(self)
	
	self.m_Grid:HideAllChilds()
	self.m_SkillList = {}
	local id = self.m_SkillId
	local dataItem = data.ridedata.SKILL[id]
	if dataItem then 
		local ridetype = dataItem.ride_type
		local skList = {}
		if ridetype == 0 then 
			table.insert(skList, id)
		    local advList = g_HorseCtrl:FindAdvanceSkills(id)
		    for k, v in ipairs(advList) do 
		    	table.insert(skList, v)
		    end 
		else
		    table.insert(skList, id)
		end 

	    for k, sid in ipairs(skList) do 
	    	if g_HorseCtrl:IsHadLearnSkill(sid) then 
	    		local item = self.m_Grid:GetChild(k)
	    		if not item then 
	    		    item = self.m_Skill:Clone()
	    		    item:SetActive(true)
	    		    item = self:InitSkillItem(item)
	    		    self.m_Grid:AddChild(item)
	    		end
	    		local config =  data.ridedata.SKILL[sid]
	    		item.icon:SpriteSkill(tostring(config.icon))
	    		item.name:SetText(config.name)
	    		item.type:SetText(config.ride_type == 0 and "主技能" or "副技能")
	    		local lv = g_HorseCtrl:GetSkillLevel(sid)
	    		if lv > 1 then 
	    			item.lv:SetText("等级-1")
	    			item.lv:SetActive(true)
	    		else
	    			item.lv:SetActive(false)
	    		end 
	    		item:SetActive(true)
	    		table.insert(self.m_SkillList, sid)

	    	end 
	    end 

	end 

end

function CHorseForgetSkillView.RefreshConsumeItem(self)

	if not self.m_SkillId then
		return
	end 

	local needCount = 0
	local hadCount = 0
	self.m_SkillLvList = {}
	local skillData = data.ridedata.SKILL[self.m_SkillId]
	if skillData.ride_type == 0 then 
		local baseLv = g_HorseCtrl:GetSkillLevel(self.m_SkillId)
		if baseLv == 1 then 
			for k, id in ipairs(self.m_SkillList) do 
				local info = {}
				info.id = id
				info.lvCnt = g_HorseCtrl:GetSkillLevel(id)
				table.insert(self.m_SkillLvList, info)
			end
			needCount = self:CalConsumeCount()
		else
			for k, id in ipairs(self.m_SkillList) do 
				local info = {}
				info.id = id
				info.lvCnt = 1
				table.insert(self.m_SkillLvList, info)
			end
			needCount = self:CalConsumeCount()
		end 

		local config = data.ridedata.OTHER[1].forget_base_cost
		local costItem = DataTools.GetItemData(config[1].sid)
		self.m_ConsumeItem.icon:SetSpriteName(costItem.icon)
		self.m_ConsumeItem.name:SetText(costItem.name)
		hadCount = g_ItemCtrl:GetBagItemAmountBySid(config[1].sid)
		self.m_ConsumeItem.data = {id = config[1].sid, hadCount = hadCount, needCount = needCount}

	else
		local info = {}
		info.id = self.m_SkillId
		info.lvCnt = 1
		table.insert(self.m_SkillLvList, info)
		needCount = self:CalConsumeCount()
		local config = data.ridedata.OTHER[1].forget_adv_cost
		local costItem = DataTools.GetItemData(config[1].sid)
		self.m_ConsumeItem.icon:SetSpriteName(costItem.icon)
		self.m_ConsumeItem.name:SetText(costItem.name)
		hadCount = g_ItemCtrl:GetBagItemAmountBySid(config[1].sid)
		self.m_ConsumeItem.data = {id = config[1].sid, hadCount = hadCount, needCount = needCount}
	end 

	if hadCount == 0 or (hadCount < needCount) then 
		self.m_ConsumeItem.count:SetText(string.format("[af302a]%s[-][1d8e00]/%s[-]", hadCount, needCount))
	else
		self.m_ConsumeItem.count:SetText(string.format("[1d8e00]%s/%s[-]", hadCount, needCount))
	end 


end

--计算消耗 id lvCnt
function CHorseForgetSkillView.CalConsumeCount(self)

	if not next(self.m_SkillLvList) then 
		return
	end 
	local count = 0
	for k, info in pairs(self.m_SkillLvList) do
		local id = info.id
		local lvCnt = info.lvCnt 
		local dataItem = data.ridedata.SKILL[id]
		if dataItem then
			if dataItem.ride_type == 0 then 
				local config = data.ridedata.OTHER[1].forget_base_cost
				count = count + config[1].cnt * lvCnt
			else
				local config = data.ridedata.OTHER[1].forget_adv_cost
				count = count + config[1].cnt * lvCnt
			end 
		end 
	end 
	return count

end

function CHorseForgetSkillView.SetData(self, id)
	
	self.m_SkillId = id 
	self:RefreshAll()

end

function CHorseForgetSkillView.OnClickForgetBtn(self)
	
	local consumeData = self.m_ConsumeItem.data
	local hadCount = consumeData.hadCount
	local needCount = consumeData.needCount
	local id = consumeData.id
	if hadCount < needCount then
	    -- local itemData = DataTools.GetItemData(id)
	    -- g_NotifyCtrl:FloatMsg(itemData.name.."不足！")
        g_QuickGetCtrl:CheckLackItemInfo({
            itemlist = {{sid = id, count = hadCount, amount = needCount}},
            exchangeCb = function()
                netride.C2GSForgetRideSkill(self.m_SkillId, 1)
                self:OnClose()
            end
        })
	    return
	end
	g_HorseCtrl:C2GSForgetRideSkill(self.m_SkillId)
	self:OnClose()

end

function CHorseForgetSkillView.OnCtrlEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Attr.Event.Change then
         self:RefreshAll()
    end

end



return CHorseForgetSkillView