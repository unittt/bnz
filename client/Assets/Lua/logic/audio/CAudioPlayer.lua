local CAudioPlayer = class("CAudioPlayer", CObject)

function CAudioPlayer.ctor(self)
	local gameObject = UnityEngine.GameObject.New()
	CObject.ctor(self, gameObject)
	self.m_AidoSource = self:AddComponent(classtype.AudioSource)
	self.m_Timer = nil
	self.m_StopPlayCb = nil
	self.m_FadePath = nil
	self.m_IsPlaying = false
	self.m_Path = nil
	self.m_IsLoading = false
	self.m_Length = 0
	self.m_Vol = self.m_AidoSource.volume
	self.m_Rate = 1
	self.m_MinTime = 1.5
end

function CAudioPlayer.FadePlay(self, sPath)
	self.m_FadePath = sPath
	if self.m_Path == sPath then
		DOTween.DOKill(self.m_Transform, true)
	else
		local function fadeup()
			if self.m_FadePath then
				self.m_AidoSource.volume = 0.4
				self:Play(self.m_FadePath)
				local tween = DOTween.DOFade(self.m_AidoSource, self:GetRealVolume(), 1.6)
				DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
				self.m_FadePath = nil
			end
		end

		DOTween.DOKill(self.m_Transform, false)
		if self:IsPlaying() then
			local tween = DOTween.DOFade(self.m_AidoSource, 0.4, 1.6)
			DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
			DOTween.OnComplete(tween, fadeup)
		else
			fadeup()
		end
	end
end

function CAudioPlayer.Play(self, sPath, scheduleed)
	if self.m_Path == sPath then
		return
	end
	self.m_Path = sPath
	self.m_IsLoading = true

	local function loadFinish(clip, path)
		self.m_IsLoading = false
		if clip and self.m_Path == path then
			self:SetClip(clip, scheduleed)
		end
	end

	if string.find(sPath, "Audio/Music/") then
		g_ResCtrl:LoadAsync(sPath, loadFinish)
	else
		g_ResCtrl:Load(sPath, loadFinish)
	end
end

function CAudioPlayer.SetClip(self, clip, scheduleed)
	if self.m_AidoSource.clip then
		g_ResCtrl:DelManagedAsset(self.m_AidoSource.clip, self.m_GameObject)
	end
	self.m_AidoSource.clip = clip
	self.m_Length = clip and clip.length or 0
	if clip then
		local oAssetInfo = g_ResCtrl:AddManageAsset(clip, self.m_GameObject, self.m_Path)
		-- 部分音频不清除
		if not oAssetInfo:IsDontRelease() and self.m_Path and
			string.find(self.m_Path, "UI/") then
			oAssetInfo:SetDontRelease(true)
		end
	end
	if self.m_AidoSource.clip then
		-- UI音效只实例化一个，需要关闭其它正在播放该音效的player
		if self.m_Path and string.find(self.m_Path, "UI/") then
			g_AudioCtrl:StopSoundsByPath(self.m_Path)
		end
		if scheduleed then
			self.m_AidoSource:PlayScheduled(0.25)
		else
			self.m_AidoSource:Play()
		end
		self.m_IsPlaying = true
	else
		self.m_IsPlaying = false
	end
	self:ResetTimer()
end

function CAudioPlayer.Stop(self)
	self.m_AidoSource:Stop()
	self:OnStopPlay()
end

function CAudioPlayer.SetStopCb(self, cb)
	self.m_StopPlayCb = cb
end

function CAudioPlayer.IsPlaying(self)
	return self.m_IsPlaying
end

function CAudioPlayer.IsReuse(self)
	return not self:IsPlaying() and not self.m_IsLoading
end

function CAudioPlayer.SetLoop(self, bLoop)
	self.m_AidoSource.loop = bLoop
	self:ResetTimer()
end

function CAudioPlayer.GetLoop(self)
	return self.m_AidoSource.loop
end

function CAudioPlayer.ResetTimer(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	if self.m_AidoSource.clip and not self.m_Pause and not self:GetLoop() and self.m_Length > 0 then
		local time = self.m_Length - self.m_AidoSource.time
		-- 定时器不准，防止音频过短，导致几乎没播放就被stop
		time = math.max(time, self.m_MinTime)
		self.m_Timer = Utils.AddTimer(callback(self, "OnStopPlay"), 0, time)
	end
end

function CAudioPlayer.Pause(self)
	self.m_Pause = true
	self.m_AidoSource:Pause()
	self:ResetTimer()
end

function CAudioPlayer.UnPause(self)
	self.m_Pause = false
	self.m_AidoSource:UnPause()
	self:ResetTimer()
end

function CAudioPlayer.OnStopPlay(self)
	if self.m_StopPlayCb then
		self.m_StopPlayCb(self)
	end
	self.m_IsPlaying = false
	self.m_Path = nil
	self:SetClip(nil)
end

function CAudioPlayer.SetRate(self, iRate)
	self.m_Rate = iRate
	self.m_AidoSource.volume = self.m_Vol * iRate
end

function CAudioPlayer.SetVolume(self, iVol)
	self.m_Vol = iVol
	self.m_AidoSource.volume = iVol * self.m_Rate
end

function CAudioPlayer.GetVolume(self)
	return self.m_Vol
end

function CAudioPlayer.GetRealVolume(self)
	return self.m_Vol * self.m_Rate
end

return CAudioPlayer