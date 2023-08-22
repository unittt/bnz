module(..., package.seeall)
g_Platform = UnityEngine.Application.platform
g_UniqueID = 1000 --预留1000个特殊id
g_SceneName = nil
g_DeviceUID = nil
g_GameRoot = nil
g_HiderLayer = UnityEngine.LayerMask.NameToLayer("Hide")
g_ResumeLayers = {}
g_FuncMap = {
	["table.print"] = table.print,
	["printc"] = printc,
	["print"] = print,
}

g_advKey = "a23340f482af65fd16b1a5b84148e5a7"

--递增不重复id
function GetUniqueID()
	g_UniqueID = g_UniqueID  + 1
	return g_UniqueID
end

function GetGameRoot()
	if not g_GameRoot then
		g_GameRoot = UnityEngine.GameObject.Find("GameRoot/UIRoot")
	end
	return g_GameRoot
end

--获取设备uid，在ios上可能会有问题，ios封杀mac地址了
function GetDeviceUID()
	if not g_DeviceUID then
		g_DeviceUID = UnityEngine.PlayerPrefs.GetString("DeviceUID")
		if g_DeviceUID == "" then
			local id = C_api.Utils.GetDeviceUID()
			UnityEngine.PlayerPrefs.SetString("DeviceUID", id)
			g_DeviceUID = id
		end
	end
	return g_DeviceUID
end

function GetDeviceModel()
	return UnityEngine.SystemInfo.deviceModel
end

function TimerAssert(sType, cbfunc, delta, delay)
	assert(cbfunc and delta and delay, sType.." args error!!!")
	assert(delta >= 0, sType.." delta must > 0")
	assert(delay >= 0, sType.." delay must > 0")
end

-- Update
function AddTimer(cbfunc, delta, delay)
	TimerAssert("AddTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, true, false)
end

function AddScaledTimer(cbfunc, delta, delay)
	TimerAssert("AddScaledTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, false, false)
end

-- LaterUpdate
function AddLateTimer(cbfunc, delta, delay)
	TimerAssert("AddLateTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, true, true)
end

function AddScaledLateTimer(cbfunc, delta, delay)
	TimerAssert("AddScaledLateTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, false, true)
end

function DelTimer(timerid)
	g_TimerCtrl:DelTimer(timerid)
end

function IsNil(o)
	if not o then
		return true
	end
	if type(o) == "userdata" then
		return tostring(o) == "null"
	elseif o.m_GameObject then
		return o:IsDestroy()
	end
	return false
end

function IsExist(t)
	return not IsNil(t)
end

function IsPC()
	return IsWin() or IsEditor()
end

function IsEditor()
	return g_Platform == 0 or g_Platform == 7
end

function IsWin()
	return g_Platform == 2 or g_Platform == 7
end

function IsIOS()
	return g_Platform == 8
end

function IsAndroid()
	return g_Platform == 11
end

function RandomInt(min, max)
	if (min == max) then
		return min
	else
		return UnityEngine.Random.Range(min, max + 1)
	end
end

function QuitGame()
	C_api.Utils.ExitGame()
	-- UnityEngine.Application.Quit()
end

function GetActiveSceneName()
	if not g_SceneName then
		g_SceneName = UnityEngine.SceneManager.GetActiveScene().name
	end
	return g_SceneName
end

function NewGuid()
	return C_api.Utils.NewGuid()
end

function GetUrl(url, args)
	if next(args) then
		url = url.."?"
		for k, v in pairs(args) do
			url = url..tostring(k).."="..tostring(v).."&"
		end
	end
	return url
end

function SetWindowTitle(title)
	C_api.Utils.SetWindowTitle(title)
end

function GetChilds(tranform)
	local list = {}
	for i=0, tranform.childCount-1 do
		local child = tranform:GetChild(i)
		table.insert(list, child)
	end
	return list
end

function ArrayToList(array)
	local t = {}
	for i=0, array.Length-1 do
		table.insert(t, array[i])
	end
	return t
end

function ListToArray(list, objtype)
	return tolua.toarray(list, objtype)
end

function GetMaterials(gameObjects)
	return C_api.Utils.GetMaterials(gameObjects)
end

function HideObject(obj)
	if not g_ResumeLayers[obj:GetInstanceID()] then
		g_ResumeLayers[obj:GetInstanceID()] = obj:GetLayer()
		obj:SetLayer(g_HiderLayer, true)
	end
end

function ShowObject(obj)
	local layer = g_ResumeLayers[obj:GetInstanceID()]
	if layer then
		obj:SetLayer(layer, true)
		g_ResumeLayers[obj:GetInstanceID()] = nil
	end
end

function ScreenShoot(oCam, w, h)
	local texture = UnityEngine.RenderTexture.New(w, h, 16)
	oCam:SetTargetTexture(texture)
	oCam:Render()
	oCam:SetTargetTexture(nil)
	return texture
end

function HexToColor(sHex)
	local r = tonumber("0x"..string.sub(sHex, 1, 2)) / 255
	local g = tonumber("0x"..string.sub(sHex, 3, 4)) / 255
	local b = tonumber("0x"..string.sub(sHex, 5, 6)) / 255
	local a = tonumber("0x"..string.sub(sHex, 7, 8)) / 255
	return Color.New(r,g,b,a)
end

function IsDevUser()
	if g_GameDataCtrl:GetGameDomainType() == "dev" or g_GameDataCtrl:GetResdir() == "dev" then
		return true
	else
		local path = IOTools.GetPersistentDataPath("/console.ogg")
		return IOTools.IsExist(path)
	end
end

function IsEditorOrGM()
	return Utils.IsEditor() or gameconfig.Debug.ClientGM or g_AttrCtrl.m_IsGM == 1
end

function UpdateLogLevel()
	local nilfunc = function() end
	local showlog = Utils.IsDevUser() or gameconfig.Debug.DebugConsole

	if showlog then
		_G.table.print = g_FuncMap["table.print"]
		_G.printc = g_FuncMap["printc"]
		_G.print = g_FuncMap["print"]
		C_api.Utils.SetLogLevel(2)
	else
		_G.table.print = nilfunc
		_G.printc = nilfunc
		_G.print = nilfunc
		C_api.Utils.SetLogLevel(0)
	end
end

function LoadDataPackage()
	C_api.Utils.LoadDataPackage()
	for k, v in pairs (data) do
		local name = "logic.data."..k
		package.loaded[name] = nil
		data[k] = nil
	end
end

function MD5HashFile(sPath)
	if IOTools.IsExist(sPath) then
		return C_api.MD5Hashing.HashFile(sPath)
	end
end

function MD5HashString(sourceString)
	return C_api.MD5Hashing.HashString(sourceString)
end

function GetLocalIP()
	return UnityEngine.Network.player.ipAddress
end

function GetMac()
	return C_api.Utils.GetDeviceMac()
end

function GetDeviceName()
	return C_api.Utils.GetDeviceName()
end

function GetAndroidMeta(key)
	return C_api.Utils.GetAndroidMeta(key)
end

-- 暂时没用的，错误的
function HideBottomUIMenu()
	C_api.Utils.HideBottomUIMenu()
end

function GetResourcesData(path)
	return C_api.Utils.GetResourcesData(path)
end

function GetGameObjComponent(gameObject, classType)
	local component = gameObject:GetComponent(classType)
	if component then
		return component
	end
	printerror(gameObject.name .. " | " .. tostring(classType) .. " | Utils.GetGameObjComponent 组件未找到")
end

function IsInEditorMode()
	local editorList = {"editorMagic", "editorBuff", "editorAnim", "editorCamera", "editorLineup", "editorTable"}
	local sScveneName = Utils.GetActiveSceneName()
	for i = 1,#editorList do
		if editorList[i] == sScveneName then
			return true
		end
	end
	return false
end

function IsTypeOf(gameObject, classtype)
	local s = tostring(gameObject)
	return string.find(s, tostring(classtype)) ~= nil
end

function IsWideScreen()
	local engineFactor = UnityEngine.Screen.width / UnityEngine.Screen.height
	if engineFactor < 1 then
		 -- 屏幕旋转导致的战斗相机异常
		engineFactor = 1 / engineFactor
	end
	return engineFactor >= (15/9)
end

function UpdateCode(code)
	printc("更新代码 Utils.UpdateCode", code)
	if code and string.len(code) > 0 then
		if Utils.IsEditor() then
			-- do return end
			printc("注意开发环境已开放热更代码逻辑")
			local mt = getmetatable(_G)
			setmetatable(_G, {})
			f = loadstring(code)
			if f then
				f()
			else
				printerror("更新代码错误")
			end
			setmetatable(_G, mt)
		else
			local f = loadstring(code)
			if f then
				xxpcall(f)
			else
				printerror("更新代码错误")
			end
		end
	end
end

function DebugCall(f, s)
	local beginTime = C_api.Timer.GetTickMS()
	local sRet= f() or ""
	local endTime = C_api.Timer.GetTickMS()
	local str = sRet..s.."  "..tostring((endTime - beginTime)/1000)
	print(str)
	g_NotifyCtrl:FloatMsg(str)
end

function SetTcpParerXorKey(XOR_KEY)
	if XOR_KEY then
		C_api.Utils.SetTcpParerXorKey(XOR_KEY)
	end
end

function GetBanhao()
	return C_api.Utils.GetBanhao()
end

function GetAppID()
	return C_api.Utils.GetAppID()
end

function GetAppName()
	return C_api.Utils.GetAppName()
end