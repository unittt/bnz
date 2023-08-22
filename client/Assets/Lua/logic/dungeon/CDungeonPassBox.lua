local CDungeonPassBox = class("CDungeonPassBox", CBox)

function CDungeonPassBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self:InitContent()
end

function CDungeonPassBox.InitContent(self)
    self.m_ContPart = self:NewUI(1, CWidget)
    self.m_EmptyPart = self:NewUI(2, CWidget)
    self.m_Tex = self:NewUI(3, CTexture)
    self.m_MaskSpr = self:NewUI(4, CSprite)
    self.m_OpenLvL = self:NewUI(5, CLabel)
    self.m_OpenLv2L = self:NewUI(6, CLabel)
    self.m_NameSelL = self:NewUI(7, CLabel)
    self.m_NameL = self:NewUI(8, CLabel)
    self.m_RewardL = self:NewUI(9, CLabel)
    self.m_TeamLimitL = self:NewUI(10, CLabel)
    self.m_SelSpr = self:NewUI(11, CSprite)
end

function CDungeonPassBox.SetInfo(self, dInfo)
    local bInfo = dInfo and true or false
    self.m_ContPart:SetActive(bInfo)
    self.m_EmptyPart:SetActive(not bInfo)
    self.id = nil
    if dInfo then
        local dDungeon = dInfo.config 
        local dOpen = dInfo.open
        self.m_Config = dDungeon
        self.m_OpenData = dOpen
        local sName = self:GetDungeonName(dDungeon)
        self.m_NameSelL:SetText(sName)
        self.m_NameL:SetText(sName)
        self:SetTexture(dDungeon.minimap)
        self:SetOpenLv(dOpen.p_level)
        local iRewardCnt = g_DungeonCtrl:GetDungeonRewardCnt(dDungeon.fuben_id)
        self.m_RewardL:SetText(string.format("奖励：%d/5", iRewardCnt))
        self.id = dDungeon.fuben_id
    end
    self:SetSelected(false)
end

function CDungeonPassBox.SetTexture(self, sTexName)
    local sTextureName = "Texture/Dungeon/dungeon_"..sTexName..".png"
    g_ResCtrl:LoadAsync(sTextureName, function(tex, errcode)
        if Utils.IsNil(self) then return end
        if tex then
            self.m_Tex:SetMainTexture(tex)
        else
            print(errcode)
        end
    end)
end

function CDungeonPassBox.GetDungeonName(self, dInfo)
    local sName = dInfo.name
    if 2 == dInfo.refresh_type then
        local sStrs = string.split(sName, "-")
        if sStrs and #sStrs > 0 then
            sName = sStrs[1]
        end
    end
    return sName
end

function CDungeonPassBox.SetOpenLv(self, iLv)
    local bOpen = g_AttrCtrl.grade >= iLv
    self.m_MaskSpr:SetActive(not bOpen)
    self.m_TeamLimitL:SetText(iLv.."级以上队伍可以挑战")
    if not bOpen then
        local sUnlock = iLv.."级开启"
        self.m_OpenLvL:SetText(sUnlock)
        self.m_OpenLv2L:SetText(sUnlock)
    end
end

function CDungeonPassBox.SetSelected(self, bSel)
    self.m_NameSelL:SetActive(bSel)
    self.m_SelSpr:SetActive(bSel)
end

return CDungeonPassBox