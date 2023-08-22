local CSourceGameTechBox = class("CSourceGameTechBox", CBox)

function CSourceGameTechBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	-- self.m_TabBtnGrid = self:NewUI(1, CGrid)
	-- self.m_TabBtnBox = self:NewUI(2, CBox)
	self.m_ColScrollView = self:NewUI(3, CScrollView)
	self.m_ColGrid = self:NewUI(4, CGrid)
	self.m_ColBoxClone = self:NewUI(5, CBox)
	self.m_ExplainSV = self:NewUI(6, CScrollView)
	self.m_Icon = self:NewUI(7, CSprite)
	self.m_CatNmae = self:NewUI(8, CLabel)
	-- self.m_TitleLab = self:NewUI(9, CLabel)
	self.m_DesLab = self:NewUI(10, CLabel)
	--self:InitContent()

	g_PromoteCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPromoteEvent"))
end

-- function CSourceGameTechBox.InitContent(self)
-- 	-- body
-- 	local tabinfo = data.sourcebookdata.GAMETECH
-- 	self.m_TabBtnGrid:Clear()
-- 	local btnlist = self.m_TabBtnGrid:GetChildList()
-- 	for i,v in ipairs(tabinfo) do
-- 		local box = nil
-- 		if i>#btnlist then
-- 			box =  self.m_TabBtnBox:Clone()
-- 			box:SetActive(true)
-- 			self.m_TabBtnGrid:AddChild(box)
-- 			box.btn = box:NewUI(1, CButton)
-- 			box.btn:SetGroup(self.m_TabBtnGrid:GetInstanceID())
-- 			box.norlab = box:NewUI(2, CLabel)
-- 			box.sellab = box:NewUI(3, CLabel)
-- 		else
-- 			box = btnlist[i]
-- 		end
-- 		box.norlab:SetText(v.title)
-- 		box.sellab:SetText(v.title)
-- 		box.btn:AddUIEvent("click", callback(self, "OnTabBtnClick", v.cat_id))
-- 	end
-- 	self.m_TabBtnGrid:Reposition()

-- 	self:OnTabBtnClick(tabinfo[1].cat_id)
-- 	self.m_TabBtnGrid:GetChild(1).btn:SetSelected(true)
-- end

function CSourceGameTechBox.RefreshUI(self, idx)
	local techInfo = data.sourcebookdata.GAMETECH
	local id = techInfo[idx].cat_id

	local contentinfo = data.sourcebookdata.GAMETECHCONTENT
	local  templist = {}
	for i,v in ipairs(contentinfo) do
		if id == v.cat_id then
			table.insert(templist, v)
		end
	end

	self.m_ColGrid:Clear()
	local collist = self.m_ColGrid:GetChildList()
	for i,v in ipairs(templist) do
		local box = nil
		if i>#collist then
			box =  self.m_ColBoxClone:Clone()
			box:SetActive(true)
			self.m_ColGrid:AddChild(box)
			box.btn = box:NewUI(1, CSprite)
			box.btn:SetGroup(self.m_ColGrid:GetInstanceID())
			box.icon = box:NewUI(2, CSprite)
			box.norlab = box:NewUI(3, CLabel)
			box.sellab = box:NewUI(4, CLabel)
			box.btn:AddUIEvent("click", callback(self, "OnColBtnClick", v))
		else
			box = collist[i]
		end
		box.icon:SetSpriteName(v.icon)
		box.norlab:SetText(v.title)
		box.sellab:SetText(v.title)
	end
	self.m_ColGrid:Reposition()
	self.m_ColScrollView:ResetPosition()

	self:OnColBtnClick(templist[1])
	self.m_ColGrid:GetChild(1).btn:SetSelected(true)
end

function CSourceGameTechBox.OnColBtnClick(self, info)
	-- body
	self.m_Icon:SetSpriteName(info.icon)
	self.m_CatNmae:SetText(info.title)
	self.m_DesLab:SetText(info.des)
end

function CSourceGameTechBox.OnPromoteEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Promote.Event.RefreshGameTechInfo then
		self:RefreshUI(oCtrl.m_EventData)
	end
end

return CSourceGameTechBox