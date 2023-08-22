local CArtifactMainPart = class("CArtifactMainPart", CPageBase)

function CArtifactMainPart.ctor(self, obj)
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
	self.m_AttrBox = self:NewUI(10, CBox)
	self.m_AttrBoxList = {}
	for i=1, 14 do
		local oBox = self.m_AttrBox:NewUI(i, CBox)
		oBox.m_NameLbl = oBox:NewUI(1, CLabel)
		oBox.m_AttrLbl = oBox:NewUI(2, CLabel)
		table.insert(self.m_AttrBoxList, oBox)	
	end
	self.m_TitleWidget = self:NewUI(11, CWidget)
	self.m_QiLingScrollView = self:NewUI(12, CScrollView)
	self.m_QiLingGrid = self:NewUI(13, CGrid)
	self.m_QiLingBoxClone = self:NewUI(14, CBox)
	self.m_ItemBox = self:NewUI(15, CBox)
	self.m_ItemBoxIconSp = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemBoxBorderSp = self.m_ItemBox:NewUI(2, CSprite)
	self.m_ItemBoxCountLbl = self.m_ItemBox:NewUI(3, CLabel)
	self.m_ItemBoxNameLbl = self.m_ItemBox:NewUI(4, CLabel)
	self.m_UpgradeBtn = self:NewUI(16, CButton)

	self.m_ItemSid = data.artifactdata.CONFIG[1].maincost
	self.m_ItemConfig = DataTools.GetItemData(self.m_ItemSid)
	-- netitem.C2GSItemGoldCoinPrice(self.m_ItemSid)

	self:InitContent()
end

function CArtifactMainPart.InitContent(self)
	self.m_QiLingBoxClone:SetActive(false)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTipsBtn"))
	self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItemBox"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgradeBtn"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_ArtifactCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlArtifactEvent"))

	self:RefreshUI()
end

function CArtifactMainPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshItem()
	end
end

function CArtifactMainPart.OnCtrlArtifactEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Artifact.Event.UpdateArtifactInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Artifact.Event.UpdateSpiritInfo then
		self:RefreshQiLingSkill()
	end
end

function CArtifactMainPart.RefreshUI(self)
	self:RefreshLeftInfo()

	self:RefreshItem()
end

function CArtifactMainPart.RefreshLeftInfo(self)
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

	local oCurStr = self:GetCurAttrStr("当前：", oAttrConfig, g_ArtifactCtrl.m_ArtifactGrade)
	local oNextLevel = g_ArtifactCtrl.m_ArtifactGrade+1
	
	if oCurStr then
		--暂时屏蔽
		self.m_CurLbl:SetActive(false)
		self.m_CurLbl:SetText(oCurStr)
	else
		self.m_CurLbl:SetActive(false)
	end
	if oNextLevel > data.artifactdata.UPGRADE[#data.artifactdata.UPGRADE].grade then
		self.m_NextLbl:SetActive(true)
		self.m_NextLbl:SetText("下级：已达最大等级")
	else
		local oNextStr = self:GetCurAttrStr("下级：", oAttrConfig, oNextLevel)
		if oNextStr then
			self.m_NextLbl:SetActive(true)
			self.m_NextLbl:SetText(oNextStr)
		else
			self.m_NextLbl:SetActive(false)
		end
	end
	local oNeedExp = 0
	if oNextLevel > data.artifactdata.UPGRADE[#data.artifactdata.UPGRADE].grade then
		oNeedExp = data.artifactdata.UPGRADE[#data.artifactdata.UPGRADE].exp_need
		self.m_ExpSlider:SetValue(oNeedExp/oNeedExp)
		self.m_ExpLbl:SetText(oNeedExp.."/"..oNeedExp.."(已满级)")
	else
		oNeedExp = data.artifactdata.UPGRADE[oNextLevel].exp_need
		self.m_ExpSlider:SetValue(g_ArtifactCtrl.m_ArtifactExp/oNeedExp)
		self.m_ExpLbl:SetText(g_ArtifactCtrl.m_ArtifactExp.."/"..oNeedExp)
	end	

	for k,v in ipairs(self.m_AttrBoxList) do
		local oAttrName = g_ArtifactCtrl.m_ArtifactAttrOrderList[k]
		if oAttrName then
			v:SetActive(true)
			local oNameStr = data.attrnamedata.DATA[oAttrName].name
			local oNameStrLen = string.utfStrlen(oNameStr)
			v.m_NameLbl:SetText(oNameStr)
			if oNameStrLen <= 2 then
				v.m_NameLbl:SetSpacingX(25)
			elseif oNameStrLen == 3 then
				v.m_NameLbl:SetSpacingX(5)
			elseif oNameStrLen >= 4 then
				v.m_NameLbl:SetSpacingX(0)
			end
			
			local oFindStr = g_ArtifactCtrl:GetIsShowRatio(oAttrName)
			if oFindStr then
				v.m_AttrLbl:SetText(g_ArtifactCtrl.m_ArtifactAttrList[oAttrName].."%")
			else
				v.m_AttrLbl:SetText(g_ArtifactCtrl.m_ArtifactAttrList[oAttrName])
			end
		else
			v:SetActive(false)
		end
	end

	self:RefreshQiLingSkill()

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

function CArtifactMainPart.RefreshQiLingSkill(self)
	if g_ArtifactCtrl.m_ArtifactFightSpiritId ~= 0 then
		self.m_QiLingScrollView:SetActive(true)
		self:SetQiLingSkillList()
	else
		self.m_QiLingScrollView:SetActive(false)
	end
end

function CArtifactMainPart.GetCurAttrStr(self, oStartStr, oAttrConfig, oLevel)
	local oStr
	for k,v in pairs(oAttrConfig) do
		if data.attrnamedata.DATA[k] then
			if v ~= "" then
				local oNumStr = string.gsub(v, "lv", tostring(oLevel))
				local oValue = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr))()))
				if not oStr then
					oStr = oStartStr..data.attrnamedata.DATA[k].name.."+"..oValue
				else
					oStr = oStr.." "..data.attrnamedata.DATA[k].name.."+"..oValue
				end
			end
		end
	end
	return oStr
end

function CArtifactMainPart.RefreshItem(self)
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

function CArtifactMainPart.SetQiLingSkillList(self)
	local oList = {}
	if g_ArtifactCtrl.m_ArtifactSpiritHashList[g_ArtifactCtrl.m_ArtifactFightSpiritId] then
		oList = g_ArtifactCtrl.m_ArtifactSpiritHashList[g_ArtifactCtrl.m_ArtifactFightSpiritId].skill_list
	end
	local optionCount = #oList
	local GridList = self.m_QiLingGrid:GetChildList() or {}
	local oQiLingSkillBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oQiLingSkillBox = self.m_QiLingBoxClone:Clone(false)
				-- self.m_QiLingGrid:AddChild(oOptionBtn)
			else
				oQiLingSkillBox = GridList[i]
			end
			self:SetQiLingSkillBox(oQiLingSkillBox, oList[i])
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

	self.m_QiLingGrid:Reposition()
	self.m_QiLingScrollView:ResetPosition()
end

function CArtifactMainPart.SetQiLingSkillBox(self, oQiLingSkillBox, oData)
	oQiLingSkillBox:SetActive(true)
	oQiLingSkillBox.m_IconSp = oQiLingSkillBox:NewUI(1, CSprite)
	oQiLingSkillBox.m_TalentSp = oQiLingSkillBox:NewUI(2, CSprite)
	oQiLingSkillBox.m_BindSp = oQiLingSkillBox:NewUI(3, CSprite)
	oQiLingSkillBox.m_SureSp = oQiLingSkillBox:NewUI(4, CSprite)
	oQiLingSkillBox.m_InfoWidget = oQiLingSkillBox:NewUI(5, CWidget)
	oQiLingSkillBox.m_EquipSp = oQiLingSkillBox:NewUI(6, CSprite)
	oQiLingSkillBox.m_QualitySp = oQiLingSkillBox:NewUI(7, CSprite)

	local oConfig = data.artifactdata.SKILL[oData]
	oQiLingSkillBox.m_IconSp:SpriteSkill(tostring(oConfig.icon))

	oQiLingSkillBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickQiLingSkillIcon", oConfig, oQiLingSkillBox.m_IconSp))

	self.m_QiLingGrid:AddChild(oQiLingSkillBox)
	self.m_QiLingGrid:Reposition()
end

--------------以下是点击事件--------------

function CArtifactMainPart.OnClickTipsBtn(self)
	local zContent = {title = data.instructiondata.DESC[14001].title,desc = data.instructiondata.DESC[14001].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CArtifactMainPart.OnClickItemBox(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CArtifactMainPart.OnClickUpgradeBtn(self)
	local oLimitLv
	if g_AttrCtrl.grade <= 0 then
		g_NotifyCtrl:FloatMsg(data.artifactdata.TEXT[1001].content)
		return
	elseif g_AttrCtrl.grade >= data.artifactdata.UPGRADELIMIT[#data.artifactdata.UPGRADELIMIT].player_grade then
		oLimitLv = data.artifactdata.UPGRADELIMIT[#data.artifactdata.UPGRADELIMIT].equip_grade_limit
	else
		oLimitLv = data.artifactdata.UPGRADELIMIT[g_AttrCtrl.grade].equip_grade_limit
	end
	if g_ArtifactCtrl.m_ArtifactGrade >= oLimitLv then
		g_NotifyCtrl:FloatMsg(data.artifactdata.TEXT[1001].content)
		return
	end

	local itemNum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	if itemNum <= 0 then
		local oNeedCount = 0
		local oNeedExp = 0
		local oNextLevel = g_ArtifactCtrl.m_ArtifactGrade+1
		if oNextLevel > data.artifactdata.UPGRADE[#data.artifactdata.UPGRADE].grade then
			return
		else
			oNeedExp = data.artifactdata.UPGRADE[oNextLevel].exp_need
		end
		local oNeedLeftExp = oNeedExp - g_ArtifactCtrl.m_ArtifactExp
		if oNeedLeftExp > 0 then
			local oValue = math.floor(tonumber(load(string.format([[return (%s)]], self.m_ItemConfig.item_formula))()))
			oNeedCount = math.ceil(oNeedLeftExp/oValue)
		end
		if itemNum < oNeedCount then
			-- netitem.C2GSItemGoldCoinPrice(self.m_ItemSid)
			local itemlist = {{sid = self.m_ItemSid, count = itemNum, amount = oNeedCount}}
			local oNeedGold = (g_ItemCtrl.m_ItemPriceDict[self.m_ItemSid] or 0)*oNeedCount
			local function goldbuyCallback()
				netartifact.C2GSArtifactUpgradeUse(1)
			end			
			local needChangeCb = function ()
				oNeedGold = (g_ItemCtrl.m_ItemPriceDict[self.m_ItemSid] or 0)*oNeedCount
				g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, oNeedGold, goldbuyCallback, nil, nil, nil)
			end			
		    g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, goldbuyCallback, nil, nil, nil)
		    return
		end
	end

	netartifact.C2GSArtifactUpgradeUse()
end

function CArtifactMainPart.OnClickQiLingSkillIcon(self, oConfig, oWidget)
	if not oConfig then
		return
	end
	CSummonSkillItemTipsView:ShowView(function (oView)
		oView:SetArtifactSkillTips(oConfig, oWidget)
	end)
end

return CArtifactMainPart