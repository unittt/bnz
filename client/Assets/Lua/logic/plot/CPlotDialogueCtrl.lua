local CPlotDialogueCtrl = class("CPlotDialogueCtrl")

function CPlotDialogueCtrl.ctor(self, dDialogueInfo, elapsedTime)
	self.m_DialogueInfo = dDialogueInfo
	self.m_ElapsedTime = elapsedTime
	self:Init(dDialogueInfo)
end

function CPlotDialogueCtrl.Init(self, dDialogueInfo)
	local oSequence = DOTween.Sequence()
	self.m_Sequence = oSequence
	--添加剧情结束回调
	local startTime = dDialogueInfo.startTime
	if self.m_ElapsedTime then
		startTime = startTime + self.m_ElapsedTime
	end
	oSequence:AppendInterval(dDialogueInfo.endTime - startTime)
	DOTween.OnComplete(oSequence, callback(self, "Dispose"))

	self:ExcuteDialogueActions(dDialogueInfo.msgActionList)
end

function CPlotDialogueCtrl.ExcuteDialogueActions(self, tActionList)
	for i,oAction in ipairs(tActionList) do
		if oAction.active then
			local waitTime = oAction.startTime
			if self.m_ElapsedTime then
				waitTime = waitTime - self.m_ElapsedTime
			end
			if waitTime > 0 then
				DOTween.InsertCallback(self.m_Sequence, waitTime, callback(self, "PlayDialogueAction", oAction))
			elseif waitTime == 0 then
				self:PlayDialogueAction(oAction)
			end
		end
	end
end

function CPlotDialogueCtrl.PlayDialogueAction(self, oAction)
	CPlotDialogueView:ShowView(function(oView)
		g_PlotCtrl:SendSkipBgEvent(0)
		oView:ExcuteDialogueAction(oAction)
	end)

end

function CPlotDialogueCtrl.Pause(self)
	if self.m_Sequence then
		self.m_Sequence:Pause()
	end
end

function CPlotDialogueCtrl.Resume(self)
	if self.m_Sequence then
		self.m_Sequence:Play()
	end
end

function CPlotDialogueCtrl.Dispose(self)
	if self.m_Sequence then
		self.m_Sequence:Kill(true)	
		self.m_Sequence = nil
	end
	g_PlotCtrl:SendSkipBgEvent(1)
	local oView = CPlotDialogueView:GetView()
	if oView then
		oView:Hide()
	end
end
return CPlotDialogueCtrl