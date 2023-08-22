local CSkillTalismanPart = class("CSkillTalismanPart", CPageBase)

function CSkillTalismanPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_LeftBox = self:NewUI(1, CBox)
	self.m_RightBox = self:NewUI(2, CBox)

	self.m_LeftScrollView = self.m_LeftBox:NewUI(1, CScrollView)
	self.m_LeftSkillGrid = self.m_LeftBox:NewUI(2, CGrid)
	self.m_LeftBoxClone = self.m_LeftBox:NewUI(3, CBox)

	self.m_TitleLabel = self.m_RightBox:NewUI(1, CLabel)
	self.m_GradeLabel = self.m_RightBox:NewUI(2, CLabel)
	self.m_GradeLimit = self.m_RightBox:NewUI(3, CLabel)
    self.m_SkillDes = self.m_RightBox:NewUI(4, CLabel)
    self.m_ItemGrid = self.m_RightBox:NewUI(5, CGrid)
    self.m_ItemClone = self.m_RightBox:NewUI(6, CBox)
    self.m_MakeDes = self.m_RightBox:NewUI(7, CLabel)
    self.m_Slider = self.m_RightBox:NewUI(8, CSlider)
    self.m_OwnSilverCoin = self.m_RightBox:NewUI(11, CLabel)
    self.m_CostOrgContribute = self.m_RightBox:NewUI(9, CLabel)
   -- self.m_OwnContribute = self.m_RightBox:NewUI(10, CLabel)
    self.m_CostVitality = self.m_RightBox:NewUI(10, CLabel)
    self.m_UpgradeBtn = self.m_RightBox:NewUI(12, CButton)
    self.m_MakeBtn = self.m_RightBox:NewUI(13, CSprite)
    self.m_QuickMakeBtn = self.m_RightBox:NewUI(14, CSprite)
    self.m_MakeLabel = self.m_RightBox:NewUI(15, CLabel)
    self.m_SliderLabel = self.m_RightBox:NewUI(16, CLabel)
    self.m_SkillIcon = self.m_RightBox:NewUI(17, CSprite)
    self.m_scroll = self.m_RightBox:NewUI(18, CScrollView)
    self.m_NoskillUI = self.m_RightBox:NewUI(19,CObject)
    self.m_curLabel = self.m_RightBox:NewUI(20,CLabel)
    self.m_NextLabel = self.m_RightBox:NewUI(21,CLabel)
    self.m_banggong = self.m_RightBox:NewUI(22,CObject)
    self.m_Huoli = self.m_RightBox:NewUI(23,CObject)  
    self.m_yinbi = self.m_RightBox:NewUI(24,CObject)
    self.m_DragScroll = self.m_RightBox:NewUI(25, CScrollView)
    self.m_DragGrid = self.m_RightBox:NewUI(26,CGrid)
    self.m_DragClone = self.m_RightBox:NewUI(27,CBox)
    self.m_tipLabel = self.m_RightBox:NewUI(28,CLabel)
    self.m_SliderEff = self.m_RightBox:NewUI(29,CObject)
    self.m_StoryNode = self.m_RightBox:NewUI(30, CObject)
    self.m_StoryCostL = self.m_RightBox:NewUI(31, CLabel)
    self.m_CostGrid = self.m_RightBox:NewUI(32, CGrid)
    self.m_ResetBtn = self.m_RightBox:NewUI(33, CButton)
    self.m_ItemScrollView = self.m_RightBox:NewUI(34, CScrollView)
   	self.m_OrgIconSp = self.m_RightBox:NewUI(35, CSprite)
   	self.m_SilverIconSp = self.m_RightBox:NewUI(36, CSprite)
   	self.m_StoryIconSp = self.m_RightBox:NewUI(37, CSprite)
   	self.m_HuoliIconSp = self.m_RightBox:NewUI(38, CSprite)
end

function CSkillTalismanPart.OnInitPage(self)
	self.m_LeftBoxClone:SetActive(false)
	self.m_ItemClone:SetActive(false)
	self.m_DragClone:SetActive(false)
	self:InitContent()

	self:RefreshUI()
end

function CSkillTalismanPart.InitContent(self)
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnClickResetBtn"))
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnClickUpgradeBtn"))
	self.m_MakeBtn:AddUIEvent("click", callback(self, "OnClickMakeBtn"))
	self.m_OrgIconSp:AddUIEvent("click", callback(self, "OnClickOrgIconSp"))
	self.m_SilverIconSp:AddUIEvent("click", callback(self, "OnClickSilverIconSp"))
	self.m_StoryIconSp:AddUIEvent("click", callback(self, "OnClickStoryIconSp"))
	self.m_HuoliIconSp:AddUIEvent("click", callback(self, "OnClickHuoliIconSp"))
	g_SkillCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSkillEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
end

function CSkillTalismanPart.OnCtrlSkillEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Skill.Event.RefreshFuZhuanSkill then
		self:RefreshUI()
	end
end

function CSkillTalismanPart.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:OnShowLimitLevel()
		self:OnShowCost()
	end
end

function CSkillTalismanPart.RefreshUI(self)
	self:SetLeftSkillList()
	if self.m_SelectShowIndex then
		self:SelectOne(self.m_SelectShowIndex)
	else
		self:SelectOne(1)
	end
end

function CSkillTalismanPart.SetLeftSkillList(self)
	local optionCount = #g_SkillCtrl.m_FuZhuanDataList
	local GridList = self.m_LeftSkillGrid:GetChildList() or {}
	local oLeftBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oLeftBox = self.m_LeftBoxClone:Clone(false)
				-- self.m_LeftSkillGrid:AddChild(oOptionBtn)
			else
				oLeftBox = GridList[i]
			end
			self:SetLeftSkillBox(oLeftBox, g_SkillCtrl.m_FuZhuanDataList[i], i)
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
				GridList[i].m_SkillData = nil
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
				v.m_SkillData = nil
			end
		end
	end

	self.m_LeftSkillGrid:Reposition()
	self.m_LeftScrollView:ResetPosition()
end

function CSkillTalismanPart.SetLeftSkillBox(self, oLeftBox, oData, oIndex)
	oLeftBox:SetActive(true)
	oLeftBox.m_SkillData = oData
	oLeftBox.m_IconSp = oLeftBox:NewUI(1, CSprite)
	oLeftBox.m_NameLbl = oLeftBox:NewUI(2, CLabel)
	oLeftBox.m_LevelLbl = oLeftBox:NewUI(3, CLabel)
	oLeftBox.m_SelNameLbl = oLeftBox:NewUI(4, CLabel)
	oLeftBox.m_SelLevelLbl = oLeftBox:NewUI(5, CLabel)

	oLeftBox:SetGroup(self:GetInstanceID())
	oLeftBox.m_SelLevelLbl:SetActive(false)
	if oData.level <= 0 then
		oLeftBox.m_LevelLbl:SetActive(false)
	else
		oLeftBox.m_LevelLbl:SetActive(true)
		oLeftBox.m_LevelLbl:SetText(oData.level.."级")
	end
	oLeftBox.m_SelLevelLbl:SetText(oData.level.."级")

	local oConfig = data.skilldata.FUZHUAN[oData.sk]
	if oConfig then
		oLeftBox.m_NameLbl:SetText(oConfig.name)
		oLeftBox.m_SelNameLbl:SetText(oConfig.name)
		oLeftBox.m_IconSp:SpriteSkill(oConfig.icon)
		oLeftBox.m_IconSp:SetGrey(oData.level <= 0)
	end

	oLeftBox:AddUIEvent("click", callback(self, "OnClickLeftBox", oData, oIndex))

	self.m_LeftSkillGrid:AddChild(oLeftBox)
	self.m_LeftSkillGrid:Reposition()
end

function CSkillTalismanPart.SelectOneById(self, oId)
	local GridList = self.m_LeftSkillGrid:GetChildList() or {}
	for k,v in pairs(GridList) do
		if v.m_SkillData and v.m_SkillData.sk == oId then
			v:SetSelected(true)
			break
		end
	end
	self:OnShowEachById(oId)
end

function CSkillTalismanPart.SelectOne(self, oIndex)
	local oChild = self.m_LeftSkillGrid:GetChild(oIndex)
	if oChild then
		oChild:SetSelected(true)
	end
	self:OnShowEachByIndex(oIndex)
end

function CSkillTalismanPart.OnShowEachByIndex(self, oIndex)
	if not g_SkillCtrl.m_FuZhuanDataList[oIndex] then
		return
	end
	self.m_SelectShowIndex = oIndex
	self:OnShowEachById(g_SkillCtrl.m_FuZhuanDataList[oIndex].sk)
end

function CSkillTalismanPart.OnShowEachById(self, oId)
	local oConfig = data.skilldata.FUZHUAN[oId]
	local oData = g_SkillCtrl.m_FuZhuanDataHashList[oId]
	if not oConfig or not oData then
		return
	end
	self.m_SelectShowId = oId
	self.m_SkillIcon:SpriteSkill(oConfig.icon)
	self.m_TitleLabel:SetText(oConfig.name)
	if oData.level <= 0 then
		self.m_GradeLabel:SetActive(false)
		self.m_UpgradeBtn:SetText("学习技能")
	else
		self.m_GradeLabel:SetActive(true)
		self.m_GradeLabel:SetText(oData.level.."级")
		self.m_UpgradeBtn:SetText("升级技能")
	end
	self.m_SkillDes:SetText(oConfig.desc)
	self:OnShowLimitLevel()
	self:SetRightItemList({oConfig.itemsid})

	self.m_banggong:SetActive(false)
	self.m_yinbi:SetActive(false)
	self.m_StoryNode:SetActive(true)	
	self.m_CostGrid:Reposition()

	self:OnShowCost()
end

function CSkillTalismanPart.OnShowCost(self)
	if not self.m_SelectShowId then
		return
	end
	local oConfig = data.skilldata.FUZHUAN[self.m_SelectShowId]
	local oData = g_SkillCtrl.m_FuZhuanDataHashList[self.m_SelectShowId]
	if not oConfig or not oData then
		return
	end
	local oNumStr = string.gsub(oConfig.learnpoint, "lv", tostring(oData.level))
	local oLearnPoint = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr))()))
	self.m_StoryCostL:SetText(g_AttrCtrl.storypoint.."/"..tostring(oLearnPoint))

	local oNumStr2 = string.gsub(oConfig.huoli, "lv", tostring(oData.level))
	local oHuoLi = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr2))()))
	self.m_CostVitality:SetText(g_AttrCtrl.energy.."/"..tostring(oHuoLi))
end

function CSkillTalismanPart.OnShowLimitLevel(self)
	if not self.m_SelectShowId then
		return
	end
	local oConfig = data.skilldata.FUZHUAN[self.m_SelectShowId]
	if not oConfig then
		return
	end
	local oNumStr = string.gsub(oConfig.limit_level, "grade", tostring(g_AttrCtrl.grade))
	local oTopLimitLv = math.floor(tonumber(load(string.format([[return (%s)]], oNumStr))()))
	self.m_MakeDes:SetText("当前制作的符篆最高"..oTopLimitLv.."级")
end

function CSkillTalismanPart.SetRightItemList(self, oMakeList)
	local optionCount = #oMakeList
	local GridList = self.m_DragGrid:GetChildList() or {}
	local oRightBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRightBox = self.m_DragClone:Clone(false)
				-- self.m_DragGrid:AddChild(oOptionBtn)
			else
				oRightBox = GridList[i]
			end
			self:SetRightItemBox(oRightBox, oMakeList[i])
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

	self.m_DragGrid:Reposition()
	self.m_DragScroll:ResetPosition()
end

function CSkillTalismanPart.SetRightItemBox(self, oRightBox, oData)
	oRightBox:SetActive(true)
	oRightBox.m_IconSp = oRightBox:NewUI(1, CSprite)
	oRightBox.m_NameLbl = oRightBox:NewUI(2, CLabel)
	oRightBox.m_BgSp = oRightBox:NewUI(3, CSprite)
	oRightBox.m_LightSp = oRightBox:NewUI(4, CSprite)
	oRightBox.m_LightSp2 = oRightBox:NewUI(5, CSprite)

	oRightBox.m_BgSp:SetActive(false)
	local oItemConfig = DataTools.GetItemData(oData)
	oRightBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	oRightBox.m_NameLbl:SetText(oItemConfig.name)

	oRightBox:AddUIEvent("click", callback(self, "OnClickItemTips", oRightBox, oData))

	self.m_DragGrid:AddChild(oRightBox)
	self.m_DragGrid:Reposition()
end


-----------------以下是点击事件------------------

function CSkillTalismanPart.OnClickResetBtn(self)
	if not self.m_SelectShowId then
		return
	end
	if not g_SkillCtrl.m_FuZhuanDataHashList[self.m_SelectShowId] then
		return
	end
	local oSkillLevel = g_SkillCtrl.m_FuZhuanDataHashList[self.m_SelectShowId].level
	if oSkillLevel <= 0 then
		g_NotifyCtrl:FloatMsg(string.gsub(data.skilldata.TEXT[1009].content, "#skill", "[0fff32]"..data.skilldata.FUZHUAN[self.m_SelectShowId].name.."[-]"))
		return
	end
	local oNumStr = string.gsub(data.skilldata.FUZHUAN[self.m_SelectShowId].reset, "lv", tostring(oSkillLevel))
	local oResetCost = math.ceil(tonumber(load(string.format([[return (%s)]], oNumStr))()))
	local oDescStr = string.gsub(data.skilldata.TEXT[1010].content, "#skill", "#G"..data.skilldata.FUZHUAN[self.m_SelectShowId].name.."#n")
	oDescStr = string.gsub(oDescStr, "#level", "#G"..(oSkillLevel-1).."#n")
	oDescStr = string.gsub(oDescStr, "#amount", "#G"..oResetCost.."#n")
	local windowConfirmInfo = {
		msg = "#D"..oDescStr,
		title = "提示",
		okCallback = function () 
			if oResetCost > g_AttrCtrl.silver then
				local coinlist = {}
	            local t = {sid = 1002, count = g_AttrCtrl.silver, amount = oResetCost }
	            table.insert(coinlist, t)
	            CQuickGetCtrl:CurrLackItemInfo({}, coinlist, nil, function ()
	            	netskill.C2GSResetFuZhuanSkill(self.m_SelectShowId)
	            end)
			else
				netskill.C2GSResetFuZhuanSkill(self.m_SelectShowId)
			end
		end,
		cancelCallback = function () 
			
		end,
		okStr = "确定",
		cancelStr = "取消",
		closeType = 1,
		color = Color.white,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CSkillTalismanPart.OnClickUpgradeBtn(self)
	if not self.m_SelectShowId then
		return
	end
	netskill.C2GSLearnFuZhuanSkill(self.m_SelectShowId)
end

function CSkillTalismanPart.OnClickMakeBtn(self)
	if not self.m_SelectShowId then
		return
	end
	if not g_SkillCtrl.m_FuZhuanDataHashList[self.m_SelectShowId] then
		return
	end
	if g_SkillCtrl.m_FuZhuanDataHashList[self.m_SelectShowId].level <= 0 then
		g_NotifyCtrl:FloatMsg(string.gsub(data.skilldata.TEXT[1013].content, "#skill", "[0fff32]"..data.skilldata.FUZHUAN[self.m_SelectShowId].name.."[-]"))
		return
	end
	local oConfig = data.skilldata.FUZHUAN[self.m_SelectShowId]
	local oData = g_SkillCtrl.m_FuZhuanDataHashList[self.m_SelectShowId]
	local oNumStr2 = string.gsub(oConfig.huoli, "lv", tostring(oData.level))
	local oHuoLi = math.ceil(tonumber(load(string.format([[return (%s)]], oNumStr2))()))
	if g_AttrCtrl.energy < oHuoLi then
		g_NotifyCtrl:FloatMsg("活力不足")
        CAttrBuyEnergyView:ShowView()
		return
	end

	netskill.C2GSProductFuZhuanSkill(self.m_SelectShowId)
end

function CSkillTalismanPart.OnClickItemTips(self, oPrizeBox, oData)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oData, args)
end

function CSkillTalismanPart.OnClickLeftBox(self, oData, oIndex)
	self:SelectOne(oIndex)
end

function CSkillTalismanPart.OnClickOrgIconSp(self)
	g_WindowTipCtrl:SetWindowGainItemTip(1008, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_OrgIconSp, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

function CSkillTalismanPart.OnClickSilverIconSp(self)
	g_WindowTipCtrl:SetWindowGainItemTip(1002, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_SilverIconSp, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

function CSkillTalismanPart.OnClickStoryIconSp(self)
	g_WindowTipCtrl:SetWindowGainItemTip(1024, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_StoryIconSp, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

function CSkillTalismanPart.OnClickHuoliIconSp(self)
	g_WindowTipCtrl:SetWindowGainItemTip(1026, function ()
        local oView = CItemTipsView:GetView()
        UITools.NearTarget(self.m_HuoliIconSp, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
    end)
end

return CSkillTalismanPart