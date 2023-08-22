local CSchoolMatchBattleBox = class("CSchoolMatchBattleBox", CBox)

function CSchoolMatchBattleBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_PlayerBoxs = {
		["Left"] = {
			ActorTexture = self:NewUI(1, CActorTexture),
			NameL = self:NewUI(2, CLabel),
		},
		["Right"] = {
			ActorTexture = self:NewUI(3, CActorTexture),
			NameL = self:NewUI(4, CLabel),
		}
	}
	self.m_StepLabel = self:NewUI(5, CLabel)

	self.m_StepText = {
		[16] = "八强",
		[8] = "四强",
		[4] = "半决赛",
		[2] = "季军",
		[1] = "冠军"
	}
end

function CSchoolMatchBattleBox.SetBatteData(self, dBattle)
	self.m_BattleData = dBattle
	self:RefreshAll()
end

function CSchoolMatchBattleBox.RefreshAll(self)
	local iCurStep = g_SchoolMatchCtrl:GetMatchStep()
	if iCurStep == 2 then
		if self.m_BattleData.jijun == 1 then
			self.m_StepLabel:SetText(self.m_StepText[2])
		else
			self.m_StepLabel:SetText(self.m_StepText[1])
		end
	else
		self.m_StepLabel:SetText(self.m_StepText[iCurStep])
	end
	self:RefreshPlayerBox(self.m_PlayerBoxs["Left"], self.m_BattleData.fighter1)
	self:RefreshPlayerBox(self.m_PlayerBoxs["Right"], self.m_BattleData.fighter2)
end

function CSchoolMatchBattleBox.RefreshPlayerBox(self, oBox, dInfo)
	table.print(dInfo)
	local bIsEmpty = not dInfo.pid or dInfo.pid == 0 
	printc("bIsEmpty", bIsEmpty)
	oBox.ActorTexture:SetActive(not bIsEmpty)
	oBox.NameL:SetActive(not bIsEmpty)

	if bIsEmpty then
		return
	end

	local dMInfo = table.copy(dInfo.model_info)
	dMInfo.horse = nil
	dMInfo.rotate = Vector3.zero
	oBox.ActorTexture:ChangeShape(dMInfo)
	oBox.NameL:SetText(dInfo.name)
	local bIsLose = self.m_BattleData.win > 1 and self.m_BattleData.win ~= dInfo.pid
	oBox.ActorTexture:SetGrey(bIsLose)
	oBox.ActorTexture:AddUIEvent("click", callback(self, "OnClickBattler", dInfo, self.m_BattleData.win))
end

function CSchoolMatchBattleBox.OnClickBattler(self, dInfo, iWin)
	local iFightTime = g_SchoolMatchCtrl.m_FightTime
	local iTextId = 0
	if iWin and iWin > 1 then
		iTextId = 1027
	elseif iFightTime > 0 then
		iTextId = 1026
	else
		netplayer.C2GSObserverWar(1, 0, dInfo.pid)
		CSchoolMatchBattleListView:CloseView()
		return
	end
	g_NotifyCtrl:FloatMsg(DataTools.GetMiscText(iTextId, "SCHOOLMATCH").content)
end

return CSchoolMatchBattleBox