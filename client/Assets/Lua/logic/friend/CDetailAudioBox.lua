local CDetailAudioBox = class("CDetailAudioBox", CBox)

function CDetailAudioBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_PlayLength = self:NewUI(1, CLabel)
    self.m_PlayIcon = self:NewUI(2, CSprite)
    self.m_TranslateLabel = self:NewUI(3, CLabel)
    self.m_TranslateBtn = self:NewUI(4, CButton)
    self.m_AudioData= {}
    self:AddUIEvent("click", callback(self, "OnPlayAudio"))
    self.m_TranslateBtn:AddUIEvent("click", callback(self, "OnTranslate"))
    self.m_PlayIcon:PauseSpriteAnimation()
    self.m_TranslateLabel:SetText("")
    self.m_PlayLength:SetActive(false)
    self.m_IsPlaying = false
    g_SpeechCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CDetailAudioBox.SetData(self, data)
    self.m_AudioData = data
    if self.m_AudioData.time then
        self.m_PlayLength:SetActive(true)
        self.m_PlayLength:SetText(self.m_AudioData.time.."''")
    else
        self.m_PlayLength:SetActive(false)
    end
end

function CDetailAudioBox.OnPlayAudio(self)
    --printc("播放语音")
    if next(self.m_AudioData) == nil then
        return
    end
    g_SpeechCtrl:PlayLocalWithKey(self.m_AudioData.key) --"speech11--137007770"
    self.m_PlayIcon:StartSpriteAnimation()
    self.m_IsPlaying = true
end

function CDetailAudioBox.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Chat.Event.EndPlayAudio then
        self.m_PlayIcon:PauseSpriteAnimation()
		self.m_PlayIcon:SetSpriteName("#500_02")
        self.m_IsPlaying = false
	end
end

function CDetailAudioBox.OnTranslate(self)
    if next(self.m_AudioData) == nil then
        return
    end
    --self.m_TranslateLabel:SetActive(true)
    self.m_TranslateLabel:SetText(" "..self.m_AudioData.translate)    
end

function CDetailAudioBox.OnClose(self)
    if self.m_IsPlaying then
        g_AudioCtrl:StopSoloPlay()
    end
end

return CDetailAudioBox