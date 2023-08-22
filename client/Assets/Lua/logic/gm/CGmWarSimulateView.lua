CGmWarSimulateView = class("CGmWarSimulateView", CViewBase)

function CGmWarSimulateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/gm/GmWarSimulateView.prefab", cb)
end

function CGmWarSimulateView.OnCreateView(self)
    self.m_SimulateGrid = self:NewUI(1, CGrid)
    self.m_BtnGrid = self:NewUI(2, CGrid)
    self.m_CloseBtn = self:NewUI(3, CButton)
	self:InitContent()
end

function CGmWarSimulateView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

    if g_GmCtrl.m_WarData == nil then
        g_GmCtrl.m_WarData = IOTools.GetRoleData("warSimulateData")
    end 
    local function InitInput(obj, idx)
        local input = CInput.New(obj)
        self["m_"..input:GetName()] = input
        return input
    end
    self.m_SimulateGrid:InitChild(InitInput)

    local funclist = {"OnReset", "OnLookCombat", "OnCombat"}
    local function InitButton(obj, idx)
        local btn = CButton.New(obj)
        btn:AddUIEvent("click", callback(self, funclist[idx]))
        btn:SetActive(idx ~= 2)
        return btn
    end
    self.m_BtnGrid:InitChild(InitButton)

    if g_GmCtrl.m_WarData == nil then
        self:SetData(data.fightshimendata.DATA[11001])
    else
        self:SetOldData()    
    end
end

function CGmWarSimulateView.OnReset(self)
    local monster = data.fightshimendata.DATA[tonumber(self.m_MonsterID:GetText())]
    if not monster then 
        g_NotifyCtrl:FloatMsg("怪物ID不存在!")
        return
    end
    self:SetData(monster)
end

function CGmWarSimulateView.SetData(self, monster)
    self.m_Blood:SetText("50000")
    self.m_Attack:SetText("lv*5+30")
    self.m_MagAttack:SetText("lv*5+30")
    self.m_PhyDefense:SetText("lv*2+20")
    self.m_MagDefense:SetText("lv*2+20")
    self.m_Speed:SetText("lv*2+20")
    self.m_Magic:SetText("5000")
    self.m_CritRate:SetText(monster.critRate)
    self.m_DodgeRate:SetText(monster.dodgeRate)
    self.m_ZSkill:SetText("0")
    self.m_BSkill:SetText("0")
    self.m_MonsterCount:SetText("1")
    self.m_MonsterID:SetText(monster.id)
    self.m_MonsterLevel:SetText(1)
    self.m_FmtID:SetText(1)
    self.m_FmtGrade:SetText(1)
    self.m_WeatherID:SetText(0)
    self.m_SkyID:SetText(0)
    self.m_BossType:SetText(0)
    self.m_AIType:SetText(0)
    self.m_ModelID:SetText("1110")
end

function CGmWarSimulateView.SetOldData(self)
    local proplist = {
        "MonsterCount",
        "MonsterLevel",
        "ZSkill",
        "Attack",
        "MagAttack",
        "PhyDefense",
        "MagDefense",
        "Speed",
        "CritRate",
        "DodgeRate",
        "Blood",
        "Magic",
        "MonsterID",
        "BSkill",
        "FmtID",
        "FmtGrade",
        "WeatherID",
        "SkyID",
        "BossType",
        "AIType",
        "ModelID",
    }
    for i,v in ipairs(proplist) do
        self["m_"..v]:SetText(g_GmCtrl.m_WarData[i] or 0)
    end
end

function CGmWarSimulateView.OnLookCombat(self)
    printc("观战模式")
end

function CGmWarSimulateView.OnCombat(self)
    printc("战斗模式")
    local shape = 1110
    if self.m_ModelID:GetText() and self.m_ModelID:GetText() ~= "0" then
        shape = self.m_ModelID:GetText()
    end
    g_GmCtrl.m_WarData = {
        tonumber(self.m_MonsterCount:GetText()),
        tonumber(self.m_MonsterLevel:GetText()),
        self.m_ZSkill:GetText(),
        self.m_Attack:GetText(),
        self.m_MagAttack:GetText(),
        self.m_PhyDefense:GetText(),
        self.m_MagDefense:GetText(),
        self.m_Speed:GetText(),
        tonumber(self.m_CritRate:GetText()),
        tonumber(self.m_DodgeRate:GetText()),
        tonumber(self.m_Blood:GetText()),
        tonumber(self.m_Magic:GetText()),
        tonumber(self.m_MonsterID:GetText()),
        self.m_BSkill:GetText(),
        tonumber(self.m_FmtID:GetText()),
        tonumber(self.m_FmtGrade:GetText()),
        tonumber(self.m_WeatherID:GetText()),
        tonumber(self.m_SkyID:GetText()),
        self.m_BossType:GetText(),
        tonumber(self.m_AIType:GetText()),
        tonumber(shape),
    }
    IOTools.SetRoleData("warSimulateData", g_GmCtrl.m_WarData)
    nettest.C2GSTestWar(unpack(g_GmCtrl.m_WarData))
end

return CGmWarSimulateView