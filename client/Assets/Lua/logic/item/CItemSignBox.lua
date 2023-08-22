local CItemSignBox = class("CItemSignBox", CBox)

function CItemSignBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_CountLabel = self:NewUI(2, CLabel)
	self.m_HookSprite = self:NewUI(3, CSprite)
	self.m_MaskSprite = self:NewUI(4, CSprite)
	self.m_DayLabel   = self:NewUI(5, CLabel)
	self.m_ReSignFlag = self:NewUI(6, CSprite)
	self.m_QualitySp  = self:NewUI(7, CSprite)

	self:AddUIEvent("click", callback(self, "OnClickRewardItem"))

end

function CItemSignBox.SetData(self, data)

	self.data = data
	if data.icon ~= nil then 
		self.m_IconSprite:SpriteItemShape(data.icon)
	end
	self.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( data.id, data.quality or 0 ))
	self:RefreshIcon()
	self:SetLabel(data.count)
	self.m_DayLabel:SetText("第"..tostring(data.day).."天")
	self:SetActive(true)

end

function CItemSignBox.OnClickRewardItem(self)
	local itemlist = g_ItemCtrl.m_BagItems
	local amount = table.count(itemlist)
	if self.data.isCanSign then 
		nethuodong.C2GSSignInDone()
		
	else
		local config = {widget = self}
		g_WindowTipCtrl:SetWindowItemTip(self.data.id, config)

	end

end


function CItemSignBox.RefreshIcon(self)
	local isHadSign = self.data.isHadSign
	local isCanSign = self.data.isCanSign
	local isReSign = self.data.isReSign

	self:DelEffect("Rect")

	if isHadSign then 
		
		self.m_HookSprite:SetActive(true)
		self.m_MaskSprite:SetActive(false)
		self.m_ReSignFlag:SetActive(false)

	else

		self.m_HookSprite:SetActive(false)
		self.m_MaskSprite:SetActive(false)

		if isCanSign then
			self:AddEffect("Rect"):SetLocalScale(Vector3.one * 0.9)
			self.m_IgnoreCheckEffect = g_SignCtrl:JudgeCanGetReward(self.data.id)
		end

		if isReSign then 
			self.m_ReSignFlag:SetActive(true)
		else
			self.m_ReSignFlag:SetActive(false)
		end  

	end 
	
end

function CItemSignBox.SetLabel(self, count)

	if count == 1 then 
		self.m_CountLabel:SetActive(false)
	else  
		self.m_CountLabel:SetActive(true)
		self.m_CountLabel:SetText(count)
	end 

end


return CItemSignBox