local CArtifactQHPart = class("CArtifactQHPart", CPageBase)

function CArtifactQHPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_NameLbl = self:NewUI(1, CLabel)
	self.m_ScoreLbl = self:NewUI(2, CLabel)
	self.m_QiLingActorTexture = self:NewUI(3, CActorTexture)
	self.m_MainActorTexture = self:NewUI(4, CActorTexture)
	self.m_CurLbl = self:NewUI(5, CLabel)
	self.m_NextLbl = self:NewUI(6, CLabel)
	self.m_ExpSlider = self:NewUI(7, CSlider)
	self.m_ExpLbl = self:NewUI(8, CLabel)
	self.m_TipsBtn = self:NewUI(9, CButton)
	self.m_CurGrid = self:NewUI(10, CGrid)
	self.m_NextGrid = self:NewUI(11, CGrid)
	self.m_ItemBox = self:NewUI(12, CBox)
	self.m_ItemBoxIconSp = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemBoxBorderSp = self.m_ItemBox:NewUI(2, CSprite)
	self.m_ItemBoxCountLbl = self.m_ItemBox:NewUI(3, CLabel)
	self.m_ItemBoxNameLbl = self.m_ItemBox:NewUI(4, CLabel)
	self.m_UpgradeBtn = self:NewUI(13, CButton)
	self.m_MaxBox = self:NewUI(14, CBox)

	local function init(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_NameLbl = oBox:NewUI(1, CLabel)
		oBox.m_AttrLbl = oBox:NewUI(2, CLabel)
		return oBox
	end
	self.m_CurGrid:InitChild(init)

	local function init2(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_NameLbl = oBox:NewUI(1, CLabel)
		oBox.m_AttrLbl = oBox:NewUI(2, CLabel)
		return oBox
	end
	self.m_NextGrid:InitChild(init2)

	self.m_ItemSid = data.artifactdata.CONFIG[1].strengthcost
	self.m_ItemConfig = DataTools.GetItemData(self.m_ItemSid)
	-- netitem.C2GSItemGoldCoinPrice(self.m_ItemSid)

	self:InitContent()
end

function CArtifactQHPart.InitContent(self)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTipsBtn"))
	self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItemBox"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgradeBtn"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_ArtifactCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlArtifactEvent"))

	self:RefreshUI()
end

function CArtifactQHPart.OnCtrlArtifactEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Artifact.Event.UpdateArtifactInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Artifact.Event.UpdateSpiritInfo then
	end
end

function CArtifactQHPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshItem()
	end
end

function CArtifactQHPart.RefreshUI(self)
	self:RefreshLeftInfo()

	self:RefreshItem()
end

function CArtifactQHPart.RefreshLeftInfo(self)
	if g_ArtifactCtrl.m_ArtifactId == 0 then
		return
	end
	local oScoreConfig = data.artifactdata.EQUIPSCORE[g_ArtifactCtrl.m_ArtifactId]
	local oAttrConfig = data.artifactdata.EQUIPATTR[g_ArtifactCtrl.m_ArtifactId]
	if g_ArtifactCtrl.m_ArtifactStrengthLv > 0 then
		self.m_NameLbl:SetText(oScoreConfig.name.." +"..g_ArtifactCtrl.m_ArtifactStrengthLv.." "..g_ArtifactCtrl.m_ArtifactGrade.."级")
	else
		self.m_NameLbl:SetText(oScoreConfig.name.." "..g_ArtifactCtrl.m_ArtifactGrade.."级")
	end
	self.m_ScoreLbl:SetText("评分："..g_ArtifactCtrl.m_ArtifactScore)

	local oNextLevel = g_ArtifactCtrl.m_ArtifactStrengthLv+1
	local oNeedExp = 0
	if oNextLevel > data.artifactdata.STRENGTH[#data.artifactdata.STRENGTH].strength_lv then
		oNeedExp = data.artifactdata.STRENGTH[#data.artifactdata.STRENGTH].exp_need
		self.m_ExpSlider:SetValue(oNeedExp/oNeedExp)
		self.m_ExpLbl:SetText(oNeedExp.."/"..oNeedExp.."(已满级)")
	else
		oNeedExp = data.artifactdata.STRENGTH[oNextLevel].exp_need
		self.m_ExpSlider:SetValue(g_ArtifactCtrl.m_ArtifactStrengthExp/oNeedExp)
		self.m_ExpLbl:SetText(g_ArtifactCtrl.m_ArtifactStrengthExp.."/"..oNeedExp)
	end	

	self:SetCurAttrList()
	self:SetNextAttrList()

	if g_ArtifactCtrl.m_ArtifactFollowSpiritId ~= 0 then
		self.m_QiLingActorTexture:SetActive(true)
		local oQiLingConfig = data.artifactdata.SPIRITINFO[g_ArtifactCtrl.m_ArtifactFollowSpiritId]
		local model_info = {}
		model_info.figure = oQiLingConfig.figureid
		model_info.horse = nil
		self.m_QiLingActorTexture:ChangeShape(model_info)
	else
		self.m_QiLingActorTexture:SetActive(false)
	end

	local model_info = {}
	model_info.figure = oScoreConfig.figureid
	model_info.horse = nil
	model_info.Shenqi = true
	self.m_MainActorTexture:ChangeShape(model_info)
end

function CArtifactQHPart.RefreshItem(self)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	self.m_ItemBoxIconSp:SpriteItemShape(self.m_ItemConfig.icon)
	self.m_ItemBoxBorderSp:SetItemQuality(g_ItemCtrl:GetQualityVal( self.m_ItemConfig.id, self.m_ItemConfig.quality or 0 ))
	self.m_ItemBoxNameLbl:SetText(self.m_ItemConfig.name)
	if iAmount >= 1 then
		self.m_ItemBoxCountLbl:SetText("[244B4E]数量：[1d8e00]"..iAmount)
		-- self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("003C41"))
	else
		self.m_ItemBoxCountLbl:SetText("[244B4E]数量：[ff0000]"..iAmount)
		-- self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("790036"))
	end
end

function CArtifactQHPart.SetCurAttrList(self)
	local oList = {}
	local oConfig = g_ArtifactCtrl:GetStrengthEffectConfigById()
	if oConfig then
		for k,v in pairs(oConfig) do
			if data.attrnamedata.DATA[k] then
				if v ~= "" then
					table.insert(oList, {key = k, value = v})
				end
			end
		end
	end
	table.sort(oList, function (a, b)
		local oLen1 = string.len(a.key)
		local oLen2 = string.len(b.key)
		if oLen1 ~= oLen2 then
			return oLen1 < oLen2
		else
			return a.key < b.key
		end
	end)
	local optionCount = #oList
	local GridList = self.m_CurGrid:GetChildList() or {}
	local oCurAttrBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oCurAttrBox = self.m_BoxClone:Clone(false)
				-- self.m_CurGrid:AddChild(oOptionBtn)
			else
				oCurAttrBox = GridList[i]
			end
			self:SetCurAttrBox(oCurAttrBox, oList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_CurGrid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CArtifactQHPart.SetCurAttrBox(self, oCurAttrBox, oData)
	oCurAttrBox:SetActive(true)

	local oNameStr = data.attrnamedata.DATA[oData.key].name
	local oNameStrLen = string.utfStrlen(oNameStr)
	oCurAttrBox.m_NameLbl:SetText(oNameStr)
	if oNameStrLen <= 2 then
		oCurAttrBox.m_NameLbl:SetSpacingX(25)
	elseif oNameStrLen == 3 then
		oCurAttrBox.m_NameLbl:SetSpacingX(5)
	elseif oNameStrLen >= 4 then
		oCurAttrBox.m_NameLbl:SetSpacingX(0)
	end
	local oNumStr = string.gsub(oData.value, "strength_lv", tostring(g_ArtifactCtrl.m_ArtifactStrengthLv))
	oNumStr = string.gsub(oNumStr, "lv", tostring(g_ArtifactCtrl.m_ArtifactGrade))
	local oValue = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr))()))
	local oFindStr = g_ArtifactCtrl:GetIsShowRatio(oData.key)
	if oFindStr then
		oCurAttrBox.m_AttrLbl:SetText(oValue.."%")
	else
		oCurAttrBox.m_AttrLbl:SetText(oValue)
	end
	
	self.m_CurGrid:AddChild(oCurAttrBox)
	self.m_CurGrid:Reposition()
end

function CArtifactQHPart.SetNextAttrList(self)
	local oList = {}
	local oNextLevel = g_ArtifactCtrl.m_ArtifactStrengthLv+1
	if oNextLevel <= data.artifactdata.STRENGTH[#data.artifactdata.STRENGTH].strength_lv then
		self.m_NextGrid:SetActive(true)
		self.m_MaxBox:SetActive(false)
	else
		self.m_NextGrid:SetActive(false)
		self.m_MaxBox:SetActive(true)
		return
	end
	local oConfig = g_ArtifactCtrl:GetStrengthEffectConfigById()
	if oConfig then
		for k,v in pairs(oConfig) do
			if data.attrnamedata.DATA[k] then
				if v ~= "" then
					table.insert(oList, {key = k, value = v})
				end
			end
		end
	end
	table.sort(oList, function (a, b)
		local oLen1 = string.len(a.key)
		local oLen2 = string.len(b.key)
		if oLen1 ~= oLen2 then
			return oLen1 < oLen2
		else
			return a.key < b.key
		end
	end)
	local optionCount = #oList
	local GridList = self.m_NextGrid:GetChildList() or {}
	local oNextAttrBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oNextAttrBox = self.m_BoxClone:Clone(false)
				-- self.m_NextGrid:AddChild(oOptionBtn)
			else
				oNextAttrBox = GridList[i]
			end
			self:SetNextAttrBox(oNextAttrBox, oList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_NextGrid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CArtifactQHPart.SetNextAttrBox(self, oNextAttrBox, oData)
	oNextAttrBox:SetActive(true)

	local oNameStr = data.attrnamedata.DATA[oData.key].name
	local oNameStrLen = string.utfStrlen(oNameStr)
	oNextAttrBox.m_NameLbl:SetText(oNameStr)	
	if oNameStrLen <= 2 then
		oNextAttrBox.m_NameLbl:SetSpacingX(25)
	elseif oNameStrLen == 3 then
		oNextAttrBox.m_NameLbl:SetSpacingX(5)
	elseif oNameStrLen >= 4 then
		oNextAttrBox.m_NameLbl:SetSpacingX(0)
	end
	local oNextLevel = g_ArtifactCtrl.m_ArtifactStrengthLv+1
	if oNextLevel <= data.artifactdata.STRENGTH[#data.artifactdata.STRENGTH].strength_lv then
		local oNumStr = string.gsub(oData.value, "strength_lv", tostring(g_ArtifactCtrl.m_ArtifactStrengthLv+1))
		oNumStr = string.gsub(oNumStr, "lv", tostring(g_ArtifactCtrl.m_ArtifactGrade))		
		local oValue = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr))()))
		local oFindStr = g_ArtifactCtrl:GetIsShowRatio(oData.key)
		if oFindStr then
			oNextAttrBox.m_AttrLbl:SetText(oValue.."%")
		else
			oNextAttrBox.m_AttrLbl:SetText(oValue)
		end
	else
		local oNumStr = string.gsub(oData.value, "strength_lv", tostring(g_ArtifactCtrl.m_ArtifactStrengthLv))
		oNumStr = string.gsub(oNumStr, "lv", tostring(g_ArtifactCtrl.m_ArtifactGrade))		
		local oValue = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr))()))
		local oFindStr = g_ArtifactCtrl:GetIsShowRatio(oData.key)
		if oFindStr then
			oNextAttrBox.m_AttrLbl:SetText(oValue.."%")
		else
			oNextAttrBox.m_AttrLbl:SetText(oValue)
		end
	end

	self.m_NextGrid:AddChild(oNextAttrBox)
	self.m_NextGrid:Reposition()
end

--------------以下是点击事件--------------

function CArtifactQHPart.OnClickTipsBtn(self)
	local zContent = {title = data.instructiondata.DESC[14002].title,desc = data.instructiondata.DESC[14002].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CArtifactQHPart.OnClickItemBox(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CArtifactQHPart.OnClickUpgradeBtn(self)
	local oLimitLv
	if g_ArtifactCtrl.m_ArtifactGrade < g_ArtifactCtrl.m_StrengthLimitConfig[1].equip_grade then
		g_NotifyCtrl:FloatMsg(data.artifactdata.TEXT[1001].content)
		return
	elseif g_ArtifactCtrl.m_ArtifactGrade == g_ArtifactCtrl.m_StrengthLimitConfig[1].equip_grade then
		oLimitLv = g_ArtifactCtrl.m_StrengthLimitConfig[1].strength_lv_limit
	elseif g_ArtifactCtrl.m_ArtifactGrade >= g_ArtifactCtrl.m_StrengthLimitConfig[#g_ArtifactCtrl.m_StrengthLimitConfig].equip_grade then
		oLimitLv = g_ArtifactCtrl.m_StrengthLimitConfig[#g_ArtifactCtrl.m_StrengthLimitConfig].strength_lv_limit
	else
		oLimitLv = self:GetLimitLv().strength_lv_limit
	end
	if g_ArtifactCtrl.m_ArtifactStrengthLv >= oLimitLv then
		g_NotifyCtrl:FloatMsg(data.artifactdata.TEXT[1001].content)
		return
	end

	local itemNum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	if itemNum <= 0 then
		local oNeedCount = 0
		local oNeedExp = 0
		local oNextLevel = g_ArtifactCtrl.m_ArtifactStrengthLv+1
		if oNextLevel > data.artifactdata.STRENGTH[#data.artifactdata.STRENGTH].strength_lv then
			return
		else
			oNeedExp = data.artifactdata.STRENGTH[oNextLevel].exp_need
		end
		local oNeedLeftExp = oNeedExp - g_ArtifactCtrl.m_ArtifactStrengthExp
		if oNeedLeftExp > 0 then
			local oValue = math.floor(tonumber(load(string.format([[return (%s)]], self.m_ItemConfig.item_formula))()))
			oNeedCount = math.ceil(oNeedLeftExp/oValue)
		end
		if itemNum < oNeedCount then
			-- netitem.C2GSItemGoldCoinPrice(self.m_ItemSid)
			local itemlist = {{sid = self.m_ItemSid, count = itemNum, amount = oNeedCount}}
			-- local oNeedGold = (g_ItemCtrl.m_ItemPriceDict[self.m_ItemSid] or 0)*oNeedCount
			local function goldbuyCallback()
				netartifact.C2GSArtifactStrength(1)
			end	
		    g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, goldbuyCallback, nil, nil, nil)
		    return
		end
	end

	netartifact.C2GSArtifactStrength()
end

function CArtifactQHPart.GetLimitLv(self)
	for i=1, #g_ArtifactCtrl.m_StrengthLimitConfig-1 do
		if g_ArtifactCtrl.m_ArtifactGrade > g_ArtifactCtrl.m_StrengthLimitConfig[i].equip_grade and g_ArtifactCtrl.m_ArtifactGrade <= g_ArtifactCtrl.m_StrengthLimitConfig[i+1].equip_grade then
			return g_ArtifactCtrl.m_StrengthLimitConfig[i+1]
		end
	end
end

return CArtifactQHPart