local CSpeechCtrl = class("CSpeechCtrl", CCtrlBase)

CSpeechCtrl.g_TestSpeech = Utils.IsEditor()
CSpeechCtrl.g_TranslateUrl = "http://vop.baidu.com/server_api"

--语音
function CSpeechCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_AudioRecord = C_api.AudioRecord.Instance
	self.m_AudioPlayer = AudioTools.CreateAudioPlayer("speech")
	self.m_Sepeechs = {}
	self.m_PlayList = {}
	self.m_TranslateDone = {}
	self.m_WaitTranslate = {}
	self.m_PathKey = {}
	self.m_TranslateToken ="test_token"
	self.m_TokenGetting = false
end

----------------以下为初始化语音相关------------------

--在main.lua初始化执行
function CSpeechCtrl.InitCtrl(self)
	local localToken = self:GetTokenFromLocal()
	if localToken then
		self.m_TranslateToken = localToken
	else
		self:GetTokenFormServer()
	end
end

function CSpeechCtrl.GetTokenFromLocal(self)
	local tLocal = IOTools.GetClientData("bdyy_token")
	if tLocal then 
		print("CSpeechCtrl.GetTokenFromLocal", g_TimeCtrl:GetTimeS(),  tLocal.expire)
		if g_TimeCtrl:GetTimeS() < tLocal.expire then
			return tLocal.token
		end
	end
end

function CSpeechCtrl.GetTokenFormServer(self)
	if self.m_TokenGetting then
		return
	end
	self.m_TokenGetting = true
	local url = self:GetTokenUrl()
	g_HttpCtrl:Get(url, callback(self, "OnTokenGet"), {json_result=true})
end

function CSpeechCtrl.GetTokenUrl(self)
	return Utils.GetUrl("https://openapi.baidu.com/oauth/2.0/token",
			{grant_type="client_credentials",
			client_id ="cbadGFhCcjh4H0difKnC8P1B",
			client_secret="3335d6d08034cff3c2f3b1980c050c66",})
end

function CSpeechCtrl.OnTokenGet(self, success, tResult)
	if success then
		self.m_TranslateToken = tResult.access_token
		local tSave = {["token"]=self.m_TranslateToken,
		["expire"]=(g_TimeCtrl:GetTimeS()+tResult.expires_in-240)}
		table.print(tResult, "OnTokenGet1-->")
		table.print(tSave, "OnTokenGet2-->")
		IOTools.SetClientData("bdyy_token", tSave)
	else
		print("OnTokenGet err")
	end
	self.m_TokenGetting = false
end

---------------以下是一些通用接口，实际是调用m_AudioRecord的方法---------------

--获取语音的音量大小的接口
function CSpeechCtrl.GetRecordVolume(self)
	return self.m_AudioRecord:GetRecordVolume(800) * 10
end

--开始录音的接口
function CSpeechCtrl.StartRecord(self, iMax)
	iMax = iMax or 35
	self.m_StartTime = g_TimeCtrl:GetTimeS()
	self.m_AudioRecord:StartRecord(0, iMax)
end

--结束录音的接口,返回语音的key值
function CSpeechCtrl.EndRecord(self)
	local iErr = self.m_AudioRecord:EndRecord()
	local sKey = nil
	local iTime = 0
	if self.m_StartTime then
		iTime = g_TimeCtrl:GetTimeS() - self.m_StartTime
		self.m_StartTime = nil
	else
		iTime = 10
		return
	end

	if iErr == enum.AudioRecordError.None then
		if iTime < 1 then
			--录音失败，时间太短
			g_NotifyCtrl:FloatAudioMsg(data.chatdata.TEXT[define.Chat.AudioTips.TimeShort].content)
			return
		end
		if g_AttrCtrl.pid and g_AttrCtrl.pid ~= 0 then
			sKey = string.format("speech%d-%d", g_AttrCtrl.pid, g_TimeCtrl:GetTimeMS())
		else
			sKey = Utils.NewGuid()
		end
	elseif iErr == enum.AudioRecordError.IsToShort then
		--录音失败，时间太短
		g_NotifyCtrl:FloatAudioMsg(data.chatdata.TEXT[define.Chat.AudioTips.TimeShort].content)
		return
	elseif iErr == enum.AudioRecordError.IsSilence then
		--录音失败，声音太小
		g_NotifyCtrl:FloatAudioMsg(data.chatdata.TEXT[define.Chat.AudioTips.VolumeSmall].content)
		return	
	elseif CSpeechCtrl.g_TestSpeech then
		if iTime < 1 then
			--录音失败，时间太短
			g_NotifyCtrl:FloatAudioMsg(data.chatdata.TEXT[define.Chat.AudioTips.TimeShort].content)
			return
		end
		sKey = Utils.NewGuid()
	end
	
	if sKey then
		local dSpeech = self:GetSpeech(sKey)
		dSpeech["time"] = iTime
	end
	return sKey
end

------------------以下是保存录音文件到本地-----------------------

function CSpeechCtrl.GetTestAmrPath(self)
	return IOTools.GetGameResPath("/Audio/testspeech_amr.amr")
end

--保存录音为amr格式，返回保存录音的路径
function CSpeechCtrl.SaveToAmr(self, key)
	if CSpeechCtrl.g_TestSpeech then
		return self:GetTestAmrPath()
	end
	local amrPath = IOTools.GetRoleFilePath(string.format("/speech/%s.amr", key))
	if self.m_AudioRecord:SaveToAmr(amrPath) then
		return amrPath
	else
		--录音失败，无法保存
		g_NotifyCtrl:FloatAudioMsg(data.chatdata.TEXT[define.Chat.AudioTips.CouldNotSave].content)
	end
end

--保存录音为wav格式，返回保存录音的路径
function CSpeechCtrl.SaveToWav(self, key)
	local wavPath = IOTools.GetRoleFilePath(string.format("/speech/%s.wav", key))
	if self.m_AudioRecord:SaveToWav(wavPath) then
		return wavPath
	else
		--录音录制失败
		g_NotifyCtrl:FloatAudioMsg(data.chatdata.TEXT[define.Chat.AudioTips.FailRecord].content)
	end
end

---------------以下为上传本地录音文件到服务器-----------------

function CSpeechCtrl.UploadToServer(self, key, path, dUploadArgs, cb)
	dUploadArgs = dUploadArgs or {}
	if CSpeechCtrl.g_TestSpeech then
		Utils.AddTimer(function()
				self:OnUploadResult(path, dUploadArgs, key, true)
			end, 0, 0)
	else
		g_QiniuCtrl:UploadFile(key, path, enum.QiniuType.Audio, callback(self, "OnUploadResult", path, dUploadArgs, cb))
	end
end

function CSpeechCtrl.OnUploadResult(self, path, dUploadArgs, cb, key, sucess)
	if sucess then
		local filetype = string.gsub(IOTools.GetExtension(path), "%.", "")
		local dSpeech = self:GetSpeech(key)
		dSpeech[filetype] = path
		dSpeech["need_send"] = dUploadArgs.channel~=nil or dUploadArgs.pid~=nil or dUploadArgs.barrage~=nil
		or dUploadArgs.bottle~=nil
		dSpeech["channel"] = dUploadArgs.channel
		dSpeech["pid"] = dUploadArgs.pid
		dSpeech["barrage"] = dUploadArgs.barrage
		dSpeech["bottle"] = dUploadArgs.bottle
		if self.m_TranslateDone[key] then
			dSpeech["translate"] = self.m_TranslateDone[key]
			self.m_TranslateDone[key] = nil
		else
			self.m_WaitTranslate[key] = true
		end
		table.print(dSpeech, "speech.OnUploadResult-->")
		if cb then
			cb(function ()
				self:CheckSendSpeech(key)
			end)
		else
			self:CheckSendSpeech(key)
		end
	else
		print("上传失败", key)
	end
end

-------------------以下为翻译语音相关---------------------------

--翻译语音的接口
function CSpeechCtrl.TranslateFromServer(self, key, filepath, cb)
	if  CSpeechCtrl.g_TestSpeech then
		Utils.AddTimer(function()
				self:OnTranslateResult(key, nil, true, {result={"测试翻译"}})
			end, 0, 0.1)
	else
		local url = Utils.GetUrl(CSpeechCtrl.g_TranslateUrl,
					{cuid = Utils.GetDeviceUID(),
					token = self.m_TranslateToken,
					lan = "zh"})
		local bytes = IOTools.LoadByteFile(filepath)
		local headers = {
			["Content-Type"]="audio/amr;rate=8000",
			["Content-Length"]= tostring(bytes.Length),
		}
		g_HttpCtrl:Post(url, callback(self, "OnTranslateResult", key, cb), headers, bytes, {json_result=true})
	end
end

function CSpeechCtrl.OnTranslateResult(self, key, cb, success, tResult)
	local sTranslate = "翻译失败"
	if success then
		local result = tResult.result
		if result and next(result)then
			sTranslate = self:ProcessTranslateResult(result[1])
		else
			if tResult.err_no == 3302 then
				self:GetTokenFormServer()
			end
			print("translate fail->err_no", tResult.err_no, tResult.err_msg)
			--这里根据策划需求去掉翻译失败后的编码
			sTranslate = sTranslate --sTranslate..tostring(tResult.err_no)
		end
		
	else
		print("translate err", key)
	end
	local bWait = self.m_WaitTranslate[key]
	if bWait then
		local dSpeech = self:GetSpeech(key)
		dSpeech["translate"] = sTranslate
		self.m_WaitTranslate[key] = nil
		self:CheckSendSpeech(key)
	else
		self.m_TranslateDone[key] = sTranslate
	end
	if cb then
		cb(sTranslate)
	end
end

function CSpeechCtrl.ProcessTranslateResult(self, sTranslate)
	sTranslate = string.gsub(sTranslate, "，", "")
	return sTranslate
end

--------------------以下是下载语音或翻译语音成功后发送语音到聊天界面---------------------

function CSpeechCtrl.CheckSendSpeech(self, key)
	local dSpeech = self:GetSpeech(key)
	if dSpeech and dSpeech.need_send and dSpeech.translate then
		local sText = g_MaskWordCtrl:ReplaceMaskWord(dSpeech.translate)
		if dSpeech.channel then -->发送频道
			--发送语音到聊天的某个频道
			local sMsg = LinkTools.GenerateSpeechLink(key, sText, dSpeech.time)
			g_ChatCtrl:SendMsg(sMsg, dSpeech.channel)

		elseif dSpeech.pid then -->发给好友
			local sMsg = LinkTools.GenerateSpeechLink(key, sText, dSpeech.time)
			g_TalkCtrl:AddSelfMsg(dSpeech.pid, sMsg)
			g_TalkCtrl:SendChat(dSpeech.pid, sMsg)
		elseif dSpeech.barrage then -->发给弹幕
			if dSpeech.barrage == 1 then
				netbulletbarrage.C2GSWarBulletBarrage(sText)
			elseif dSpeech.barrage == 3 then
				netbulletbarrage.C2GSOrgBulletBarrage(sText)
				COrgBarrageSendView:CloseView()
			end
		elseif dSpeech.bottle then -->祝福瓶
			local sMsg = LinkTools.GenerateSpeechLink(key, sText, dSpeech.time)
			g_WishBottleCtrl:SendMsg(dSpeech.bottle, sMsg)
		end
		dSpeech.need_send = false
	end
end

--获取语音的数据
function CSpeechCtrl.GetSpeech(self, key)
	if not self.m_Sepeechs[key] then
		self.m_Sepeechs[key] = {key=key}
	end
	return self.m_Sepeechs[key]
end

-----------------以下为播放语音相关----------------------

--根据path播放，同一时间只播放一个语音
function CSpeechCtrl.PlayWithPath(self, path)
	local err, oClip = self.m_AudioRecord:GetClipAmr(path)
	if oClip then
		printc("PlayWithPath,有oClip", self.m_PathKey[path])
		self.m_CurPlayPath = path
		g_AudioCtrl:SoloClip(oClip, 0, callback(self, "OnPlayEnd"), true)
		self:OnEvent(define.Chat.Event.PlayAudio, self.m_PathKey[path])
		-- self:OnEvent(define.Chat.Event.PlayAudio, self.m_PathKey[path])
		-- self.m_AudioPlayer:SetClip(oClip, callback(self, "OnPlayEnd"))
	else
		printc("PlayWithPath,没有oClip")
	end
end

--根据key播放
function CSpeechCtrl.PlayWithKey(self, key)
	local dSpeech = self:GetSpeech(key)
	if dSpeech then
		printc("PlayWithKey,有dSpeech")
		local function f(path)			
			self:ClearPlayList()
			self.m_CurPlayPath = nil
			g_AudioCtrl:StopSolo()
			self:PlayWithPath(path)
		end
		if dSpeech.amr then
			self.m_PathKey[dSpeech.amr] = key
			f(dSpeech.amr)
		else
			printc("PlayWithKey,没有dSpeech.amr")
			self:DownloadFromServer(key, "amr", f)
		end
	end
end

function CSpeechCtrl.PlayLocalWithKey(self, key)
	local dSpeech = self:GetSpeech(key)
	if dSpeech then
		printc("PlayLocalWithKey,有dSpeech")
		local function f(path)
			self:ClearPlayList()
			self.m_CurPlayPath = nil
			g_AudioCtrl:StopSolo()
			self:PlayWithPath(path)
		end
		if dSpeech.amr then
			self.m_PathKey[dSpeech.amr] = key
			f(dSpeech.amr)
		else
			local path = string.format("Audio/%s.mp3", key)
			g_AudioCtrl:SoloPath(path, 0, function ()
				self:OnPlayEnd()
			end, true)
			
			-- local path = IOTools.GetGameResPath(string.format("/Audio/%s.mp3", key))
			-- local info = {}
			-- info.bytes = IOTools.LoadByteFile(path)
			-- if info.bytes == nil then
			-- 	printc("本地语音文件("..key..".mp3)不存在！")
			-- 	self:OnPlayEnd()
			-- 	return
			-- end
			-- self:OnDownloadResult("amr", f, key, info)
		end
	end
end

function CSpeechCtrl.ClearPlayList(self)
	self.m_PlayList = {}
end

--通过一个m_PlayList来播放语音
function CSpeechCtrl.AddPlayWithPath(self, path, bFirst)
	if bFirst then
		table.insert(self.m_PlayList, 1, path)
	else
		table.insert(self.m_PlayList, path)
	end
	self:PlayNext()
end

function CSpeechCtrl.PlayNext(self)
	if self.m_CurPlayPath then
		return
	end
	if next(self.m_PlayList) then
		local path = self.m_PlayList[1]
		table.remove(self.m_PlayList, 1)
		self.m_CurPlayPath = path
		self:PlayWithPath(path)
	end
end

function CSpeechCtrl.AddPlayWithKey(self, key)
	local dSpeech = self:GetSpeech(key)
	if dSpeech then
		local function f(path)
			self:AddPlayWithPath(path)
		end
		if dSpeech.amr then
			self.m_PathKey[dSpeech.amr] = key
			f(dSpeech.amr)
		else
			self:DownloadFromServer(key,"amr",f)
		end
	end
end

function CSpeechCtrl.OnPlayEnd(self)
	print("播放完毕->", self.m_CurPlayPath)
	local sKey = self.m_PathKey[self.m_CurPlayPath]
	self.m_CurPlayPath = nil
	self:OnEvent(define.Chat.Event.EndPlayAudio, sKey)
	self:PlayNext()
end

function CSpeechCtrl.IsPlay(self, key)
	local curKey = self.m_PathKey[self.m_CurPlayPath]
	if curKey then
		return key == curKey
	end
	return false
end

--下载语音文件
function CSpeechCtrl.DownloadFromServer(self, key, type, cb)
	if CSpeechCtrl.g_TestSpeech then
		Utils.AddTimer(function()
			local path = self:GetTestAmrPath()
			data.bytes = IOTools.LoadByteFile(path)
			self:OnDownloadResult(type, cb, key, data)
		end, 0, 0.5)
	else
		--根据key就可以下载语音
		g_QiniuCtrl:DownloadFile(key, callback(self, "OnDownloadResult", type, cb))
	end
end

--根据下载的字节保存为本地文件
function CSpeechCtrl.OnDownloadResult(self, type, cb, key, www)
	if www then		
		local path = IOTools.GetRoleFilePath(string.format("/speech/%s.%s", key, type))
		IOTools.SaveByteFile(path, www.bytes)
		local dSpeech = self:GetSpeech(key)
		dSpeech[type] = path
		self.m_PathKey[path] = key
		printc("下载成功key:", key, ";path:", path)
		if cb then
			cb(path)
		end
		table.print(dSpeech, "speech.OnDownloadResult-->")
	else
		printc("CSpeechCtrl.OnDownloadResult,没有www")
		print("下载失败", key)
	end
end

return CSpeechCtrl