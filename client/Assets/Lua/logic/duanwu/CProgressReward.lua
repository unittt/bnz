local CProgressReward = class("CProgressReward", CBox)

function CProgressReward.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_CurPointLabel = self:NewUI(1, CLabel)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_RewardBox = self:NewUI(3, CRewardItem)
	self.m_Name = self:NewUI(4, CLabel)

end

--[[
	{
		curPoint = 100,
		name = "祭品",
		stepLsit = {
			{id = 1, icon = "1003", target = 200, rewardId = 1001, hadReward = false, canReward = false, cnt}			
		}
	}
]]
function CProgressReward.RefreshInfo(self, info, cb)

	self.m_Name:SetText(info.name)
	self.m_CurPointLabel:SetText(info.curPoint)

	self.m_CurPoint = info.curPoint or 0

	local stepList = self:CalculateStepList(info.stepList)
	for k, v in ipairs(stepList) do 
		local item = self.m_Grid:GetChild(k)
		if not item then
			item = self.m_RewardBox:Clone()
			item:SetActive(true)
			self.m_Grid:AddChild(item)
		end 
		item:RefreshInfo(v, cb)
	end 

end 

function CProgressReward.CalculateStepList(self, stepList)

	local list = {}
	for k, v in ipairs(stepList) do 
		local stepInfo = {}
		stepInfo.id = v.id
		stepInfo.icon = v.icon
		stepInfo.hadReward = v.hadReward
		stepInfo.rewardId = v.rewardId
		stepInfo.target = v.target
		stepInfo.canReward = v.canReward
		stepInfo.cnt = v.cnt
		if stepList[k-1] then 
			stepInfo.curV = self.m_CurPoint - stepList[k-1].target
			stepInfo.maxV = v.target - stepList[k-1].target
		else
			stepInfo.curV = self.m_CurPoint
			stepInfo.maxV = v.target
		end
		table.insert(list, stepInfo) 
	end
	return list

end 

return CProgressReward