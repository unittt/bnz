module(..., package.seeall)

g_StateToHash = {}
g_HashToState = {}
g_FrameDelta = 1/30

function GetModelConfig(figure)
	local t = data.modeldata.CONFIG[figure]
	if not t then
		t = data.modeldata.CONFIG[0]
		if not t or t.model == 0 then
			printerror("警告：策划造型表数据错误，默认模型ID不能为0")
			t = data.modeldata.CONFIG[define.Model.Defalut_Shape]
		end
		if not t or t.model == 0 then
			t = {model=1110,posy=-0.9,scale=1000}
		end
	end
	return t
end

function GetModelHudInfo(shape)
	local info = data.hudoffsetdata.DATA[shape]
	if not info then
		printc("警告：策划HUD模型配置表未找到，使用默认1110模型配置，未配置的模型ID：", shape, "导表地址：https://nsvn.cilugame.com/H7/doc/trunk/daobiao/excel/system/role/hudoffset.xlsx")
		info = data.hudoffsetdata.DATA[1110]
	end
	return info
end

function StateToHash(sState)
	local iHash = g_StateToHash[sState]
	if not iHash then
		local sHashStr = string.format("BaseLayer.%s", sState)
		iHash = UnityEngine.Animator.StringToHash(sHashStr)
		g_StateToHash[sState] = iHash
		g_HashToState[iHash] = sState
	end
	return iHash
end

function HashToState(iHash)
	return g_HashToState[iHash]
end

function FrameToTime(iFrame)
	return iFrame * g_FrameDelta
end

function TimeToFrame(iTime)
	return math.max(0, math.floor(iTime/g_FrameDelta + 0.5))
end

function IsCommonState(sState)
	return table.index(define.Model.COMMON_STATE, sState) ~= nil
end

function GetAllState(iShape)
	local list = table.copy(define.Model.COMMON_STATE)
	
	local dExtra = datauser.comboactdata.DATA[iShape]
	if iShape and dExtra then
		for k, v in pairs(dExtra) do
			table.insert(list, 1, k)
		end
	end
	return list
end

function GetOriShape(shape)
	local oriShape = shape
	for k, v in pairs(data.ransedata.SZBASIC) do
		for j, i in pairs(v.szlist) do
			local config = data.ransedata.SHIZHUANG[i]
			if config then
				if config.model == shape then
					oriShape = v.shape
					break
				end
			end
		end
	end
	return oriShape
end

function GetAllModelShape()
	local list = {}
	if Utils.IsEditor() then
		local dirs = System.IO.Directory.GetDirectories(IOTools.GetAssetPath("/GameRes/Model/Character/"))
		for i=0, dirs.Length-1 do
			local iShape = tonumber(System.IO.Path.GetFileName(dirs[i]))
			table.insert(list, iShape)
		end
		table.sort(list)
	else
		list = table.keys(data.modeldata.CONFIG)
		table.sort(list)
	end

	return list
end

function GetAllWeaponShape()
	local list = {}
	if Utils.IsEditor() then
		local dirs = System.IO.Directory.GetDirectories(IOTools.GetAssetPath("/GameRes/Model/Weapon/"))
		for i=0, dirs.Length-1 do
			local iShape = tonumber(System.IO.Path.GetFileName(dirs[i]))
			table.insert(list, iShape)
		end
		table.sort(list)
	else
		list = {1110, 1120}
	end
	return list
end

function GetAnimClipInfo(iShape, sState, iAnimatorIdx)
	local tInfo = nil
	local tShape = datauser.animclipdata.DATA[iShape]
	if tShape then
	-- 	iAnimatorIdx = iAnimatorIdx or 1
	-- 	local tAnimator = tShape[iAnimatorIdx]
	-- 	if tAnimator then
	-- 		printc("======== ModelTools.GetAnimClipInfo ========", sState, iAnimatorIdx)
	-- 		sState = iAnimatorIdx > 1 and string.format("%s_%d", sState, iAnimatorIdx) or sState
	-- 		tInfo = tAnimator[sState]
	-- 	end
	
		tInfo = tShape[sState]
	end
	if not tInfo then
		tInfo = {frame=30, length=1}
	end
	return tInfo
end

function GetAnimClipData(shape)
	return datauser.animclipdata.DATA[shape]
end

function NormalizedToFixed(iShape, animatorIdx, sState, normalized)
	local length = GetAnimClipInfo(iShape, sState, animatorIdx).length
	return length * normalized
end

-- N1 Begin
function GetWeaponModelID(iWeaponID)
	local dEquip = DataTools.GetItemData(iWeaponID, "EQUIP")
	if dEquip and dEquip.model ~= 0 then
		return dEquip.model
	end
end

function GetMountList(iShape, iModel)
	local dInfo = data.modeldata.MOUNT[iShape]
	if not dInfo then
		return
	end
	local sKey = GetWeaponKey(iModel)
	local list = dInfo[sKey]
	if not list then
		list = dInfo["Default"]
	end
	return list
end

function GetWeaponKey(iWeapon)
	if 2000 <= iWeapon and iWeapon <= 2099 then
		return "Bow"
	elseif 2100 <= iWeapon and iWeapon <= 2199 then
		return "Sword"
	end
end

function GetAnimatorIdx(iShape, iWeapon)
	local idx = 1
	local dInfo =  data.modeldata.ANIMATOR[iShape]
	if dInfo then
		local sKey = GetWeaponKey(iWeapon)
		if sKey and dInfo[sKey] then
			idx = dInfo[sKey]
		end
	end
	return idx
end
-- N1 End