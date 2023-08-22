local COrgBuildShopTipsView = class("COrgBuildShopTipsView", CViewBase)

function COrgBuildShopTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgBuildShopTipsView.prefab", cb)
	--界面设置
    self.m_OldTime = 0
	self.m_ExtendClose = "Black"
end

function COrgBuildShopTipsView.OnCreateView(self)
    self.m_ScrollView = self:NewUI(1, CScrollView)
    self.m_BigGrid = self:NewUI(2, CTable)
    self.m_InfoClone = self:NewUI(3, CBox)
    self.m_CloseBtn = self:NewUI(4, CButton)

    self:InitContent()
end

function COrgBuildShopTipsView.InitContent(self)
    --printc(data.orgdata.BUILDSHOP[#data.orgdata.BUILDSHOP].level)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self:InitGrid()
end

function COrgBuildShopTipsView.InitGrid(self)
    local Biglist = self.m_BigGrid:GetChildList()

    for i=1,5 do

        local stopdata = g_OrgCtrl:GetBuildShop(i)
        local infopart = nil
        if i>#Biglist then

            infopart = self.m_InfoClone:Clone()
            infopart:SetGroup(self.m_BigGrid:GetInstanceID())
            self.m_BigGrid:AddChild(infopart)

            infopart.m_title = infopart:NewUI(1, CLabel)
            infopart.m_grid = infopart:NewUI(2, CGrid)
            infopart.m_item = infopart:NewUI(3, CBox)
            infopart.m_bg = infopart:NewUI(4, CSprite)
            infopart.m_title:SetText("珍宝阁"..i.."级")

            local _,iCellH = infopart.m_grid:GetCellSize()
            local iBgH = math.floor((#stopdata + 1)/2)*iCellH + 20
            infopart.m_bg:SetHeight(iBgH)

            for j= 1,#stopdata do 

                local lgridlist = infopart.m_grid:GetChildList()
                local item = nil
                if j>#lgridlist then

                    local itemData = DataTools.GetItemData(stopdata[j].item)
                    item = infopart.m_item:Clone()

                    item:SetGroup(infopart.m_grid:GetInstanceID())
                    infopart.m_grid:AddChild(item)
                    item:SetActive(true)
                    item.icon = item:NewUI(1, CSprite)
                    item.name = item:NewUI(2, CLabel)
                    item.icon:SetSpriteName(tostring(itemData.icon))
                    item.name:SetText(itemData.name)
                    infopart.m_grid:AddChild(item)
                    item:AddUIEvent("click", callback(self, "OnTips", item.icon, itemData.id))
                else
                    item = lgridlist[i]
                end
                infopart.m_item:SetActive(false)
                infopart.m_grid:Reposition()
            end
        else
            infopart = Biglist[i]
        end
    end 
    self.m_InfoClone:SetActive(false)
    self.m_BigGrid:Reposition()
end

function COrgBuildShopTipsView.OnTips(self, item, itemid)
    -- body
    local config = {widget = item}
    g_WindowTipCtrl:SetWindowItemTip(itemid, config)
end

return COrgBuildShopTipsView