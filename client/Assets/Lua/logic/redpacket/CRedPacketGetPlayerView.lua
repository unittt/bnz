local CRedPacketGetPlayerView = class("CRedPacketGetPlayerView", CViewBase)

function CRedPacketGetPlayerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/RedPacket/RedPacketGetPlayerView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CRedPacketGetPlayerView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSp= self:NewUI(2, CSprite)
	self.m_NameLbl = self:NewUI(3, CLabel)
	self.m_DescLbl = self:NewUI(4, CLabel)
	self.m_NumLbl = self:NewUI(5, CLabel)
	self.m_MoneyLbl = self:NewUI(6, CLabel)
	self.m_ScrollView = self:NewUI(7, CScrollView)
	self.m_Grid = self:NewUI(8, CGrid)
	self.m_BoxClone = self:NewUI(9, CBox)
	self.m_MoneyBox = self:NewUI(10, CBox)
	self.m_BgSp = self:NewUI(11, CSprite)

	self:InitContent()
end

function CRedPacketGetPlayerView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	g_RedPacketCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CRedPacketGetPlayerView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RedPacket.Event.GetRedPacketPlayer then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

function CRedPacketGetPlayerView.RefreshUI(self, pbdata)
	self.m_IconSp:SpriteAvatar(pbdata.rpbasicinfo.ownericon)
	self.m_NameLbl:SetText(pbdata.rpbasicinfo.ownername)
	self.m_DescLbl:SetText(pbdata.rpbasicinfo.bless)

	local bIsMyExist = false
	local oMyData
	for k,v in pairs(g_RedPacketCtrl.m_RedPacketGetPlayerList) do
		if v.pid == g_AttrCtrl.pid then
			bIsMyExist = true
			oMyData = v
			break
		end
	end
	if bIsMyExist then
		self.m_MoneyBox:SetActive(true)
		local moneyStr = tostring(oMyData.cash)
		local resultStr = ""
		for i = 1, string.len(moneyStr) do
			resultStr = resultStr.."#gold_"..string.sub(moneyStr, i, i)
		end
		self.m_NumLbl:SetText(resultStr.."#cur_3")
	else
		self.m_MoneyBox:SetActive(false)
		local oPos1 = self.m_MoneyLbl:GetLocalPos()
		self.m_MoneyLbl:SetLocalPos(Vector3.New(oPos1.x, 48 + 52, oPos1.z))
		local oPos2 = self.m_ScrollView:GetLocalPos()
		self.m_ScrollView:SetLocalPos(Vector3.New(oPos2.x, 94 + 52, oPos2.z))
		self.m_BgSp:SetHeight(496)
	end
	
	self.m_MoneyLbl:SetText("[244B4E]已领取[FF0000]"..#g_RedPacketCtrl.m_RedPacketGetPlayerList.."/"..pbdata.rpbasicinfo.count.."[-]个，共计[FF0000]"..g_RedPacketCtrl:GetPlayerGetMoney().."/"..pbdata.rpbasicinfo.cashsum.."[-]#cur_3")
	self:SetPlayerGetList()
end

function CRedPacketGetPlayerView.SetPlayerGetList(self)
	local optionCount = #g_RedPacketCtrl.m_RedPacketGetPlayerList
	local GridList = self.m_Grid:GetChildList() or {}
	local oPlayer
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPlayer = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oPlayer = GridList[i]
			end
			self:SetPlayerGetBox(oPlayer, g_RedPacketCtrl.m_RedPacketGetPlayerList[i], i)
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

function CRedPacketGetPlayerView.SetPlayerGetBox(self, oPlayer, oData, index)
	oPlayer:SetActive(true)
	oPlayer.m_IconSp = oPlayer:NewUI(1, CSprite)
	oPlayer.m_NameLbl = oPlayer:NewUI(2, CLabel)
	oPlayer.m_TimeLbl = oPlayer:NewUI(3, CLabel)
	oPlayer.m_MoneyLbl = oPlayer:NewUI(4, CLabel)
	oPlayer.m_BestSp = oPlayer:NewUI(5, CSprite)
	oPlayer.m_WorstSp = oPlayer:NewUI(6, CSprite)

	oPlayer.m_IconSp:SpriteAvatar(oData.icon)
	oPlayer.m_NameLbl:SetText(oData.name)
	oPlayer.m_TimeLbl:SetText(os.date("%Y-%m-%d", oData.time))
	oPlayer.m_MoneyLbl:SetText(oData.cash.."#cur_3")

	if #g_RedPacketCtrl.m_RedPacketGetPlayerList >= g_RedPacketCtrl.m_RedPacketGetPlayerTotal and index == 1 then
		oPlayer.m_BestSp:SetActive(true)
	else
		oPlayer.m_BestSp:SetActive(false)
	end

	self.m_Grid:AddChild(oPlayer)
	self.m_Grid:Reposition()
end

return CRedPacketGetPlayerView