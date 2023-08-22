local CZeroBuyCtrl = class("CZeroBuyCtrl", CCtrlBase)

function CZeroBuyCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_EndTime = 0
	self.m_ZeroInfoList = {}
	self.m_ZeroInfoHashList = {}

	self.m_ZeroBuyChenIndex = 1
	self.m_ZeroBuyWaiguanIndex = 2
	self.m_ZeroBuyFlyIndex = 3

	self:Clear()
end

function CZeroBuyCtrl.Clear(self)
	self.m_IsHasClickMainMenu = false
end

function CZeroBuyCtrl.GS2CZeroYuanInfo(self, pbdata)
	self.m_EndTime = pbdata.activity_endtime
	self.m_ZeroInfoList = table.copy(pbdata.info)
	self.m_ZeroInfoHashList = {}
	for k,v in pairs(pbdata.info) do
		self.m_ZeroInfoHashList[v.type] = v
	end
	self:OnEvent(define.ZeroBuy.Event.UpdateInfo)
end

function CZeroBuyCtrl.GS2CZeroYuanInfoUnit(self, pbdata)
	self.m_ZeroInfoHashList[pbdata.unit_info.type] = pbdata.unit_info
	local oKey
	for k,v in pairs(self.m_ZeroInfoList) do
		if v.type == pbdata.unit_info.type then
			oKey = k
			table.remove(self.m_ZeroInfoList, k)
			break
		end
	end
	if oKey then
		table.insert(self.m_ZeroInfoList, oKey, pbdata.unit_info)
	end
	self:OnEvent(define.ZeroBuy.Event.UpdateInfo)
end

function CZeroBuyCtrl.CheckIsZeroBuyOpen(self)
	-- if not next(self.m_ZeroInfoHashList) then
	-- 	return false
	-- end
	-- local oChenData = self.m_ZeroInfoHashList[self.m_ZeroBuyChenIndex]
	-- local oWaiguanData = self.m_ZeroInfoHashList[self.m_ZeroBuyWaiguanIndex]
	-- local oFlyData = self.m_ZeroInfoHashList[self.m_ZeroBuyFlyIndex]
	return g_OpenSysCtrl:GetOpenSysState(define.System.ZeroBuy) and (self.m_EndTime - g_TimeCtrl:GetTimeS()) > 0 --and not (oChenData.status == 3 and oWaiguanData.status == 3 and oFlyData.status == 3)
end

function CZeroBuyCtrl.CheckIsZeroBuyRedPoint(self)
	local oChenData = self.m_ZeroInfoHashList[self.m_ZeroBuyChenIndex]
	if oChenData then
		if (oChenData.status == 0 and g_AttrCtrl.grade >= data.zerobuydata.ACTIVITY[1].limit_level) or oChenData.status == 2 then
			return true
		end
	end
	local oWaiguanData = self.m_ZeroInfoHashList[self.m_ZeroBuyWaiguanIndex]
	if oWaiguanData then
		if oWaiguanData.status == 2 then
			return true
		end
	end
	local oFlyData = self.m_ZeroInfoHashList[self.m_ZeroBuyFlyIndex]
	if oFlyData then
		if oFlyData.status == 2 then
			return true
		end
	end
	return false
end

function CZeroBuyCtrl.OpenView(self)
	if not self:CheckIsZeroBuyOpen() then
		g_NotifyCtrl:FloatMsg("0元购买尚未开启")
		return
	end
	CZeroBuyView:ShowView(function (oView)
		oView:ShowSubPageByIndex(oView:GetPageIndex("Chen"))
	end)
end

return CZeroBuyCtrl