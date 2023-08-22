local CHorseWenShiItemBox = class("CHorseWenShiItemBox", CBox)

function CHorseWenShiItemBox.ctor(self, obj)

	CBox.ctor(self, obj)
    self.m_Toggle = self:NewUI(1, CSprite)
    self.m_SubItem = self:NewUI(2, CHorseWenShiSubItemBox)
    self.m_Name = self:NewUI(3, CLabel)
    self.m_SubGrid = self:NewUI(4, CGrid)
    self.m_TweenNode = self:NewUI(5, CWidget)
    self.m_Tween = self.m_TweenNode:GetComponent(classtype.TweenHeight)
    self.m_CName = self:NewUI(6, CLabel)
    self.m_Icon = self:NewUI(7, CSprite)

    self.m_Toggle:AddUIEvent("click", callback(self, "OnClickBtn"))  

    self.m_IsExpand = false

end

function CHorseWenShiItemBox.SetInfo(self, info, cb)

    local name = info.name
    self.m_Name:SetText(name)
    self.m_CName:SetText(name)
    self.m_Icon:SpriteItemShape(info.icon)
    self:RefreshSubItem(info)
    self.m_Cb = cb
    self.m_Toggle:ForceSelected(false)

end


function CHorseWenShiItemBox.RefreshSubItem(self, info)
    
    self:ClearSubItem()
    self.m_SubGrid:HideAllChilds()

    local subInfoList = info.sub
    local colorType = info.color

    table.sort(subInfoList, function (a, b)
        if a.grade > b.grade then 
            return true
        else
            return false
        end 
    end)

    table.insert(subInfoList, { colorType = colorType })

    for k, info in ipairs(subInfoList) do 
        local item = self.m_SubGrid:GetChild(k)
        if not item then 
            item = self.m_SubItem:Clone()
            item:SetActive(true)
            self.m_SubGrid:AddChild(item)
        end 
        item:SetActive(true)
        item:SetInfo(info, callback(self, "OnClickSubItem", item))
    end 

    self:RefreshHeight()

end

function CHorseWenShiItemBox.OnClickSubItem(self, item)
    
    self.m_SubId = item.m_Id
    self.m_TweenNode:SetActive(true)
    if self.m_Cb then
        self.m_Cb(item.m_ColorType, item.m_Id)
    end 

end

function CHorseWenShiItemBox.ClearSubItem(self)
    
    local childList = self.m_SubGrid:GetChildList()
    for k, item in ipairs(childList) do 
        item:Clear()
    end 

end

function CHorseWenShiItemBox.OnClickBtn(self)

    self.m_IsExpand = not self.m_IsExpand

    if self.m_Tween then 
        local childList = self.m_SubGrid:GetChildList()
        local count = 0
        for k, v in pairs(childList) do
            if v:GetActive() then 
                count = count + 1
            end 
        end
        local height =  self.m_SubItem:GetItemHeight()
        local totalHeight = height * count
        self.m_Tween.to = totalHeight
    end 
    
    if self.m_Cb then 
        self.m_Cb()
    end 

    self.m_SubGrid:SetActive(true)

end

function CHorseWenShiItemBox.RefreshHeight(self)
    
    if self.m_Tween and  self.m_IsExpand then 
        local childList = self.m_SubGrid:GetChildList()
        local count = 0
        for k, v in pairs(childList) do
            if v:GetActive() then 
                count = count + 1
            end 
        end 
        local height =  self.m_SubItem:GetItemHeight()
        local totalHeight = height * count
        self.m_Tween.to = totalHeight
        --self.m_Tween:Play(true)
        self.m_Tween.enabled = true
    end 

end

function CHorseWenShiItemBox.GetSubItemHeight(self)
    
    return self.m_SubItem:GetItemHeight()

end

return CHorseWenShiItemBox