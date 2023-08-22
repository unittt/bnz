local CSummonRSkillPageBox = class("CSummonRSkillPageBox", CBox)

function CSummonRSkillPageBox.ctor(self, obj, type)
	CBox.ctor(self, obj)
	self.m_Type = type 
	self:InitContent(type)	
end

function CSummonRSkillPageBox.InitContent(self, type)
    local function InitSlider1(obj, idx)
		local box = CBox.New(obj)
			if idx ~= 6 then 
				box.slider = box:NewUI(2, CSlider)	
			else	
				box.number = box:NewUI(2, CLabel)
			end
		return box
	end
    local function InitSlider2(obj, idx)
		local box = CBox.New(obj)
			if idx ~= 1 then 
				box.slider = box:NewUI(2, CSlider)	
			else	
				box.number = box:NewUI(2, CLabel)
			end
		return box
	end

	self.m_AptAttrList = self:NewUI(1, CGrid)
    if type == nil or type == "" then 
	    self.m_AptAttrList:InitChild(InitSlider1)
    else
        self.m_AptAttrList:InitChild(InitSlider2)
    end
	self.m_Talent = self:NewUI(2, CBox)
	self.m_Talent_01 = self.m_Talent:NewUI(1, CSprite)
    self.m_Talent_02 = self.m_Talent:NewUI(2, CSprite)
    self.m_Talent_01:SetActive(false)
    self.m_Talent_02:SetActive(false)
	self.m_SkillItemGird = self:NewUI(3, CGrid)
    self.m_SkillItem = self:NewUI(4, CBox)
	
end

function CSummonRSkillPageBox.SetInfo(self, summon, itype)
	local dp = nil
	if type(summon) == "number" then
		dp = g_SummonCtrl:GetSummon(summon)
	elseif type(summon) == "table" then
		dp = summon
	end
	if dp == nil then 
		return
	end 
	local list = {
		{cur = dp["curaptitude"]["attack"], max = dp["maxaptitude"]["attack"]},
		{cur = dp["curaptitude"]["defense"], max = dp["maxaptitude"]["defense"]},
		{cur = dp["curaptitude"]["health"], max = dp["maxaptitude"]["health"]},
		{cur = dp["curaptitude"]["mana"], max = dp["maxaptitude"]["mana"]},
		{cur = dp["curaptitude"]["speed"], max = dp["maxaptitude"]["speed"]}
	}
	for k,v in pairs(self.m_AptAttrList:GetChildList()) do
        if itype == nil or itype == "" then 
            if k ~= 6 then
                self:SetSlider(v.slider, list[k].cur, list[k].max)
            else
                v.number:SetText(dp["grow"]/1000)
            end 
        else
            if k ~= 1 then 
                self:SetSlider(v.slider, list[k-1].cur, list[k-1].max)
            else
                v.number:SetText(dp["grow"]/1000)
            end 
        end    
	end
	---天赋信息
	if dp["talent"][1] ~= nil then 		
		self.m_Talent_01:SetActive(true)
		local icon = tonumber(data.summondata.SKILL[dp["talent"][1].sk].iconlv[1].icon)
		self.m_Talent_01:SpriteSkill(icon)
		self.m_Talent_01:AddUIEvent("click", callback(self, "OnSkillItem", dp["talent"][1], self.m_Talent_01, true))
	else
		self.m_Talent_01:AddUIEvent("click", callback(self, "OnSkillItem", nil))
		self.m_Talent_01:SetActive(false)	
	end	
	if dp["talent"][2] ~= nil then
		self.m_Talent_02:SetActive(true)
		local icon = tonumber(data.summondata.SKILL[dp["talent"][2].sk].iconlv[1].icon)
		self.m_Talent_02:SpriteSkill(icon)
		self.m_Talent_02:AddUIEvent("click", callback(self, "OnSkillItem", dp["talent"][2],self.m_Talent_02,true))
	else
		self.m_Talent_02:AddUIEvent("click", callback(self, "OnSkillItem", nil))
		self.m_Talent_02:SetActive(false)				
	end
	self:InitSkillGrid(summon)
end

--初始化技能列表
function CSummonRSkillPageBox.InitSkillGrid(self, summon)
	local sumid = nil
	local i = 1
	local child = nil
	local dp = nil
	if type(summon) == "number" then
		local sum = g_SummonCtrl:GetSummon(summon)
		dp = sum.skill
		sumid = sum.typeid
	elseif type(summon) == "table" then
		dp = summon.skill
		sumid = summon.typeid
	end

	local function UpdateItem(item, v)
		item.icon:SpriteAdvancedSkill(data.summondata.SKILL[v.sk].iconlv, v.level)
		item.icon:SetActive(true)
		item.level:SetText(v.level.."级")
		item.level:SetActive(true)
		item.frame:SetSpriteName(g_SummonCtrl.m_FrameList[v.level])
		item.frame:SetActive(true)
		local sure = g_SummonCtrl:IsSureSkill(sumid, v.sk)
		item.sureSpr:SetActive(sure or false)
		item:AddUIEvent("click",callback(self, "OnSkillItem", v, item, nil))
		item:SetGroup(self.m_SkillItemGird:GetInstanceID())
		item:SetActive(true)
	end

	for k,v in pairs(dp) do
		child = self.m_SkillItemGird:GetChild(i)
		if child ~= nil then 
			UpdateItem(child, v)
		else	
			local item = self.m_SkillItem:Clone("Item")
			item.icon = item:NewUI(1, CSprite)	
			item.level = item:NewUI(2, CLabel)
			item.frame = item:NewUI(3, CSprite)
			item.sureSpr = item:NewUI(4, CSprite)
			UpdateItem(item, v)
			self.m_SkillItemGird:AddChild(item) 		
		end
		i = i + 1
	end
	if self.m_SkillItemGird:GetChild(i) ~= nil then 
		for k,v in pairs(self.m_SkillItemGird:GetChildList()) do
			if k >= i then 
				v.icon:SetActive(false)
				v.level:SetActive(false)
				v.frame:SetActive(false)
				v.sureSpr:SetActive(false)
				v:AddUIEvent("click",nil)
			end
		end
	end
	local function AddEmptyItem()
		local item = self.m_SkillItem:Clone("Item")
		item.icon = item:NewUI(1,CSprite)
		item.level = item:NewUI(2,CLabel)
		item.frame = item:NewUI(3,CSprite)
		item.sureSpr = item:NewUI(4, CSprite)
		item.icon:SetActive(false)
		item.level:SetActive(false)
		item.frame:SetActive(false)
		item.sureSpr:SetActive(false)
		item:SetGroup(self.m_SkillItemGird:GetInstanceID())
		item:SetActive(true)
		self.m_SkillItemGird:AddChild(item) 
	end
	for j=self.m_SkillItemGird:GetCount()+1, g_SummonCtrl.m_SummonSkillMax do
		 AddEmptyItem()
	end 
end

--显示技能Tips
function CSummonRSkillPageBox.OnSkillItem(self, data, item, istalent)
if data == nil then 
	return
end 
CSummonSkillItemTipsView:ShowView(function (oView)
		oView:SetData(data, item:GetPos(), istalent, nil, self.m_Type)	
	end)
end

function CSummonRSkillPageBox.SetSlider(self, slider, val1, val2)
	slider:SetValue(val1/val2)
	slider:SetSliderText(val1.."/"..val2)
end

return CSummonRSkillPageBox