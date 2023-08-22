local CPartnerListNodeBox = class("CPartnerListNodeBox", CBox)

CPartnerListNodeBox.UIStatus = {Common = 1, Formation = 2}

function CPartnerListNodeBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_PartnerBoxScroll = self:NewUI(2, CScrollView)
	self.m_PartnerBoxGrid = self:NewUI(3, CGrid)
	self.m_PartnerBoxClone = self:NewUI(4, CPartnerBox)
	self.m_PartnerBoxClone:SetActive(false)

	self.m_CallbackList = {}
	self.m_RecordTabIndex = 0
	self.m_RecordBoxIndex = nil
	self.m_PartnerInfoList = nil
	self.m_UIStatus = self.UIStatus.common 

	self:AddCallback(cb)
end

function CPartnerListNodeBox.AddCallback(self, cb)
	if not cb then
		return
	end
	table.insert(self.m_CallbackList, cb)
end

function CPartnerListNodeBox.SetUIStatus(self, status)
	self.m_UIStatus = status
end

function CPartnerListNodeBox.ReinitPartnerList(self, reposition)
	reposition = reposition == nil and true or reposition
	local recruitTab = g_PartnerCtrl.m_PartnerRecord.View.TabIndex == 1
	self.m_PartnerInfoList = g_PartnerCtrl:GetPartnerInfoList(1)
	local partnerBoxList = self.m_PartnerBoxGrid:GetChildList()
	local oPartnerBox = nil
	local gridID = self.m_PartnerBoxGrid:GetInstanceID()

	for i,v in ipairs(self.m_PartnerInfoList) do
		if i > #partnerBoxList then
			oPartnerBox = self.m_PartnerBoxClone:Clone()
			oPartnerBox:SetGroup(gridID)
			self.m_PartnerBoxGrid:AddChild(oPartnerBox)
		else
			oPartnerBox = partnerBoxList[i]
		end
		oPartnerBox:AddUIEvent("click", function ()
			if self.m_RecordBoxIndex ~= i or self.m_UIStatus == self.UIStatus.Formation then
				self.m_RecordBoxIndex = i
				self:Excute(i)
			end
		end)
		oPartnerBox:SetPartnerBox(v)
		oPartnerBox:SetActive(true)
		if i == 1 then
			if self.m_RecordBoxIndex and self.m_RecordBoxIndex > 0 then
				self.m_PartnerBoxGrid:GetChild(self.m_RecordBoxIndex):ForceSelected(false)
			end
			self.m_RecordBoxIndex = i
			oPartnerBox:SetSelected(true)
		end

		if v.id == g_GuideHelpCtrl:GetPartner1() then
			self.m_GetPartnerIndex = i
			g_GuideCtrl:AddGuideUI("partnerview_tab_btn", oPartnerBox)
		end
	end
	for i=#self.m_PartnerInfoList+1,#partnerBoxList do
		oPartnerBox = partnerBoxList[i]
		if not oPartnerBox then
			break
		end
		oPartnerBox:SetActive(false)
	end
	if reposition then
		self.m_PartnerBoxGrid:Reposition()
		self.m_PartnerBoxScroll:ResetPosition()
	end
end

function CPartnerListNodeBox.RefreshSpecialBox(self, partnerID)
	local partnerInfo = self.m_PartnerInfoList[self.m_RecordBoxIndex]
	local partnerBoxList = self.m_PartnerBoxGrid:GetChildList()
	if partnerInfo.id == partnerID then
		if partnerBoxList[self.m_RecordBoxIndex] then
			partnerBoxList[self.m_RecordBoxIndex]:SetPartnerBox(partnerInfo)
		end
		return
	end
	for i,v in ipairs(self.m_PartnerInfoList) do
		if v.id == partnerID then
			if partnerBoxList[i] then
				partnerBoxList[i]:SetPartnerBox(v)
			end
			return
		end
	end
end

function CPartnerListNodeBox.SelectSpecialPartnerBox(self, partnerID, bIsExcute)
	if bIsExcute == nil then
		bIsExcute = true
	end
	partnerID = partnerID or self:GetCurPartnerInfo().id
	for i,v in ipairs(self.m_PartnerInfoList) do
		if partnerID == v.id then
			if self.m_RecordBoxIndex ~= i then
				if self.m_RecordBoxIndex then
					self.m_PartnerBoxGrid:GetChild(self.m_RecordBoxIndex):ForceSelected(false)
				end
				self.m_RecordBoxIndex = i
				self.m_PartnerBoxGrid:GetChild(self.m_RecordBoxIndex):SetSelected(true)
				-- if self.m_Callback then
				-- 	self.m_Callback()
				-- end
				if bIsExcute then
					self:Excute(i)

					local tMolecule = i - 1
					local tDenominator = #self.m_PartnerInfoList - 5.9
					local tScallBarFloat = (tMolecule - 5.9) > 0 and ((tMolecule-2) > tDenominator and 1 or (tMolecule-2) / tDenominator) or 0
					self.m_PartnerBoxScroll.m_UIScrollView:SetDragAmount(0, tScallBarFloat, false)
					self.m_PartnerBoxScroll.m_UIScrollView:SetDragAmount(0, tScallBarFloat, true)
				end
			end
			break
		end
	end
end

function CPartnerListNodeBox.GetCurPartnerInfo(self)
	if self.m_RecordBoxIndex then
		return self.m_PartnerInfoList[self.m_RecordBoxIndex]
	end
end

function CPartnerListNodeBox.Excute(self, iIndex)
	for k,cb in ipairs(self.m_CallbackList) do
		if cb then
			cb(iIndex)
		end
	end
end

function CPartnerListNodeBox.ShowLineupFlag(self, bIsShow, iLineup)
	local partnerBoxList = self.m_PartnerBoxGrid:GetChildList()

	for index,oBox in ipairs(partnerBoxList) do
		local cInfo = self.m_PartnerInfoList[index]
		local sData = g_PartnerCtrl:GetRecruitPartnerDataByID(cInfo.id)
		oBox:ShowLineupSprite(false)
		if sData and not g_PartnerCtrl:IsInLineup(sData.id, iLineup) then
			oBox:ShowLineupSprite(bIsShow)
		end
	end
end

function CPartnerListNodeBox.FiterLineupPartner(self, bIsFiter, iLineup)
	local partnerBoxList = self.m_PartnerBoxGrid:GetChildList()
	for index,oBox in ipairs(partnerBoxList) do
		local cInfo = self.m_PartnerInfoList[index]
		local sData = g_PartnerCtrl:GetRecruitPartnerDataByID(cInfo.id)
		if sData then
			oBox:FiterLineupPartner(false)
			if bIsFiter and g_PartnerCtrl:IsInLineup(sData.id, iLineup) then
				oBox:FiterLineupPartner(bIsFiter)
			end
		end
	end
end

return CPartnerListNodeBox