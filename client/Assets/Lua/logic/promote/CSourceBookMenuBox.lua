local CSourceBookMenuBox = class("CSourceBookMenuBox", CBox)

function CSourceBookMenuBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_SelIdx = 0
	self.m_Type = nil
	self.m_Callback = cb
	self.m_MenuBtn = self:NewUI(1, CButton, true, false)
	self.m_ArrowSpr = self:NewUI(2, CSprite)
	self.m_SubMenuBgSpr = self:NewUI(3, CWidget)
	self.m_SubMenuPanel = self:NewUI(4, CPanel)
	self.m_SubMenuGrid = self:NewUI(5, CGrid)
	self.m_SubMenuBtnClone = self:NewUI(6, CBox)
	self.m_MenuSelectLbl = self:NewUI(7, CLabel)
	self.m_SelArrowSpr = self:NewUI(8, CSprite)
	self.m_TweenRotation = self.m_ArrowSpr:GetComponent(classtype.TweenRotation)
	self.m_SelTweenRotation = self.m_SelArrowSpr:GetComponent(classtype.TweenRotation)

	self.m_TweenHeight = self.m_SubMenuBgSpr:GetComponent(classtype.TweenHeight)
end

function CSourceBookMenuBox.RefMenuBox(self, info)
	self.m_Type = info.stype

	local groupID = self.m_SubMenuGrid:GetInstanceID()
	local dInfolist = g_PromoteCtrl:GetSourceBookByStype(info.stype)

	self.m_MenuBtn:SetText(info.name)
	self.m_MenuSelectLbl:SetText(info.name)

	-- 伙伴资料隐藏二级选项
	if info.stype == "SOURCE_PARTNER" then
		self.m_ArrowSpr:SetActive(false)
		self.m_SelArrowSpr:SetActive(false)
	end

	local btnlist = self.m_SubMenuGrid:GetChildList()
	for i, v in ipairs(dInfolist) do
		local oBtn = nil
		if i > #btnlist then
			oBtn = self.m_SubMenuBtnClone:Clone()
			oBtn.m_Label = oBtn:NewUI(1, CLabel)
			oBtn.m_SelLabel = oBtn:NewUI(2, CLabel)

			oBtn:SetActive(true)
			oBtn:SetGroup(groupID)
			oBtn:AddUIEvent("click", callback(self, "OnClickSubMenu", i))
			self.m_SubMenuGrid:AddChild(oBtn)
		else
			oBtn = btnlist[i]
		end

		oBtn.m_Label:SetText(v.name)
		oBtn.m_SelLabel:SetText(v.name)
	end

	local btnCount = self.m_SubMenuGrid:GetCount()
	local _, h = self.m_SubMenuBtnClone:GetSize()
	self.m_TweenHeight.to = (btnCount + 0.2) * (h + 8) -- + 26(用0.5加了)
end

function CSourceBookMenuBox.SetDefaultSelect(self)
	self.m_SelIdx = 1
	local oBtn = self.m_SubMenuGrid:GetChild(1)
	if oBtn then
		oBtn:SetSelected(true)
	end
	self:RefreshRightPart()
end

function CSourceBookMenuBox.OnClickSubMenu(self, idx)
	if self.m_SelIdx == idx then
		return
	end
	self.m_SelIdx = idx
	self:RefreshRightPart()
end

function CSourceBookMenuBox.RefreshRightPart(self)
	-- 很据stype刷新相应界面 --
	local iEvent = g_PromoteCtrl:GetSourceEvent(self.m_Type)
	g_PromoteCtrl:OnEvent(iEvent, self.m_SelIdx)
end

return CSourceBookMenuBox 