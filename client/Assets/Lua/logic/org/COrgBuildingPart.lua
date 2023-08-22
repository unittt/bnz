local COrgBuildingPart = class("COrgBuildingPart", CPageBase)

function COrgBuildingPart.ctor(self, cb)
    CPageBase.ctor(self, cb)
end

function COrgBuildingPart.OnInitPage(self)
    self.m_MainPalace       = self:NewUI(1, COrgBuildMainRoomBox)
    self.m_Palace           = self:NewUI(2, COrgBuildGodRoomBox)
    self.m_Room             = self:NewUI(3, COrgBuildWingRoomBox)
    self.m_TreasureRoom     = self:NewUI(4, COrgBuildTreasureRoomBox)
    self.m_Vault            = self:NewUI(5, COrgBuildStorageRoomBox)
    self.m_TreasureRoomBox  = self:NewUI(6, COrgTreasureRoomBox)
    self.m_IsFirstRequest = true
    self.m_AutoClickBuild = 0
    self:InitContent()
end

function COrgBuildingPart.InitContent(self)
    -- 绑定 bid 与 cbox
    self.m_CboxTable = {
        [101] = self.m_MainPalace,
        [102] = self.m_TreasureRoom,
        [103] = self.m_Room,
        [104] = self.m_Palace,
        [105] = self.m_Vault,
    }
    -- 其它初始化
    self.m_TreasureRoomBox:SetActive(false)
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    -- 获取建筑数据
    if self.m_IsFirstRequest then
        g_OrgCtrl:C2GSGetBuildInfo()
    end
end

function COrgBuildingPart.JumpToTargetBuilding(self, iBuildId)
    self.m_AutoClickBuild = iBuildId
end

function COrgBuildingPart.OnShowPage(self)
    if not self.m_IsFirstRequest then
        g_OrgCtrl:C2GSGetBuildInfo()
    end
    self.m_IsFirstRequest = false
end

function COrgBuildingPart.ShowTreasureShop(self, info)
    self.m_TreasureRoomBox:SetActive(true)   
    self.m_TreasureRoomBox:InitItemGrid(info) 
end

function COrgBuildingPart.CloseTreasureRoomBox(self)
    self.m_TreasureRoomBox:SetActive(false)
end

function COrgBuildingPart.OnOrgEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Org.Event.UpdateOrgBuildingInfos then
        for k, building in pairs(oCtrl.m_EventData) do
            self.m_CboxTable[k]:ShowBuildInfo(building)
            if self.m_AutoClickBuild == building.bid then
                self.m_CboxTable[k]:OnShowInfo()
                self.m_AutoClickBuild = 0
            end
        end
    end
end

return COrgBuildingPart