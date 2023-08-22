local CRedPacketSelectMoneyView = class("CRedPacketSelectMoneyView", CViewBase)

function CRedPacketSelectMoneyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketSelectMoneyView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketSelectMoneyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	self.m_ConfirmBtn = self:NewUI(5, CButton)
	self.m_TitleLbl = self:NewUI(6, CLabel)

	self.m_AddGoldIcon = nil

	self:InitContent()
end

function CRedPacketSelectMoneyView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))

	-- self:RefreshUI()
end

function CRedPacketSelectMoneyView.RefreshUI(self, oMoneyList, oTitle, oClickFunc)
	self:SetMoneyList(oMoneyList)
	self:OnClickSelectMoney(oMoneyList[1], self.m_Grid:GetChild(1))
	self.m_TitleLbl:SetText(oTitle)
	self.m_ClickFunc = oClickFunc
end

function CRedPacketSelectMoneyView.SetMoneyList(self, oMoneyList)
	local optionCount = #oMoneyList
	local GridList = self.m_Grid:GetChildList() or {}
	local oMoneyBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oMoneyBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oMoneyBox = GridList[i]
			end
			self:SetMoneyBox(oMoneyBox, oMoneyList[i])
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

	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CRedPacketSelectMoneyView.SetMoneyBox(self, oMoneyBox, oData)
	oMoneyBox:SetActive(true)
	oMoneyBox:SetGroup(self:GetInstanceID())
	oMoneyBox.m_ValueLbl = oMoneyBox:NewUI(1, CLabel)
	oMoneyBox.m_ValueLbl:SetText(oData.."#cur_2 = "..oData*define.RedPacket.Convert.GoldCoinToGold.."#cur_3")

	oMoneyBox:AddUIEvent("click", callback(self, "OnClickSelectMoney", oData, oMoneyBox))

	self.m_Grid:AddChild(oMoneyBox)
	self.m_Grid:Reposition()
end

----------------以下是点击事件---------------

function CRedPacketSelectMoneyView.OnClickConfirm(self)
	if not self.m_AddGoldIcon then
		g_NotifyCtrl:FloatMsg("请选择要增加的元宝哦")
		return
	end
	if self.m_ClickFunc then
		self.m_ClickFunc(self.m_AddGoldIcon)
	end
	g_RedPacketCtrl:OnEvent(define.RedPacket.Event.SysMoneyAdd)	
	self:CloseView()
end

function CRedPacketSelectMoneyView.OnClickSelectMoney(self, oData, oMoneyBox)
	self.m_AddGoldIcon = oData
	oMoneyBox:SetSelected(true)
end

return CRedPacketSelectMoneyView