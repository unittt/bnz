local CHorseBuyBox = class("CHorseBuyBox", CBox)

function CHorseBuyBox.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_BuyBtn = self:NewUI(1, CButton)
    self.m_Time = self:NewUI(2, CLabel)
    self.m_Item = self:NewUI(3, CBox)

    self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuyBtn"))

    self:InitItemBox(self.m_Item)

end

-- 1，时间  2，消耗类型,数量,icon 3，cb
function CHorseBuyBox.SetInfo(self, info, cb)
   
    self.m_Info = info

    local validDay = info.validDay
    local consumeType = info.consumeType
    local count = info.count
    local icon = info.icon

    if validDay == -1 then 
        --self.m_Time:SetText("[63432CFF]永久[-]")
        self.m_Time:SetText("永久")
    else
       -- self.m_Time:SetText("[0FFF32FF]" .. tostring(validDay) .. "天[-]")
        self.m_Time:SetText(tostring(validDay) .. "天")
    end 
        
    self:RefreshItemBox(consumeType, count, icon)

    self.m_Cb = cb
    
end

function CHorseBuyBox.RefreshItemBox(self, consumeType, count, icon)
    
    self.m_Item.m_consume:SetText(count)
     
    self.m_Item.m_icon:SetSpriteName(icon)

    self.m_Item.type = consumeType

end

function CHorseBuyBox.InitItemBox(self, item)

    item.m_name = item:NewUI(1, CLabel)
    item.m_consume = item:NewUI(2, CLabel)
    item.m_icon = item:NewUI(3, CSprite)
    item.type = nil   
    item.OnClicIcon = function ()
        if item.type == 6 then 
            g_WindowTipCtrl:SetWindowGainItemTip(11040)
        end 
    end

    item.m_icon:AddUIEvent("click", callback(item, "OnClicIcon"))

end

function CHorseBuyBox.OnClickBuyBtn(self)
    
    if self.m_Cb then 
        self.m_Cb(self.m_Info, self)
    end 

end


return CHorseBuyBox