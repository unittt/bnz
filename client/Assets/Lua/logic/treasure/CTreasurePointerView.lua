local CTreasurePointerView = class("CTreasurePointerView", CViewBase)

function CTreasurePointerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasurePointerView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "ClickOut"
end

function CTreasurePointerView.OnCreateView(self)
	self.m_TipWidget = self:NewUI(1, CWidget)
	self.m_PointerSp = self:NewUI(2, CWidget)
	self:InitContent()
end

--初始化执行
function CTreasurePointerView.InitContent(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil			
	end
	local function progress()
		self:OnClose()
		if self.m_Timer then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil			
		end
		return false
	end
	self.m_Timer = Utils.AddTimer(progress, 0, 2)
end

--设置宝图指针旋转
function CTreasurePointerView.SetPointerRotate(self, startPos, endPos, pos, callback_sessionidx)
	local iDegress = self:GetDegress(startPos, endPos)
	-- printc("宝图指针旋转", "startPos:", startPos.x, startPos.y, "endPos:", endPos.x, endPos.y, "iDegress:", iDegress)
	local tween = DOTween.DORotate(self.m_PointerSp.m_Transform, Vector3.New(0, 0, iDegress + 360*2), 1, 1)
	local function onEnd()
		-- g_NotifyCtrl:FloatMsg("发现宝藏,正在前往宝藏位置 "..g_MapCtrl:GetSceneName().."("..math.floor(pos.x/1000)..","..math.floor(pos.y/1000)..")")
		g_MapTouchCtrl:WalkToPos(netscene.DecodePos(pos), nil, define.Walker.Npc_Talk_Distance,callback(g_TreasureShowCtrl,"OnPositionCallback",callback_sessionidx))
	end
	DOTween.OnComplete(tween, onEnd)
end

--获取指针旋转的角度
function CTreasurePointerView.GetDegress(self, startPos, endPos)
	local xDelta = endPos.x - startPos.x
	local yDelta = endPos.y - startPos.y
	local iDegress
	if xDelta > 0 and yDelta > 0 then
		iDegress = -(90 - math.deg(math.atan(math.abs(yDelta/xDelta))))
	elseif xDelta > 0 and yDelta == 0 then
		iDegress = -90
	elseif xDelta > 0 and yDelta < 0 then
		iDegress = -(90 + math.deg(math.atan(math.abs(yDelta/xDelta))))
	elseif xDelta == 0 and yDelta > 0 then
		iDegress = 0
	elseif xDelta == 0 and yDelta == 0 then
		iDegress = 0
	elseif xDelta == 0 and yDelta < 0 then
		iDegress = 180
	elseif xDelta < 0 and yDelta > 0 then
		iDegress = 90 - math.deg(math.atan(math.abs(yDelta/xDelta)))
	elseif xDelta < 0 and yDelta == 0 then
		iDegress = 90
	elseif xDelta < 0 and yDelta < 0 then
		iDegress = 90 + math.deg(math.atan(math.abs(yDelta/xDelta)))
	end
	return iDegress
end

return CTreasurePointerView