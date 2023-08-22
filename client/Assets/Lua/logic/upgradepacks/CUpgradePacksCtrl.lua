local CUpgradePacksCtrl = class("CUpgradePacksCtrl", CCtrlBase)


function CUpgradePacksCtrl.ctor(self)

	CCtrlBase.ctor(self)
	self.m_hadReward = {}
end

function CUpgradePacksCtrl.ClearAll(self)
	self.m_hadReward = {}
end

--登录时收到的领取信息
function CUpgradePacksCtrl.GS2CLoginGradeGiftInfo(self, data)
 	--已领取等级礼包列表
 	self.m_hadReward = {}
 	table.copy(data, self.m_hadReward)
 	-- self.m_hadReward = data

 	self:UpdatePacksList()

 	g_ItemCtrl:SetUpgradsPackConfigByGrade()
 	g_GuideCtrl:OnTriggerAll()
 	g_GuideHelpCtrl:CheckAllNotifyGuide()
 end 

--礼包领取成功回调
 function CUpgradePacksCtrl.GS2CRewareGradeGift(self, data)
 	
 	table.insert(self.m_hadReward, data)

 	self:UpdatePacksList()

 	--礼包引导相关
 	g_GuideHelpCtrl.m_IsOnlineRewareGradeGift[data] = true

 	--抛出礼包领取成功事件
 	self:OnEvent(define.UpgradePacks.Event.GetReward, self)
 	g_ItemCtrl:SetUpgradsPackConfigByGrade()
 	g_GuideCtrl:OnTriggerAll()
 	g_GuideHelpCtrl:CheckAllNotifyGuide()
 end


--角色属性变化
 function CUpgradePacksCtrl.UpdatePacks(self)

	self:UpdatePacksList()
	g_ItemCtrl:SetUpgradsPackConfigByGrade()
	g_GuideCtrl:OnTriggerAll()
	g_GuideHelpCtrl:CheckAllNotifyGuide()
end

--更新礼包数据
 function CUpgradePacksCtrl.UpdatePacksList(self)

 	if self.m_hadReward ~= nil then 

		--不能领取的等级礼包列表
		self.m_notHadReward = self:GetNotRewardUpgradePacks()
		--能领取的等级礼包
		self.m_canReward = self:GetCanRewardUpgradePacks()
		--合并
		self.m_upgradePackList = self:MergeTable()

		 --抛出礼包数据改变事件
		self:OnEvent(define.UpgradePacks.Event.UpgradePacksDataChange, self)

 	end 


end


 function CUpgradePacksCtrl.MergeTable(self)
 	
 	local packsList = {}

 	if self.m_canReward and next(self.m_canReward) then 

 		for k , v in pairs(self.m_canReward) do 

 			local upgradePack = {}
 			upgradePack.grade = v
 			upgradePack.state = 1
 			table.insert(packsList, upgradePack)

 		end 

 	end

 	if self.m_notHadReward and next(self.m_notHadReward) then 

		for k , v in pairs(self.m_notHadReward) do 

			local upgradePack = {}
			upgradePack.grade = v
			upgradePack.state = 2
			table.insert(packsList, upgradePack)

		end 

	end

	return packsList

 end

 function CUpgradePacksCtrl.IsHadRedPoint(self)
 	local canRewardList = self:GetCanRewardUpgradePacks()
 	return canRewardList and next(canRewardList) ~= nil
 end


--获取未领取的并且不能领取(未达等级)的等级礼包列表
function CUpgradePacksCtrl.GetNotRewardUpgradePacks(self)
	
	--礼包配置表
	local upgradePacksConfig = data.upgradePacksdata.upgradePacks

	--不能领取
	local notRewardList = {}


	for k , v in pairs(upgradePacksConfig) do 

		if self:isInHadRewardUpgradePacks(v.grade) == false then 

			if g_AttrCtrl.grade < v.grade then

				table.insert(notRewardList, v.grade)

			end

		end

	end

	table.sort(notRewardList)

	return notRewardList


end

--获取未领取的并且能领取(已达等级)的等级礼包列表
function CUpgradePacksCtrl.GetCanRewardUpgradePacks(self)

	local hadRewardList = {}

	local upgradePacksConfig = data.upgradePacksdata.upgradePacks

	for k , v in pairs(upgradePacksConfig) do 
		
		if self:isInHadRewardUpgradePacks(v.grade) == false then 

			if g_AttrCtrl.grade >= v.grade then

				table.insert(hadRewardList, v.grade)

			end

		end

	end

	table.sort(hadRewardList)

	return hadRewardList

end



--是否已在已领取列表中
function CUpgradePacksCtrl.isInHadRewardUpgradePacks(self, grade)

	local isIn = false
	if self.m_hadReward and next(self.m_hadReward) then 
		for k , v in pairs(self.m_hadReward) do 

			if v == grade  then 

				isIn = true 
				break

			end 

		end
	end
	return isIn

end

--判断等级级礼包是否能领取
function CUpgradePacksCtrl.IsCanRewardUpgragePackByGrade(self, grade)

	local canRewardList = self:GetCanRewardUpgradePacks()

	for k,v in pairs(canRewardList) do
		if v == grade then
			return true
		end
	end
	return false
end


return CUpgradePacksCtrl