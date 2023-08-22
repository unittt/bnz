local CHorseSkillTipsView = class("CHorseSkillTipsView", CViewBase)

function CHorseSkillTipsView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/HorseSkillTipsView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "sub"
    --self.m_ExtendClose = "ClickOut"

end

function CHorseSkillTipsView.OnCreateView(self)

    self.m_Icon = self:NewUI(1, CSprite)
    self.m_Name = self:NewUI(2, CLabel)
    self.m_Level = self:NewUI(3, CLabel)
    self.m_Type = self:NewUI(4, CLabel)
    self.m_Des = self:NewUI(5, CLabel)
    self.m_SkillItem = self:NewUI(6, CBox)
    self.m_ForgetBtn = self:NewUI(7, CSprite)
    self.m_CloseBtn = self:NewUI(8, CSprite)
    self.m_Grid = self:NewUI(9, CGrid)
    self.m_HorseSkillForgetBox = self:NewUI(10, CHorseSkillForgetBox)
    self.m_Text = self:NewUI(11, CLabel)

    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose")) 
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_ForgetBtn:AddUIEvent("click", callback(self, "OnForget"))  

end


function CHorseSkillTipsView.SetInfo(self, id)

    self.m_Id = id 
    local dataItem = data.ridedata.SKILL[id]
    self.m_Data = dataItem
    self.m_Icon:SpriteSkill(tostring(dataItem.icon))
    self.m_Name:SetText(dataItem.name)
    local level = g_HorseCtrl:GetSkillLevel(id)
    self.m_Level:SetText(level)

    local ridetype = dataItem.ride_type
    if ridetype == 0 then 
        self.m_Type:SetText("主技能")
        self.m_Text:SetText("可学习以下副技能")
    else
        self.m_Type:SetText("副技能")
        self.m_Text:SetText("需要学习的主技能")
    end 

    -- if g_HorseCtrl:IsCanForgetSkill(id) then 
    --  --   self.m_Text2:SetActive(true)
    --     self.m_ForgetBtn:SetActive(true)
    -- else
    --  --   self.m_Text2:SetActive(false)
    --     self.m_ForgetBtn:SetActive(false)
    -- end 

    self.m_Des:SetText(dataItem.desc)

    self.m_Grid:HideAllChilds()

    local skList = {}
    if ridetype == 0 then 
        skList = g_HorseCtrl:FindAdvanceSkills(id)
    else
        local id = dataItem.con_skill[1]
        table.insert(skList, id)
    end 

    if skList and next(skList) then 
        for k, v in ipairs(skList) do 
            local item = self.m_Grid:GetChild(k)
            if not item then 
                item = self.m_SkillItem:Clone()
                item:SetActive(true)
                item.m_Icon = item:NewUI(1, CSprite)
                item.m_Name = item:NewUI(2, CLabel)
                self.m_Grid:AddChild(item)
            end
            local config = data.ridedata.SKILL[v]
            item.m_Icon:SpriteSkill(tostring(config.icon))
            item.m_Name:SetText(config.name)
            item.m_Icon:AddUIEvent("click", callback(self, "ClickItem", item, config.id))
            item:SetActive(true)
        end 
    end 

    self.m_Grid:Reposition()

end

function CHorseSkillTipsView.ClickItem(self, oItem, id)

    local config = {widget = oItem, skId = id}
    g_WindowTipCtrl:SetWindowHorseSkillTip(config)

end

function CHorseSkillTipsView.OnForget(self)

    --self.m_HorseSkillForgetBox:SetActive(true)
   -- self.m_HorseSkillForgetBox:SetInfo(self.m_Data.id, callback(self, "OnClose"))
   CHorseForgetSkillView:ShowView(function (oView)
       oView:SetData(self.m_Id)
   end)

   self:OnClose()

end



return CHorseSkillTipsView