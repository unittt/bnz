local CWarTouchCtrl = class("CWarTouchCtrl")

function CWarTouchCtrl.ctor(self)
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("War")
	self.m_SwipeRange = nil
	self.m_IsLock = false
	self.m_IsPathMove = true
	self.m_LockInfo = nil
	self.m_LastPopWarriorRef = nil
	self.m_TouchWidList = nil

	self.m_PressTimer = nil
	self.m_Pressed = nil
end

function CWarTouchCtrl.InitSwipeRange(self)
	if not self.m_SwipeRange then
		self.m_SwipeRange = {
			min_y = g_CameraCtrl:GetCameraInfo("war", "swipe_vmin").pos.y,
			max_y = g_CameraCtrl:GetCameraInfo("war", "swipe_vmax").pos.y,
		}
	end
end

function CWarTouchCtrl.OnTouchDown(self, touchPos)
	if not g_WarCtrl:IsWar() then
		return
	end
	self.m_Pressed = false
	-- g_AudioCtrl:PlaySound(define.Audio.SoundPath.Btn)

	if self.m_PressTimer then
		Utils.DelTimer(self.m_PressTimer)
	end
	self.m_PressTimer = Utils.AddTimer(callback(self, "OnPressEvent"), 0.5, 0.2)
	local oWarrior = self:GetTouchWarrior(touchPos.x, touchPos.y)
	if oWarrior then
		g_AudioCtrl:PlaySound(define.Audio.SoundPath.Btn)
		self.m_LastPopWarriorRef = weakref(oWarrior)
	end
end

function CWarTouchCtrl.OnPressEvent(self)
	local oPopWarrior
	if self.m_LastPopWarriorRef then
		oPopWarrior = getrefobj(self.m_LastPopWarriorRef)
	end
	if oPopWarrior then
		if not self.m_Pressed then
			oPopWarrior:AddBindObj("warrior_longpress")
		else
			CWarTargetDetailView:ShowView(function(oView)
				oView:SetWarrior(oPopWarrior)
			end)
		end
	end
	if not self.m_Pressed then
		self.m_Pressed = true
		return true
	end
	if self.m_PressTimer then
		Utils.DelTimer(self.m_PressTimer)
	end
	return false
end

--{[1]=gameobj, [2]=point,...}
function CWarTouchCtrl.OnTouchUp(self, touchPos)
	if not g_WarCtrl:IsWar() then
		return
	end
	if self.m_LastPopWarriorRef then
		local oPopWarrior = getrefobj(self.m_LastPopWarriorRef)
		if oPopWarrior then
			if self.m_Pressed then
				oPopWarrior:DelayCall(0.3, "DelBindObj", "warrior_longpress")
			else
				if oPopWarrior:IsOrderTarget() then
					g_WarOrderCtrl:SetTargetID(oPopWarrior.m_ID)
				elseif oPopWarrior:IsAlly() then
					g_WarOrderCtrl:SetCurOrderWid(oPopWarrior.m_ID)
				end
			end
		end
		self.m_LastPopWarriorRef = nil
	elseif self.m_TouchWidList then
		g_NotifyCtrl:FloatWarriorList(self.m_TouchWidList)
		self.m_TouchWidList = nil
	end
	self.m_Pressed = false
	if self.m_PressTimer then
		Utils.DelTimer(self.m_PressTimer)
	end
	-- local oWarrior = self:GetTouchWarrior(touchPos.x, touchPos.y)
	-- if oWarrior then
	-- 	-- if g_WarCtrl:IsAutoWar() and not oWarrior:IsAlly() then
	-- 	-- 	if not g_TeamCtrl:IsInTeam() or g_TeamCtrl:IsLeader() then
	-- 	-- 		local iJiHuo = oWarrior:IsJiHuo() and 0 or 1
	-- 	-- 		netwar.C2GSWarTarget(g_WarCtrl:GetWarID(), oWarrior.m_ID, iJiHuo)
	-- 	-- 	end
	-- 	-- else
	-- 	if oWarrior:IsOrderTarget() then
	-- 		g_WarOrderCtrl:SetTargetID(oWarrior.m_ID)
	-- 	elseif oWarrior:IsAlly() then
	-- 		g_WarOrderCtrl:SetCurOrderWid(oWarrior.m_ID)
	-- 	end
	-- end
end

function CWarTouchCtrl.OnLongTabStart(self, touchPos)
	if not g_WarCtrl:IsWar() then
		return
	end
end

function CWarTouchCtrl.SetLock(self, bLock)
	local oCam = g_CameraCtrl:GetWarCamera()
	if bLock then
		self.m_LockInfo = {pos=oCam:GetLocalPos(), rotate=oCam:GetLocalEulerAngles()}
	else
		if self.m_LockInfo then
			oCam:SetPos(self.m_LockInfo.pos)
			oCam:SetLocalEulerAngles(self.m_LockInfo.rotate)
			self.m_LockInfo = nil
		end
	end
	self.m_IsLock = bLock
end

function CWarTouchCtrl.IsLock(self)
	if not g_WarCtrl:IsWar() or 
		-- g_WarCtrl:IsPrepare() or 
		-- g_WarCtrl:IsReplace() or 
		self.m_IsLock then
		return true
	else
		return false
	end
end

function CWarTouchCtrl.IsPressing(self)
	return self.m_Pressed
end

function CWarTouchCtrl.GetTouchWarrior(self, x, y)
	if self.m_TouchWidList then
		self.m_TouchWidList = nil
	end
	local lTouch = C_api.EasyTouchHandler.SelectMultiple(g_CameraCtrl:GetWarCamera().m_Camera, x, y, self.m_LayerMask)
	if not lTouch or #lTouch == 0 then
		return
	end
	local bFirst = g_WarCtrl.m_IsFirstSpecityWar
	local iCnt = #lTouch/2
	if iCnt == 1 then
		local go = lTouch[1]
		local oWarrior = g_WarCtrl.m_InstanceID2Warrior[go:GetInstanceID()]
		if oWarrior then
			if oWarrior:GetTouchEnabled() then
				return oWarrior
			else
				printc("不可点击", oWarrior:GetName())
			end
		end
	else
		local iValid = 0
		local widList = {}
		local oWarrior
		for i=1, iCnt do
			-- local go, point = lTouch[i*2-1], lTouch[i*2]
			local go = lTouch[i*2-1]
			local o = g_WarCtrl.m_InstanceID2Warrior[go:GetInstanceID()]
			if o then
				if o:GetTouchEnabled() then
					if bFirst or o:IsOrderTarget() then
						iValid = iValid + 1
						table.insert(widList, o.m_ID)
					end
					oWarrior = o
				else
					printc("不可点击", o:GetName())
				end
			end
		end
		if iValid > 1 then
			self.m_TouchWidList = widList
		elseif iValid == 1 then
			return g_WarCtrl:GetWarrior(widList[1])
		elseif oWarrior then
			return oWarrior
		end
	end
end

function CWarTouchCtrl.SetPathMove(self, b)
	self.m_IsPathMove = b
end

function CWarTouchCtrl.OnSwipe(self, swipePos)
	do return end
	if self:IsLock() then
		return
	end
	if self.m_IsPathMove then
		local iVal = g_CameraCtrl:GetAnimatorPercent()
		iVal = iVal + (-swipePos.x/500)
		g_CameraCtrl:SetAnimatorPercent(iVal)
	else
		local oCam = g_CameraCtrl:GetWarCamera()
		local vPos = DataTools.GetLineupPos("Center")
		local oRoot = g_WarCtrl:GetRoot()
		vPos = oRoot:TransformPoint(vPos)
		if math.abs(swipePos.x) > math.abs(swipePos.y) then
			oCam:RotateAround(vPos, Vector3.up, swipePos.x/5)
		else
			self:InitSwipeRange()
			local oriPos = oCam:GetLocalPos()
			local oriRotation = oCam:GetRotation()
			oCam:RotateAround(vPos, oCam:GetRight(), -swipePos.y/10)
			-- local pos = oCam:GetLocalPos()
			-- if pos.y < self.m_SwipeRange.min_y or pos.y > self.m_SwipeRange.max_y then
			-- 	oCam:SetLocalPos(oriPos)
			-- 	oCam:SetRotation(oriRotation)
			-- end
		end
	end
end

return CWarTouchCtrl