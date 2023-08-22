local CWishBottleInputPart = class("CWishBottleInputPart", CPageBase)

function CWishBottleInputPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_EmojiBtn = self:NewUI(1, CButton)
    self.m_SpeechBtn = self:NewUI(2, CButton)
    self.m_Input = self:NewUI(3, CChatInput,true,define.Chat.WishBottleInputArgs)
    self.m_SendBtn = self:NewUI(4, CButton)
    self.m_RemainTime = self:NewUI(5, CLabel)
    self:SetInputCol()
    self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
    self.m_SpeechBtn:AddUIEvent("press", callback(self, "OnSpeech"))
    self.m_Input:AddUIEvent("submit", callback(self, "OnSubmit"))
    self.m_SendBtn:AddUIEvent("click", callback(self, "OnSubmit"))
    self.m_Input:AddUIEvent("select", callback(self, "OnFocusInput"))
    self.m_Input:AddUIEvent("click", callback(self, "ClearDefaultInput"))
end

function CWishBottleInputPart.SetInputCol(self)
    self.m_Input.m_ColorStr = ''
    local oInputCpn = self.m_Input.m_UIInput
    if not oInputCpn then return end
    oInputCpn.activeTextColor = Color.RGBAToColor("808080")
end

function CWishBottleInputPart.SetInfo(self, dInfo)
    self.m_BottleId = dInfo.bottleId
    -- self.m_Input:SetCharLimit(60)
    local sOri = g_WishBottleCtrl:GetInputCache()
    if sOri and string.len(sOri) > 0 then
        self.m_Input:SetText(sOri)
        self.m_Clicked = true
    else
        self.m_Input:SetText(DataTools.GetMiscText(1001, "BOTTLE").content)
    end
    self:RefreshTime(dInfo.timeOut)
    print("bottle SetInfo Clicked ------- ", self.m_Clicked)
    -- self:AddChangeCb()
end

function CWishBottleInputPart.RefreshTime(self, time)
    if self.m_RefreshTimer then
        Utils.DelTimer(self.m_RefreshTimer)
        self.m_RefreshTimer = nil
    end
    self.m_RefreshTimer = Utils.AddTimer(callback(self, "UpdateTime", time), 1, 0)
end

function CWishBottleInputPart.UpdateTime(self, time)
    local iDiffTime = os.difftime(time, g_TimeCtrl:GetTimeS())
    if iDiffTime > 0 then
        self.m_RemainTime:SetText(string.format("(%s)",os.date("%M:%S",iDiffTime)))
        return true
    else
        self.m_RemainTime:SetText("(00:00)")
        g_WishBottleCtrl:UpdateBottleId(-1)
        return false
    end
end

function CWishBottleInputPart.OnSubmit(self)
    local sText = self.m_Input:GetText()
    if sText == "" and self.m_Clicked then
        g_NotifyCtrl:FloatMsg(DataTools.GetMiscText(1003, "BOTTLE").content)
        return
    else
        local linkStr = {}
        for sLink in string.gmatch(sText, "%b{}") do
            table.insert(linkStr, sLink)
        end
        sText = string.gsub(sText, "#%u", "")
        sText = string.gsub(sText, "#n", "")
        sText = g_ChatCtrl:BlockColorInput(sText)
        if string.utfStrlen(sText) > 30 and self.m_Clicked then
            g_NotifyCtrl:FloatMsg("输入内容超过30字，请重新输入")
            return
        end
        sText = g_MaskWordCtrl:ReplaceMaskWord(sText)
        -- limit emoji count
        local iEmojiCnt = 0
        -- local iLenR = self:GetTextLen(sText)
        -- for sEmj in string.gmatch(sText, "#%d+") do
        --     iEmojiCnt = iEmojiCnt + 1
        --     iLenR = iLenR + 4 - string.len(sEmj)
        -- end
        -- if iLenR > 80 then
        --     local iSub = iEmojiCnt - math.ceil((iLenR - 80)/4)
        --     iEmojiCnt = 0
        --     local function subFunc(s)
        --         iEmojiCnt = iEmojiCnt + 1
        --         if iEmojiCnt > iSub then
        --             return ""
        --         else
        --             return s
        --         end
        --     end
        --     sText = string.gsub(sText, "#%d+", subFunc)
        -- end
        sText = string.gsub(sText, "#%d+", function(s)
            iEmojiCnt = iEmojiCnt + 1
            if iEmojiCnt > 5 then
                return ""
            else
                return s
            end
        end)

        local index = 1
        for sLink in string.gmatch(sText, "%b{}") do
            if linkStr[index] then
                sText = string.replace(sText, sLink, linkStr[index])
            end
            index = index + 1
        end
    end
    g_WishBottleCtrl:SendMsg(self.m_BottleId, sText)
    self.m_Input:SetText("")
    self.m_Input.m_RealText = ""
    COnlyEmojiView:CloseView()
end

function CWishBottleInputPart.GetTextLen(self, str)
    local len = #str
    local left = len 
    local cnt = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local temp = string.byte(str, -left)
        local i = #arr
        while arr[i] do
            if temp >= arr[i] then
                left = left - i
                if i > 1 then
                    cnt = cnt + 1
                end
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function CWishBottleInputPart.OnEmoji(self)
    self:ClearDefaultInput()
    self.m_Input.m_UIInput.isSelected = true
    self.m_Input.m_UIInput:RemoveFocus()
    COnlyEmojiView:ShowView(
        function(oView)
            oView:SetSendFunc(callback(self, "AppendText"))
            UITools.NearTarget(self.m_EmojiBtn, oView.m_RightWidget, enum.UIAnchor.Side.Bottom)
        end
    )
end

function CWishBottleInputPart.ClearDefaultInput(self)
    printtrace("bottle clear default ------- ", self.m_Clicked)
    if not self.m_Clicked then
        self.m_Clicked = true
        self.m_Input:SetText("")
        self.m_Input.m_RealText = ""
        self.m_Input.m_ChildLabel:SetLocalPos(Vector3.New(define.Chat.WishBottleInputArgs.Posx,0,0))
    end
    print("bottle clear end ------- ", self.m_Clicked)
end

function CWishBottleInputPart.AppendText(self, s, isClearInput)
    if string.match(s, "%b{}") then
        self.m_Input:ClearLink()
    end
    if isClearInput then
        self.m_Input:SetText(s)
    else
        if self.m_Input:GetInputLength() + string.len(s) <= 60 then
            local sOri = self.m_Input:GetText()
            self.m_Input:SetText(sOri..s)
        end
    end
end

function CWishBottleInputPart.OnSpeech(self, oBtn, bPress)
    if bPress then
        g_ChatCtrl.m_IsChatRecording = true
        self:StartRecord(oBtn)
    else
        g_ChatCtrl.m_IsChatRecording = false
        self:EndRecord()
    end
end

function CWishBottleInputPart.OnFocusInput(self)
    print("bottle OnFocusInput ------- ", self.m_Clicked)
    self.m_Input:SetDefaultText("")
    self:ClearDefaultInput()
    -- if self.m_Input.m_UIInput.isSelected then
    --     COnlyEmojiView:CloseView()
    -- end
end

function CWishBottleInputPart.StartRecord(self, oBtn)
    g_AudioCtrl:SetSlience()
    CSpeechRecordView:CloseView()
    CSpeechRecordView:ShowView(function(oView)
        oView:SetRecordBtn(oBtn)
        oView:BeginRecordWithArgs({bottle = self.m_BottleId}, self, 18)
    end)
end

function CWishBottleInputPart.EndRecord(self)
    g_AudioCtrl:ExitSlience()
    local oView = CSpeechRecordView:GetView()
    if oView then
        oView:EndRecordWithArgs({bottle = self.m_BottleId})
    end
end

function CWishBottleInputPart.Clean(self)
    if self.m_RefreshTimer then
        Utils.DelTimer(self.m_RefreshTimer)
        self.m_RefreshTimer = nil
    end
    if g_AudioCtrl.m_SetSlience then
        g_AudioCtrl:ExitSlience()
    end
    CSpeechRecordView:CloseView()
    if self.m_MsgTimer then
        Utils.DelTimer(self.m_MsgTimer)
        self.m_MsgTimer = nil
    end
    -- 记录输入
    if self.m_Clicked then
        local sOri = self.m_Input:GetText()
        -- if sOri and string.len(sOri)>0 then
        g_WishBottleCtrl:SetInputCache(sOri)
        -- end
    end
end

function CWishBottleInputPart.AddChangeCb(self)
    self.m_Input.m_ChangeCb = function()
        if self.m_Input:GetInputLength() >= 60 then
            if not self.m_ShowingMsg then
                if self.m_MsgTimer then
                    Utils.DelTimer(self.m_MsgTimer)
                    self.m_MsgTimer = nil
                end
                self.m_MsgTimer = Utils.AddTimer(function()
                    self.m_ShowingMsg = false
                end, 0, 0.5)
                self.m_ShowingMsg = true
                g_NotifyCtrl:FloatMsg("输入字数已到达上限")
            end
        end
    end
end

return CWishBottleInputPart