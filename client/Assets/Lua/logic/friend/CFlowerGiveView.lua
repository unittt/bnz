local CFlowerGiveView = class("CFlowerGiveView", CViewBase)

function CFlowerGiveView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Friend/FlowerGiveView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CFlowerGiveView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_HeadSp = self:NewUI(2, CSprite)
	self.m_GradeLbl = self:NewUI(3, CLabel)
	self.m_NameLbl = self:NewUI(4, CLabel)
	self.m_RelationSp = self:NewUI(5, CSprite)
	self.m_RelationLbl = self:NewUI(6, CLabel)
	self.m_GiveBtn = self:NewUI(7, CButton)
	self.m_Input = self:NewUI(8, CInput)
	self.m_InputLbl = self:NewUI(9, CLabel)
	self.m_FlowerSelectBox1 = self:NewUI(10, CBox)
	self.m_FlowerSelectBox2 = self:NewUI(11, CBox)
	self.m_FlowerSelectBox3 = self:NewUI(12, CBox)
	self.m_FlowerSelectGrid = self:NewUI(13, CGrid)
	self.m_AddFlowerBtn = self:NewUI(14, CButton)
	self.m_FlowerCountLbl = self:NewUI(15, CLabel)
	self.m_FlowerIconSp = self:NewUI(16, CSprite)
	self.m_AddRelationLbl = self:NewUI(17, CLabel)
	self.m_EmojiBtn = self:NewUI(18, CButton)

	self.m_SelectFlowerIndex = 1
	self.m_GiveFriendData = nil
	
	self:InitContent()
end

function CFlowerGiveView.InitContent(self)
	self.m_FlowerSelectBox1:SetGroup(self:GetInstanceID())
	self.m_FlowerSelectBox2:SetGroup(self:GetInstanceID())
	self.m_FlowerSelectBox3:SetGroup(self:GetInstanceID())

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	for i = 1, 3 do
		self["m_FlowerSelectBox"..i]:AddUIEvent("click", callback(self, "OnClickSelectFlower", i))
	end
	self.m_GiveBtn:AddUIEvent("click", callback(self, "OnClickGive"))
	self.m_AddFlowerBtn:AddUIEvent("click", callback(self, "OnClickAddFlower"))
	self.m_Input:AddUIEvent("select", callback(self, "OnFocusInput"))
	self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnClickEmoji"))

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CFlowerGiveView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.DelItem 
	or oCtrl.m_EventID == define.Item.Event.ItemAmount then
		if self.m_FlowerItemSid then
			self.m_FlowerCountLbl:SetText(g_ItemCtrl:GetBagItemAmountBySid(self.m_FlowerItemSid))
		end
	end
end

function CFlowerGiveView.RefreshUI(self, oData)
	self.m_GiveFriendData = oData
	self.m_HeadSp:SpriteAvatar(oData.icon)
	self.m_GradeLbl:SetText("Lv."..tostring(oData.grade))
	self.m_NameLbl:SetText(oData.name)
	self.m_RelationSp:SetSpriteName(g_FriendCtrl:GetRelationIcon(oData.friend_degree))
	self.m_RelationLbl:SetText(oData.friend_degree)

	local otherSex = data.roletypedata.DATA[oData.role_type].sex
	local mySex = data.roletypedata.DATA[g_AttrCtrl.roletype].sex
	if otherSex == mySex then
		self.m_FlowerItemSid = define.Flower.Type.Same
		self.m_FlowerSelectConfig = g_FriendCtrl:GetFlowerSameSexConfig()
		self.m_FlowerItemConfig = DataTools.GetItemData(self.m_FlowerItemSid)
	else
		self.m_FlowerItemSid = define.Flower.Type.NotSame
		self.m_FlowerSelectConfig = g_FriendCtrl:GetFlowerNotSameSexConfig()
		self.m_FlowerItemConfig = DataTools.GetItemData(self.m_FlowerItemSid)
	end
	self.m_FlowerCountLbl:SetText(g_ItemCtrl:GetBagItemAmountBySid(self.m_FlowerItemSid))
	self.m_FlowerIconSp:SetSpriteName(self:GetFlowerIconName(1))
	self.m_FlowerIconSp:MakePixelPerfect()

	for i = 1, 3 do
		local effectLbl = self["m_FlowerSelectBox"..i]:NewUI(1, CLabel)
		local descLbl = self["m_FlowerSelectBox"..i]:NewUI(2, CLabel)
		local flowerSp = self["m_FlowerSelectBox"..i]:NewUI(3, CSprite)

		effectLbl:SetText(self.m_FlowerSelectConfig[i].effect)
		descLbl:SetText("赠送"..self.m_FlowerSelectConfig[i].count.."朵"..self.m_FlowerItemConfig.name)
		flowerSp:SetSpriteName(self:GetFlowerIconName(i))
		flowerSp:MakePixelPerfect()
	end

	local blessList = self:GetBlessConfig(self.m_FlowerItemSid)
	local blessStr = table.randomvalue(blessList).content
	blessStr = string.gsub(blessStr, "#role", g_AttrCtrl.name)
	blessStr = string.gsub(blessStr, "#friend", oData.name)
	self.m_Input:SetText(blessStr)

	self.m_SelectFlowerIndex = 1
	self:SetFlowerSelectByIndex()
end

function CFlowerGiveView.GetBlessConfig(self, flowerItemSid)
	local list = {}
	local config = data.frienddata.FLOWERSELECT[flowerItemSid]
	if config and config.bless_list then
		for k,v in pairs(config.bless_list) do
			table.insert(list, data.frienddata.FLOWERBLESS[v])
		end
	end
	return list
end

function CFlowerGiveView.SetFlowerSelectByIndex(self)
	if self.m_SelectFlowerIndex == 1 then
		self.m_FlowerSelectBox1:ForceSelected(true)
		self.m_FlowerSelectBox2:ForceSelected(false)
		self.m_FlowerSelectBox3:ForceSelected(false)
	elseif self.m_SelectFlowerIndex == 2 then
		self.m_FlowerSelectBox1:ForceSelected(false)
		self.m_FlowerSelectBox2:ForceSelected(true)
		self.m_FlowerSelectBox3:ForceSelected(false)
	elseif self.m_SelectFlowerIndex == 3 then
		self.m_FlowerSelectBox1:ForceSelected(false)
		self.m_FlowerSelectBox2:ForceSelected(false)
		self.m_FlowerSelectBox3:ForceSelected(true)
	end

	self.m_AddRelationLbl:SetText("+"..tonumber(self.m_FlowerItemConfig.item_formula)*self.m_FlowerSelectConfig[self.m_SelectFlowerIndex].count)
	UITools.NearTarget(self.m_RelationLbl, self.m_AddRelationLbl, enum.UIAnchor.Side.Right)
end

function CFlowerGiveView.GetFlowerIconName(self, index)
	if self.m_FlowerItemSid == define.Flower.Type.Same then
		if index == 1 then
			return 10175
		elseif index == 2 then
			return 10176
		elseif index == 3 then
			return 10177
		else
			return 10175
		end
	else
		if index == 1 then
			return 10018
		elseif index == 2 then
			return 10178
		elseif index == 3 then
			return 10179
		else
			return 10018
		end		
	end
end

--------------以下是点击事件----------------

function CFlowerGiveView.OnClickSelectFlower(self, index)
	self.m_SelectFlowerIndex = index
	self:SetFlowerSelectByIndex()
end

function CFlowerGiveView.OnClickGive(self)
	if not self.m_GiveFriendData then
		return
	end
	if self.m_Input:GetText() == "" then
		g_NotifyCtrl:FloatMsg(data.frienddata.FRIENDTEXT[define.Flower.Text.NoBless].content)
		return
	end
	if g_MaskWordCtrl:IsContainMaskWord(self.m_Input:GetText()) then
		g_NotifyCtrl:FloatMsg(data.frienddata.FRIENDTEXT[define.Flower.Text.MaskBless].content)
		return
	end
	-- local leftCount =  self.m_FlowerSelectConfig[self.m_SelectFlowerIndex].count - g_ItemCtrl:GetBagItemAmountBySid(self.m_FlowerItemSid)
	-- if leftCount > 0 then
	-- 	local windowConfirmInfo = {
	-- 		msg = self.m_FlowerItemConfig.name.."数量不足花费"..(leftCount*self.m_FlowerItemConfig.giftPrice).."元宝补足",
	-- 		title = "提示",
	-- 		okCallback = function () 
	--			CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(2) end) 
	-- 		end,	
	-- 		okStr = "确定",
	-- 		cancelStr = "取消",
	-- 	}
	-- 	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	-- 	return
	-- end

	local _, roleMarkCount = string.gsub(self.m_Input:GetText(), g_AttrCtrl.name, "")
	local _, friendMarkCount = string.gsub(self.m_Input:GetText(), self.m_GiveFriendData.name, "")
	if roleMarkCount > 0 and friendMarkCount > 0 then
		self.m_IsSys = 1
	else
		self.m_IsSys = 0
	end

	local sendBlessStr = self.m_Input:GetText()
	sendBlessStr = string.gsub(sendBlessStr, g_AttrCtrl.name, "#G"..g_AttrCtrl.name.."#n")
	sendBlessStr = string.gsub(sendBlessStr, self.m_GiveFriendData.name, "#G"..self.m_GiveFriendData.name.."#n")
	
	netfriend.C2GSSendFlower(self.m_GiveFriendData.pid, self.m_FlowerItemSid, self.m_FlowerSelectConfig[self.m_SelectFlowerIndex].count, sendBlessStr, self.m_IsSys)
end

function CFlowerGiveView.OnClickAddFlower(self)
	
end

function CFlowerGiveView.OnFocusInput(self)
	if self.m_Input.m_UIInput.isSelected then
		self.m_Input.m_UIInput.selectAllTextOnFocus = true
	end
end

function CFlowerGiveView.OnClickEmoji(self)
	COnlyEmojiView:ShowView(
		function(oView)
			oView:SetSendFunc(callback(self, "AppendText"))
			-- oView:SetWidget(self.m_EmojiBtn)
			UITools.NearTarget(self.m_EmojiBtn, oView.m_RightWidget, enum.UIAnchor.Side.Bottom)
		end
	)
end

--添加链接，只能有一个链接
function CFlowerGiveView.AppendText(self, s)
	if string.match(s, "%b{}") then
		self.m_Input:ClearLink()
	end
	local sOri = self.m_Input:GetText()
	local _, count = string.gsub(sOri..s, "#%d+", "")
	if count > 5 then
		g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.MaxEmoji].content)
		return
	end

	self.m_Input:SetText(sOri..s)
end

return CFlowerGiveView