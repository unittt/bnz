local CSoccerWorldCupCtrl = class("CSoccerWorldCupCtrl", CCtrlBase)


function CSoccerWorldCupCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_State = 2   			--1 活动开启阶段 2 活动结束
end

function CSoccerWorldCupCtrl.ClearAll(self)
	self.m_State = 2
end

function CSoccerWorldCupCtrl.IsOpening(self)
	if self.m_State == 1 then
		return true
	else
		return false
	end
end


function CSoccerWorldCupCtrl.CheckRedPoint(self)
	return false
end

function CSoccerWorldCupCtrl.OnShowWorldCupMainView(self)
	CSoccerWorldCupMainView:ShowView(function (oView)
		oView:RefreshUI()
	end)
end

function CSoccerWorldCupCtrl.GS2CWorldCupState(self, pbdata)
	self.m_State = pbdata.state
	printc("CSoccerWorldCupCtrl:GS2CWorldCupState self.m_State:", self.m_State)
end

return CSoccerWorldCupCtrl