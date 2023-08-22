local CHorseAddExpBox = class("CHorseAddExpBox", CBox)

function CHorseAddExpBox.ctor(self, obj)

	CBox.ctor(self, obj)
	self.m_ItemBoxClone = self:NewUI(1, CBox)
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "SetActive", false))
	self:InitItemBox()
	self.m_ItemId = 11099

end


function CHorseAddExpBox.RefreshBox(self)

	local itemData = DataTools.GetItemData(self.m_ItemId)

	local oBox =self.m_ItemBoxClone

	oBox.m_IconSpr:SetSpriteName(tostring(itemData.icon))
	oBox.m_NameL:SetText(itemData.name)
	local itemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
	oBox.m_Count:SetText("增加" .. itemData.item_formula .. "经验")
	
	if itemCount == 0 then 
		oBox.m_AmountL:SetText("[ff0000]".. tostring(itemCount) .. "[-]" )
	else
		oBox.m_AmountL:SetText(itemCount)
	end  

end

function CHorseAddExpBox.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Horse.Event.HorseAttrChange then
		self:RefreshBox()
	end
end

function CHorseAddExpBox.InitItemBox(self)
	local oBox = self.m_ItemBoxClone
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_Count = oBox:NewUI(3, CLabel)
	oBox.m_AmountL = oBox:NewUI(4, CLabel)
	oBox.m_BgSpr = oBox:NewUI(5, CSprite)
	oBox.m_ItemBgSpr = oBox:NewUI(6, CSprite)

	oBox:SetActive(true)
	oBox.m_ItemBgSpr:AddUIEvent("click", function()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_ItemId)
	end)
	--oBox.m_BgSpr:AddUIEvent("click", callback(self, "OnClickAddExp", oBox))
	oBox.m_BgSpr:AddUIEvent("press", callback(self, "OnLongClickAddExp", oBox))
	oBox.m_BgSpr:AddUIEvent("click", callback(self, "OnClickAddExp", oBox))
	oBox.m_ItemBgSpr:AddUIEvent("press", callback(self, "OnLongClickAddExp", oBox))

end

function CHorseAddExpBox.RequestAddExp(self, oBox)

    local bagItemCount = g_ItemCtrl:GetBagItemAmountBySid(self.m_ItemId)
    if bagItemCount <= 0 then
        local itemData = DataTools.GetItemData(self.m_ItemId)
        g_NotifyCtrl:FloatMsg(itemData.name.."不足！")
        return
    end
    g_HorseCtrl:C2GSUpGradeRide()

end

function CHorseAddExpBox.OnLongClickAddExp(self, oBox)

	self.m_IsRequest = not self.m_IsRequest 
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	local function progress()

		if Utils.IsNil(self) then
			return false
		end 

		if not self:GetActive() then 
			self.m_IsRequest = false  
			return false
		end 

		if not self.m_IsRequest then
			return false
		end
		self:RequestAddExp(oBox)
		return true
	end
	self.m_Timer = Utils.AddTimer(progress, 0.1, 0.5)
end

function CHorseAddExpBox.OnClickAddExp(self, oBox)
	
	self:RequestAddExp(oBox)

end

return CHorseAddExpBox