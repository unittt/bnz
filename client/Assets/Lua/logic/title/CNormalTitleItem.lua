local CNormalTitleItem = class("CNormalTitleItem", CBox)

function CNormalTitleItem.ctor(self, obj, cb)
    CBox.ctor(self, obj)
    self.m_CallBack2     = cb
    self.m_ItemBG        = self:NewUI(1, CSprite)
    self.m_WearingSprite = self:NewUI(2, CSprite)
    self.m_TitleLabel    = self:NewUI(3, CLabel)
    self.m_SelTitleLabel = self:NewUI(4, CLabel)
    self.m_TitleSprite   = self:NewUI(5, CSprite)
    self.m_Id            = nil
    self.m_Name          = nil
    self:InitContent()
end

function CNormalTitleItem.InitContent(self)
    self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))
end

function CNormalTitleItem.SetGroup(self, groupId)
    self.m_ItemBG:SetGroup(groupId)
end

function CNormalTitleItem.SetBoxInfo(self, title, callback)
    self.m_Id = title.tid
    self.m_Name = title.name
    -- 佩戴中
    self.m_WearingSprite:SetActive(g_TitleCtrl:IsWearing(title.tid))
    if data.titledata.INFO[self.m_Id].type == 0 then --普通称谓
        self.m_TitleSprite:SetActive(false)
        self.m_SelTitleLabel:SetActive(true)
        self.m_TitleLabel:SetActive(true)
        self.m_TitleLabel:SetText(title.name)
        self.m_SelTitleLabel:SetText(title.name)
    else  --特殊称谓
        self.m_TitleLabel:SetActive(false)
        self.m_SelTitleLabel:SetActive(false)
        self.m_TitleSprite:SetActive(true)
        self.m_TitleSprite:SetSpriteName(tostring(data.titledata.INFO[self.m_Id].icon))
    end
    self.m_CallBack = callback
end

function CNormalTitleItem.ItemCallBack(self)
    if self.m_CallBack then
        self.m_CallBack()
    end
end

function CNormalTitleItem.SetSelected(self, flag)
    self.m_ItemBG:SetSelected(flag)
    if self.m_CallBack2 then
        self.m_CallBack2()
    end
    if flag then
        --self.m_TitleLabel:SetColor(Color.white)
    end
end

function CNormalTitleItem.UpdateWearingSprite(self)
    if g_TitleCtrl:IsWearing(self.m_Id) then
        self.m_WearingSprite:SetActive(true)
        self.m_ItemBG:SetSelected(true)   
    else
        self.m_WearingSprite:SetActive(false)
        self.m_ItemBG:SetSelected(false)  
    end 
end

function CNormalTitleItem.SetNoWearSprite(self)
     self.m_WearingSprite:SetActive(false)
end

function CNormalTitleItem.ResetLabelColor(self)
   -- self.m_TitleLabel:SetColor(Color.RGBAToColor("B96650"))
end

return CNormalTitleItem