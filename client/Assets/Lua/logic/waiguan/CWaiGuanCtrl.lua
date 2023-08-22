local CWaiGuanCtrl = class("CWaiGuanCtrl", CCtrlBase)

function CWaiGuanCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CWaiGuanCtrl.Clear(self)
	self.m_SzInfoList = {}
end

--请求所有时装数据
function CWaiGuanCtrl.C2GSGetAllSZInfo(self)
	
	netplayer.C2GSGetAllSZInfo()

end

--请求使用时装
function CWaiGuanCtrl.C2GSSetSZ(self, id)
	
	netplayer.C2GSSetSZ(id)

end

--请求使用时装颜色
function CWaiGuanCtrl.C2GSSetSZColor(self, szId, colorId)
	
	netplayer.C2GSSetSZColor(szId, colorId)

end

--解锁时装
function CWaiGuanCtrl.C2GSOpenShiZhuang(self, type, szId)
	
	netplayer.C2GSOpenShiZhuang(type, szId)

end

--解锁时装颜色
function CWaiGuanCtrl.C2GSSZRanse(self, szID, colorId, flag)
	
	netplayer.C2GSSZRanse(szID, colorId, flag)

end

--获取所有时装信息
function CWaiGuanCtrl.GS2CAllShiZhuang(self, szlist)


	self.m_SzDataList = szlist
	self:HandleData()

end

--刷新时装数据
function CWaiGuanCtrl.GS2CRefreshShiZhuang(self, pbdata)

	if not next(pbdata) then 		
		for k, v in ipairs(self.m_SzInfoList) do 
			if v.isDefaultSz then 
				v.isUse = true
			else
				v.isUse = false
			end 
		end 

	else
		local szInfo = pbdata.szobj
		for k, v in ipairs(self.m_SzInfoList) do 
			if v.szId == szInfo.sz then 
				v.curColor = szInfo.curcolor
				v.time = szInfo.time
				v.isForever = szInfo.forever
				v.isUnLock = true
				v.isUse = true
				v.colorList = {}

				local defaultColor = {}
				defaultColor.showColor =  Color.New(1,1,1,1)
				defaultColor.isUnLock = true
				defaultColor.isUse =  v.curColor == 0
				defaultColor.isDefault = true

				table.insert(v.colorList, defaultColor)

				local ranseConfig = data.ransedata.SHIZHUANG[v.szId].colorlist
				for j, item in ipairs(ranseConfig) do 

					local ranseItem = {}
					ranseItem.id = item.color
					ranseItem.isUnLock = self:IsRanseUnLock(item.color, szInfo)
					ranseItem.showColor = g_RanseCtrl:ParseStrToColor(data.ransedata.SHIZHUANG[v.szId].showColor[item.color].value)
					ranseItem.ranseColor = {}
					local value1 = g_RanseCtrl:ParseStrToColor(item.value1)
					local value2 = g_RanseCtrl:ParseStrToColor(item.value2)
					ranseItem.ranseColor[define.Ranse.PartType.clothes] = value1
					ranseItem.ranseColor[define.Ranse.PartType.other] = value2
					local consume = string.split(data.ransedata.SHIZHUANG[v.szId].itemlist[item.color].item, "*")
					ranseItem.consume = {id = tonumber(consume[1]), count = tonumber(consume[2])}
					ranseItem.isUse = v.curColor == item.color
					table.insert(v.colorList, ranseItem)
				end 
			else
				v.isUse = false
			end  
		end
	end  
	self:OnEvent(define.WaiGuan.Event.RefreshClothesInfo, self.m_SzInfoList)

end

function CWaiGuanCtrl.OpenWaiGuanView(self)

	if g_OpenSysCtrl:GetOpenSysState(define.System.ShiZhuang) then 
		CRanseMainView:ShowView(function (oView)
			oView:ShowWaiGuan()
		end)
	else
		g_NotifyCtrl:FloatMsg("时装系统尚未开启")
	end 

end 


function CWaiGuanCtrl.HandleData(self)

	self.m_SzInfoList = {}
	
	local shape =  g_AttrCtrl.model_info.shape
	local config = data.ransedata.SZBASIC[shape]
	if config == nil then 
		return
	end 

	local defaultSz = {}
	defaultSz.isDefaultSz = true
	defaultSz.icon = "h7_sz_mo"
	defaultSz.shape = shape
	defaultSz.isUnLock = true
	defaultSz.name = g_AttrCtrl.name
	defaultSz.isUse = g_AttrCtrl.model_info.shizhuang  == 0
	table.insert(self.m_SzInfoList, defaultSz)


	for k, v in ipairs(config.szlist) do 

		local info = {}
		local szData = self:GetOpenShiZhuanData(v)
		local szConfig =  data.ransedata.SHIZHUANG[v]
		info.szId = v
		info.isUnLock = szData and true or false
		info.icon = szConfig.icon
		info.shape = szConfig.model
		info.openSeven = szConfig.seven
		info.openForever = szConfig.forever
		info.name = szConfig.name
		info.isForever = szData and szData.forever or 0 
		info.curColor = szData and szData.curcolor or 0
		info.time = szData and szData.time or 0
		info.isDefaultSz = false
		info.isUse = g_AttrCtrl.model_info.shizhuang  == v 
		info.colorList = {}

		--先插入默认颜色
		local defaultColor = {}
		defaultColor.showColor =  Color.New(1,1,1,1)
		defaultColor.isUnLock = true
		defaultColor.isUse =  info.curColor == 0
		defaultColor.isDefault = true

		table.insert(info.colorList, defaultColor)


		--设置该时装对应的染色数据
		local ranseConfig = szConfig.colorlist
		for j, item in ipairs(ranseConfig) do 

			local ranseItem = {}
			ranseItem.id = item.color
			ranseItem.isDefault = false
			ranseItem.isUnLock = self:IsRanseUnLock(item.color, szData)
			ranseItem.showColor = g_RanseCtrl:ParseStrToColor(szConfig.showColor[item.color].value)
			ranseItem.ranseColor = {}
			local value1 = g_RanseCtrl:ParseStrToColor(item.value1)
			local value2 = g_RanseCtrl:ParseStrToColor(item.value2)
			local value3 = g_RanseCtrl:ParseStrToColor(item.value3)
			ranseItem.ranseColor[define.Ranse.PartType.clothes] = value1
			ranseItem.ranseColor[define.Ranse.PartType.other] = value2
			ranseItem.ranseColor[define.Ranse.PartType.pant] = value3
			local consume = string.split(szConfig.itemlist[item.color].item, "*")
			ranseItem.consume = {id = tonumber(consume[1]), count = tonumber(consume[2])}
			ranseItem.isUse =  info.curColor == item.color 
			table.insert(info.colorList, ranseItem)

		end 

		table.insert(self.m_SzInfoList, info)

	
	end 

	self:OnEvent(define.WaiGuan.Event.AllClothesInfo, self.m_SzInfoList)

end

--获取开启时装的数据
function CWaiGuanCtrl.GetOpenShiZhuanData(self, id)
	
	for k, v in ipairs(self.m_SzDataList) do 

		if v.sz == id then 

			return v

		end 

	end


end

--判断该染色是否已经解锁
function CWaiGuanCtrl.IsRanseUnLock(self, colorId, szData)


	if szData == nil then 
		return false
	end 

	if  not next(szData.colorlist) then 
		return false
	end 

	
	for k , v in ipairs(szData.colorlist) do 

		if v == colorId then 

			return true

		end 

	end

	return false 

end

function CWaiGuanCtrl.GetSzList(self)
	
	return self.m_SzInfoList

end

function CWaiGuanCtrl.GetTipText(self, id, name)
	
	local config = data.ransedata.TEXT[id]
	if config then 
		if name then
			return string.gsub(config.text, "#name", name)
		else
			return config.text
		end 
		
	end 	

end

return CWaiGuanCtrl



