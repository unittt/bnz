local CFaBaoMakeView = class("CFaBaoMakeView", CViewBase)

function CFaBaoMakeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/FaBao/FaBaoMakeView.prefab", cb)

	self.m_DepthType = "Dialog"
	--self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"

	self.m_SelectIndex = 1
end

function CFaBaoMakeView.OnCreateView(self)
	-- body
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_FaBaoScroll = self:NewUI(2, CScrollView)
	self.m_FaBaoGrid = self:NewUI(3, CGrid)
	self.m_FaBaoClone = self:NewUI(4, CBox)

	self.m_AttrGrid = self:NewUI(5, CGrid)
	self.m_AttrBoxClone = self:NewUI(6, CBox)

	--self.m_SkillScroll = self:NewUI(7, CScrollView)
	self.m_SkillGrid = self:NewUI(8, CGrid)
	self.m_SkillClone = self:NewUI(9, CBox)

	self.m_ItemBox = self:NewUI(10, CBox)
	self.m_ItemIcon = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemQuality = self.m_ItemBox:NewUI(2, CSprite)
	self.m_ItemName = self.m_ItemBox:NewUI(3, CLabel)
	self.m_ItemAmount = self.m_ItemBox:NewUI(4, CLabel)

	self.m_MakeBtn = self:NewUI(11, CButton)

	self:InitContent()
end

function CFaBaoMakeView.InitContent(self)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MakeBtn:AddUIEvent("click", callback(self, "OnMake"))
	self.m_ItemBox:AddUIEvent("click", callback(self, "OnItemClick"))

	g_FaBaoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFaBaoEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))

	local dInfo = data.fabaodata.INFO
	local groupId = self.m_FaBaoGrid:GetInstanceID()

	for i, v in ipairs(dInfo) do
		local oFaBao = self.m_FaBaoGrid:GetChild(i)
		if oFaBao == nil then
			oFaBao = self.m_FaBaoClone:Clone()
			oFaBao.m_Icon = oFaBao:NewUI(1, CSprite)
			oFaBao.m_NameL = oFaBao:NewUI(2, CLabel)
			oFaBao.m_SelNameL = oFaBao:NewUI(3, CLabel)

			oFaBao:SetActive(true)
			oFaBao:SetGroup(groupId)
			oFaBao:AddUIEvent("click", callback(self, "OnFaBaoSelect", i))

			self.m_FaBaoGrid:AddChild(oFaBao)
		end

		oFaBao.m_Icon:SpriteItemShape(v.icon)
		oFaBao.m_NameL:SetText(v.name)
		oFaBao.m_SelNameL:SetText(v.name)
	end
	self.m_FaBaoGrid:Reposition()
	self.m_FaBaoScroll:ResetPosition()

	self.m_FaBaoGrid:GetChild(1):SetSelected(true)

	self:RefreshAttribute()
end

function CFaBaoMakeView.OnFaBaoSelect(self, idx)
	if self.m_SelectIndex == idx then
		return
	end
	self.m_SelectIndex = idx

	self:RefreshAttribute()
end

function CFaBaoMakeView.CheckFaBaoPatchCount(self)
	-- local sid = data.fabaodata.COMBINE[2].itemsid
	-- local count = g_ItemCtrl:GetBagItemAmountBySid(sid)
	-- local needAmount = data.fabaodata.COMBINE[2].amount
	-- if count < needAmount then
	-- 	local itemlist = {{sid = sid,  count = count, amount= needAmount}}
	-- 	g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function()
	-- 		netfabao.C2GSCombineFaBao(2, self.m_SelectIndex)
	-- 	end)
	-- else
	-- 	netfabao.C2GSCombineFaBao(2, self.m_SelectIndex)
	-- end
	netfabao.C2GSCombineFaBao(2, self.m_SelectIndex)
end

function CFaBaoMakeView.OnMake(self)
	self:CheckFaBaoPatchCount()
end

function CFaBaoMakeView.RefreshAttribute(self)
	self:CreateAttrBox()
	self:CreateSkillBox()
	self:CreateItemBox()
end

function CFaBaoMakeView.CreateAttrBox(self)
	local dInfo = data.fabaodata.INFO
	local info = dInfo[self.m_SelectIndex]

	self.m_AttrGrid:Clear()

	--基础属性
	local attrKeylist = {"magic", "strength", "endurance", "agility", "physique"}
	local attrlist = {}

	for i, v in ipairs(attrKeylist) do
		if info[v] > 0 then
			attrlist[v] = info[v]
		end
	end

	local index = 1
	for k, v in pairs(attrlist) do
		local oAttr = self.m_AttrGrid:GetChild(index)
		if oAttr == nil then
			oAttr = self.m_AttrBoxClone:Clone()
			oAttr.m_AttrLbl = oAttr:NewUI(1, CLabel)
			oAttr._AttrVal = oAttr:NewUI(2, CLabel)

			oAttr:SetActive(true)
			self.m_AttrGrid:AddChild(oAttr)
		end

		local attrL = g_FaBaoCtrl.m_Attr[k]
		oAttr.m_AttrLbl:SetText(attrL)
		oAttr._AttrVal:SetText("+"..v)

		index = index + 1
	end
end

function CFaBaoMakeView.CreateSkillBox(self)
	--法宝技能
	self.m_SkillGrid:Clear()
	local skillKey = {"juexing_skill", "tianhun_skill", "dihun_skill", "renhun_skill"}
	local info = data.fabaodata.INFO[self.m_SelectIndex]
	local dSkill = data.skilldata.FABAO
	local skills = {} --法宝技能列表

	for i, v in ipairs(skillKey) do
		local skill = info[v]
		if type(skill) == "table" then
			for i, v in ipairs(skill) do
				table.insert(skills, v)
			end
		else
			table.insert(skills, skill)
		end
	end
	
	for i, id in ipairs(skills) do
		local skilldata = dSkill[id]
		local oSkill = self.m_SkillGrid:GetChild(i)
		if oSkill == nil then
			oSkill = self.m_SkillClone:Clone()
			oSkill.m_Icon = oSkill:NewUI(1, CSprite)
			oSkill.m_Quality = oSkill:NewUI(2, CSprite)

			oSkill:AddUIEvent("click", callback(self, "OnShowSkillInfo", i, id))

			oSkill:SetActive(true)
			self.m_SkillGrid:AddChild(oSkill)
		end
		oSkill.m_Icon:SpriteSkill(skilldata.icon)
	end
	self.m_SkillGrid:Reposition()
end

function CFaBaoMakeView.CreateItemBox(self)
	-- 合成消耗
	local needAmount = data.fabaodata.COMBINE[2].amount
	local itemsid = data.fabaodata.COMBINE[2].itemsid
	local itemdata = DataTools.GetItemData(itemsid)
	local CurAmount = g_ItemCtrl:GetBagItemAmountBySid(itemsid)

	self.m_ItemIcon:SpriteItemShape(itemdata.icon)
	self.m_ItemQuality:SetItemQuality(itemdata.quality)
	self.m_ItemName:SetText(itemdata.name)

	self:SetColorText(CurAmount, needAmount)
end

function CFaBaoMakeView.SetColorText(self, curAmount, needAmount)
	if curAmount >= needAmount then
		self.m_ItemAmount:SetText("[244B4E]数量: #G"..curAmount.."[-]/"..needAmount.."[-]")
	else
		self.m_ItemAmount:SetText("[244B4E]数量: #R"..curAmount.."[-]/"..needAmount.."[-]")
	end
end

function CFaBaoMakeView.OnItemClick(self)
	local itemsid = data.fabaodata.COMBINE[2].itemsid

	g_WindowTipCtrl:SetWindowGainItemTip(itemsid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CFaBaoMakeView.OnShowSkillInfo(self, idx, skillId)
	local dInfo = data.skilldata.FABAO[skillId]
	local oSkill = self.m_SkillGrid:GetChild(idx)
	dInfo.widget = oSkill
	g_WindowTipCtrl:SetWindowSkillTip(dInfo)
end

function CFaBaoMakeView.OnFaBaoEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FaBao.Event.RefrershFaBaoPatch then
		local sid = data.fabaodata.COMBINE[2].itemsid
		local needAmount = data.fabaodata.COMBINE[2].amount
		local count = g_ItemCtrl:GetBagItemAmountBySid(sid)
		self:SetColorText(count, needAmount)
	end
end

function CFaBaoMakeView.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		local sid = oCtrl.m_EventData:GetSValueByKey("sid")
		self:ResetFabaoPatch(sid)
	elseif oCtrl.m_EventID == define.Item.Event.ItemAmount then
		local sid = oCtrl.m_EventData
		self:ResetFabaoPatch(sid)
	end
end

function CFaBaoMakeView.ResetFabaoPatch(self, sid)
	local needAmount = data.fabaodata.COMBINE[2].amount
	local itemsid = data.fabaodata.COMBINE[2].itemsid
	if sid == itemsid then
		local count = g_ItemCtrl:GetBagItemAmountBySid(sid)
		self:SetColorText(count, needAmount)
	end
end

return CFaBaoMakeView