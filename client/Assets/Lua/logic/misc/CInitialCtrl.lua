local CInitialCtrl = class("CInitialCtrl")

-- 参数aStr串，bStr串
function CInitialCtrl.InitialSortStr(aStr, bStr, dExtra)
	local a = string.getFirstChar(aStr)
	local b = string.getFirstChar(bStr)
	return CInitialCtrl.InitialSortChar(a, b, dExtra)
end

-- 参数a字，b字
function CInitialCtrl.InitialSortChar(a, b, dExtra)
	local abyte = string.byte(a)
	local bbyte = string.byte(b)
	if abyte > 127 and bbyte > 127 then
		local aKey = nil
		local bKey = nil
		for _,v in pairs(datauser.initialdata.INITIAL) do
			if not aKey or not bKey then
				if not aKey and string.find(v.value, a) then
					aKey = string.sub(v.key, 1, 1)
				end
				if not bKey and string.find(v.value, b) then
					bKey = string.sub(v.key, 1, 1)
				end
			end
			if aKey and bKey then
				break
			end
		end
		if aKey and bKey then
			if string.byte(aKey) == string.byte(bKey) and dExtra then
				return dExtra.a < dExtra.b
			end
			return string.byte(aKey) < string.byte(bKey)
		elseif aKey then
			return true
		end
		return false
	elseif bbyte > 127 then
		return true
	end
	return false
end

return CInitialCtrl