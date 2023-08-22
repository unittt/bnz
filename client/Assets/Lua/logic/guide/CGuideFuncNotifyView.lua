local CGuideFuncNotifyView = class("CGuideFuncNotifyView", CViewBase)

function CGuideFuncNotifyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Guide/GuideFuncNotifyView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CGuideFuncNotifyView.OnCreateView(self)
	self.m_TitleLbl = self:NewUI(1, CLabel)
	self.m_TextScrollView = self:NewUI(2, CScrollView)
	self.m_InfoLbl = self:NewUI(3, CLabel)
	self.m_PrizeScrollView = self:NewUI(4, CScrollView)
	self.m_PrizeGrid = self:NewUI(5, CGrid)
	self.m_PrizeClone = self:NewUI(6, CBox)
	self.m_ConfirmBtn = self:NewUI(7, CButton)
	self.m_LevelLbl = self:NewUI(8, CLabel)
	self.m_GetBtn = self:NewUI(9, CButton)
	self.m_CloseBtn = self:NewUI(10, CButton)

	g_GuideCtrl:AddGuideUI("preopen_get_btn", self.m_ConfirmBtn)
	
	self:InitContent()
end

function CGuideFuncNotifyView.InitContent(self)
	self.m_PrizeClone:SetActive(false)
	self.m_ConfirmBtn:SetActive(true)
	self.m_ConfirmBtn:SetText("确定")
	self.m_GetBtn:SetActive(false)

	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))
	-- self.m_GetBtn:AddUIEvent("click", callback(self, "OnClickGet"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CGuideFuncNotifyView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if self.m_PreOpenData then
			self:RefreshUI(self.m_PreOpenData)
		end
	end
end

function CGuideFuncNotifyView.RefreshUI(self, oData)
	self.m_PreOpenData = oData

	self.m_TitleLbl:SetText(oData.name)
	self.m_InfoLbl:SetText(oData.desc)
	self.m_LevelLbl:SetText(oData.reward_grade.."级领取")

	self:SetPrizeList(g_GuideHelpCtrl:GetRewardList("PREOPEN", oData.rewardid))

	if g_AttrCtrl.grade >= oData.reward_grade then
		self.m_ConfirmBtn:SetActive(true)
		self.m_ConfirmBtn:DelEffect("Rect")
		self.m_ConfirmBtn:AddEffect("Rect")
		self.m_ConfirmBtn:SetText("领取")
		self.m_ConfirmBtn:SetGrey(false)
	else
		self.m_ConfirmBtn:SetActive(true)
		self.m_ConfirmBtn:DelEffect("Rect")
		self.m_ConfirmBtn:SetText("确定")
		self.m_ConfirmBtn:SetGrey(true)
	end

	self.m_TextScrollView:ResetPosition()
end

function CGuideFuncNotifyView.SetPrizeList(self, list)
	local optionCount = #list
	local GridList = self.m_PrizeGrid:GetChildList() or {}
	local oPrizeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPrizeBox = self.m_PrizeClone:Clone(false)
				-- self.m_PrizeGrid:AddChild(oOptionBtn)
			else
				oPrizeBox = GridList[i]
			end
			self:SetPrizeBox(oPrizeBox, list[i])
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

	self.m_PrizeGrid:Reposition()
	self.m_PrizeScrollView:ResetPosition()
end

function CGuideFuncNotifyView.SetPrizeBox(self, oPrizeBox, oData)
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_IconSp:SpriteItemShape(oData.item.icon)
	
	oPrizeBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData.item, oPrizeBox))

	self.m_PrizeGrid:AddChild(oPrizeBox)
	self.m_PrizeGrid:Reposition()
end

---------------以下是点击事件------------------

function CGuideFuncNotifyView.OnClickConfirm(self)
	if self.m_PreOpenData and g_AttrCtrl.grade >= self.m_PreOpenData.reward_grade then
		netplayer.C2GSRewardPreopenGift(self.m_PreOpenData.id)
	end
	self:CloseView()
end

function CGuideFuncNotifyView.OnClickGet(self)
	if self.m_PreOpenData then
		netplayer.C2GSRewardPreopenGift(self.m_PreOpenData.id)
	end
	self:CloseView()
end

function CGuideFuncNotifyView.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.id, args)
end

return CGuideFuncNotifyView