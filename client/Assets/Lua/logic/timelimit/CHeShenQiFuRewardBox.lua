local CHeShenQiFuRewardBox = class("CHeShenQiFuRewardBox", CBox)

function CHeShenQiFuRewardBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_Point = self:NewUI(2, CLabel)
	self.m_Slider = self:NewUI(3, CSlider)
	self.m_EffectIcon = self:NewUI(4, CSprite)

	self.m_IgnoreCheckEffect = true


	self:AddUIEvent("click", callback(self, "OnClickItem"))

	self.m_Trans = {"一","二","三","四","五"}

	self.m_EffectIcon:SetActive(false)

end

function CHeShenQiFuRewardBox.SetData(self, lv, targetPoint, rewardIndex, state)
	
	self.m_Point:SetText(targetPoint)
	self.m_Icon:SpriteItemShape(lv == 5 and 10007 or 10008)
	self.m_rewardIndex = rewardIndex
	self.m_Lv = lv
	self:RefreshState(state)

end

function CHeShenQiFuRewardBox.RefreshSlider(self, info)
	
	self:SetSlider(info.Cur, info.Max)

end

function CHeShenQiFuRewardBox.SetSlider(self, curV, MaxV)
	
	local v = curV / MaxV 
	self.m_Slider:SetValue(v)

end

function CHeShenQiFuRewardBox.RefreshState(self, state)
	
	self.m_State = state
	self.m_Icon:SetGrey(self.m_State == 2)
	if self.m_State == 1 then 
		self.m_EffectIcon:SetActive(true)
		self:AddEffect("Rect")
	else
		self.m_EffectIcon:SetActive(false)
		self:DelEffect("Rect")
	end 
	
end

function CHeShenQiFuRewardBox.OnClickItem(self)

	if self.m_State == 2 then 
		return
	end 

	local itemlist = DataTools.GetQiFuRewardList(self.m_rewardIndex)

	local title = self.m_Trans[self.m_Lv] .. "星秘宝"

	local desc = nil
	local hideBtn = nil
	local cb = nil

	if not self.m_State or self.m_State == 0 then 
		hideBtn = true
		desc = "领取宝箱将获得丰厚的奖励"
	elseif self.m_State == 1 then 
		cb = function ( ... )
			 g_HeShenQiFuCtrl:C2GSQiFuGetDegreeReward(self.m_Lv)
		end
	end 

	g_WindowTipCtrl:ShowItemBoxView({
		title = title,
        hideBtn = hideBtn,
        items = itemlist,
        comfirmText = "确定",
        desc = desc,
        comfirmCb = cb
	})

end

return CHeShenQiFuRewardBox