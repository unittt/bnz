local CBaoshiduView = class("CBaoshiduView", CViewBase)


function CBaoshiduView.ctor(self, cb)

    CViewBase.ctor(self, "UI/FightOutsideBuff/BaoshiduView.prefab", cb)
    self.m_GroupName = "sub"
    self.m_ExtendClose = "ClickOut"  
    self.m_DepthType = "Fourth"
end


function CBaoshiduView.OnCreateView(self)

    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_AddCount = self:NewUI(2, CLabel)
    self.m_Count = self:NewUI(3, CLabel)
    self.m_TipBtn = self:NewUI(4, CSprite)
    self.m_AddBaoshiduBtn = self:NewUI(5, CSprite)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
    self.m_AddBaoshiduBtn:AddUIEvent("click", callback(self, "OnClickAddBtn"))

    self:InitData()

end

function CBaoshiduView.InitData(self)
	
	self.m_AddCount:SetText("补充" .. tostring(g_FightOutsideBuffCtrl.m_BaoshiduData.count) .. "场饱食度") 
	self.m_Count:SetText(g_FightOutsideBuffCtrl.m_BaoshiduData.sliver)

end

function CBaoshiduView.OnClickTip(self)

	local id = define.Instruction.Config.Baoshidu
	if data.instructiondata.DESC[id] ~= nil then 

	    local content = {
	        title = data.instructiondata.DESC[id].title,
	        desc  = data.instructiondata.DESC[id].desc
	    }
	    g_WindowTipCtrl:SetWindowInstructionInfo(content)

	end 

end

function CBaoshiduView.OnClickAddBtn(self)
	
	netstate.C2GSAddBaoShi()
	self:OnClose()

end


return CBaoshiduView