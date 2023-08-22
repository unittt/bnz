local CUpgradePacksPart = class("CUpgradePacksPart", CPageBase)

function CUpgradePacksPart.ctor(self, cb)

	CPageBase.ctor(self, cb)

	self.m_UpgradePackBox = self:NewUI(1,CUpgradePackBox)
	self.m_ItemGrid = self:NewUI(2,CGrid)
	self.m_FinishIcon = self:NewUI(3, CTexture)
	self.m_Bg = self:NewUI(4, CWidget)

	self.m_UpgradePackBox:SetActive(false)

end


function CUpgradePacksPart.OnInitPage(self)

	self:RefreshUpgradeBoxs()

	g_UpgradePacksCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

end

--刷新所有box
function CUpgradePacksPart.RefreshUpgradeBoxs(self)

	local data = g_UpgradePacksCtrl.m_upgradePackList

	if data ~= nil then 

		self:HideAllPackBox()

		for k , v in pairs(data) do 

			local box = self.m_ItemGrid:GetChild(k)
			if box == nil then 

				box = self.m_UpgradePackBox:Clone()
				self.m_ItemGrid:AddChild(box)

			end 

			box:SetData(v)
			box:SetActive(true)

			if v.grade == 10 then
				g_GuideCtrl:AddGuideUI("upgradepack_item1_reward_btn", box.m_RewardBtn)
			elseif v.grade == 20 then
				g_GuideCtrl:AddGuideUI("upgradepack_item2_reward_btn", box.m_RewardBtn)
			elseif v.grade == 30 then
				g_GuideCtrl:AddGuideUI("upgradepack_item3_reward_btn", box.m_RewardBtn)
			elseif v.grade == 40 then
				g_GuideCtrl:AddGuideUI("upgradepack_item4_reward_btn", box.m_RewardBtn)
			end
		end


		self.m_FinishIcon:SetActive(#data == 0)
		self.m_Bg:SetActive(#data ~= 0)

	end 

end


--协议通知返回
function CUpgradePacksPart.OnCtrlEvent(self, oCtrl)

	if oCtrl.m_EventID == define.UpgradePacks.Event.GetReward then 
		self:FloatItemList()
		self:DelayRefreshUpgradeBoxs()
	end

	if oCtrl.m_EventID == define.UpgradePacks.Event.UpgradePacksDataChange  then
		self:RefreshUpgradeBoxs()
	end

end

function CUpgradePacksPart.FloatItemList(self)
	if g_UpgradePacksCtrl.m_FloatItemList then
		for i,v in ipairs(g_UpgradePacksCtrl.m_FloatItemList) do
			local oItemData = DataTools.GetItemData(v.itemid)

			g_NotifyCtrl:FloatItemBox(oItemData.icon, nil, v.pos)
		end
		g_UpgradePacksCtrl:SelectItemList(nil)
	end
end



function CUpgradePacksPart.DelayRefreshUpgradeBoxs(self)
	
	local function delay()
		if not Utils.IsNil(self) then
			self:RefreshUpgradeBoxs()
		end
		return false
    end

	for k , v in pairs(self.m_ItemGrid:GetChildList()) do 

		if v.m_RequireGetReward then 

			v:SetBtn(3)
			v.m_RequireGetReward = nil

		end 
		
	end

    Utils.AddTimer(delay, 0, 2.5)

end

--隐藏所有格子
function  CUpgradePacksPart.HideAllPackBox(self)
	
	local  boxList = self.m_ItemGrid:GetChildList()
	if #boxList ~= 0 then 
		for k , v in pairs(boxList) do 
			v:SetActive(false)
		end 
	end 

end


return CUpgradePacksPart