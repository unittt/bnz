local CMainMenuLB = class("CMainMenuLB", CBox)

function CMainMenuLB.ctor(self, obj)
	CBox.ctor(self, obj)

	-- self.m_TeamBox = self:NewUI(1, CBox)
	self.m_ChatBox = self:NewUI(2, CMainMenuChatBox)
	self.m_ExpSlider = self:NewUI(3, CSlider)
	self:InitContent()

end

function CMainMenuLB.InitContent(self)
	self.m_ChatBox:AddUIEvent("click", callback(self, "ShowChat"))	
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))

	self:RefrehExp()
	self:BindMenuArea()
end

function CMainMenuLB.BindMenuArea(self)
	local tweenAlpha = self.m_ChatBox:GetComponent(classtype.TweenAlpha)
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Chat, tweenAlpha)
end

function CMainMenuLB.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		local data = oCtrl.m_EventData
		self:RefrehExp(data.dPreAttr, data.dAttr)
	end
end

function CMainMenuLB.RefrehExp(self, preData, curData)
	-- print("当前角色经验："..g_AttrCtrl:GetCurGradeExp().." 升级经验："..g_AttrCtrl:GetUpgradeExp())
	-- TODO:寫得好長，回頭拆分
	if self.m_ExpTimer then
		Utils.DelTimer(self.m_ExpTimer)
	end
	if not curData or not curData.exp or preData.pid ~= curData.pid then
		self.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())
	else
		if not curData.grade then
			curData.grade = g_AttrCtrl.grade
			preData.grade = g_AttrCtrl.grade
		end
		local iNewGrade = curData.grade
		local iNewExp = curData.exp
		local iCurGrade = preData.grade
		local iCurExp = preData.exp
		local function updateExp()
			if iCurGrade == iNewGrade and math.abs(curData.exp - iCurExp) <= 10 then
				self.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())
				return false
			end
			local iUpgradeExp = 1
			if iNewGrade == iCurGrade then
				iCurExp = iCurExp + math.max((iNewExp - iCurExp)/2, 5)
				iUpgradeExp = data.upgradedata.DATA[iCurGrade + 1].player_exp
			else
				local dData = data.upgradedata.DATA[iCurGrade + 1]
				if math.abs(dData.player_exp - iCurExp) <= 10 then
					iCurGrade = iCurGrade + 1
					iCurExp = 0 
				else
					iCurExp =iCurExp +  math.max((dData.player_exp - iCurExp)/2, 5)
					iUpgradeExp = dData.player_exp
				end
			end
			self.m_ExpSlider:SetValue(iCurExp/iUpgradeExp)
			return true
		end
		self.m_ExpTimer = Utils.AddTimer(updateExp, 0.05, 0)
	end
end

function CMainMenuLB.ShowChat(self)
	CChatMainView:ShowView()
end

return CMainMenuLB