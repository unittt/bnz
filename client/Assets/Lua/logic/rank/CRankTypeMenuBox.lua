local CRankTypeMenuBox = class("CRankTypeMenuBox", CBox)

function CRankTypeMenuBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)
	self.m_ClickCallback = cb
	self.m_MainMenuBtn = self:NewUI(1, CButton, true, false)
	self.m_MainMenuFlag = self:NewUI(2, CSprite)
	self.m_SubMenuBgSpr = self:NewUI(3, CSprite)
	self.m_SubMenuPanel = self:NewUI(4, CPanel)
	self.m_SubMenuGrid = self:NewUI(5, CGrid)
	self.m_SubMenuBtnClone = self:NewUI(6, CBox)
	self.m_NormalName = self:NewUI(7, CLabel)
	self.m_SelectName = self:NewUI(8, CLabel)
	self.m_TweenHeight = self.m_SubMenuBgSpr:GetComponent(classtype.TweenHeight)
	self.m_TweenRotation = self.m_MainMenuFlag:GetComponent(classtype.TweenRotation)
	self.m_SubMenuBtnClone:SetActive(false)
end

function CRankTypeMenuBox.SetTypeMenu(self, mainMenu, groupID)
	self:RefMenuBox(mainMenu, groupID)
end

function CRankTypeMenuBox.RefMenuBox(self, mainMenu, groupID)
	local mainMenuName = mainMenu.name
	self.m_SelectName:SetText(mainMenuName)
	self.m_NormalName:SetText(mainMenuName)
	local taskCount = #mainMenu.subid
	local subMenuBoxList = self.m_SubMenuGrid:GetChildList() or {}
	if taskCount > 0 then
		for i,v in ipairs(mainMenu.subid) do
			local oSubMenu = nil
			if i > #subMenuBoxList then
				oSubMenu = self.m_SubMenuBtnClone:Clone()
				self:InitTabBox(oSubMenu)
				oSubMenu:SetGroup(groupID)
				self.m_SubMenuGrid:AddChild(oSubMenu)
				oSubMenu:AddUIEvent("click", callback(self, "OnClickSubMenu", i, oSubMenu))
			else
				oSubMenu = subMenuBoxList[i]
				self:InitTabBox(oSubMenu)
			end 
			oSubMenu.name:SetText(data.rankdata.INFO[v].name)
			oSubMenu.select:SetText(data.rankdata.INFO[v].name)
			oSubMenu:SetActive(true)
		end

		local _, h = self.m_SubMenuBtnClone:GetSize()
		if mainMenu.id > 1 then
			self.m_TweenHeight.to = taskCount * h + (taskCount+1)*9
		else
			self.m_TweenHeight.to = taskCount * (h+9) 
		end
	elseif subMenuBoxList and #subMenuBoxList > 0 then
		for _,v in ipairs(subMenuBoxList) do
			v:SetActive(false)
		end
	end
end

function CRankTypeMenuBox.SelectSubMenu(self, index)
	local gridList = self.m_SubMenuGrid:GetChildList()
	if gridList and #gridList > 0 then
		index = index or 1
		if gridList[index] then
			gridList[index]:SetSelected(true)
		end
	end
end

function CRankTypeMenuBox.OnClickSubMenu(self, idx)
	local info = self.subid[idx]
	if self.m_ClickCallback then
		self.m_ClickCallback(info)
	end
	local dData = data.rankdata.INFO[info]
	if dData.mien == 1 then
		local view = CRankListView:GetView()
		view:ShowMienInfo()
	end
end

function CRankTypeMenuBox.InitTabBox(self, prefab)
	local prefabBox = prefab
	prefabBox.name = prefabBox:NewUI(1, CLabel)
	prefabBox.select = prefabBox:NewUI(2, CLabel)
	prefab.preSelect = nil
	return prefabBox
end

return CRankTypeMenuBox
