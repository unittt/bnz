local CScheduleHintTipBox = class("CScheduleHintTipBox", CBox)

function CScheduleHintTipBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_DesLabel = self:NewUI(1, CLabel)
	self.m_PointLabel = self:NewUI(2, CLabel)
	self.m_HitTipBG = self:NewUI(3, CSprite)
	self.m_SignDesGrid = self:NewUI(4, CGrid)
	self.m_SignDesClone = self:NewUI(5, CLabel)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "ShowScheduleTipBox", false))
end

function CScheduleHintTipBox.ShowScheduleTipBox(self, show)
	show = show or false
	self:SetActive(show)
	local count = 1
	if show then
		local deslabelList, activePoint = g_ScheduleCtrl:GetHintInfoDes()
		count = #deslabelList
		self.m_PointLabel:SetText(string.format("总计: %d/%d", activePoint, g_ScheduleCtrl.m_ActivePointMax))
		--self.m_DesLabel:SetText(deslabelList)
		local list = self.m_SignDesGrid:GetChildList()
		for i=1,#deslabelList  do
			local des = nil
			if i>#list then
				des = self.m_SignDesClone:Clone()
				des:SetGroup(self.m_SignDesGrid:GetInstanceID())
				self.m_SignDesGrid:AddChild(des)
				
			else
				des = list[i]
			end
			des:SetText(deslabelList[i])
		end
		self.m_SignDesClone:SetActive(false)
		self.m_SignDesGrid:Reposition()
	end

	local Height = self.m_SignDesClone:GetHeight()
	self.m_HitTipBG:SetHeight(Height*count + 150)
end

return CScheduleHintTipBox