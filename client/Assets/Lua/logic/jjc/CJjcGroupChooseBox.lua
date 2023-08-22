local CJjcGroupChooseBox = class("CJjcGroupChooseBox", CBox)

function CJjcGroupChooseBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ChallengeBtn1 = self:NewUI(1, CButton)
	self.m_ChallengeBtn2 = self:NewUI(2, CButton)
	self.m_ChallengeBtn3 = self:NewUI(3, CButton)
	self.m_CountLbl = self:NewUI(4, CLabel)
	-- self.m_Grid1 = self:NewUI(5, CGrid)
	-- self.m_Grid2 = self:NewUI(6, CGrid)
	-- self.m_Grid3 = self:NewUI(7, CGrid)
	self.m_Content1 = self:NewUI(8, CBox)
	self.m_Content2 = self:NewUI(9, CBox)
	self.m_Content3 = self:NewUI(10, CBox)
	self:InitContentBox(self.m_Content1)
	self:InitContentBox(self.m_Content2)
	self:InitContentBox(self.m_Content3)
	self.m_TipsBtn = self:NewUI(11, CButton)
	self.m_CountLbl = self:NewUI(12, CLabel)
	self.m_DescLbl = self:NewUI(13, CLabel)
	self.m_ChallengeBtn = self:NewUI(14, CButton)
	-- local function init(obj, idx)
	-- 	local oBox = CJjcGroupBox.New(obj)
	-- 	return oBox
	-- end
	-- self.m_Grid1:InitChild(init)
	-- self.m_Grid2:InitChild(init)
	-- self.m_Grid3:InitChild(init)

	self.m_SelectIndex = 1

	self:InitContent()
end

function CJjcGroupChooseBox.InitContentBox(self, oBox)
	oBox.m_ScoreLbl = oBox:NewUI(1, CLabel)
	oBox.m_ScrollView = oBox:NewUI(2, CScrollView)
	oBox.m_Grid = oBox:NewUI(3, CGrid)
	oBox.m_BoxClone = oBox:NewUI(4, CBox)
	oBox.m_CountLbl = oBox:NewUI(5, CLabel)
	oBox.m_DescLbl = oBox:NewUI(6, CLabel)
	oBox.m_ChallengeBtn = oBox:NewUI(7, CButton)
end

function CJjcGroupChooseBox.InitContent(self)
	for i=1,3 do
		self["m_Content"..i].m_BoxClone:SetActive(false)
	end
	self.m_ChallengeBtn1:SetGroup(self:GetInstanceID())
	self.m_ChallengeBtn2:SetGroup(self:GetInstanceID())
	self.m_ChallengeBtn3:SetGroup(self:GetInstanceID())
	self.m_ChallengeBtn1:AddUIEvent("click", callback(self, "OnClickSelectChallenge", 1))
	self.m_ChallengeBtn2:AddUIEvent("click", callback(self, "OnClickSelectChallenge", 2))
	self.m_ChallengeBtn3:AddUIEvent("click", callback(self, "OnClickSelectChallenge", 3))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickJjcChooseTips"))
	-- self.m_Content1.m_ChallengeBtn:AddUIEvent("click", callback(self, "OnClickChallenge", 1))
	-- self.m_Content2.m_ChallengeBtn:AddUIEvent("click", callback(self, "OnClickChallenge", 2))
	-- self.m_Content3.m_ChallengeBtn:AddUIEvent("click", callback(self, "OnClickChallenge", 3))
	self.m_ChallengeBtn:AddUIEvent("click", callback(self, "OnClickChallenge"))

	g_JjcCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

--协议通知返回
function CJjcGroupChooseBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Jjc.Event.JJCChallengeChooseRankUI then
		local oView = CJjcMainView:GetView()
		oView.m_GroupPart:ShowChooseBox()
		self:RefreshJJCChallengeChooseRankUI(oCtrl.m_EventData)
	end
end

function CJjcGroupChooseBox.RefreshJJCChallengeChooseRankUI(self, pbdata)
	for k,v in ipairs(g_JjcCtrl.m_JjcChallengeList) do
		for g, target in ipairs(v.targets) do
			self["m_Grid"..k]:GetChild(g):SetContent(target)
		end
	end

	for i=1, 3 do
		self:SetGroupPrizeList(i)
	end

	for k,v in ipairs(data.jjcdata.CHALLENGEGROUP) do
		self["m_Content"..k].m_ScoreLbl:SetText(math.floor(g_AttrCtrl.score*v.tuijian))
	end

	-- self:ShowSelectBox()
	self.m_CountLbl:SetText(g_JjcCtrl.m_JjcChallengeRewardTime.."次")
	self.m_DescLbl:SetActive(true)
	self.m_ChallengeBtn:SetActive(true)
end

function CJjcGroupChooseBox.SetGroupPrizeList(self, idx)
	local optionCount = #data.jjcdata.CHALLENGEREWARD[idx].client_item
	local GridList = self["m_Content"..idx].m_Grid:GetChildList() or {}
	local oPrizeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPrizeBox = self["m_Content"..idx].m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oPrizeBox = GridList[i]
			end
			self:SetGroupPrizeBox(oPrizeBox, data.jjcdata.CHALLENGEREWARD[idx].client_item[i], idx)
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

	self["m_Content"..idx].m_Grid:Reposition()
	self["m_Content"..idx].m_ScrollView:ResetPosition()
end

function CJjcGroupChooseBox.SetGroupPrizeBox(self, oPrizeBox, oData, idx)
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
	local oItemConfig = DataTools.GetItemData(oData.sid)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ))
	oPrizeBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	oPrizeBox.m_CountLbl:SetText(oData.amont)
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickShowTips", oData, oPrizeBox))

	self["m_Content"..idx].m_Grid:AddChild(oPrizeBox)
	self["m_Content"..idx].m_Grid:Reposition()
end

function CJjcGroupChooseBox.ShowSelectBox(self)
	self["m_ChallengeBtn"..self.m_SelectIndex]:SetSelected(true)
	for i = 1, 3 do
		if i == self.m_SelectIndex then
			self["m_Content"..i].m_CountLbl:SetActive(true)
			self["m_Content"..i].m_CountLbl:SetText(g_JjcCtrl.m_JjcChallengeRewardTime.."次")
			self["m_Content"..i].m_DescLbl:SetActive(true)
			self["m_Content"..i].m_ChallengeBtn:SetActive(true)
		else
			self["m_Content"..i].m_CountLbl:SetActive(false)
			self["m_Content"..i].m_DescLbl:SetActive(false)
			self["m_Content"..i].m_ChallengeBtn:SetActive(false)
		end
	end
end

function CJjcGroupChooseBox.OnClickSelectChallenge(self, index)
	self.m_SelectIndex = index
	-- self:ShowSelectBox()
end

function CJjcGroupChooseBox.OnClickChallenge(self)
	if g_JjcCtrl.m_JjcChallengeRewardTime <= 0 then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.PrizeNoTime].content)
	else
		netjjc.C2GSChooseChallenge(self.m_SelectIndex)
	end
end

function CJjcGroupChooseBox.OnClickJjcChooseTips(self)
	local zId = define.Instruction.Config.JjcGroup
	local zContent = {title = data.instructiondata.DESC[zId].title,desc = data.instructiondata.DESC[zId].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

function CJjcGroupChooseBox.OnClickShowTips(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
end

return CJjcGroupChooseBox