local CUpgradePackBox = class("CUpgradePackBox", CBox)

function CUpgradePackBox.ctor(self, obj)

	CBox.ctor(self, obj)

	self.m_GradeLabel = self:NewUI(1, CLabel)
	self.m_RewardBtn = self:NewUI(2, CButton)
	self.m_Hadreward = self:NewUI(3, CSprite)
	self.m_ItemBox = self:NewUI(4, CBox)
	self.m_ItemGrid = self:NewUI(5,CGrid)
	self.m_CanNotRewardSprite = self:NewUI(6,CSprite)
	self.m_RewardBtnLabel = self:NewUI(7, CLabel)

	self:InitContent()

	self.m_ItemBox:SetActive(false)

end

function CUpgradePackBox.OnClickRewardItem(self, itemId, item)
	local config = {widget = item}
	g_WindowTipCtrl:SetWindowItemTip(itemId, config)

end

function CUpgradePackBox.InitContent(self)
	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnClickRewardBtn"))

end

function CUpgradePackBox.SetData(self, data)
	
	self.data = data
	self:SetBtn(self.data.state)
	self:SetLabel(self.data.grade)
	self:setRewardList(self.data.grade)

end

function CUpgradePackBox.setRewardList(self, grade)

	local roleType = g_AttrCtrl.roletype
	local roleSex = g_AttrCtrl.sex
	local RewardItemList = DataTools.GetUpgradeGiftList(data.upgradePacksdata.upgradePacks[grade].reward_id, roleType, roleSex)
	self:HideAllRewardItems()

	local tempTable = {}

	for k ,v in pairs(RewardItemList) do 

		table.insert(tempTable, k)

	end

	table.sort(tempTable)

	for k, v in pairs(tempTable) do 

		local  item = self.m_ItemGrid:GetChild(k)

		if item == nil then

			item = self.m_ItemBox:Clone()
			self.m_ItemGrid:AddChild(item)

		end 

		item:SetActive(true)

		item.m_icon= item:NewUI(1, CSprite)
		item.m_count = item:NewUI(2, CLabel)
		item.m_QualityBorder= item:NewUI(3, CSprite)

		local data = RewardItemList[tempTable[k]]

		if data and next(data) then
			item.m_data = data

			item.m_count:SetText( "[b]" .. data.count)	

			local iconData = DataTools.GetItemData(data.sid)
			local quality = g_ItemCtrl:GetQualityVal( iconData.id, iconData.quality or 0 )

			if iconData ~= nil then 

				item.m_icon:SpriteItemShape(iconData.icon)

				if iconData.quality ~= nil then 

					item.m_QualityBorder:SetItemQuality(quality)

				end

			end

			item:AddUIEvent("click", callback(self, "OnClickRewardItem",data.sid, item))
		end

	end

	self.m_ItemGrid:Reposition()

end

function CUpgradePackBox.HideAllRewardItems(self)
	
	for k , v in pairs(self.m_ItemGrid:GetChildList()) do 

		v:SetActive(false)

	end 

end


--刷新领取按钮的状态的状态  1能领取 2不能领取 3 已领取但无法按下
function CUpgradePackBox.SetBtn(self, state)

	if state == 1 then 
		self.m_RewardBtn:SetActive(true)
		self.m_CanNotRewardSprite:SetActive(false)
	elseif state == 2 then 
		self.m_RewardBtn:SetActive(false)
		self.m_CanNotRewardSprite:SetActive(true)
		self.m_RewardBtnLabel:SetText("领取")
	elseif state == 3 then 
		self.m_RewardBtn:SetActive(false)
		self.m_CanNotRewardSprite:SetActive(true)
		self.m_RewardBtnLabel:SetText("已领取")
	end

end

function CUpgradePackBox.SetLabel(self, grade)
	
	self.m_GradeLabel:SetText(grade .. "级")

end

function CUpgradePackBox.OnClickRewardBtn(self)
	--暂时屏蔽
	-- if g_WarCtrl:IsWar() then
	-- 	g_NotifyCtrl:FloatMsg("请脱离战斗后再进行操作")
	-- 	return
	-- end
	self.m_RequireGetReward = true
	netplayer.C2GSRewardGradeGift(self.data.grade)
	--礼包引导相关
 	g_GuideHelpCtrl.m_IsOnlineClickGradeGift[self.data.grade] = true

 	g_GuideCtrl:OnTriggerAll()

	--引导相关
	-- if self.data.grade == 10 then
	-- 	CWelfareView:CloseView()
	-- end
end

return CUpgradePackBox