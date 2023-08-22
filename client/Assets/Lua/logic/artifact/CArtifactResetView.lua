local CArtifactResetView = class("CArtifactResetView", CViewBase)

function CArtifactResetView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Artifact/ArtifactResetView.prefab", cb)
	--界面设置
	-- self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CArtifactResetView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CurScrollView = self:NewUI(2, CScrollView)
	self.m_CurGrid = self:NewUI(3, CGrid)
	self.m_CurBoxClone = self:NewUI(4, CBox)
	self.m_NewScrollView = self:NewUI(5, CScrollView)
	self.m_NewGrid = self:NewUI(6, CGrid)
	self.m_NewBoxClone = self:NewUI(7, CBox)
	self.m_ItemBox = self:NewUI(8, CBox)
	self.m_ItemBoxIconSp = self.m_ItemBox:NewUI(1, CSprite)
	self.m_ItemBoxBorderSp = self.m_ItemBox:NewUI(2, CSprite)
	self.m_ItemBoxCountLbl = self.m_ItemBox:NewUI(3, CLabel)
	self.m_ItemBoxNeedLbl = self.m_ItemBox:NewUI(4, CLabel)
	self.m_ResetBtn = self:NewUI(9, CButton)
	self.m_SaveBtn = self:NewUI(10, CButton)
	
	self:InitContent()
end

function CArtifactResetView.InitContent(self)
	self.m_CurBoxClone:SetActive(false)
	self.m_NewBoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ItemBox:AddUIEvent("click", callback(self, "OnClickItemBox"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnClickResetBtn"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnClickSaveBtn"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_ArtifactCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlArtifactEvent"))
end

function CArtifactResetView.OnCtrlArtifactEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Artifact.Event.UpdateArtifactInfo then
		
	elseif oCtrl.m_EventID == define.Artifact.Event.UpdateSpiritInfo then
		if self.m_QiLingId then
			self:RefreshUI(self.m_QiLingId)
		end
	end
end

function CArtifactResetView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
		self:RefreshItem()
	end
end

function CArtifactResetView.RefreshUI(self, oQiLingId)
	local oServerData = g_ArtifactCtrl.m_ArtifactSpiritHashList[oQiLingId]
	if not oServerData then
		return
	end
	self.m_QiLingId = oQiLingId
	self:SetCurSkillList(oServerData.skill_list)
	self:SetNewSkillList(oServerData.bak_skill_list)
	local oConfig = data.artifactdata.SPIRITINFO[oQiLingId]
	self.m_ItemSid = oConfig.reset_skill_cost[1].sid
	self.m_ItemConfig = DataTools.GetItemData(self.m_ItemSid)
	self.m_ItemArtifactConfig = oConfig
	self:RefreshItem()

	if next(oServerData.bak_skill_list) then
		self.m_SaveBtn:SetActive(true)
	else
		self.m_SaveBtn:SetActive(false)
	end
end

function CArtifactResetView.RefreshItem(self)
	if not self.m_ItemSid then
		return
	end
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemSid)
	self.m_ItemBoxIconSp:SpriteItemShape(self.m_ItemConfig.icon)
	self.m_ItemBoxBorderSp:SetItemQuality(g_ItemCtrl:GetQualityVal( self.m_ItemConfig.id, self.m_ItemConfig.quality or 0 ))
	self.m_ItemBoxNeedLbl:SetText(self.m_ItemConfig.name)
	-- self.m_ItemBoxNeedLbl:SetText("/"..self.m_ItemArtifactConfig.reset_skill_cost[1].amount)
	if iAmount >= 1 then
		self.m_ItemBoxCountLbl:SetText("[244B4E]数量：".."[1d8e00]"..iAmount.."/"..self.m_ItemArtifactConfig.reset_skill_cost[1].amount.."[-]")
		-- self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("003C41"))
	else
		self.m_ItemBoxCountLbl:SetText("[244B4E]数量：".."[ff0000]"..iAmount.."[-][63432C]/"..self.m_ItemArtifactConfig.reset_skill_cost[1].amount.."[-]")
		-- self.m_ItemBoxCountLbl:SetEffectColor(Color.RGBAToColor("790036"))
	end
end

function CArtifactResetView.SetCurSkillList(self, oSkillList)
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
	local GridList = self.m_CurGrid:GetChildList() or {}
	local oCurSkillBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oCurSkillBox = self.m_CurBoxClone:Clone(false)
				-- self.m_CurGrid:AddChild(oOptionBtn)
			else
				oCurSkillBox = GridList[i]
			end
			self:SetCurSkillBox(oCurSkillBox, oList[i])
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
	self.m_CurScrollView:ResetPosition()
end

function CArtifactResetView.SetCurSkillBox(self, oCurSkillBox, oData)
	oCurSkillBox:SetActive(true)
	oCurSkillBox.m_IconSp = oCurSkillBox:NewUI(1, CSprite)
	oCurSkillBox.m_TalentSp = oCurSkillBox:NewUI(2, CSprite)
	oCurSkillBox.m_BindSp = oCurSkillBox:NewUI(3, CSprite)
	oCurSkillBox.m_SureSp = oCurSkillBox:NewUI(4, CSprite)
	oCurSkillBox.m_InfoWidget = oCurSkillBox:NewUI(5, CWidget)
	oCurSkillBox.m_EquipSp = oCurSkillBox:NewUI(6, CSprite)
	oCurSkillBox.m_QualitySp = oCurSkillBox:NewUI(7, CSprite)

	local oConfig
	if oData ~= "empty" then
		oConfig = data.artifactdata.SKILL[oData]
		oCurSkillBox.m_IconSp:SetActive(true)
		oCurSkillBox.m_IconSp:SpriteSkill(tostring(oConfig.icon))
	else
		oCurSkillBox.m_IconSp:SetActive(false)
	end

	oCurSkillBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickCurSkillIcon", oConfig, oCurSkillBox.m_IconSp))

	self.m_CurGrid:AddChild(oCurSkillBox)
	self.m_CurGrid:Reposition()
end

function CArtifactResetView.SetNewSkillList(self, oSkillList)
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
	local GridList = self.m_NewGrid:GetChildList() or {}
	local oNewSkillBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oNewSkillBox = self.m_NewBoxClone:Clone(false)
				-- self.m_NewGrid:AddChild(oOptionBtn)
			else
				oNewSkillBox = GridList[i]
			end
			self:SetNewSkillBox(oNewSkillBox, oList[i])
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

	self.m_NewGrid:Reposition()
	self.m_NewScrollView:ResetPosition()
end

function CArtifactResetView.SetNewSkillBox(self, oNewSkillBox, oData)
	oNewSkillBox:SetActive(true)
	oNewSkillBox.m_IconSp = oNewSkillBox:NewUI(1, CSprite)
	oNewSkillBox.m_TalentSp = oNewSkillBox:NewUI(2, CSprite)
	oNewSkillBox.m_BindSp = oNewSkillBox:NewUI(3, CSprite)
	oNewSkillBox.m_SureSp = oNewSkillBox:NewUI(4, CSprite)
	oNewSkillBox.m_InfoWidget = oNewSkillBox:NewUI(5, CWidget)
	oNewSkillBox.m_EquipSp = oNewSkillBox:NewUI(6, CSprite)
	oNewSkillBox.m_QualitySp = oNewSkillBox:NewUI(7, CSprite)

	local oConfig
	if oData ~= "empty" then
		oConfig = data.artifactdata.SKILL[oData]
		oNewSkillBox.m_IconSp:SetActive(true)
		oNewSkillBox.m_IconSp:SpriteSkill(tostring(oConfig.icon))
	else
		oNewSkillBox.m_IconSp:SetActive(false)
	end

	oNewSkillBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickNewSkillIcon", oConfig, oNewSkillBox.m_IconSp))

	self.m_NewGrid:AddChild(oNewSkillBox)
	self.m_NewGrid:Reposition()
end

--------------以下是点击事件--------------

function CArtifactResetView.OnClickCurSkillIcon(self, oConfig, oWidget)
	if not oConfig then
		return
	end
	CSummonSkillItemTipsView:ShowView(function (oView)
		oView:SetArtifactSkillTips(oConfig, oWidget)
	end)
end

function CArtifactResetView.OnClickNewSkillIcon(self, oConfig, oWidget)
	if not oConfig then
		return
	end
	CSummonSkillItemTipsView:ShowView(function (oView)
		oView:SetArtifactSkillTips(oConfig, oWidget)
	end)
end

function CArtifactResetView.OnClickItemBox(self)
	if not self.m_ItemSid then
		return
	end
	g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemSid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_ItemBox, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

function CArtifactResetView.OnClickResetBtn(self)
	if not self.m_QiLingId then
		return
	end
	local oConfig = data.artifactdata.SPIRITINFO[self.m_QiLingId]
	local itemNum = g_ItemCtrl:GetBagItemAmountBySid(oConfig.reset_skill_cost[1].sid)
	local oNeedCount = oConfig.reset_skill_cost[1].amount	
	if itemNum < oNeedCount then
		local itemlist = {{sid = oConfig.reset_skill_cost[1].sid, count = itemNum, amount = oNeedCount}}
	    g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function ()
	    	netartifact.C2GSArtifactSpiritResetSkill(self.m_QiLingId, 1)
	    end)
	    return
	end
	netartifact.C2GSArtifactSpiritResetSkill(self.m_QiLingId)
end

function CArtifactResetView.OnClickSaveBtn(self)
	if not self.m_QiLingId then
		return
	end
	netartifact.C2GSArtifactSpiritSaveSkill(self.m_QiLingId)
	self:OnClose()
end

return CArtifactResetView