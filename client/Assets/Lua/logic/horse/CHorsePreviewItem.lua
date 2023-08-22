local CHorsePreviewItem = class("CHorsePreviewItem", CBox)

function CHorsePreviewItem.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)

end

function CHorsePreviewItem.SetInfo(self, id)
	
	self.m_Id = id 
	local dataItem = data.ridedata.SKILL[id]
	if dataItem then 
		self.m_Icon:SpriteSkill(tostring(dataItem.icon))
		self.m_Icon:SetActive(true)
		self:AddUIEvent("click", callback(self, "OnShowTips", dataItem))
	end 

end

function CHorsePreviewItem.OnShowTips(self, config)

    local args = {
        widget= self,
        side = enum.UIAnchor.Side.Left,
        skId = self.m_Id
    }
     g_WindowTipCtrl:SetWindowHorseSkillTip(args)

end

return CHorsePreviewItem