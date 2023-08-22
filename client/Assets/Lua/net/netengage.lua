module(..., package.seeall)

--GS2C--

function GS2CEngageCondition(pbdata)
	local members = pbdata.members
	local type = pbdata.type
	local status = pbdata.status --0 没开始 1 开始 2　确认
	--todo
	g_EngageCtrl:SetEngageCondition(members, type, status)
end

function GS2CStartEngageResult(pbdata)
	--todo
	g_EngageCtrl:OnEvent(define.Engage.Event.EngageStart)
end

function GS2CCancelEngage(pbdata)
	--todo
	g_EngageCtrl:OnEngageFail()
end

function GS2CSetEngageTextUI(pbdata)
	--todo
	CEngageDeclarationView:ShowView()

	if g_EngageCtrl.m_IsCannotMove == false then
		g_EngageCtrl.m_IsCannotMove = true
	end
	if g_EngageCtrl.m_EngageStatus == false then
		g_EngageCtrl.m_EngageStatus = true
	end

end

function GS2CSetEngageTextRusult(pbdata)
	--todo
	g_EngageCtrl:OnEngageTextRusult()
end

function GS2CEngageSuccess(pbdata)
	local type = pbdata.type
	--todo
	g_EngageCtrl:ShowEngageSuccess()
end

function GS2CEngageOperate(pbdata)
	local type = pbdata.type --0 取消订婚 1 订婚
	--todo
	if type == 1 then
		g_EngageCtrl:ShowEngageGiftView()
	else
		CDissolveEngageView:ShowView()
	end
end


--C2GS--

function C2GSEngageCondition(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("engage", "C2GSEngageCondition", t)
end

function C2GSStartEngage(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("engage", "C2GSStartEngage", t)
end

function C2GSConfirmEngage(agree)
	local t = {
		agree = agree,
	}
	g_NetCtrl:Send("engage", "C2GSConfirmEngage", t)
end

function C2GSSetEngageText(text)
	local t = {
		text = text,
	}
	g_NetCtrl:Send("engage", "C2GSSetEngageText", t)
end

function C2GSDissolveEngage()
	local t = {
	}
	g_NetCtrl:Send("engage", "C2GSDissolveEngage", t)
end

function C2GSCancelEngage()
	local t = {
	}
	g_NetCtrl:Send("engage", "C2GSCancelEngage", t)
end

