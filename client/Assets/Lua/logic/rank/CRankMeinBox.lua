local CRankMeinBox = class("CRankMeinBox", CBox)

function CRankMeinBox.ctor(self, obj, cb)
	CBox.ctor(self, obj) 
    self.m_Item_02 = self:NewUI(1, CRankMeinItemBox)
    self.m_Item_01 = self:NewUI(2, CRankMeinItemBox)
    self.m_Item_03 = self:NewUI(3, CRankMeinItemBox)
    self.m_ItemGrid = self:NewUI(4, CGrid)
    self.m_ItemClone = self:NewUI(5, CBox)
    self:SetBottomItemEmpty()
    self.m_CurItemID = nil
end

function CRankMeinBox.ShowHint(self)
    self.m_Item_01:SetActive(false)
    self.m_Item_02:SetActive(false)
    self.m_Item_03:SetActive(false)
end

function CRankMeinBox.SetInfo(self, data)
    if self.m_CurItemID then
        self["m_Item_0"..self.m_CurItemID]:HideDialog()
        self.m_CurItemID = nil
    end
    
    if next(data) == nil then
       self.m_Item_01:SetSubUIShow(false)
       self.m_Item_02:SetSubUIShow(false)
       self.m_Item_03:SetSubUIShow(false)
       self:ReSetItem(1)
       return
    end
    self.m_Item_01:SetInfo(data[1])
    self.m_Item_02:SetInfo(data[2])
    self.m_Item_03:SetInfo(data[3])

    local idx = math.random(1, math.min(3, #data))
    self.m_CurItemID = idx
    self["m_Item_0"..self.m_CurItemID]:ShowDialog()
    self:SetBottomItemInfo(data)
end

function CRankMeinBox.SetBottomItemInfo(self, info)
    --self.m_ItemGrid:Clear()
    --table.print(info,"前10信息：")
    if #info <= 3 then
       self:ReSetItem(1)
    else
        local i = 1
        for k,v in pairs(info) do
            if i >= 8 then
                break
            end 
            if k > 3 then 
                local item = self.m_ItemGrid:GetChild(i)
                item:SetActive(true)
                item.icon:SetActive(true)
                item.ismy:SetActive(false)
                local name = ""
                if g_RankCtrl.m_CurSubTypeId ~= 108 then
                   name = v.name
                   item.icon:SetSpriteName(tostring(v.model_info.shape))
                else
                   local summondata = data.summondata.INFO[v.type]
                   item.icon:SetSpriteName(tostring(summondata.shape))
                   name = summondata.name
                end
                local rank = k
                local color
                if v.pid == g_AttrCtrl.pid then
                    color = Color.RGBAToColor("A64E00FF")
                    item.ismy:SetActive(true)
                else
                    color = Color.RGBAToColor("244B4EFF")
                end
                item.name:SetText(name)
                item.rank:SetText(rank)
                item.name:SetColor(color)
                item.rank:SetColor(color)
                item.rankStr:SetColor(color)
                i = i + 1
            end
        end
        self:ReSetItem(i)
    end
end

function CRankMeinBox.SetBottomItemEmpty(self)
    for i=1,7 do
        local item = self.m_ItemClone:Clone()
        item:SetActive(true)
        item.icon = item:NewUI(1, CSprite)
        item.name = item:NewUI(2, CLabel)
        item.rank = item:NewUI(3, CLabel)
        item.ismy = item:NewUI(5, CLabel)
        item.rankStr = item:NewUI(6, CLabel)
        item.rank:SetText(i+3)
        if i >= 7 then
            item.rankStr:SetText("第  名")
        else
            item.rankStr:SetText("第 名")
        end
        self:SetItemEmptyInfo(item)
        self.m_ItemGrid:AddChild(item)         
    end
end

--重置
function CRankMeinBox.ReSetItem(self, index)
    for i=index,7 do
        local item = self.m_ItemGrid:GetChild(i)
        if item then
            self:SetItemEmptyInfo(item)
        end         
    end
end

function CRankMeinBox.SetItemEmptyInfo(self, oItem)
    oItem:SetActive(true)
    oItem.ismy:SetActive(false)
    oItem.icon:SetSpriteName("")
    oItem.name:SetText("虚位以待")
    local color = Color.RGBAToColor("244B4EFF")
    oItem.rank:SetColor(color)
    oItem.rankStr:SetColor(color)
    oItem.name:SetColor(color)
end

return CRankMeinBox
