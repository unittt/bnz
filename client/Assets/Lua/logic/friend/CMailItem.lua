local CMailItem = class("CMailItem", CBox)
local define = {
    mailtype = {
        normal = 101,
        org    = 102,     
        }
}
function CMailItem.ctor(self, obj, cb)
    CBox.ctor(self, obj)
    self.m_CallBack = cb
    self.m_ItemBG = self:NewUI(1, CSprite)
    self.m_HeadSprite = self:NewUI(2, CSprite)
    self.m_TitleLabel = self:NewUI(3, CLabel)
    self.m_ExpireDateLabel = self:NewUI(4, CLabel)
    self.m_HasAttachSprite = self:NewUI(5, CSprite)
    self.m_BangPaiSprite = self:NewUI(6, CSprite)
    self.m_BgStripe = self:NewUI(7, CSprite)
    self.m_GetSprite = self:NewUI(8, CSprite)
    self.m_SelTitleLabel = self:NewUI(9, CLabel)
end

function CMailItem.SetBoxInfo(self, mail)
    if mail == nil then
        printerror("CMailItem.SetBoxInfo, mail == nil")
        return
    end
    self.m_Mail = mail
    local title = mail.title
    local expireDate = g_MailCtrl:GetFullTime(mail.validtime)
    local opened = mail.opened or g_MailCtrl.MAIL_STATUS.UNOPENED
    local hasAttach = mail.hasattach
    -- 已读（背景、图标）
    if opened == g_MailCtrl.MAIL_STATUS.OPENED then
        self:SetOpened()
        self.m_TitleLabel:SetText("[5C6163]"..title.."[-]")
    else
        self:SetNoOpen() 
        self.m_TitleLabel:SetText("[244B4EFF]"..title.."[-]")
    end
    self.m_SelTitleLabel:SetText("[bd5733FF]"..title.."[-]")
    -- 帮派图标（默认使用一般邮件图标）
    if self.m_Mail.mailtype == define.mailtype.org then --101普通邮件，102帮派邮件
        self.m_BangPaiSprite:SetActive(true)
    else
        self.m_BangPaiSprite:SetActive(false)
    end
    -- 到期时间
    self.m_ExpireDateLabel:SetText("过期时间：" .. expireDate)
    -- 是否包含附件（默认显示）
    if hasAttach == g_MailCtrl.ATTACH_STATUS.HAS_ATTACH then  --有附件   
        self.m_HasAttachSprite:SetActive(true) 
    elseif hasAttach == g_MailCtrl.ATTACH_STATUS.ATTACH_RETRIEVED then
        self.m_HasAttachSprite:SetActive(false)   
        self.m_GetSprite:SetActive(true)
    else --无附件
        self.m_GetSprite:SetActive(false)
        self.m_HasAttachSprite:SetActive(false)
    end
end

function CMailItem.SetNoOpen(self)
    --self.m_ItemBG:SetGrey(false
    self.m_GetSprite:SetActive(false)
    self.m_ItemBG:SetSpriteName("h7_di_2")
    self.m_HeadSprite:SetSpriteName("h7_xinfeng_1")
    self.m_HasAttachSprite:SetActive(true)
    self.m_BgStripe:SetActive(true)
end

function CMailItem.SetOpened(self)
    self.m_ItemBG:SetSpriteName("h7_di_12")
    --self.m_ItemBG:SetGrey(true)
    self.m_GetSprite:SetActive(true)
    self.m_HeadSprite:SetSpriteName("h7_xinfeng_6")
    self.m_HasAttachSprite:SetActive(false)
    self.m_BgStripe:SetActive(false)
end

function CMailItem.ItemCallBack(self)
    if self.m_CallBack then
        self.m_CallBack(self.m_Mail)
    end
end

return CMailItem