local CArtifactQiLingPart = class("CArtifactQiLingPart", CPageBase)

function CArtifactQiLingPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_HasAwake = self:NewUI(1, CBox)
	self.m_NotAwakeBox = self:NewUI(2, CBox)
	self.m_HasAwakeClickBtn = self.m_HasAwake:NewUI(1, CWidget)
	self.m_HasAwakeArrowSp = self.m_HasAwake:NewUI(2, CSprite)
	self.m_HasAwakeHeightTweenWidget = self.m_HasAwake:NewUI(3, CWidget)
	self.m_HasAwakeTweenScrollView = self.m_HasAwake:NewUI(4, CScrollView)
	self.m_HasAwakeGrid = self.m_HasAwake:NewUI(5, CGrid)
	self.m_HasAwakeClone = self.m_HasAwake:NewUI(6, CBox)

	self.m_NotAwakeClickBtn = self.m_NotAwakeBox:NewUI(1, CWidget)
	self.m_NotAwakeArrowSp = self.m_NotAwakeBox:NewUI(2, CSprite)
	self.m_NotAwakeHeightTweenWidget = self.m_NotAwakeBox:NewUI(3, CWidget)
	self.m_NotAwakeTweenScrollView = self.m_NotAwakeBox:NewUI(4, CScrollView)
	self.m_NotAwakeGrid = self.m_NotAwakeBox:NewUI(5, CGrid)
	self.m_NotAwakeBoxClone = self.m_NotAwakeBox:NewUI(6, CBox)

	self.m_QiLingTitleLbl = self:NewUI(3, CLabel)
	self.m_FightSp = self:NewUI(4, CSprite)
	self.m_ActorTexture = self:NewUI(5, CActorTexture)
	self.m_SkillPreviewBtn = self:NewUI(6, CButton)
	self.m_TipsBtn = self:NewUI(7, CButton)

	self.m_HasAwakeBottomBox = self:NewUI(8, CBox)
	self.m_ItemBox1 = self.m_HasAwakeBottomBox:NewUI(1, CBox)
	self.m_ItemBoxIconSp1 = self.m_ItemBox1:NewUI(1, CSprite)
	self.m_ItemBoxBorderSp1 = self.m_ItemBox1:NewUI(2, CSprite)
	self.m_ItemBoxCountLbl1 = self.m_ItemBox1:NewUI(3, CLabel)
	self.m_ItemBoxNeedLbl1 = self.m_ItemBox1:NewUI(4, CLabel)
	self.m_ResetBtn = self.m_HasAwakeBottomBox:NewUI(2, CButton)
	self.m_FollowSelectWidget = self.m_HasAwakeBottomBox:NewUI(3, CWidget)
	self.m_FightSelectWidget = self.m_HasAwakeBottomBox:NewUI(4, CWidget)

	self.m_NotAwakeBottomBox = self:NewUI(9, CBox)
	self.m_DescLbl = self.m_NotAwakeBottomBox:NewUI(1, CLabel)
	self.m_ItemBox2 = self.m_NotAwakeBottomBox:NewUI(2, CBox)
	self.m_ItemBoxIconSp2 = self.m_ItemBox2:NewUI(1, CSprite)
	self.m_ItemBoxBorderSp2 = self.m_ItemBox2:NewUI(2, CSprite)
	self.m_ItemBoxCountLbl2 = self.m_ItemBox2:NewUI(3, CLabel)
	self.m_ItemBoxNeedLbl2 = self.m_ItemBox2:NewUI(4, CLabel)
	self.m_AwakeBtn = self.m_NotAwakeBottomBox:NewUI(3, CButton)

	self.m_AttrGrid = self:NewUI(10, CGrid)
	self.m_AttrBoxClone = self:NewUI(11, CBox)
	self.m_SkillScrollView = self:NewUI(12, CScrollView)
	self.m_SkillGrid = self:NewUI(13, CGrid)
	self.m_SkillBoxClone = self:NewUI(14, CBox)

	-- self.m_HasAwakeSelectIndex = nil
	-- self.m_HasAwakeSelectId = nil
	-- self.m_NotAwakeSelectIndex = nil
	-- self.m_NotAwakeSelectId = nil

	self:InitContent()
end

function CArtifactQiLingPart.InitContent(self)
	self.m_HasAwakeClone:SetActive(false)
	self.m_NotAwakeBoxClone:SetActive(false)
	self.m_AttrBoxClone:SetActive(false)
	self.m_SkillBoxClone:SetActive(false)
	self.m_HasAwakeClickBtn:SetGroup(self:GetInstanceID()-2)
	self.m_NotAwakeClickBtn:SetGroup(self:GetInstanceID()-2)
	self.m_HasAwakeClickBtn:AddUIEvent("click", callback(self, "OnClickHasAwakeClickBtn"))
	self.m_NotAwakeClickBtn:AddUIEvent("click", callback(self, "OnClickNotAwakeClickBtn"))
	self.m_SkillPreviewBtn:AddUIEvent("click", callback(self, "OnClickSkillPreViewBtn"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTipsBtn"))
	self.m_ItemBox1:AddUIEvent("click", callback(self, "OnClickItemBox1"))
	self.m_ItemBox2:AddUIEvent("click", callback(self, "OnClickItemBox2"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnClickResetBtn"))
	self.m_FollowSelectWidget:AddUIEvent("click", callback(self, "OnClickFollowSelectWidget"))
	self.m_FightSelectWidget:AddUIEvent("click", callback(self, "OnClickFightSelectWidget"))
	self.m_AwakeBtn:AddUIEvent("click", callback(self, "OnClickAwakeBtn"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_ArtifactCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlArtifactEvent"))

	self:RefreshUI()
end

function CArtifactQiLingPart.OnCtrlArtifactEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Artifact.Event.UpdateArtifactInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Artifact.Event.UpdateSpiritInfo then
		self:RefreshUI()
	end
end

function CArtifactQiLingPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshHasAwakeItem()
		self:RefreshNotAwakeItem()
	end
end

function CArtifactQiLingPart.RefreshUI(self)
	self:SetHasAwakeList()
	self:SetNotAwakeList()
	
	if next(g_ArtifactCtrl.m_ArtifactSpiritHashList) then
		self.m_HasAwakeClickBtn:ForceSelected(true)
		self.m_NotAwakeClickBtn:ForceSelected(false)
		self:SelectHasAwakeTab()
		if self.m_HasAwakeSelectIndex then
			self:HasAwakeSelectOne(self.m_HasAwakeSelectIndex)
		else
			self:HasAwakeSelectOne(1)
		end
	else
		self.m_HasAwakeClickBtn:ForceSelected(false)
		self.m_NotAwakeClickBtn:ForceSelected(true)
		self:SelectNotAwakeTab()
		if self.m_NotAwakeSelectIndex then
			self:NotAwakeSelectOne(self.m_NotAwakeSelectIndex)
		else
			self:NotAwakeSelectOne(1)
		end
	end
end

function CArtifactQiLingPart.SelectHasAwakeTab(self)
	local oHeight = self.m_HasAwakeHeightTweenWidget:GetHeight()
	if oHeight > 50 then
		return
	end
	local orgTween = self.m_HasAwakeHeightTweenWidget:GetComponent(classtype.TweenHeight)
	-- self.m_HasAwakeHeightTweenWidget:SetLocalScale(Vector3.New(1, 1, 1))
	orgTween.enabled = true
	orgTween.from = 2
	local oHeight = #g_ArtifactCtrl.m_ArtifactSpiritList*105
	if oHeight > 380 then
		oHeight = 380
	end
	orgTween.to = oHeight
	orgTween.duration = 0.3
	orgTween:ResetToBeginning()
	orgTween.delay = 0
	orgTween:PlayForward()
	orgTween.onFinished = function ()
		
	end

	local talismanTween = self.m_NotAwakeHeightTweenWidget:GetComponent(classtype.TweenHeight)
	talismanTween.enabled = true
	-- talismanTween.from = 2
	-- talismanTween.to = 450
	-- talismanTween.duration = 0.3
	-- talismanTween:ResetToBeginning()
	-- talismanTween.delay = 0
	talismanTween:PlayReverse()
	talismanTween.onFinished = function ()
		
	end
end

function CArtifactQiLingPart.SelectNotAwakeTab(self)
	local oHeight = self.m_NotAwakeHeightTweenWidget:GetHeight()
	if oHeight > 50 then
		return
	end
	local orgTween = self.m_HasAwakeHeightTweenWidget:GetComponent(classtype.TweenHeight)
	orgTween.enabled = true
	-- orgTween.from = 2
	-- orgTween.to = 380
	-- orgTween.duration = 0.3
	-- orgTween:ResetToBeginning()
	-- orgTween.delay = 0
	orgTween:PlayReverse()
	orgTween.onFinished = function ()
		
	end

	local talismanTween = self.m_NotAwakeHeightTweenWidget:GetComponent(classtype.TweenHeight)
	-- self.m_NotAwakeHeightTweenWidget:SetLocalScale(Vector3.New(1, 1, 1))
	talismanTween.enabled = true
	talismanTween.from = 2
	talismanTween.to = 450
	talismanTween.duration = 0.3
	talismanTween:ResetToBeginning()
	talismanTween.delay = 0
	talismanTween:PlayForward()
	talismanTween.onFinished = function ()
		
	end
end

function CArtifactQiLingPart.RefreshHasAwakeItem(self)
	if not self.m_HasAwakeSelectId then
		return
	end
	local oConfig = data.artifactdata.SPIRITINFO[self.m_HasAwakeSelectId]
	self.m_ItemSid1 = oConfig.reset_skill_cost[1].sid
	self.m_ItemConfig1 = DataTools.GetItemData(self.m_ItemSid1)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid1)
	self.m_ItemBoxIconSp1:SpriteItemShape(self.m_ItemConfig1.icon)
	self.m_ItemBoxBorderSp1:SetItemQuality(g_ItemCtrl:GetQualityVal( self.m_ItemConfig1.id, self.m_ItemConfig1.quality or 0 ))
	self.m_ItemBoxNeedLbl1:SetText(self.m_ItemConfig1.name)
	-- self.m_ItemBoxNeedLbl1:SetText("/"..oConfig.reset_skill_cost[1].amount)
	if iAmount >= 1 then
		self.m_ItemBoxCountLbl1:SetText("[244B4E]数量：".."[1d8e00]"..iAmount.."/"..oConfig.reset_skill_cost[1].amount.."[-]")
		-- self.m_ItemBoxCountLbl1:SetEffectColor(Color.RGBAToColor("003C41"))
	else
		self.m_ItemBoxCountLbl1:SetText("[244B4E]数量：".."[ff0000]"..iAmount.."[-][63432C]/"..oConfig.reset_skill_cost[1].amount.."[-]")
		-- self.m_ItemBoxCountLbl1:SetEffectColor(Color.RGBAToColor("790036"))
	end
end

function CArtifactQiLingPart.RefreshNotAwakeItem(self)
	if not self.m_NotAwakeSelectId then
		return
	end
	local oConfig = data.artifactdata.SPIRITINFO[self.m_NotAwakeSelectId]
	self.m_ItemSid2 = oConfig.wake_up_cost[1].sid
	self.m_ItemConfig2 = DataTools.GetItemData(self.m_ItemSid2)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid2)
	self.m_ItemBoxIconSp2:SpriteItemShape(self.m_ItemConfig2.icon)
	self.m_ItemBoxBorderSp2:SetItemQuality(g_ItemCtrl:GetQualityVal( self.m_ItemConfig2.id, self.m_ItemConfig2.quality or 0 ))
	self.m_ItemBoxNeedLbl2:SetText(self.m_ItemConfig2.name)
	-- self.m_ItemBoxNeedLbl2:SetText("/"..oConfig.wake_up_cost[1].amount)
	if iAmount >= 1 then
		self.m_ItemBoxCountLbl2:SetText("[244B4E]数量：".."[1d8e00]"..iAmount.."/"..oConfig.wake_up_cost[1].amount.."[-]")
		-- self.m_ItemBoxCountLbl2:SetEffectColor(Color.RGBAToColor("003C41"))
	else
		self.m_ItemBoxCountLbl2:SetText("[244B4E]数量：".."[ff0000]"..iAmount.."[-][63432C]/"..oConfig.wake_up_cost[1].amount.."[-]")
		-- self.m_ItemBoxCountLbl2:SetEffectColor(Color.RGBAToColor("790036"))
	end
end

function CArtifactQiLingPart.SetHasAwakeList(self)
	local oList = g_ArtifactCtrl.m_HasAwakeList
	
	local optionCount = #oList
	local GridList = self.m_HasAwakeGrid:GetChildList() or {}
	local oHasAwakeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oHasAwakeBox = self.m_HasAwakeClone:Clone(false)
				-- self.m_HasAwakeGrid:AddChild(oOptionBtn)
			else
				oHasAwakeBox = GridList[i]
			end
			self:SetHasAwakeBox(oHasAwakeBox, oList[i], i)
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
				GridList[i].m_Data = nil
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
				v.m_Data = nil
			end
		end
	end

	self.m_HasAwakeGrid:Reposition()
	-- self.m_HasAwakeTweenScrollView:ResetPosition()
end

function CArtifactQiLingPart.SetHasAwakeBox(self, oHasAwakeBox, oData, oIndex)
	oHasAwakeBox:SetActive(true)
	oHasAwakeBox.m_IconSp = oHasAwakeBox:NewUI(1, CSprite)
	oHasAwakeBox.m_NameLbl = oHasAwakeBox:NewUI(2, CLabel)
	oHasAwakeBox.m_LevelLbl = oHasAwakeBox:NewUI(3, CLabel)
	oHasAwakeBox.m_SelNameLbl = oHasAwakeBox:NewUI(4, CLabel)
	oHasAwakeBox.m_SelLevelLbl = oHasAwakeBox:NewUI(5, CLabel)
	oHasAwakeBox.m_FightSp = oHasAwakeBox:NewUI(6, CSprite)
	oHasAwakeBox.m_QualitySp = oHasAwakeBox:NewUI(7, CSprite)
	oHasAwakeBox:SetGroup(self:GetInstanceID())
	oHasAwakeBox.m_Data = oData

	local oConfig = data.artifactdata.SPIRITINFO[oData]
	local oServerData = g_ArtifactCtrl.m_ArtifactSpiritHashList[oData]
	oHasAwakeBox.m_IconSp:SpriteAvatar(oConfig.figureid)
	oHasAwakeBox.m_NameLbl:SetText(oConfig.name)
	oHasAwakeBox.m_SelNameLbl:SetText(oConfig.name)
	if g_ArtifactCtrl.m_ArtifactFightSpiritId == oData then
		oHasAwakeBox.m_FightSp:SetActive(true)
	else
		oHasAwakeBox.m_FightSp:SetActive(false)
	end
	if oConfig.quality == 1 then
		oHasAwakeBox.m_QualitySp:SetSpriteName("h7_pinzhikuang_2")
	elseif oConfig.quality == 2 then
		oHasAwakeBox.m_QualitySp:SetSpriteName("h7_pinzhikuang_4")
	else
		oHasAwakeBox.m_QualitySp:SetSpriteName("h7_pinzhikuang_4")
	end

	oHasAwakeBox:AddUIEvent("click", callback(self, "OnClickHasAwakeBox", oData, oIndex))

	self.m_HasAwakeGrid:AddChild(oHasAwakeBox)
	self.m_HasAwakeGrid:Reposition()
end

function CArtifactQiLingPart.HasAwakeSelectOneById(self, oId)
	local GridList = self.m_HasAwakeGrid:GetChildList() or {}
	for k,v in pairs(GridList) do
		if v.m_Data and v.m_Data == oId then
			v:SetSelected(true)
			break
		end
	end
	self:HasAwakeOnShowEachById(oId)
end

function CArtifactQiLingPart.HasAwakeSelectOne(self, oIndex)
	local oChild = self.m_HasAwakeGrid:GetChild(oIndex)
	if oChild then
		oChild:SetSelected(true)
	end
	self:HasAwakeOnShowEachByIndex(oIndex)
end

function CArtifactQiLingPart.HasAwakeOnShowEachByIndex(self, oIndex)
	if not g_ArtifactCtrl.m_HasAwakeList[oIndex] then
		return
	end
	self.m_HasAwakeSelectIndex = oIndex
	self:HasAwakeOnShowEachById(g_ArtifactCtrl.m_HasAwakeList[oIndex])
end

function CArtifactQiLingPart.HasAwakeOnShowEachById(self, oId)
	local oConfig = data.artifactdata.SPIRITINFO[oId]
	local oData = g_ArtifactCtrl.m_HasAwakeHashList[oId]
	if not oConfig or not oData then
		return
	end
	self.m_HasAwakeSelectId = oId
	self.m_QiLingTitleLbl:SetText(oConfig.name)
	local model_info = {}
	model_info.figure = oConfig.figureid
	model_info.horse = nil
	model_info.notplayanim = true
	self.m_ActorTexture:ChangeShape(model_info)
	self.m_HasAwakeBottomBox:SetActive(true)
	self.m_NotAwakeBottomBox:SetActive(false)

	self.m_FightSp:SetActive(g_ArtifactCtrl.m_ArtifactFightSpiritId == oId)
	self.m_FollowSelectWidget:SetSelected(g_ArtifactCtrl.m_ArtifactFollowSpiritId == oId)
	self.m_FightSelectWidget:SetSelected(g_ArtifactCtrl.m_ArtifactFightSpiritId == oId)

	self:RefreshHasAwakeItem()
	-- self:RefreshNotAwakeItem()
	self:SetAttrList(g_ArtifactCtrl.m_ArtifactSpiritHashList[oId].attr_list)
	self:SetSkillList(g_ArtifactCtrl.m_ArtifactSpiritHashList[oId].skill_list)
end

function CArtifactQiLingPart.SetNotAwakeList(self)
	local oList = g_ArtifactCtrl.m_NotAwakeList

	local optionCount = #oList
	local GridList = self.m_NotAwakeGrid:GetChildList() or {}
	local oNotAwakeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oNotAwakeBox = self.m_NotAwakeBoxClone:Clone(false)
				-- self.m_NotAwakeGrid:AddChild(oOptionBtn)
			else
				oNotAwakeBox = GridList[i]
			end
			self:SetNotAwakeBox(oNotAwakeBox, oList[i], i)
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
				GridList[i].m_Data = nil
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
				v.m_Data = nil
			end
		end
	end

	self.m_NotAwakeGrid:Reposition()
	-- self.m_NotAwakeTweenScrollView:ResetPosition()
end

function CArtifactQiLingPart.SetNotAwakeBox(self, oNotAwakeBox, oData, oIndex)
	oNotAwakeBox:SetActive(true)
	oNotAwakeBox.m_IconSp = oNotAwakeBox:NewUI(1, CSprite)
	oNotAwakeBox.m_NameLbl = oNotAwakeBox:NewUI(2, CLabel)
	oNotAwakeBox.m_LevelLbl = oNotAwakeBox:NewUI(3, CLabel)
	oNotAwakeBox.m_SelNameLbl = oNotAwakeBox:NewUI(4, CLabel)
	oNotAwakeBox.m_SelLevelLbl = oNotAwakeBox:NewUI(5, CLabel)
	oNotAwakeBox.m_FightSp = oNotAwakeBox:NewUI(6, CSprite)
	oNotAwakeBox.m_QualitySp = oNotAwakeBox:NewUI(7, CSprite)
	oNotAwakeBox:SetGroup(self:GetInstanceID()-1)
	oNotAwakeBox.m_Data = oData

	local oConfig = data.artifactdata.SPIRITINFO[oData]
	oNotAwakeBox.m_IconSp:SpriteAvatar(oConfig.figureid)
	oNotAwakeBox.m_NameLbl:SetText(oConfig.name)
	oNotAwakeBox.m_SelNameLbl:SetText(oConfig.name)
	oNotAwakeBox.m_FightSp:SetActive(false)
	if oConfig.quality == 1 then
		oNotAwakeBox.m_QualitySp:SetSpriteName("h7_pinzhikuang_2")
	elseif oConfig.quality == 2 then
		oNotAwakeBox.m_QualitySp:SetSpriteName("h7_pinzhikuang_4")
	else
		oNotAwakeBox.m_QualitySp:SetSpriteName("h7_pinzhikuang_4")
	end

	oNotAwakeBox:AddUIEvent("click", callback(self, "OnClickNotAwakeBox", oData, oIndex))

	self.m_NotAwakeGrid:AddChild(oNotAwakeBox)
	self.m_NotAwakeGrid:Reposition()
end

function CArtifactQiLingPart.NotAwakeSelectOneById(self, oId)
	local GridList = self.m_NotAwakeGrid:GetChildList() or {}
	for k,v in pairs(GridList) do
		if v.m_Data and v.m_Data == oId then
			v:SetSelected(true)
			break
		end
	end
	self:NotAwakeOnShowEachById(oId)
end

function CArtifactQiLingPart.NotAwakeSelectOne(self, oIndex)
	local oChild = self.m_NotAwakeGrid:GetChild(oIndex)
	if oChild then
		oChild:SetSelected(true)
	end
	self:NotAwakeOnShowEachByIndex(oIndex)
end

function CArtifactQiLingPart.NotAwakeOnShowEachByIndex(self, oIndex)
	if not g_ArtifactCtrl.m_NotAwakeList[oIndex] then
		return
	end
	self.m_NotAwakeSelectIndex = oIndex
	self:NotAwakeOnShowEachById(g_ArtifactCtrl.m_NotAwakeList[oIndex])
end

function CArtifactQiLingPart.NotAwakeOnShowEachById(self, oId)
	local oConfig = data.artifactdata.SPIRITINFO[oId]
	local oData = g_ArtifactCtrl.m_NotAwakeHashList[oId]
	if not oConfig or not oData then
		return
	end
	self.m_NotAwakeSelectId = oId
	self.m_QiLingTitleLbl:SetText(oConfig.name)
	local model_info = {}
	model_info.figure = oConfig.figureid
	model_info.horse = nil
	model_info.notplayanim = true
	self.m_ActorTexture:ChangeShape(model_info)
	self.m_HasAwakeBottomBox:SetActive(false)
	self.m_NotAwakeBottomBox:SetActive(true)

	self.m_FightSp:SetActive(false)

	-- self:RefreshHasAwakeItem()
	self:RefreshNotAwakeItem()
	self:SetAttrList(g_ArtifactCtrl:GetQiLingAttrConfig(oId))
	self:SetSkillList({})
end

function CArtifactQiLingPart.SetAttrList(self, oOriginList)
	local oList = {}
	table.copy(oOriginList, oList)
	table.sort(oList, function (a, b)
		return a.attr < b.attr
	end)
	local optionCount = #oList
	local GridList = self.m_AttrGrid:GetChildList() or {}
	local oAttrBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oAttrBox = self.m_AttrBoxClone:Clone(false)
				-- self.m_AttrGrid:AddChild(oOptionBtn)
			else
				oAttrBox = GridList[i]
			end
			self:SetAttrBox(oAttrBox, oList[i])
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

	self.m_AttrGrid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CArtifactQiLingPart.SetAttrBox(self, oAttrBox, oData)
	oAttrBox:SetActive(true)
	oAttrBox.m_NameLbl = oAttrBox:NewUI(1, CLabel)
	oAttrBox.m_AttrLbl = oAttrBox:NewUI(2, CLabel)

	local oConfig = data.attrnamedata.DATA[oData.attr]	
	local oNameStr = oConfig.name
	local oNameStrLen = string.utfStrlen(oNameStr)
	oAttrBox.m_NameLbl:SetText(oNameStr)
	if oNameStrLen <= 2 then
		oAttrBox.m_NameLbl:SetSpacingX(25)
	elseif oNameStrLen == 3 then
		oAttrBox.m_NameLbl:SetSpacingX(5)
	elseif oNameStrLen >= 4 then
		oAttrBox.m_NameLbl:SetSpacingX(0)
	end
	local oFindStr = g_ArtifactCtrl:GetIsShowRatio(oData.attr)
	if oFindStr then
		oAttrBox.m_AttrLbl:SetText("+"..oData.val.."%")
	else
		oAttrBox.m_AttrLbl:SetText("+"..oData.val)
	end

	self.m_AttrGrid:AddChild(oAttrBox)
	self.m_AttrGrid:Reposition()
end

function CArtifactQiLingPart.SetSkillList(self, oSkillList)
	local oList = {}
	for k,v in pairs(oSkillList) do
		oList[k] = v
	end
	local optionCount = #oList
	if optionCount < 9 then
		for i=1, 9-optionCount do
			table.insert(oList, "empty")
		end
	end
	optionCount = #oList
	local GridList = self.m_SkillGrid:GetChildList() or {}
	local oSkillBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oSkillBox = self.m_SkillBoxClone:Clone(false)
				-- self.m_SkillGrid:AddChild(oOptionBtn)
			else
				oSkillBox = GridList[i]
			end
			self:SetSkillBox(oSkillBox, oList[i])
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

	self.m_SkillGrid:Reposition()
	self.m_SkillScrollView:ResetPosition()
end

function CArtifactQiLingPart.SetSkillBox(self, oSkillBox, oData)
	oSkillBox:SetActive(true)
	oSkillBox.m_IconSp = oSkillBox:NewUI(1, CSprite)
	oSkillBox.m_TalentSp = oSkillBox:NewUI(2, CSprite)
	oSkillBox.m_BindSp = oSkillBox:NewUI(3, CSprite)
	oSkillBox.m_SureSp = oSkillBox:NewUI(4, CSprite)
	oSkillBox.m_InfoWidget = oSkillBox:NewUI(5, CWidget)
	oSkillBox.m_EquipSp = oSkillBox:NewUI(6, CSprite)
	oSkillBox.m_QualitySp = oSkillBox:NewUI(7, CSprite)

	local oConfig
	if oData ~= "empty" then
		oConfig = data.artifactdata.SKILL[oData]
		oSkillBox.m_IconSp:SetActive(true)
		oSkillBox.m_IconSp:SpriteSkill(tostring(oConfig.icon))
	else
		oSkillBox.m_IconSp:SetActive(false)
	end

	oSkillBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickQiLingSkillIcon", oConfig, oSkillBox.m_IconSp))

	self.m_SkillGrid:AddChild(oSkillBox)
	self.m_SkillGrid:Reposition()
end

--------------以下是点击事件--------------

function CArtifactQiLingPart.OnClickHasAwakeClickBtn(self)
	if not next(g_ArtifactCtrl.m_ArtifactSpiritHashList) then
		g_NotifyCtrl:FloatMsg("还没有已觉醒的器灵哦，赶紧去觉醒吧")
		self:OnClickNotAwakeClickBtn()
		return
	end
	self.m_HasAwakeClickBtn:ForceSelected(true)
	self.m_NotAwakeClickBtn:ForceSelected(false)
	self:SelectHasAwakeTab()
	if self.m_HasAwakeSelectIndex then
		self:HasAwakeSelectOne(self.m_HasAwakeSelectIndex)
	else
		self:HasAwakeSelectOne(1)
	end
end

function CArtifactQiLingPart.OnClickNotAwakeClickBtn(self)
	if not next(g_ArtifactCtrl.m_NotAwakeHashList) then
		g_NotifyCtrl:FloatMsg("所有的器灵都已觉醒了哦")
		self:OnClickHasAwakeClickBtn()
		return
	end
	self.m_HasAwakeClickBtn:ForceSelected(false)
	self.m_NotAwakeClickBtn:ForceSelected(true)
	self:SelectNotAwakeTab()
	if self.m_NotAwakeSelectIndex then
		self:NotAwakeSelectOne(self.m_NotAwakeSelectIndex)
	else
		self:NotAwakeSelectOne(1)
	end
end

function CArtifactQiLingPart.OnClickHasAwakeBox(self, oData, oIndex)
	self:HasAwakeSelectOne(oIndex)
	-- self:HasAwakeOnShowEachById(oData)
end

function CArtifactQiLingPart.OnClickNotAwakeBox(self, oData, oIndex)
	self:NotAwakeSelectOne(oIndex)
	-- self:NotAwakeOnShowEachById(oData)
end

function CArtifactQiLingPart.OnClickSkillPreViewBtn(self)
	CArtifactSkillPreView:ShowView(function (oView)
		oView:RefreshUI()
	end)
	-- CArtifactResetView:ShowView(function (oView)
	-- 	oView:RefreshUI()
	-- end)
end

function CArtifactQiLingPart.OnClickTipsBtn(self)
	local zContent = {title = data.instructiondata.DESC[14003].title,desc = data.instructiondata.DESC[14003].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CArtifactQiLingPart.OnClickItemBox1(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid1, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox1, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CArtifactQiLingPart.OnClickItemBox2(self)
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid2, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox2, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CArtifactQiLingPart.OnClickQiLingSkillIcon(self, oConfig, oWidget)
	if not oConfig then
		return
	end
	CSummonSkillItemTipsView:ShowView(function (oView)
		oView:SetArtifactSkillTips(oConfig, oWidget)
	end)
end

function CArtifactQiLingPart.OnClickResetBtn(self)
	if not self.m_HasAwakeSelectId then
		return
	end
	local oServerData = g_ArtifactCtrl.m_ArtifactSpiritHashList[self.m_HasAwakeSelectId]
	if next(oServerData.bak_skill_list) then
		CArtifactResetView:ShowView(function (oView)
			oView:RefreshUI(self.m_HasAwakeSelectId)
		end)
	else
		local oConfig = data.artifactdata.SPIRITINFO[self.m_HasAwakeSelectId]
		local itemNum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid1)
		local oNeedCount = oConfig.reset_skill_cost[1].amount	
		if itemNum < oNeedCount then
			local itemlist = {{sid = self.m_ItemSid1, count = itemNum, amount = oNeedCount}}
		    g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function (oNeedMoney)
		    	netartifact.C2GSArtifactSpiritResetSkill(self.m_HasAwakeSelectId, 1)
		    	if (g_AttrCtrl.goldcoin+g_AttrCtrl.rplgoldcoin) >= oNeedMoney then
			    	CArtifactResetView:ShowView(function (oView)
						oView:RefreshUI(self.m_HasAwakeSelectId)
					end)
				end
		    end)
		    return
		end
		netartifact.C2GSArtifactSpiritResetSkill(self.m_HasAwakeSelectId)
		CArtifactResetView:ShowView(function (oView)
			oView:RefreshUI(self.m_HasAwakeSelectId)
		end)
	end	
end

function CArtifactQiLingPart.OnClickFollowSelectWidget(self)
	if not self.m_HasAwakeSelectId then
		return
	end
	local oSelect = self.m_FollowSelectWidget:GetSelected()
	if oSelect then
		netartifact.C2GSArtifactSetFollowSpirit(self.m_HasAwakeSelectId)
	else
		netartifact.C2GSArtifactSetFollowSpirit(0)
	end
end

function CArtifactQiLingPart.OnClickFightSelectWidget(self)
	if not self.m_HasAwakeSelectId then
		return
	end
	local oSelect = self.m_FightSelectWidget:GetSelected()
	if oSelect then
		netartifact.C2GSArtifactSetFightSpirit(self.m_HasAwakeSelectId)
	else
		netartifact.C2GSArtifactSetFightSpirit(0)
	end
end

function CArtifactQiLingPart.OnClickAwakeBtn(self)
	if not self.m_NotAwakeSelectId then
		return
	end
	local oConfig = data.artifactdata.SPIRITINFO[self.m_NotAwakeSelectId]	
	local itemNum = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid2)
	local oNeedCount = oConfig.wake_up_cost[1].amount	
	if itemNum < oNeedCount then
		local itemlist = {{sid = self.m_ItemSid2, count = itemNum, amount = oNeedCount}}
	    g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function ()
	    	netartifact.C2GSArtifactSpiritWakeup(self.m_NotAwakeSelectId, 1)
	    end)
	    return
	end
	netartifact.C2GSArtifactSpiritWakeup(self.m_NotAwakeSelectId)
end

return CArtifactQiLingPart