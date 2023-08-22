module(..., package.seeall)
AssetDatabase = UnityEditor.AssetDatabase
AnimationUtility = UnityEditor.AnimationUtility
AnimationClipCurveData = UnityEditor.AnimationClipCurveData
g_CurveCache = {}
function GenAnimTimeData()
	local list = ModelTools.GetAllModelShape()
	local dData = {}
	local dTime = {}
	local frameRate = 30
	for i, shape in ipairs(list) do
		dData[shape] = {}
		local idx = 1
		while idx do
			local sIdx = idx == 1 and "" or "_"..tostring(idx)
			local path = string.format("Assets/GameRes/Model/Character/%d/Anim/Animator%d%s.overrideController", shape, shape, sIdx)
			local roleCreatePath = string.format("Assets/GameRes/Model/Character/%d/RoleCreate/RolrCreate%d.overrideController", shape, shape)
			local marryPath = string.format("Assets/GameRes/Model/Character/%d/Marry/Marry%d.overrideController", shape, shape)
			--指定创建角色的武器动画控制器,以后要根据需求修改
			local oWeaponAnimList = {[1110] = 1, [1120] = 1, [1310] = 7, [1320] = 7, [1210] = 2, [1220] = 9}
			local weaponCreatePath
			if oWeaponAnimList[shape] then
				weaponCreatePath = string.format("Assets/GameRes/Model/Weapon/%d_%s/RoleCreate/RolrCreate%d_%s.overrideController", shape, tostring(oWeaponAnimList[shape]), shape, tostring(oWeaponAnimList[shape]))
			end

			if IOTools.IsExist(path) then
				local clips = AssetDatabase.LoadAssetAtPath(path, classtype.AnimatorOverrideController).animationClips
				for i=0, clips.Length-1 do
					local clip = clips[i]
					local clipPath = string.format("Assets/GameRes/Model/Character/%d/Anim/%s.anim", shape, clip.name)
					if IOTools.IsExist(clipPath) then
						if frameRate ~= clip.frameRate then
							print(string.format("error!!! %d/%s fps错误，需将请改为30", shape, clip.name, clip.frameRate))
							printc("失败！")
							return
						end
						dData[shape][clip.name] = {length=clip.length,frame=math.floor(clip.length/(1/clip.frameRate))}
						if clip.name == "hit1" or clip.name == "hit2" then
							if not dTime[shape] then
								dTime[shape] = {}
							end
							local time = clip.length
							if clip.name == "hit1" then
								time = time * 1.7
							end
							dTime[shape][clip.name] = math.ceil(time * 1000)
						end
					else
						-- printc("=== 不存在剪辑 ===", clip.name)
					end
				end

				if AssetDatabase.LoadAssetAtPath(roleCreatePath, classtype.AnimatorOverrideController) then
					local roleCreateclips = AssetDatabase.LoadAssetAtPath(roleCreatePath, classtype.AnimatorOverrideController).animationClips
					for i=0, roleCreateclips.Length-1 do
						local clip = roleCreateclips[i]
						-- if frameRate ~= clip.frameRate then
						-- 	print(string.format("error!!! %d/%s fps错误，需将请改为30", shape, clip.name, clip.frameRate))
						-- 	printc("失败！")
						-- 	return
						-- end
						dData[shape][clip.name] = {length=clip.length,frame=math.floor(clip.length/(1/clip.frameRate))}
					end
				end

				if weaponCreatePath and AssetDatabase.LoadAssetAtPath(weaponCreatePath, classtype.AnimatorOverrideController) then
					local roleCreateclips = AssetDatabase.LoadAssetAtPath(weaponCreatePath, classtype.AnimatorOverrideController).animationClips
					for i=0, roleCreateclips.Length-1 do
						local clip = roleCreateclips[i]
						-- if frameRate ~= clip.frameRate then
						-- 	print(string.format("error!!! %d/%s fps错误，需将请改为30", shape, clip.name, clip.frameRate))
						-- 	printc("失败！")
						-- 	return
						-- end
						dData[shape]["weapon_"..clip.name] = {length=clip.length,frame=math.floor(clip.length/(1/clip.frameRate))}
					end
				end
				if IOTools.IsExist(marryPath) then
					local marryClips = AssetDatabase.LoadAssetAtPath(marryPath, classtype.AnimatorOverrideController).animationClips
					for i = 0, marryClips.Length - 1 do
						local c = marryClips[i]
						dData[shape][c.name] = {length = c.length,frame=math.floor(c.length*c.frameRate)}
					end
				end
				idx = idx + 1
			else
				idx = nil
			end
		end
	end
	local s = table.dump(dData, "DATA")

	s = "module(...)\n\n--auto generate in editorgui.GenAnimTimeData\n"..s
	IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/datauser/animclipdata.lua"), s)

	local sTime = table.dump(dTime, "DATA")
	sTime = "module(...)\n\n--auto generate in editorgui.GenAnimTimeData\n" .. sTime
	IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/datauser/animclipdata2.lua"), sTime)

	printc("生成完毕！")
end

function GenAllCombActAnim()
	IOTools.CreateDirectory("Assets/GameRes/_Temp")
	for iShape, v in pairs(datauser.comboactdata.DATA) do
		for sAct, v2 in pairs(v) do
			CombActToAnim(iShape, sAct)
		end
	end

end

function CombActToAnim(iShape, sAct)
	iShape = tonumber(iShape)
	t = datauser.comboactdata.DATA[iShape][sAct]
	-- printc(">>>>>>>>>>>>>>", iShape, sAct)
	-- local t = {
	-- 	[1]={action='attack1',end_frame=10,hit_frame=3,speed=1,start_frame=0,},
	-- 	[2]={action='attack1',end_frame=23,hit_frame=23,speed=1,start_frame=10,},
	-- }
	-- local iShape = 1110
	-- sAct = "test"
	g_CurveCache = {}
	local lAllCurves = {}
	local iCurFrame = 0
	for i, v in ipairs(t) do
		local clip = GetClip(iShape, v.action)
		if clip then
			speed = v.speed or 1
			local lSub = SliceClip(clip, v.start_frame, v.end_frame, iCurFrame-v.start_frame, speed)
			iCurFrame = iCurFrame + (v.end_frame - v.start_frame) * speed
			table.extend(lAllCurves, lSub)
		end
	end
	local newclip = UnityEngine.AnimationClip.New()
	for i, one in ipairs(lAllCurves) do
		newclip:SetCurve(one.path, one.type, one.propertyName, one.curve)
	end
	local path = string.format("Assets/GameRes/_Temp/%d_%s.anim", iShape, sAct)
	AssetDatabase.CreateAsset(newclip, path)
	printc("生成完毕！", path)
end

function GetClip(iShape, sAction)
	local sPath = string.format("Assets/GameRes/Model/Character/%d/Anim/%s.anim", iShape, sAction)
	return AssetDatabase.LoadAssetAtPath(sPath, classtype.AnimationClip)
end

function SliceClip(clip, frameStart, frameEnd, offsetFrame, speed)
	local allCurves = AnimationUtility.GetAllCurves(clip)
	local sliceData = {}
	for i=0, allCurves.Length - 1 do
		local oneCurveData = allCurves[i]
		local key = string.format("%s-%s", oneCurveData.path, oneCurveData.propertyName)
		local newCurveData = AnimationClipCurveData.New()
		local bAdd =false
		for j=0, oneCurveData.curve.keys.Length-1 do
			local old = oneCurveData.curve.keys[j]
			local iFrame = ModelTools.TimeToFrame(old.time)

			if frameStart <= iFrame and iFrame <= frameEnd then
				if not g_CurveCache[key] then
					g_CurveCache[key] = UnityEngine.AnimationCurve.New()
					bAdd = true
				end
				local iTime = ModelTools.FrameToTime(frameStart + offsetFrame+ (iFrame-frameStart)*speed)
				local newKeyFrame = UnityEngine.Keyframe.New(iTime, old.value, old.inTangent, old.outTangent)
				g_CurveCache[key]:AddKey(newKeyFrame)
			end
		end
		if bAdd then
			newCurveData.curve = g_CurveCache[key]
			newCurveData.path = oneCurveData.path
			newCurveData.type = oneCurveData.type
			newCurveData.propertyName = oneCurveData.propertyName
			table.insert(sliceData, newCurveData)
		end
	end
	return sliceData
end

function GenAudioPath()
	local dirs = {"/Audio/Sound/War", "/Audio/Sound/Model"}
	local dData = {}
	if Utils.IsEditor() then
		for _, dir in pairs(dirs) do
			local list = IOTools.GetFiles(IOTools.GetGameResPath(dir), "*.mp3", true)
			local list2 = IOTools.GetFiles(IOTools.GetGameResPath(dir), "*.ogg", true)
			list = table.extend(list, list2)
			for i, sPath in ipairs(list) do
				local idx = string.find(sPath, dir)
				if idx then
					local path = string.sub(sPath, idx, string.len(sPath))
					local name = string.sub(path, string.len(dir)+2, string.len(path))
					local names = string.split(name, '.')
					dData[names[1]] = string.sub(sPath, idx+1, string.len(sPath))
					-- table.insert(dData, string.sub(sPath, idx+1, string.len(sPath)))
				end
			end
		end

		local s = table.dump(dData, "DATA")

		s = "module(...)\n\n--auto generate in editorgui.GenAudioData\n"..s
		IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/datauser/audiodata.lua"), s)
		printc("生成音效文件完毕！")
	end
end

function CheckMagicFiles()
	local dir = "/Lua/logic/magic/magicfile"
	local path = IOTools.GetAssetPath(dir)
	local dData = {}
	if Utils.IsEditor() then
		selList = IOTools.GetFiles(path, "*.lua", true)
		for k,p in pairs(selList) do
			local content = IOTools.LoadTextFile(p)
			if not content then return end
			content = string.gsub(content, "module%b()", "")
			content = string.format("local %s\n return DATA", content)

			local f = loadstring(content)
			local d = nil
			if f then
				d = f()
				local endTime = 0
				local maxTime = 0
				local effTime = 0
				local hitTime = 0
				for k,v in pairs(d.cmds) do
					local startTime = v.start_time and v.start_time or 0
					if v.func_name == "End" then
						endTime = startTime
					elseif v.func_name == "VicHitInfo" then
						if v.start_time > hitTime then
							hitTime = v.start_time
						end
					elseif v.func_name == "StandEffect" or v.func_name == "BodyEffect" or v.func_name == "ShootEffect" then
						if not v.args.alive_time then
							printerror("错误：没填存在时间，给一个默认时间", v.func_name, p)
							table.print(v.args)
							v.args.alive_time = 1
						end
						local t = v.start_time + v.args.alive_time
						if t > effTime then
							effTime = t
						end
					end
					if startTime > maxTime then
						maxTime = v.start_time
					end
				end
				if endTime > effTime then
					effTime = endTime
				end
				if maxTime >= endTime then
					printc("======= 警告：结束时间小于最大时间 -> 检查法术ID:" .. p)
				end

				if endTime <= 0 then
					printerror("======= 错误：结束时间为0 -> 检查法术ID:" .. p)
				end

				local idx = string.find(p, dir)
				if idx then
					local p = string.sub(p, idx, string.len(p))
					local name = string.sub(p, string.len(dir)+2, string.len(p))
					local names = string.split(name, '.')
					if names[1] then
						local strs = string.split(names[1], '_')
						if #strs <= 1 or #strs > 4 then
							error("错误，非法的法术文件名字", name, p)
						else
							-- magic_magicid_modelid_index
							local maigcID = tonumber(strs[2])
							local shapeID = tonumber(strs[3])
							local magicIdx = tonumber(strs[4] or 1) or 1

							if #strs == 3 then
								if maigcID ~= 101 then
									shapeID = 1
									magicIdx = tonumber(strs[3] or 1) or 1
								end
							end

							if not dData[maigcID] then
								dData[maigcID] = {}
							end
							if not dData[maigcID][shapeID] then
								dData[maigcID][shapeID] = {}
							end
							if not dData[maigcID][shapeID][magicIdx] then
								dData[maigcID][shapeID][magicIdx] = {}
								table.insert(dData[maigcID][shapeID][magicIdx], endTime * 1000)
								table.insert(dData[maigcID][shapeID][magicIdx], effTime * 1000)
								table.insert(dData[maigcID][shapeID][magicIdx], hitTime * 1000)
							end
						end
					else
						error("错误，非法的法术文件名字", name, p)
					end
				end
			end
		end

		local s = table.dump(dData, "DATA")

		s = "module(...)\n-- auto generate in editorgui.GenMagicTimeData\n-- 1、结束时间 2、最大时间 3、受击时间\n"..s
		IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/datauser/magictimedata.lua"), s)
		printc("生成技能时间文件完毕！")
	end
end
