local CMarryXTGiftView = class("CMarryXTGiftView", CViewBase)

function CMarryXTGiftView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Marry/MarryXTGiftView.prefab", cb)

    self.m_DepthType = "Dialog"
    self.m_ExtendClose = "Black"
end

function CMarryXTGiftView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_PlayerIcon = self:NewUI(2, CSprite)
    self.m_LvL = self:NewUI(3, CLabel)
    self.m_NameL = self:NewUI(4, CLabel)
    self.m_FriendDegreeL = self:NewUI(5, CLabel)
    self.m_ItemBox = self:NewUI(6, CBox)
    self.m_EmojiBtn = self:NewUI(7, CButton)
    self.m_Input = self:NewUI(8, CInput)
    self.m_GiftBtn = self:NewUI(9, CButton)
    self.m_FriendBtn = self:NewUI(10, CButton)
    self.m_AmountBox = self:NewUI(11, CAmountSettingBox)
    self.m_CurAmount = 1
    self.m_MaxAmount = 10
    self.m_CurFriendInfo = nil

    self:InitContent()
end

function CMarryXTGiftView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_Input:AddUIEvent("select", callback(self, "OnFocusInput"))
    self.m_GiftBtn:AddUIEvent("click", callback(self, "OnSubmit"))
    self.m_FriendBtn:AddUIEvent("click", callback(self, "ShowFriendList"))
    self.m_EmojiBtn:AddUIEvent("click", callback(self, "OnEmoji"))
    g_MarryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMarryCtrl"))
    g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrl"))

    local oInputCpn = self.m_Input.m_UIInput
    if oInputCpn then
        oInputCpn.activeTextColor = Color.RGBAToColor("a64e00")
    end
    self.m_Input.m_ColorStr = ''
    self.m_Input:SetText(g_MarryCtrl:GetMarryText(2057))

    self.m_AmountBox:SetValue(self.m_CurAmount)
    self.m_AmountBox.m_MinFloatMsg = "不能再减少了"
    self.m_AmountBox:SetCallback(function(iVal)
        if Utils.IsNil(self) then
            return
        end
        if iVal ~= self.m_CurAmount then
            self.m_CurAmount = iVal
            self:RefreshFriendDegree()
        end
    end)

    self:RefreshItemBox()
    self:InitDefaultFriend()
    local iCnt = g_ItemCtrl:GetBagItemAmountByBindingState(g_MarryCtrl.m_XtId)
    self:RefreshXTAmount(iCnt)
    self:SetOperaMode()
end

function CMarryXTGiftView.OnMarryCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Engage.Event.SelectXTPresentPlayer then
        local iPid = oCtrl.m_EventData or 0
        if iPid ~= (self.m_CurFriendInfo and self.m_CurFriendInfo.pid) then
            local dFriend = g_FriendCtrl:GetFriend(iPid)
            if dFriend then
                self.m_CurFriendInfo = dFriend
                self:RefreshFriendInfo(dFriend)
            end
        end
    end
end

function CMarryXTGiftView.OnItemCtrl(self, oCtrl)
    if oCtrl.m_EventID == define.Item.Event.AddItem or oCtrl.m_EventID == define.Item.Event.ItemAmount or oCtrl.m_EventID == define.Item.Event.DelItem then
        local iCnt = g_ItemCtrl:GetBagItemAmountByBindingState(g_MarryCtrl.m_XtId)
        if iCnt ~= self.m_XtAmount then
            self:RefreshXTAmount(iCnt)
        end
    end
end

function CMarryXTGiftView.InitDefaultFriend(self)
    local lFriend = g_FriendCtrl:GetMyFriend()
    local dSel = nil
    for i, v in ipairs(lFriend) do
        local dFriend = g_FriendCtrl:GetFriend(v)
        if dSel then
            if dSel.friend_degree < dFriend.friend_degree then
                dSel = dFriend
            end
        else
            dSel = dFriend
        end
    end
    self.m_CurFriendInfo = dSel
    self:RefreshFriendInfo(dSel)
end

function CMarryXTGiftView.RefreshXTAmount(self, iCnt)
    self.m_XtAmount = iCnt
    local sText, iRange
    if iCnt >= self.m_MaxAmount then
        sText = string.FormatString(g_MarryCtrl:GetMarryText(2047), {count = self.m_MaxAmount}, true)
        iRange = self.m_MaxAmount
    else
        sText = string.FormatString(g_MarryCtrl:GetMarryText(2058), {count = iCnt}, true)
        iRange = iCnt
    end
    self.m_AmountBox:SetAmountRange(1, iRange)
    self.m_AmountBox.m_MaxFloatMsg = sText
    self.m_ItemBox.cntL:SetText(self.m_XtAmount)
end

function CMarryXTGiftView.RefreshItemBox(self)
    local dItem = DataTools.GetItemData(g_MarryCtrl.m_XtId)
    local oBox = self.m_ItemBox
    oBox.iconSpr = oBox:NewUI(1, CSprite)
    oBox.qualitySpr = oBox:NewUI(2, CSprite)
    oBox.cntL = oBox:NewUI(3, CLabel)
    oBox.nameL = oBox:NewUI(4, CLabel)
    oBox.descL = oBox:NewUI(5, CLabel)

    oBox.iconSpr:SpriteItemShape(dItem.icon)
    oBox.qualitySpr:SetItemQuality(dItem.quality)
    oBox.cntL:SetText(self.m_XtAmount)
    oBox.nameL:SetText(dItem.name)
    oBox.descL:SetText(dItem.description)
end

function CMarryXTGiftView.RefreshFriendInfo(self, dFriend)
    self.m_PlayerIcon:SpriteAvatar(dFriend.icon)
    self.m_LvL:SetText(dFriend.grade.."级")
    self.m_NameL:SetText(dFriend.name)
    self:RefreshFriendDegree(dFriend.friend_degree)    
end

function CMarryXTGiftView.RefreshFriendDegree(self, iDegree)
    if not iDegree then
        iDegree = self.m_CurFriendInfo and self.m_CurFriendInfo.friend_degree
    end
    if iDegree then
        -- local iAddPt = self.m_CurAmount * 30
        self.m_FriendDegreeL:SetText(string.format("[af302a]%d[-]", iDegree))
        --(string.format("[af302a]%d[-][1d8e00]+%d[-]", iDegree, iAddPt))    
    end
end

function CMarryXTGiftView.SetOperaMode(self)
    local bOpera = self.m_XtAmount ~= 1
    self.m_GiftBtn:SetEnabled(bOpera)
    self.m_FriendBtn:SetEnabled(bOpera)
    self.m_GiftBtn:SetBtnGrey(not bOpera)
    if not bOpera then
        CMarryXTFriendListView:ShowView(function(oView)
            oView:RefreshFriends(self.m_CurAmount, true)
        end)
    end
end

----------------------- ui events ----------------------
function CMarryXTGiftView.ShowFriendList(self)
    CMarryXTFriendListView:ShowView(function(oView)
        oView:RefreshFriends(self.m_CurAmount)
    end)
end

function CMarryXTGiftView.AppendText(self, s)
    if string.match(s, "%b{}") then
        self.m_Input:ClearLink()
    end
    local sOri = self.m_Input:GetText()
    local _, count = string.gsub(sOri..s, "#%d+", "")
    if count > 5 then
        g_NotifyCtrl:FloatMsg(data.barragedata.TEXT[define.Barrage.Text.MaxEmoji].content)
        return
    end
    self.m_Input:SetText(sOri..s)
end

function CMarryXTGiftView.OnEmoji(self)
    self.m_Input.m_UIInput.isSelected = true
    COnlyEmojiView:ShowView(
        function(oView)
            oView:SetSendFunc(callback(self, "AppendText"))
            UITools.NearTarget(self.m_EmojiBtn, oView.m_RightWidget, enum.UIAnchor.Side.Bottom)
        end
    )
end

function CMarryXTGiftView.OnSubmit(self)
    if not self.m_CurFriendInfo then
        return
    end
    local sText = self.m_Input:GetText()
    if sText == "" then
        g_NotifyCtrl:FloatMsg("请输入文本")
        return
    elseif g_MaskWordCtrl:IsContainMaskWord(self.m_Input:GetText()) then
        g_MarryCtrl:MarryFloatMsg(2059)
        return
    end
    COnlyEmojiView:CloseView()
    g_MarryCtrl:ShowXTComfirm({
        amount = self.m_CurAmount,
        name = self.m_CurFriendInfo.name,
        pid = self.m_CurFriendInfo.pid,
        text = sText,
        cb = callback(self, "OnClose"),
    })
end

function CMarryXTGiftView.OnFocusInput(self)
    if self.m_Input.m_UIInput.isSelected then
        self.m_Input.m_UIInput.selectAllTextOnFocus = true
    end
end

function CMarryXTGiftView.OnClose(self)
    local oView = CMarryXTFriendListView:GetView()
    if oView then
        oView:CloseView()
    end
    self:CloseView()
end

return CMarryXTGiftView