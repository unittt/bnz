local CFloatBox = class("CFloatBox", CBox)

function CFloatBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_FloatLabel = self:NewUI(1, CLabel)
	self.m_BgSprite = self:NewUI(2, CSprite)
	
	self.m_Callback = nil
	self.m_FloatTimer = nil
	self.m_PastTime = 0
	self.m_LastTime = 0
end

function CFloatBox.SetMaxWidth(self, w)
	self.m_FloatLabel:SetOverflowWidth(w)
end

function CFloatBox.SetTimer(self, iTime, cb)
	self.m_Callback = cb
	self.m_PastTime = 0
	self.m_LastTime = iTime
	if self.m_FloatTimer then
		Utils.DelTimer(self.m_FloatTimer)
		self.m_FloatTimer = nil
	end
	self.m_FloatTimer = Utils.AddTimer(callback(self, "AlphaAndCB"), 0, 0)
end

function CFloatBox.AlphaAndCB(self, t)
	local iLastTime = self.m_LastTime
	self.m_PastTime = self.m_PastTime + t
	if self.m_PastTime > iLastTime then
		local fAlpha = (1 - (self.m_PastTime - iLastTime))
		if fAlpha < 0 then
			if self.m_Callback then
				self.m_Callback(self)
				self.m_Callback = nil
			end
			return false
		else
			self:SetAlpha(fAlpha)
		end
	end
	return true
end

function CFloatBox.SetText(self, sText, itemData)
	self.m_FloatLabel:SetRichText(sText, nil, nil, true)

	-- local oStr, oCount = string.gsub(sText, "#cur_%d", "")
	-- if oCount > 0 then
	-- 	self.m_BgSprite:SetAnchorTarget(self.m_FloatLabel.m_GameObject, 0, 0, 0, 0)		
	-- 	self.m_BgSprite:SetAnchor("topAnchor", 14, 1)
 --        self.m_BgSprite:SetAnchor("bottomAnchor", -8, 0)
	-- else
	-- 	self.m_BgSprite:SetAnchorTarget(self.m_FloatLabel.m_GameObject, 0, 0, 0, 0)		
	-- 	self.m_BgSprite:SetAnchor("topAnchor", 14, 1)
 --        self.m_BgSprite:SetAnchor("bottomAnchor", -16, 0)     
	-- end
	-- self.m_BgSprite:SetAnchor("leftAnchor", -91, 0)
	-- self.m_BgSprite:SetAnchor("rightAnchor", 91, 1)
	-- self.m_BgSprite:ResetAndUpdateAnchors()

	if itemData and type(itemData) == "table" then
		self.m_ItemIconSp:SetActive(true)
		if itemData.icon then
			self.m_ItemIconSp:SpriteItemShape(tonumber(itemData.icon))
		elseif itemData.shape then
			self.m_ItemIconSp:SpriteAvatar(tonumber(itemData.shape))
		end
		--暂时屏蔽
		-- if itemData.count > 1 then
		-- 	self.m_ItemCountLbl:SetActive(true)
		-- 	self.m_ItemCountLbl:SetText(itemData.count)
		-- else
		-- 	self.m_ItemCountLbl:SetActive(false)
		-- end	
	end
end

return CFloatBox