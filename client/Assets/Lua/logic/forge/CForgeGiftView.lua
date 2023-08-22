local CForgeGiftView = class("CForgeGiftView", CViewBase)

function CForgeGiftView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeGiftView.prefab", cb)
	--界面设置
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CForgeGiftView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_OkBtn = self:NewUI(2, CButton)
	self.m_GiftGrid = self:NewUI(3, CGrid)
	self.m_GiftBox = self:NewUI(4, CBox)

	self.m_SelectedId = -1
	self:InitContent()
end

function CForgeGiftView.InitContent(self)
	self.m_GiftBox:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnClickOk"))
	self:RefreshGiftGrid()
end

function CForgeGiftView.RefreshGiftGrid(self)
	local iCurGrade = math.floor(g_AttrCtrl.grade/10)*10 
	local tData = data.equipdata.SOUL_POINT[iCurGrade]
	if not tData then
		return
	end
	self.m_GiftGrid:Clear()
	for i,dReward in ipairs(tData.reward_choose) do
		local oBox = self:CreateGiftBox(dReward, i)
		self.m_GiftGrid:AddChild(oBox)
		if i == 1 then
			oBox:SetSelected(true)
			self.m_SelectedId = dReward.sid
		end
	end
	self.m_GiftGrid:Reposition()
end

function CForgeGiftView.CreateGiftBox(self, dReward, iIndex)
	local tItem = DataTools.GetItemData(dReward.sid)
	local oBox = self.m_GiftBox:Clone()
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)

	oBox:SetGroup(self.m_GiftGrid:GetInstanceID())
	if iIndex == 2 then
		oBox.m_IconSpr:SetSpriteName("h7_zhuquebaoxiang")
	end
	oBox.m_NameL:SetText(tItem.name)

	oBox:SetActive(true)
	local function OnClick()
		oBox:SetSelected(true)
		self.m_SelectedId = dReward.sid
	end 
	oBox:AddUIEvent("click", OnClick)
	return oBox
end

function CForgeGiftView.OnClickOk(self)
	if self.m_SelectedId == -1 then 
		g_NotifyCtrl:FloatMsg("请先选择礼包")
		return
	end
	netitem.C2GSRecFuHunPointReward(self.m_SelectedId)
	self:CloseView()
end

return CForgeGiftView