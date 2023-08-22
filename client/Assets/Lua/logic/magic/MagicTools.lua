module(..., package.seeall)

function GetLocalPosByType(sEnv, sType, oAtk, oVic)
	if sEnv == "war" then
		return WarGetLocalPosByType(sType, oAtk, oVic)
	else
		return Vector3.zero
	end
end

function GetCalcPosObj(obj, oFaceObj, vPrePos)
	g_MagicCtrl.m_CalcPosObject:SetParent(obj.m_Transform, false)
	local pos = obj:GetPos()
	pos.y= 0
	g_MagicCtrl.m_CalcPosObject:SetPos(pos)
	if oFaceObj then
		local vFacePos = oFaceObj:GetPos()
		if vPrePos then
			vFacePos = vPrePos
		end
		vFacePos.y = 0
		g_MagicCtrl.m_CalcPosObject:LookAt(vFacePos, obj:GetUp())
	end
	return g_MagicCtrl.m_CalcPosObject
end

function CalcRelativePos(oRelative, iAngle, iDis)
	if iDis == 0 then
		return Vector3.zero
	else
		local rad = math.rad(iAngle)
		local pos = Vector3.New(math.sin(rad)*iDis, 0, math.cos(rad)*iDis)
		return oRelative:TransformVector(pos) 
	end
end

function CalcDepth(pos, depth)
	local pos = Vector3.New(pos.x, pos.y+depth, pos.z)
	return pos
end

function GetRelativeObj(sType, oAtk, oVic, bFaceDir)
	if sType == "atk" then
		local oFaceObj =  bFaceDir and oVic.m_Actor or nil
		return GetCalcPosObj(oAtk.m_Actor, oFaceObj)
	elseif sType == "vic" then
		local oFaceObj =  bFaceDir and oAtk.m_Actor or nil
		local vPrePos = nil
		if oAtk and oVic then
			vPrePos = oAtk:GetNormalAttackPos(oVic)
		end
		return GetCalcPosObj(oVic.m_Actor, oFaceObj, vPrePos)
	elseif sType == "cam" then
		local oCam = g_CameraCtrl:GetWarCamera()
		return oCam
	elseif sType == "atk_team_center" or sType == "center"then
		local obj = GetCalcPosObj(g_WarCtrl:GetRoot())
		obj:SetLocalEulerAngles(oAtk:GetDefalutRotateAngle())
		return obj
	elseif sType == "vic_team_center" then
		local obj = GetCalcPosObj(g_WarCtrl:GetRoot())
		obj:SetLocalEulerAngles(oVic:GetDefalutRotateAngle())
		return obj
	else
		local oRoot = g_WarCtrl:GetRoot()
		return oRoot
	end
end

function GetCommonPos(sType)
	local xz_pos = {x=0, z=0}
	if sType == "ally_team_center" then
		xz_pos = DataTools.GetLineupPos("A1")
	elseif sType == "enemy_team_center" then
		xz_pos = DataTools.GetLineupPos("B1")
		if g_WarCtrl:IsBossWarType() then
			xz_pos = g_WarCtrl:GetBossLinupPos(1)
		end
	elseif sType == "center" then
		xz_pos = {x=0, z=0}
	end
	return Vector3.New(xz_pos.x, 0, xz_pos.z)
end

function WarGetLocalPosByType(sType, oAtk, oVic)
	local vAllyTeamPos = GetCommonPos("ally_team_center")
	local vEnemyTeamPos = GetCommonPos("enemy_team_center")
	local pos
	if sType == "atk" and oAtk then
		pos = oAtk:GetLocalPos()
		pos.y = 0
	elseif sType == "vic" and oVic then
		pos = oVic:GetLocalPos()
		pos.y = 0
	elseif sType == "atk_lineup" then
		pos = oAtk:GetOriginPos()
	elseif sType == "vic_lineup" then
		pos = oVic:GetOriginPos()
	elseif sType == "atk_team_center" then
		pos = oAtk:IsAlly() and vAllyTeamPos or vEnemyTeamPos
	elseif sType == "vic_team_center" then
		pos = oVic:IsAlly() and vAllyTeamPos or vEnemyTeamPos
	elseif sType == "center" then
		pos = GetCommonPos("center")
	elseif sType == "cam" then
		local oCam = g_CameraCtrl:GetWarCamera()
		pos = oCam:GetPos()
	else
		pos = Vector3.zero
	end
	return pos
end

function GetParentByEnv(sEnv)
	local tranform
	if sEnv == "war" then
		local o = g_WarCtrl:GetRoot()
		if o then
			tranform = o.m_Transform
		end
	end
	return tranform
end

function GetCameraByEnv(sEnv)
	if sEnv == "war" then
		return g_CameraCtrl:GetWarCamera()
	end
end

function GetExcutors(oAtkObj, bAlly, bIncludeSelf)
	local lExcutors = {}
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		local bAllyValid
		if bAlly == nil then
			bAllyValid = true
		else
			if bAlly then
				bAllyValid = oWarrior.m_CampID == oAtkObj.m_CampID
			else
				bAllyValid = oWarrior.m_CampID ~= oAtkObj.m_CampID
			end
		end
		if bAllyValid then
			local bSelfValid = bIncludeSelf and oWarrior.m_ID == oAtkObj.m_ID
			or oWarrior.m_ID ~= oAtkObj.m_ID
			if bSelfValid then
				table.insert(lExcutors, oWarrior)
			end
		end
	end
	return lExcutors
end

function GetDir(obj, type)
	if type == "local_up" then
		if obj.GetLocalUp then
			return obj:GetLocalUp()
		else
			return obj:GetUp()
		end
	elseif type == "local_right" then
		return obj:GetRight()
	elseif type == "local_forward" then
		if obj.GetLocalForward then
			return obj:GetLocalForward()
		else
			return obj:GetForward()
		end
	elseif type == "world_up" then
		return Vector3.up
	elseif type == "world_right" then
		return Vector3.right
	elseif type == "world_forward" then
		return Vector3.forward
	end
end

function GetExcutorDirPos(excutor, sType, vPos)
	local vDirPos
	local oRotateObj = excutor.m_RotateObj or excutor
	if sType == "forward" then
		vDirPos = vPos + oRotateObj:GetForward()
	elseif sType == "backward" then
		vDirPos = vPos + oRotateObj:GetForward() * -1
	elseif sType == "up" then
		vDirPos = vPos + oRotateObj:GetUp()
	elseif sType == "down" then
		vDirPos = vPos + oRotateObj:GetUp() * -1
	elseif sType == "right" then
		vDirPos = vPos + oRotateObj:GetRight()
	elseif sType == "left" then
		vDirPos = vPos + oRotateObj:GetRight() * -1
	end
	return vDirPos
end

function GetExcutorLocalAngle(excutor, sType)
	local oRotateObj = excutor.m_RotateObj or excutor
	local vAngle = oRotateObj:GetLocalEulerAngles()
	if sType == "forward" then
		--todo
	elseif sType == "backward" then
		vAngle.y = vAngle.y + 180
	elseif sType == "right" then
		vAngle.y = vAngle.y + 90
	elseif sType == "left" then
		vAngle.y = vAngle.y - 90
	else
		return
	end
	return vAngle
end

function ReverseCalcPos(sRunEnv, sBasePos, atkObj, vicObj, vEndPos, bFaceDir)
	local vPos = MagicTools.GetLocalPosByType(sRunEnv, sBasePos, atkObj, vicObj)
	bFaceDir = (bFaceDir == nil) and true or bFaceDir
	local oRelative = MagicTools.GetRelativeObj(sBasePos, atkObj, vicObj, bFaceDir)
	local angle, dis, height = 0, 0, 0
	local vRelativePos = oRelative:GetPos()
	if vEndPos ~= vRelativePos then
		height = vEndPos.y - vRelativePos.y
		dis = math.sqrt((vEndPos.x-vRelativePos.x)^2+(vEndPos.z - vRelativePos.z)^2)
		angle = Vector3.Angle(oRelative:GetForward(), Vector3.Normalize(Vector3.New(vEndPos.x, vRelativePos.y, vEndPos.z)-vRelativePos))
		local vLocal = oRelative:InverseTransformPoint(vEndPos)
		if vLocal.x < 0 then 
			angle = 360 - angle
		end
	end
	if dis == 0 or angle == 360 then
		angle = 0
	end
	return math.roundext(angle, 2), math.roundext(dis, 2), math.roundext(height, 2)
end