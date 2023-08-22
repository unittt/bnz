local CAttachItem = class("CAttachItem", CBox)

function CAttachItem.ctor(self, obj)
    CBox.ctor(self, obj)
    
    self.m_ItemBG         = self:NewUI(1, CSprite)
    self.m_Sprite         = self:NewUI(2, CSprite)
    self.m_CountLabel     = self:NewUI(3, CLabel)
    self.m_ReceivedSprite = self:NewUI(4, CSprite)

    self.m_Type  = nil
    self.m_Sid   = nil
    self.m_Count = nil
    self.m_ItemBG:AddUIEvent("click", callback(self, "ItemCallBack"))
end

function CAttachItem.SetGroup(self, groupId)
    self.m_ItemBG:SetGroup(groupId)
end

function CAttachItem.SetBoxInfo(self, attach, hasAttach)
    self.m_Type = attach.type
    self.m_Sid = attach.sid
    self.m_Count = attach.val
    local itemdata = DataTools.GetItemData(self.m_Sid)
    if self.m_Type == 1 then --物品
        self.m_Sprite:SpriteItemShape(itemdata.icon)   
    elseif self.m_Type == 2 then
        --printc("金币类型："..tostring(itemdata.icon))
        self.m_Sprite:SpriteItemShape(itemdata.icon)
    elseif self.m_Type == 3 then  --宠物
        self.m_Sprite:DynamicSprite("Avatar", data.summondata.INFO[self.m_Sid].shape)  
    end
    self:SetRetrieved(hasAttach)
    -- 数量
    self.m_CountLabel:SetText(string.numberConvert(self.m_Count))
    -- if self.m_Count > 1 then
        self.m_CountLabel:SetActive(true)
    -- else
    --     self.m_CountLabel:SetActive(false)
    -- end
end

function CAttachItem.SetRetrieved(self, hasAttach)
    if hasAttach == g_MailCtrl.ATTACH_STATUS.HAS_ATTACH then
        self.m_Sprite:SetGrey(false)
        self.m_ReceivedSprite:SetActive(false)
        self.m_ItemBG:SetEnabled(true)
    else
        self.m_Sprite:SetGrey(true)
        self.m_ReceivedSprite:SetActive(true)
        self.m_ItemBG:SetEnabled(true)
    end
end

function CAttachItem.ItemCallBack(self)
    -- 显示物品信息
    local args = {
        widget = self,
        side = enum.UIAnchor.Side.TopRight,
        offset = Vector2.New(-90, 10)
    }
    g_WindowTipCtrl:SetWindowItemTip(self.m_Sid, args)
end

return CAttachItem