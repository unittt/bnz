CFormationCtrl = class("CFormationCtrl", CCtrlBase)

function CFormationCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Reset()
end

function CFormationCtrl.Reset(self)
	self.m_CurFmt = 0
	self.m_PlayerList = nil
	self.m_PartnerList = nil
	self.m_LocalPlayerList = {}
	self.m_LocalPartnerList = {}
	self.m_FmtList = {}
	self.m_UnlockFmtSize = 0
	self.m_NeedGuideLearn = false
	self.m_LeftCouldLearnNum = 0
end

function CFormationCtrl.InitUnlockFmtSize(self)
	self.m_UnlockFmtSize = 0
	for _,dInfo in pairs(self.m_FmtList) do
		if dInfo.grade > 0 then
			self.m_UnlockFmtSize = self.m_UnlockFmtSize + 1
		end
	end
end

function CFormationCtrl.GetUnlockFmtSize(self)
	return self.m_UnlockFmtSize
end

function CFormationCtrl.SetAllFormationInfo(self, iCurFmt, tPlayerList, tPartnerList, tFmtList)
	self.m_LocalPlayerList = {}
	self.m_LocalPartnerList = {}

	self.m_PlayerList = tPlayerList
	self.m_PartnerList = tPartnerList
	for k,dInfo in pairs(tFmtList) do
		self.m_FmtList[dInfo.fmt_id] = dInfo
	end
	self:SetCurrentFmt(iCurFmt)
	self:InitUnlockFmtSize()
	self:CheckFormationGuide()
	self:OnEvent(define.Formation.Event.UpdateAllFormation, self.m_CurFmt)
end
 
function CFormationCtrl.UpdateFormationInfo(self, dFmtInfo)
	self.m_FmtList[dFmtInfo.fmt_id] = dFmtInfo
	self:InitUnlockFmtSize()
	self:CheckFormationGuide()
	self:OnEvent(define.Formation.Event.UpdateFormationInfo)
end

function CFormationCtrl.UpdatePosList(self, iCurFmt, tPlayerList, tPartnerList)
	if #tPlayerList ~= 0 then
		self.m_PlayerList = tPlayerList
	end
	if #tPartnerList ~= 0 then
		self.m_PartnerList = tPartnerList
	end
	self:SetCurrentFmt(iCurFmt)
	self:OnEvent(define.Formation.Event.UpdatePosList)
end

function CFormationCtrl.SetCurrentFmt(self, iCurFmt)
	if self.m_CurFmt ~= 0 and self.m_CurFmt ~= iCurFmt then
		self.m_CurFmt = iCurFmt
		self:OnEvent(define.Formation.Event.SetCurrentFormation)
	end
	self.m_CurFmt = iCurFmt
end

function CFormationCtrl.GetCurrentFmt(self)
	return self.m_CurFmt
end

function CFormationCtrl.SetCurrentPartnerList(self, tPartnerList)
	self.m_PartnerList = {}
	for i,pid in ipairs(tPartnerList) do
		table.insert(self.m_PartnerList, pid)
	end
end

function CFormationCtrl.GetCurrentPartnerList(self)
	local list = {}
	if self.m_PartnerList then
		for i,v in ipairs(self.m_PartnerList) do
			table.insert(list, v)
		end
	end
	return list
end

function CFormationCtrl.GetCurrentPlayerList(self)
	local list = {}
	if self.m_PlayerList then
		for i,v in ipairs(self.m_PlayerList) do
			table.insert(list, v)
		end
	end
	return list
end

function CFormationCtrl.GetPlayerListByFmtID(self, iFmtId)
	local sourceList = {}
	if iFmtId == self.m_CurFmt then
		sourceList = self.m_PlayerList
	else		
		sourceList = self.m_LocalPlayerList[iFmtId]
	end
	if not sourceList then
		return nil
	end
	local result = {}
	for i,v in ipairs(sourceList) do
		table.insert(result, sourceList[i])
	end
	return result 
end

function CFormationCtrl.GetPartnerListByFmtID(self, iFmtId)
	local sourceList = {}
	if iFmtId == self.m_CurFmt then
		sourceList = self.m_PartnerList
	else		
		sourceList = self.m_LocalPartnerList[iFmtId]
	end
	if not sourceList then
		return nil
	end
	local result = {}
	for i,v in ipairs(sourceList) do
		table.insert(result, sourceList[i])
	end
	return result 
end

function CFormationCtrl.GetFormationInfoByFmtID(self, iFmtId)
	local dInfo = self.m_FmtList[iFmtId]
	if not dInfo then
		dInfo = {
			fmt_id = iFmtId,
			exp = 0,
			grade = 0,
		}
	end
	return dInfo
end

function CFormationCtrl.GetAllFormationInfo(self)
	return self.m_FmtList
end

function CFormationCtrl.IsInUse(self, iFmtId)
	return self.m_CurFmt == iFmtId
end

function CFormationCtrl.GetFormationStatus(self, iFmtId)
	local iStatus = -1
	-- if self.m_CurFmt == iFmtId then
	-- 	return define.Formation.Status.InUse
	-- end
	if iFmtId == 1 then
		return define.Formation.Status.None
	end
	local dFmtInfo = self.m_FmtList[iFmtId]
	local dItemInfo = DataTools.GetFormationItemExpData(iFmtId)
	local bHasLearnItem = false
	if dItemInfo then
		local iItemCount = g_ItemCtrl:GetBagItemAmountBySid(dItemInfo.itemid)
		bHasLearnItem = iItemCount > 0
	end
	local bCanUpgrade = false
	for itemid,v in pairs(data.formationdata.ITEMINFO) do
		local iItemCount = g_ItemCtrl:GetBagItemAmountBySid(itemid)
		if iItemCount > 0 then
			bCanUpgrade = true 
			break
		end
	end
	local iMaxUnlockSize = DataTools.GetFormationUnlockSizeByGrade(g_AttrCtrl.grade)
	local dBaseInfo = data.formationdata.BASEINFO[iFmtId]
	local iMaxGrade = #dBaseInfo.exp
	if dFmtInfo and dFmtInfo.grade > 0 then
		if iMaxGrade == dFmtInfo.grade then
			return define.Formation.Status.None
		elseif bCanUpgrade then
			return define.Formation.Status.UpgradeAllow
		end
	else 
		if iMaxUnlockSize == self.m_UnlockFmtSize then
			return define.Formation.Status.UnableLearn
		elseif bHasLearnItem then
			return define.Formation.Status.LearnAllow
		else
			return define.Formation.Status.NotLearn
		end
	end
end

function CFormationCtrl.SetLocalPosList(self, iFmtId, tPlayerList, tPartnerList)
	self.m_LocalPlayerList[iFmtId] = tPlayerList
	self.m_LocalPartnerList[iFmtId] = tPartnerList
end

function CFormationCtrl.ClearLocalPosList(self)
	self.m_LocalPlayerList = {}
	self.m_LocalPartnerList = {}
end

function CFormationCtrl.UpdatePosStatus(self, tPosList, tPlayerList)
 	local lPlayerList = tPlayerList or self.m_PlayerList
	if not lPlayerList then
		return
	end
	local dAddStatus = {}
	for k,iPid in ipairs(tPosList) do
		dAddStatus[k] = g_TeamCtrl:IsInTeam(iPid)
	end
	local tExistStatus = {}
	local iLastIndex = -1
	for i = #lPlayerList, 1, -1 do
		local pid = lPlayerList[i]
		local bIsExist = false
		for k,iPid in ipairs(tPosList) do
			if g_TeamCtrl:IsInTeam(iPid) and pid == iPid then
				bIsExist = true
				dAddStatus[k] = false
			end
		end
		if not bIsExist then
			self:DelLocalPos(pid)
			table.remove(lPlayerList, i)
		end
	end
	if iLastIndex == -1 then
		iLastIndex = #lPlayerList + 1
	end
	for i,bIsAdd in ipairs(dAddStatus) do
		if bIsAdd then
			table.insert(lPlayerList, iLastIndex, tPosList[i])
			self:AddLocalPos(tPosList[i])
			iLastIndex = iLastIndex + 1
		end
	end
	self:OnEvent(define.Formation.Event.UpdatePosList)
end

function CFormationCtrl.DelLocalPos(self, iPid)
	for _,list in pairs(self.m_LocalPlayerList) do
		for i,pid in ipairs(list) do
			if iPid == pid then
				table.remove(list, i)
				break
			end 
		end
	end
end

function CFormationCtrl.AddLocalPos(self, iPid)
	for _,list in pairs(self.m_LocalPlayerList) do
		table.insert(list, iPid)
	end
end

function CFormationCtrl.GetFmtMutexInfo(self, dData)
	local result = {}
	for k,v in pairs(dData.mutex) do
		if v ~= 0 then
			if not result[v] then
				result[v] = {}
			end
			table.insert(result[v], k)
		end
	end
	local t = {}
	for k,v in pairs(result) do
		table.insert(t,{value = k, list = v})
	end
	local function sort(data1, data2)
		return math.abs(data1.value) > math.abs(data2.value)
	end
	table.sort(t, sort)
	return t
end 

function CFormationCtrl.CheckFormationGuide(self)
	self.m_NeedGuideLearn = table.count(self.m_FmtList) == 1 and g_ItemCtrl:IsContainFormationItem()
	self:OnEvent(define.Formation.Event.RefreshGuildStatus) 
end

return CFormationCtrl