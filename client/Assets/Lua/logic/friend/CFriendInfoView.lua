local CFriendInfoView = class("CFriendInfoView", CViewBase)

function CFriendInfoView.ctor(self, cb)
    CViewBase.ctor(self, "UI/Friend/FriendInfoView.prefab", cb)
    self.m_DepthType = "Dialog"
    --self.m_GroupName = "main"
    --g_MailCtrl.m_DontCloseDetailView = false
end

--创建CFriendInfoView回调，只在创建界面时执行一次
function CFriendInfoView.OnCreateView(self)
    self.m_Container = self:NewUI(1, CWidget)
    self.m_Brief = self:NewUI(2, CBriefView, true, callback(self, "GetSelf"), callback(self, "GetDetailContainer"))
    self.m_Detail = self:NewUI(3, CDetailMailBox)
    self.m_CloseBtn = self:NewUI(4, CButton, true, false)
    self:InitContent()
    
    local tween = self.m_Container:GetComponent(classtype.TweenPosition)
    tween.enabled = true
    self.m_Container:SetLocalPos(Vector3.New(-560, 0, 0))
    tween.from = Vector3.New(-560, 0, 0)
    tween.to = Vector3.New(0, 0, 0)
    tween.duration = 0.2
    tween:ResetToBeginning()
    -- tween.delay = define.Task.Time.MoveDown
    tween:PlayForward()
    tween.onFinished = function ()
        tween.enabled = false
        self:ResizeWindow()
    end
    g_ScreenResizeCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "ResizeWindow"))
end

function CFriendInfoView.ResizeWindow(self)
    if C_api.ScreenResizeManager.Instance:IsNeedResize() then
        g_ScreenResizeCtrl:ResizePanel(self.m_GameObject)
        -- local bg = transform.Find("ModuleBgBoxCollider(Clone)")
        -- if bg ~= nil then
        --     C_api.ScreenResizeManager.Instance:ScreenFilling(bg.GetComponent<UIWidget>())
        -- end
    end
end

--初始化执行
function CFriendInfoView.InitContent(self)
    -- UITools.ResizeToRootSize(self.m_Container)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseClicked"))
    self.m_Detail:SetActive(false)
end

--获取CFriendInfoView本身
function CFriendInfoView.GetSelf(self)
    return self
end

--打开聊天界面
function CFriendInfoView.ShowTalk(self, pid)
    self.m_Brief:ShowTalk(pid)
end

function CFriendInfoView.ShowRecent(self)
     self.m_Brief:ShowRecent()
end

--打开邮件界面
function CFriendInfoView.ShowMail(self)
    self.m_Brief:ShowMail()
end

--获取CDetailView界面，也就是邮件详情界面
function CFriendInfoView.GetDetailContainer(self)
    return self.m_Detail
end

--点击关闭好友界面按钮
function CFriendInfoView.OnCloseClicked(self)
    local tween = self.m_Container:GetComponent(classtype.TweenPosition)
    tween.enabled = true
    tween.from = Vector3.New(0, 0, 0)
    tween.to = Vector3.New(-560, 0, 0)
    tween.duration = 0.2
    tween:ResetToBeginning()
    -- tween.delay = define.Task.Time.MoveDown
    tween:PlayForward()
    tween.onFinished = function ()
        tween.enabled = false
        self:CloseBrief()
        self.m_Detail:OnClose()
        self:OnClose()
    end
end

-- --关闭CBriefView，即主体的界面，包含CFriendPart、CRecentPart等等
function CFriendInfoView.CloseBrief(self)
    self.m_Brief:ClosePart()
end

return CFriendInfoView