local COrgAppointOpView = class("COrgAppointOpView", CViewBase)

function COrgAppointOpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgAppointOpView.prefab", cb)
	--界面设置
	--self.m_ExtendClose = "ClickOut"
	-- self.m_BehindStrike = true
end

function COrgAppointOpView.OnCreateView(self)
	self.m_OpTable = self:NewUI(1, CTable)
	self.m_OpBtn = self:NewUI(2, CButton, true, false)
	self.m_Bg = self:NewUI(3, CSprite)

	self.m_OpBtn:SetActive(false)
	self.m_Pid = nil
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function COrgAppointOpView.SetCallback(self, cb)
	self.m_callback = cb
end

function COrgAppointOpView.ShowExpandViewOp(self, player)
	self.m_Pid = player.pid
	self.m_Name = player.name
	self.m_MyPos = g_AttrCtrl.org_pos
	self.m_MemberPos = player.org_pos
	self.m_OpTable:Clear()
	local tData = data.orgdata.POSITIONAUTHORITY[self.m_MyPos]
	local tAppointList = {}
	if self.m_MyPos == 1 then
		table.insert(tAppointList, 1)
	end
	for k,pos in ipairs(tData.authorize_pos) do
		table.insert(tAppointList, pos)
	end
	for _, pos in pairs(tAppointList) do
		local iAmount = g_OrgCtrl:GetMemberAmountByPos(pos)
		local iUpper = DataTools.GetOrgAppointUpper(player.org_level, pos)
		local sPos = data.orgdata.POSITIONID[pos].name
		if iUpper == 1 then
			self:AddOp(sPos, function() self:RequestSetPosition(pos, iUpper) end)
		else
			local sBtnText = string.format("%s[%d/%d]", sPos, iAmount, iUpper)
			self:AddOp(sBtnText, function() self:RequestSetPosition(pos, iUpper) end)
		end
	end

	self:ResizeBg()
end

function COrgAppointOpView.ResizeBg(self)
	self.m_OpTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_OpTable.m_Transform)
	self.m_Bg:SetHeight(bounds.max.y - bounds.min.y + 10)
end

function COrgAppointOpView.AddOp(self, sText, func)
	local oBtn = self.m_OpBtn:Clone(false)
	oBtn:SetActive(true)
	local function wrapclose()
		func()
		if Utils.IsExist(self) then
			COrgAppointOpView:CloseView()
		end
	end
	oBtn:AddUIEvent("click", wrapclose)
	oBtn:SetText(sText)
	self.m_OpTable:AddChild(oBtn)
	return oBtn
end

function COrgAppointOpView.RequestSetPosition(self, iPos, iUpper)
	if iPos < self.m_MyPos then
		g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1057].content)
		return
	end
	if iPos == self.m_MemberPos then
		local sPos = data.orgdata.POSITIONID[iPos].name
		local hint = string.gsub(data.orgdata.TEXT[1049].content, "#position", sPos)
		g_NotifyCtrl:FloatMsg(hint)
		return
	end
	if self.m_MemberPos == 7 and iPos ~= 6 then
		g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1069].content)
		return
	end
	local sMsg = ""
	local sMyPos 	 = data.orgdata.POSITIONID[self.m_MyPos].name 		
	local sMemberPos = data.orgdata.POSITIONID[self.m_MemberPos].name 	
	local sTargetPos = data.orgdata.POSITIONID[iPos].name 				
	if iPos == 1 then
		sMsg = string.gsub(data.orgdata.TEXT[1052].content, "#position", sMyPos)
		sMsg = string.gsub(sMsg, "#role", self.m_Name)
		sMsg = string.gsub(sMsg, "#authorizeposition", sMemberPos)
	elseif self.m_MemberPos > 5 then
		sMsg = string.gsub(data.orgdata.TEXT[1051].content, "#role", self.m_Name)
		sMsg = string.gsub(sMsg, "#position", sMemberPos)
		sMsg = string.gsub(sMsg, "#authorizeposition", sTargetPos)
	else
		sMsg = string.gsub(data.orgdata.TEXT[1053].content, "#role", self.m_Name)
		sMsg = string.gsub(sMsg, "#authorizeposition", sTargetPos)
	end
	local windowConfirmInfo = {
		msg = sMsg,
		okCallback = function()
				netorg.C2GSOrgSetPosition(self.m_Pid, iPos)
				if self.m_callback then
					self.m_callback()
				end
			end,	
		okStr = "确定",
		cancelStr = "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end
return COrgAppointOpView