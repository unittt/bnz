module(..., package.seeall)
g_TimeStart= {}
function Print(...)
	printc(...)
end

function CreateWarrior(type, camp_id, info)
	-- printc("############### 单位创建", g_TimeCtrl:GetTimeMS(), g_TimeCtrl:GetTimeS())
	local oWarrior = CWarrior.New(info.wid)
	oWarrior.m_Pid = info.pid
	oWarrior.m_OwnerWid = info.owner
	oWarrior.m_CampID = camp_id
	oWarrior.m_CampPos = info.pos
	oWarrior.m_Type = type
	oWarrior.m_SummonID = info.sum_id
	oWarrior.m_SpecialId = info.specail_id
	oWarrior.m_MagicList = {}
	oWarrior.m_PfCd = {}
	-- pflist: repeated {pf_id, cd}
	if info.pflist then
		for _, pf in ipairs(info.pflist) do
			table.insert(oWarrior.m_MagicList, pf.pf_id)
			oWarrior.m_PfCd[pf.pf_id] = pf.cd
		end
	end
	oWarrior.m_IsAppoint = info.appoint == 1
    oWarrior.m_IsAppointTop = info.appointop == 1
	table.sort(oWarrior.m_MagicList)
	oWarrior:ChangeShape(info.status.model_info)
	oWarrior:SetStatus(info.status)
	oWarrior:SetStatusBuff(info.status_list)
	oWarrior:SetName(info.status.name or "nil" .. "_wid:" .. tostring(info.status.wid))
	-- 重登buff
	if info.buff_list and #info.buff_list > 0 then
		for i,v in ipairs(info.buff_list) do
			oWarrior:RefreshBuff(v.buff_id, v.bout, 1, false, v.attrlist)
		end
	end
	if info.status.status then
		oWarrior:SetAlive(info.status.status == define.War.Status.Alive)
	end
	g_WarOrderCtrl:ShowWarriorSelectTarget(oWarrior)
	return oWarrior
end

function GetWorldDir(stratPos, endPos)
	local dir = (endPos - stratPos).normalized
	local oRoot = g_WarCtrl:GetRoot()
	return oRoot:TransformDirection(dir)
end

function SetWarPos(obj, x, z, depth)
	local oCam = g_CameraCtrl:GetWarCamera()
	local offset = obj:InverseTransformDirection(oCam.m_Transform.forward) * depth * -1
	local pos = Vector3.New(x, 0, z) + offset
	obj:SetLocalPos(pos)
end

function GetHorizontalDis(pos1, pos2)
	return math.sqrt((pos1.x - pos2.x)^2 + (pos1.z - pos2.z)^2)
end

function CheckInDistance(pos1, pos2, max)
	return ((pos1.x-pos2.x)^2+(pos1.z - pos2.z)^2) <= max^2
end

function WarToUIPos(warpos)
	local oWarCam = g_CameraCtrl:GetWarCamera()
	local oUICam = g_CameraCtrl:GetUICamera()
	local viewPos = oWarCam:WorldToViewportPoint(warpos)
	viewPos.x = viewPos.x * oWarCam.m_Camera.rect.size.x + oWarCam.m_Camera.rect.position.x
	viewPos.y = viewPos.y * oWarCam.m_Camera.rect.size.y + oWarCam.m_Camera.rect.position.y
	local oUIPos = oUICam:ViewportToWorldPoint(viewPos)
	oUIPos.z = 0
	return oUIPos
end

function WarToViewportPos(warpos)
	local oWarCam = g_CameraCtrl:GetWarCamera()
	local viewPos = oWarCam:WorldToViewportPoint(warpos)
	viewPos.x = viewPos.x * oWarCam.m_Camera.rect.size.x + oWarCam.m_Camera.rect.position.x
	viewPos.y = viewPos.y * oWarCam.m_Camera.rect.size.y + oWarCam.m_Camera.rect.position.y
	return viewPos
end

function GetAttackPos(atkObj, vicObj)
	if not(atkObj and vicObj) then
		return Vector3.zero
	end
	local atkpos = atkObj:GetLocalPos()
	local vicpos = vicObj:GetLocalPos()
	local dis = GetHorizontalDis(atkpos, vicpos)
	if dis > define.War.Atk_Distance then
		local rate = (dis - define.War.Atk_Distance) / dis
		local v = Vector3.Lerp(atkpos, vicpos, rate)
		return v
	end
	return atkpos
end

function GetQuickInsertActionFunc(list)
	local function f(func, ...)
		local action = g_WarCtrl:CreateAction(func, ...)
		table.insert(list, action)
	end
	return f
end

function GetMainInsertActionFunc()
	local function f(func, ...)
		g_WarCtrl:InsertAction(func, ...)
	end
	return f
end

function TimeStart(typename)
	g_WarCtrl:InsertAction(function()
		g_TimeStart[typename] = g_TimeCtrl:GetTimeMS()
	end)
end

function TimeEnd(typename)
	g_WarCtrl:InsertAction(function()
		local iStart = g_TimeStart[typename]
		if iStart then
			print(string.format("<color=Lime> >>> %s执行耗时:%d  </color>", typename, g_TimeCtrl:GetTimeMS()-iStart))
		end
	end)
end

function OutViewPortPos(pos, dir, iTime)
	local oCam = g_CameraCtrl:GetWarCamera()
	v = oCam:WorldToViewportPoint(pos)
	local iMax = 1.1
	local iMin = -0.1
	local iSafeFlag = 200
	while (v.x >= iMin and v.x <= iMax and v.y >= iMin and v.y <=iMax) and iSafeFlag > 0 do
		pos = pos + dir
		v = oCam:WorldToViewportPoint(pos)
		iSafeFlag = iSafeFlag - 1
	end
	return pos
end

function GetWarriorByCampPos(bAlly, iCmapPos)
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if oWarrior:IsAlly() == bAlly then
			if oWarrior.m_CampPos == iCmapPos then
				return oWarrior
			end
		end
	end
end

