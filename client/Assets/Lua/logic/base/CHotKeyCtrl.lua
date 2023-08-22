-- 注意判断仅当编辑器下才能使用快捷键，PC端需注意测试

local CHotKeyCtrl = class("CHotKeyCtrl")

function CHotKeyCtrl.ctor(self)
	
end

function CHotKeyCtrl.InitCtrl(self)
	if not C_api.HotkeyHandler.Instance then
		return
	end

	if g_GameDataCtrl:IsQRPC() then
		return
	end

	C_api.HotkeyHandler.Instance:SetKeyUpCallback(callback(self, "OnKey", false))
	C_api.HotkeyHandler.Instance:SetKeyDownCallback(callback(self, "OnKey", true))
	self.m_Key2Name = {}
	for k, v in pairs(datauser.hotkeydata.SINGLE) do
		local iKey = enum.KeyCode[k]
		self.m_Key2Name[iKey] = k
		C_api.HotkeyHandler.Instance:AddHotKey(iKey)
	end

	self.m_multiName = {}
	for k1, v in pairs(datauser.hotkeydata.MULTI) do
		local keys = {}
		for _, v2 in pairs(v) do
			local iKey = enum.KeyCode[v2]
			C_api.HotkeyHandler.Instance:AddHotKey(iKey)
			table.insert(keys, iKey)
		end
		self.m_multiName[k1] = keys
	end
end

function CHotKeyCtrl.OnKey(self, bDown, keys)
	local len = keys.Count
	if len == 1 then
		local iKey = keys[0]
		local sName = self.m_Key2Name[iKey]
		local sFuncName = datauser.hotkeydata.SINGLE[sName]
		local func = self[sFuncName]
		if func then
			func(self, bDown)
		end
	else
		for k,v in pairs(self.m_multiName) do
			if #v == len then
				local dofunc = true
				for i=0,len-1 do
					if not table.index(v, keys[i]) then
						dofunc = false
						break
					end
				end
				if dofunc then
					local func = self[k]
					if func then
						func(self, bDown)
					end
					return
				end
			end
		end
	end
end

--单键的回调
function CHotKeyCtrl.OnSingle(self, bDown)
	if bDown then
	end
end

function CHotKeyCtrl.OnEscape(self, bDown)
	if bDown then
		if Utils.IsPC() then
			if g_AttrCtrl.pid > 0 then
				local serverName = g_ServerPhoneCtrl:GetCurServerName()
				local pID = g_AttrCtrl.pid
				local accountID = g_LoginPhoneCtrl.m_VerifyInfo.account
				local accountName = g_AttrCtrl.name
				local content = "服务器名称:"..serverName.." 账号:"..accountID .. " 角色:"..accountName.." PID:"..pID
				g_NotifyCtrl:FloatMsg(content)
				printc("已复制角色信息到剪贴板 | " .. content)
				NGUI.NGUITools.clipboard = content
			end
		else
			if g_LoginPhoneCtrl.m_IsPC then
				local windowConfirmInfo = {
					msg				= "是否退出游戏？",
					title			= "退出游戏",
					okCallback = function ()
						g_SdkCtrl:Exit()
						Utils.QuitGame()
					end,
					pivot = enum.UIWidget.Pivot.Center,
					depthType = "Top",
				}
				g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
					self.m_WinTipViwe = oView
				end)
			else
				if g_LoginPhoneCtrl.m_IsQrPC then
					local windowConfirmInfo = {
						msg				= "是否退出游戏？",
						title			= "退出游戏",
						okCallback = function ()
							g_SdkCtrl:Exit()
							Utils.QuitGame()
						end,
						pivot = enum.UIWidget.Pivot.Center,
						depthType = "Top",
					}
					g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
						self.m_WinTipViwe = oView
					end)
				else
					g_SdkCtrl:DoExiter()
				end
			end
		end
	end
end

function CHotKeyCtrl.OnF1(self, bDown)
	if bDown and Utils.IsEditorOrGM() then
		CGmFunc.SetGMBtnActive()
	end
end

function CHotKeyCtrl.OnF2(self, bDown)
	if bDown and Utils.IsEditorOrGM() then
		if g_HorseCtrl:GetIsInFlyMap(g_HorseCtrl.m_CurUseHorseId) then
			g_NotifyCtrl:FloatMsg("飞行坐骑的加速无法使用")
			return
		end
		local hero = g_MapCtrl:GetHero()
		if hero then
			if hero.m_IsFlyWaterProgress then
				g_NotifyCtrl:FloatMsg("踩水过程的加速无法使用")
				return
			end
			local curSpeed = hero.m_Walker.moveSpeed < 5 and 10 or 2.7
			hero.m_Walker.moveSpeed = curSpeed
			g_GmCtrl.m_GMRecord.Logic.heroSpeed = curSpeed
		else
			print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "OnF2", "没有找到玩家"))
		end
	end
end

function CHotKeyCtrl.OnF3(self, bDown)
	if bDown and Utils.IsEditorOrGM() then
		local oView = CGmMainView:GetView()
		if oView then
			CGmMainView:CloseView()
		else
			CGmMainView:ShowView()
		end
	end
end

function CHotKeyCtrl.OnF4(self, bDown)
	if bDown and Utils.IsEditorOrGM() then
		-- local luafile = "alotluadebug"
		-- package.loaded[luafile] = nil
		-- require(luafile)
		-- dofile "alotluadebug"

		--dofile "logic/chat/chat_debug_my"
	end
end

function CHotKeyCtrl.OnF5(self, bDown)
	if bDown and Utils.IsEditorOrGM() then
		printc("OnF5")
		main.Test()
	end
end

function CHotKeyCtrl.OnF6(self, bDown)
	if bDown and Utils.IsEditorOrGM() then
		printc("OnF6")
		main.Test2()
	end
end


--组合键的回调

return CHotKeyCtrl