local CFuncNotifyShowView = class("CFuncNotifyShowView", CViewBase)

function CFuncNotifyShowView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Guide/FuncNotifyShowView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CFuncNotifyShowView.OnCreateView(self)
	self.m_TitleLbl = self:NewUI(1, CLabel)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_ActorTexture = self:NewUI(3, CActorTexture)
	self.m_BgSp = self:NewUI(4, CSprite)
	self.m_DescSp1 = self:NewUI(5, CSprite)
	self.m_DescSp2 = self:NewUI(6, CSprite)
	self.m_DescSp3 = self:NewUI(7, CSprite)
	self.m_DescTable = self:NewUI(8, CTable)
	
	self:InitContent()
end

function CFuncNotifyShowView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	-- g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CFuncNotifyShowView.RefreshUI(self, oData)
	self.m_TitleLbl:SetText(oData.reward_grade.."级开启"..oData.name)
	local model_info = {}
	model_info.figure = tonumber(oData.showview)
	model_info.horse = nil
	self.m_ActorTexture:ChangeShape(model_info)

	local oDesc1, oDesc2, oDesc3 = self:GetDescSpName(oData.id)
	self.m_DescSp1:SetSpriteName(oDesc1)
	self.m_DescSp1:MakePixelPerfect()
	self.m_DescSp2:SetSpriteName(oDesc2)
	self.m_DescSp2:MakePixelPerfect()
	self.m_DescSp3:SetSpriteName(oDesc3)
	self.m_DescSp3:MakePixelPerfect()
	self.m_DescTable:Reposition()
end

function CFuncNotifyShowView.GetDescSpName(self, oId)
	if oId == 1 then
		-- return "h7_biaoyu_8", "h7_biaoyu_2", "h7_biaoyu_6"
		return "h7_biaoyu_8", "h7_biaoyu_13", "h7_biaoyu_23"
	elseif oId == 2 then
		return "h7_biaoyu_12", "h7_biaoyu_11", "h7_biaoyu_7"
	elseif oId == 3 then
		return "h7_biaoyu_9", "h7_biaoyu_3", "h7_biaoyu_1"
	elseif oId == 6 then
		return "h7_biaoyu_10", "h7_biaoyu_4", "h7_biaoyu_5"
	else
		return "h7_biaoyu_8", "h7_biaoyu_2", "h7_biaoyu_6"
	end
end

return CFuncNotifyShowView