local CAudioCtrl = class("CAudioCtrl")
define.Audio = {
	MusicPath = {
		login = "denglu.mp3",
		warboss = "zhandou1.mp3",
		warnormal = "zhandou2.mp3",
		warpvp = "zhandou3.mp3",
		warwin = "Audio/Music/shengli.mp3",
		warfail = "Audio/Music/shibai.mp3",
	},
	SoundPath = {
		-- 通用按钮点击音效
		Btn = "UI/dianji.ogg",
		-- 翻页、整理背包音效
		Tab = "UI/fanye.ogg",
		-- 获得金币奖励时都要播此音效
		Gold = "UI/jinbi.ogg",
		-- 功能解锁开放的音效
		Unlock = "UI/gongneng.ogg",
		-- 角色升级
		Upgrade = "UI/shengji.ogg",
		-- 宠物升级、进阶、招募、突破音效
		Summon = "UI/chongwu.ogg",
		-- 伙伴升级、进阶、招募、突破音效
		Partner = "UI/huoban.ogg",
		-- 装备强化、打造过程音效
		StrengPros = "UI/qianghua1.ogg",
		-- 装备强化、打造成功音效
		StrengSucc = "UI/qianghua2.ogg",
	},
}
--音频播放管理
function CAudioCtrl.ctor(self)
	self.m_MusicPlayer = AudioTools.CreateAudioPlayer("music") --背景音乐
	self.m_SoloPlayer = AudioTools.CreateAudioPlayer("solo")
	self.m_SoloPlayer2 = AudioTools.CreateAudioPlayer("solo2")
	self.m_NpcPlayer = AudioTools.CreateAudioPlayer("npc")
	-- self.m_MusicPlayer:SetRate(0.5)
	self.m_MusicPlayer:SetLoop(true)
	self.m_SoundPlayerList = {}	--音效播放控件列表

	self.m_SetSlience = false

	self.m_AudioRate = {
		default = 1,
		current = {music = 1, sound = 1, solo = 1, npc = 1},
		resume = {music = 1, sound = 1, solo = 1, npc = 1}
	}

	self.m_AudioVolume = {
		default = 1,
		current = {music = 1, sound = 1, solo = 1, npc = 1},
		resume = {music = 1, sound = 1, solo = 1, npc = 1}
	}

	-- self.m_RecordInfo = {groupid = uiid, ...}
	self.m_RecordInfo = {}

	-- 先实例3个御用
	for i=1,3 do
		self:CreateSoundPlayer()
	end

	self.m_WarHitPathList = {}
end

function CAudioCtrl.SetRecordInfo(self, groupid, uuid)
	self.m_RecordInfo[groupid] = uuid
end

-- NPC单独播放(路径)
function CAudioCtrl.NpcPath(self, sPath, iRate, cb)
	if not sPath then
		return
	end
	-- 当存在语音播放，直接reutrn
	if self.m_SoloPlayer:IsPlaying() or self.m_SoloPlayer2:IsPlaying() then
		return
	end
	
	-- printc("======== Npc音效 =======")
	if self.m_NpcPlayer:IsPlaying() then
		self.m_AudioRate.current = table.copy(self.m_AudioRate.resume)
	end
	local function onStop()
		if cb then cb() end
		self:ResumeAudioRate()
	end
	self.m_NpcPlayer:Play(sPath)
	self.m_NpcPlayer:SetStopCb(onStop)
	iRate = iRate or self.m_AudioRate.current.music
	if iRate ~= self.m_AudioRate.current.music then
		self.m_AudioRate.resume = table.copy(self.m_AudioRate.current)
		self.m_AudioRate.current.music = iRate
		-- self.m_AudioRate.current.sound = iRate
		self:ReSetAudioRate()
	end
end

-- 单独播放(路径)
function CAudioCtrl.SoloPath(self, sPath, iRate, cb, isDouble)
	-- printc("======== Solo音效 - 路径 =======")
	if not sPath then
		return
	end
	local function onStop()
		if cb then cb() end
		self:ResumeAudioRate()
	end
	self.m_SoloPlayer:Play(sPath)
	self.m_SoloPlayer:SetStopCb(onStop)
	if isDouble then
		self.m_SoloPlayer2:Play(sPath)
		self.m_SoloPlayer2:SetStopCb(onStop)
	end
	iRate = iRate or self.m_AudioRate.current.music
	if iRate ~= self.m_AudioRate.current.music then
		self:ResumeAudioRate()
		self.m_AudioRate.resume = table.copy(self.m_AudioRate.current)
		self.m_AudioRate.current.music = iRate
		self.m_AudioRate.current.sound = iRate
		self:ReSetAudioRate()
	end
end

-- 单独播放(音频剪辑)
function CAudioCtrl.SoloClip(self, oClip, iRate, cb, isDouble)
	if not oClip then
		return
	end
	-- printc("======== Solo音效 - 剪辑 =======")
	local function onStop()
		if cb then cb() end
		self:ResumeAudioRate()
	end
	self.m_SoloPlayer:SetClip(oClip)
	self.m_SoloPlayer:SetStopCb(onStop)
	if isDouble then
		self.m_SoloPlayer2:SetClip(oClip)
		self.m_SoloPlayer2:SetStopCb(onStop)
	end
	if iRate then
		self:ResumeAudioRate()
		self.m_AudioRate.resume = table.copy(self.m_AudioRate.current)
		self.m_AudioRate.current.music = iRate
		self.m_AudioRate.current.sound = iRate
		self:ReSetAudioRate()
	end
end

-- scheduleed 是否按xx的进度播放 | record 是否记录
function CAudioCtrl.PlayEffect(self, sPath, scheduleed, record)
	if not sPath then
		return
	end

	local bEnabled = g_SystemSettingsCtrl:GetSitchByIndex(2)
	if not bEnabled then
		return
	end
	
	if record then
		local oAudioPlayer = self.m_WarHitPathList[sPath]
		if oAudioPlayer then
			return
		end
	end

	printc("======== 播放音效 =======", sPath, scheduleed, record)
	local oAudioPlayer = self:GetSoundPlayer()
	oAudioPlayer:Play(sPath, scheduleed)
	
	if record then
		self.m_WarHitPathList[sPath] = oAudioPlayer
		oAudioPlayer:SetStopCb(function ()
			self.m_WarHitPathList[sPath] = nil
		end)
	end
end

--音乐
function CAudioCtrl.PlayMusic(self, sPath)
	local bEnabled = g_SystemSettingsCtrl:GetSitchByIndex(1)
	if not bEnabled then
		return
	end
	
	local sABPath = "Audio/Music/"..sPath
	if self.m_AudioRate.current.music == 0 or self.m_AudioVolume.current.music == 0 then
		self.m_MusicPlayer:Play(sABPath)
	else
		self.m_MusicPlayer:FadePlay(sABPath)
	end
end

--音效
function CAudioCtrl.PlaySound(self, sPath)
	if not sPath then
		return
	end
	local bEnabled = g_SystemSettingsCtrl:GetSitchByIndex(2)
	if not bEnabled then
		return
	end
	
	local sABPath = "Audio/Sound/" .. sPath
	local oAudioPlayer = self:GetSoundPlayer()
	oAudioPlayer:Play(sABPath)
end

-- Rate ==============================================
-- 恢复各音量大小
function CAudioCtrl.ResumeAudioRate(self)
	self.m_AudioRate.current = table.copy(self.m_AudioRate.resume)
	self:ReSetAudioRate()
end

-- 重置各音量大小
function CAudioCtrl.ReSetAudioRate(self)
	self:SetSoloRate(self.m_AudioRate.current.solo)
	self:SetMusicRate(self.m_AudioRate.current.music)
	-- self:SetSoundRate(self.m_AudioRate.current.sound)
end

-- 语音音量
function CAudioCtrl.SetSoloRate(self, iRate)
	self.m_AudioRate.current.solo = iRate
	self.m_SoloPlayer:SetRate(iRate)
	self.m_SoloPlayer2:SetRate(iRate)
end

-- 音乐音量
function CAudioCtrl.SetMusicRate(self, iRate)
	self.m_AudioRate.current.music = iRate
	self.m_MusicPlayer:SetRate(iRate)
end

-- 音效音量
function CAudioCtrl.SetSoundRate(self, iRate)
	self.m_AudioRate.current.sound = iRate

	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		oCachePlayer:SetRate(iRate)
	end
	self.m_NpcPlayer:SetRate(iRate)
end

-- Vol ===============================================

-- 恢复各音量大小
function CAudioCtrl.ResumeAudioVol(self)
	self.m_AudioVolume.current = table.copy(self.m_AudioVolume.resume)
	self:ReSetAudioVol()
end

-- 重置各音量大小
function CAudioCtrl.ReSetAudioVol(self)
	self:SetSoloVol(self.m_AudioVolume.current.solo)
	self:SetMusicVol(self.m_AudioVolume.current.music)
	self:SetSoundVol(self.m_AudioVolume.current.sound)
end

-- 语音音量
function CAudioCtrl.SetSoloVol(self, iVol)
	self.m_AudioVolume.current.solo = iVol
	self.m_SoloPlayer:SetVolume(iVol)
	self.m_SoloPlayer2:SetVolume(iVol)
end

-- 音乐音量
function CAudioCtrl.SetMusicVol(self, iVol)
	self.m_AudioVolume.current.music = iVol
	self.m_MusicPlayer:SetVolume(iVol)
end

-- 音效音量
function CAudioCtrl.SetSoundVol(self, iVol)
	self.m_AudioVolume.current.sound = iVol

	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		oCachePlayer:SetVolume(iVol)
	end
	self.m_NpcPlayer:SetVolume(iVol)
end

--设置静音
function CAudioCtrl.SetSlience(self)
	if self.m_SetSlience then
		return
	end
	self.m_SetSlience = true
	self.m_AudioVolume.resume = table.copy(self.m_AudioVolume.current)
	self.m_AudioVolume.current.music = 0
	self.m_AudioVolume.current.sound = 0
	self:ReSetAudioVol()
end

-- 恢复音量
function CAudioCtrl.ExitSlience(self)
	if not self.m_SetSlience then
		return
	end
	self.m_SetSlience = false
	self:ResumeAudioVol()
end


function CAudioCtrl.GetSoundPlayer(self)
	local oAudioPlayer = nil
	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		if oCachePlayer:IsReuse() then
			oAudioPlayer = oCachePlayer
			break
		end
	end
	if not oAudioPlayer then
		oAudioPlayer = self:CreateSoundPlayer()
		-- oAudioPlayer = AudioTools.CreateAudioPlayer("sound"..tostring(#self.m_SoundPlayerList+1))
		-- table.insert(self.m_SoundPlayerList, oAudioPlayer)
	end
	if oAudioPlayer.m_Rate ~= self.m_AudioRate.current.sound then
		oAudioPlayer:SetRate(self.m_AudioRate.current.sound)
	end
	if oAudioPlayer.m_Vol ~= self.m_AudioVolume.current.sound then
		oAudioPlayer:SetVolume(self.m_AudioVolume.current.sound)
	end
	return oAudioPlayer
end

function CAudioCtrl.CreateSoundPlayer(self)
	local oAudioPlayer = AudioTools.CreateAudioPlayer("sound"..tostring(#self.m_SoundPlayerList+1))
	table.insert(self.m_SoundPlayerList, oAudioPlayer)
	return oAudioPlayer
end

function CAudioCtrl.StopSound(self)
	for i, oCachePlayer in ipairs(self.m_SoundPlayerList) do
		oCachePlayer:Stop()
	end
	self.m_NpcPlayer:Stop()
end

function CAudioCtrl.StopSoloPlay(self)
	if self.m_SoloPlayer:IsPlaying() then
		self.m_SoloPlayer:Stop()
		self:ResumeAudioVol()
	end
	if self.m_SoloPlayer2:IsPlaying() then
		self.m_SoloPlayer2:Stop()
	end
end

function CAudioCtrl.StopSolo(self)
	self.m_SoloPlayer:Stop()
	self.m_SoloPlayer2:Stop()
end

function CAudioCtrl.StopSoundsByPath(self, sPath)
	for i, oPlayer in ipairs(self.m_SoundPlayerList) do
		if oPlayer:IsPlaying() and sPath == oPlayer.m_Path then
			oPlayer:Stop()
		end
	end
end

return CAudioCtrl