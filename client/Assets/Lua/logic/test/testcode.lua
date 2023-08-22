-- 地图测试
-- mapgo = nil
-- local MapLoadDone(...)
-- 	print('MapLoadDone ', ...)
-- 	local mapCamera = UnityEngine.GameOebjct.Find("MainCamera"):GetComponent(classtype.Map2DCamera)
-- 	mapCamera:SetCurMap(curMap);
-- end

-- local map1010 =  C_api.Map2D.New(1010)
-- map1010.LoadAsync(Vector3.zero, MapLoadDone)
-- function f(...)
-- 	local args = {...}
-- 	local len = select("#", ...)
-- 	local a1, a2, a3 = unpack(args, 1, len)
-- 	print(a1, a2, a3)
-- 	local m1, m2, m3 = unpack(args)
-- 	print(m1, m2, m3)
-- end

-- f(nil, 1, nil)

-- for i=1, 1 do
-- 	print(i)
-- end
-- local args = {1, 2, nil, 4, nil}
-- local a1, a2, a3 = unpack({})
-- print(a1, a2, a3,args[1], args[2], args[3], select("#", args))

-- function f(...)
-- 	local len = select("#", ...)
-- 	args = {...}
-- 	for i=1, len do
-- 		local t1, t2, t3 = select(i, ...)
-- 		print(t1, t2, t3)
-- 	end
-- end

-- f(nil, 1, nil)

-- function f()
-- 	return 1, 2
-- end
-- function ff()
-- 	return f()
-- end

-- i1, i2 = ff()
-- print(i1, i2)

-- function f()
-- 	local i = 0

-- 	local  function ff1()
-- 		i = i + 1
-- 		-- table.insert(t, 1)
-- 	end
-- 	local function ff2()
-- 		i = i +  1
-- 		-- table.insert(t, 2)
-- 		return i
-- 	end
-- 	return ff1, ff2
-- end

-- ff1, ff2 =f()
-- ff1()
-- i = ff2()

function table_tostring(t, maxlayer, name)
	local tableList = {}
	local layer = 0
	maxlayer = maxlayer or 100
	local function cmp(t1, t2)
		return tostring(t1) < tostring(t2)
	end
	local function table_r (t, name, indent, full, layer)
		local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
		local tag = indent .. id .. ' = '
		local out = {}  -- result
		if type(t) == "table" and layer < maxlayer then
			if tableList[t] ~= nil then
				table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
			else
				tableList[t]= full and (full .. '.' .. id) or id
				if next(t) then -- Table not empty
					table.insert(out, tag .. '{')
					local keys = {}
					for key,value in pairs(t) do
						table.insert(keys, key)
					end
					table.sort(keys, cmp)
					for i, key in ipairs(keys) do
						local value = t[key]
						table.insert(out,table_r(value,key,indent .. '|  ',tableList[t], layer + 1))
					end
					table.insert(out,indent .. '}')
				else table.insert(out,tag .. '{}') end
			end
		else
			local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
			table.insert(out, tag .. val)
		end
		return table.concat(out, '\n')
	end
	return table_r(t,name or 'Table', '', '', layer)
end


function table.print(t, name, maxlayer)
	print(table_tostring(t, maxlayer, name))
end

function ff()
	function f()
		table.print(debug.getinfo(1, "S"))
		print(getfenv(1) == _G)
	end
	f()
end

-- ff()

-- f(1,37,nil, nil,36,35, 34,nil)

-- local s = "123456"
-- s = string.sub(s, 3)
-- print(s)

-- local s ="do local ret={login_account=[==[669888]==],account_role={[669888]=754096}} return ret end"
-- print(loadstring(s))

-- function f()
-- 	i = 1
-- 	function f1()
-- 		i = i + 1
-- 		print(i)
-- 	end
-- 	function f2()
-- 		i = i + 1
-- 		print(i)
-- 	end
-- 	print(i)
-- 	return f1, f2
-- end

-- local f1, f2 = f()
-- f1()
-- f2()

function f(...)
	local args = {...}
	local iLen = select("#", ...)
	print(iLen)
	return function(...)
		local iLen = select("#", args)
		print(iLen)
	end
end

function ff(a1, ...)
	local args = {...}
	local iLen = select("#", ...)
	local newargs = {}
	for i=1, iLen do
		print(">>>>>", i, args[i])
		newargs[i] = args[i]
	end
	-- iLen = iLen + 1
	-- newargs[iLen] = nil
	return f(unpack(newargs, 1, iLen), nil)
end
f = ff(11, nil, 1, nil)
-- f()

for i = 9, 1 do
	print(i)
end
