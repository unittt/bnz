local CTimelimitSevenDayPage = class("CTimelimitSevenDayPage", CPageBase)

function CTimelimitSevenDayPage.ctor(self,cb)

	CPageBase.ctor(self, cb)

	self.m_HuluList = {}
	self.m_HuluPos = {{-222, 72}, {-128, -8}, {-27, 82}, {72, -49}, {175, 34}, {275, 124}, {367, 46}}  --保存每个葫芦的位置数据
end

function CTimelimitSevenDayPage.OnInitPage(self)
	self.m_timeL = self:NewUI(1, CLabel)
	self.m_dayL = self:NewUI(2, CLabel)
	self.m_itemBoxClone = self:NewUI(3, CItemSevenDayBox)
	table.insert(self.m_HuluList, self.m_itemBoxClone)

	self:InitContent()

	g_TimelimitCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTimelimitCtrl"))
end

function CTimelimitSevenDayPage.InitContent(self)

	local start, ended = g_TimelimitCtrl:GetSevenDayDuration() 
	local startL = g_TimeCtrl:GetTimeMDHM(start)
	local endL = g_TimeCtrl:GetTimeMDHM(ended)
	local curDayL = g_TimelimitCtrl:GetCurLoginDay()

	self.m_timeL:SetText(startL.." - "..endL)
	self.m_dayL:SetText("#mark_"..curDayL)

	self:RefreshItemBox()
	
end

function CTimelimitSevenDayPage.RefreshItemBox(self)
	local sevenLoginData = DataTools.GetHuodongData("SEVENLOGIN")

	for k, v in ipairs(sevenLoginData) do
		local oItem = self.m_HuluList[k]
		if oItem == nil then
			oItem = self.m_itemBoxClone:Clone()
			oItem:SetActive(true)
			local x = self.m_HuluPos[k][1]
			local y = self.m_HuluPos[k][2]
			oItem:SetParent(self.m_itemBoxClone:GetParent())
			oItem:SetLocalPos(Vector3.New(x, y))

			table.insert(self.m_HuluList, oItem)
		end		
		oItem:SetData(v)
	end
end

function CTimelimitSevenDayPage.OnTimelimitCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Timelimit.Event.RefreshSevenLogin then
		if not Utils.IsNil(self) then
			self:RefreshItemBox()
		end	
	end
end

return CTimelimitSevenDayPage