local CSpecialTitleItem = class("CSpecialTitleItem", CBox)

function CSpecialTitleItem.ctor(self, obj, cb)
    CBox.ctor(self, obj)
    self.m_CallBack      = cb
    self.m_ItemBG        = self:NewUI(1, CSprite)
    self.m_WearingSprite = self:NewUI(2, CSprite)
    self.m_TitleSprite   = self:NewUI(3, CSprite)
    self.m_Id            = nil
    self.m_Name          = nil
    self:InitContent()
end

function CSpecialTitleItem.InitContent(self)
    self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))

end

function CSpecialTitleItem.SetGroup(self, groupId)
    self.m_ItemBG:SetGroup(groupId)
end

function CSpecialTitleItem.SetBoxInfo(self, title, callback)
    self.m_Id = title.tid
    self.m_Name = title.name

    -- 佩戴中
    self.m_WearingSprite:SetActive(g_TitleCtrl:IsWearing(title.tid))

    -- 称谓美术图
    self:SetSpecialTitleSprite()
    self.m_CallBack = callback
end

function CSpecialTitleItem.ItemCallBack(self)
    if self.m_CallBack then
        self.m_CallBack()
    end
end


function CSpecialTitleItem.SetSelected(self, flag)
    self.m_ItemBG:SetSelected(flag)
end

function CSpecialTitleItem.UpdateWearingSprite(self)
    if g_TitleCtrl:IsWearing(self.m_Id) then
        self.m_WearingSprite:SetActive(true)
        self.m_ItemBG:SetSelected(true) 
    else
        self.m_WearingSprite:SetActive(false)
        self.m_ItemBG:SetSelected(false)
    end
end

function CSpecialTitleItem.SetNoWearSprite(self)
    self.m_WearingSprite:SetActive(false)
end

function CSpecialTitleItem.SetSpecialTitleSprite(self)
    local iconid = data.titledata.INFO[self.m_Id].icon
    if iconid ~= nil then
        self.m_TitleSprite:SetSpriteName(tostring(iconid))
    end
end

return CSpecialTitleItem