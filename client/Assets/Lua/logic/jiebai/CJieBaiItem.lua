local CJieBaiItem = class("CJieBaiItem", CBox)

function CJieBaiItem.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Icon = self:NewUI(1, CSprite)
    self.m_RemoveBtn = self:NewUI(2, CSprite)
    self.m_Lv = self:NewUI(3, CLabel)
    self.m_Name = self:NewUI(4, CLabel)
    self.m_SchoolSprite = self:NewUI(5, CSprite)
    self.m_FriendShip = self:NewUI(6, CLabel)
    self.m_State = self:NewUI(7, CSprite)

    self:InitContent()

end

function CJieBaiItem.InitContent(self)

    self.m_RemoveBtn:AddUIEvent("click", callback(self, "OnClickRemove"))

end

function CJieBaiItem.SetInfo(self, info)
    
    local icon = info.icon
    local name = info.name
    local lv = info.lv
    local friendShip = info.friendShip
    local school = info.school
    local state = info.state
    self.m_Info = info
    self.m_Pid = info.pid
    self.m_Icon:SpriteAvatar(icon)
    self.m_Name:SetText(name)
    self.m_Lv:SetText(lv)
    self.m_FriendShip:SetText("好友度:" .. friendShip)
    self.m_SchoolSprite:SpriteSchool(school)

    local stateName = state == 1 and "h7_yijieshou" or "h7_querenzhong"
    self.m_State:SetSpriteName(stateName)

    local state = g_JieBaiCtrl:GetJieBaiState()
    self.m_RemoveBtn:SetGrey(state == define.JieBai.State.InYiShi)

    self.m_Icon:SetGrey(not g_JieBaiCtrl:IsInviterOnLine(info.pid))

end

function CJieBaiItem.OnClickRemove(self)
    
    local state = g_JieBaiCtrl:GetJieBaiState()

    if state == define.JieBai.State.InYiShi then
        --local tip =  g_JieBaiCtrl:GetTextTip(1008) 
        g_NotifyCtrl:FloatMsg("已发起结拜仪式，不能移除")
        return
    end 

    local tip =  g_JieBaiCtrl:GetTextTip(1008)
    tip = string.gsub(tip, "#role",  self.m_Info.name)
    local windowConfirmInfo = {
        msg = tip,
        okCallback = function()
            g_JieBaiCtrl:C2GSJBKickInvite(self.m_Pid)
        end,    
        pivot = enum.UIWidget.Pivot.Center,
        okStr = "同意",
        cancelStr = "不同意"
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)

end



return CJieBaiItem