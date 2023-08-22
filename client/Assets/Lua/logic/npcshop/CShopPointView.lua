local CShopPointView = class("CShopPointView", CViewBase)

function CShopPointView.ctor(self, cb)
	-- body
	CViewBase.ctor(self,"UI/NpcShop/ShopPointView.prefab", cb)
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CShopPointView.OnCreateView(self)
	-- body
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_Lab  = self:NewUI(2, CLabel)
	self.m_Bg = self:NewUI(3, CWidget)
	self:InitContent()
end

function CShopPointView.InitContent(self)
	-- body
end

function CShopPointView.SetNpcShowPoint(self, shopid, dServierdata)
	-- body
	local dData 
	if shopid == 103 then
		dData = table.copy(data.shoppointdata.CLIENTLEADERPOINT)
	elseif shopid == 104 then  
		dData =  table.copy(data.shoppointdata.CLIENTXIAYIPOINT)
	elseif shopid == 106 then
		dData =  table.copy(data.shoppointdata.CLIENTCHUMOPOINT)
	end
	
	for _,v in pairs(dServierdata) do
		if v.moneyvalue and v.moneyvalue> 0 then
			dData[v.source].dayvalue = v.moneyvalue
		end
	end
	local list = dData
	
	if shopid == 104 then
		table.insert(list, {name = "1000", text = "", sort = 1000})
		table.insert(list, {name = "1001", text = "师徒系统侠义值不计算", sort = 1001})
	end
	table.sort(list, function (a,b)
		return a.sort < b.sort
	end)

	local gridlist = self.m_Grid:GetChildList()
	for i,v in ipairs(list) do
		local clone = nil
		if i>#gridlist and string.len(v.name)>0 then
			clone = self.m_Lab:Clone()
			self.m_Grid:AddChild(clone)
			if v.text then
				clone:SetText("[8FF2E2]"..v.text)
			else
				v.dayvalue = v.dayvalue or 0
				if v.client_limit > 0 then 
					clone:SetText("[8FF2E2]"..v.name..":[-][47FD00]"..v.dayvalue.."/"..v.client_limit.."[-]" )
				elseif v.client_limit == 0 then
					clone:SetText("[8FF2E2]"..v.name..":[-][47FD00]"..v.dayvalue.."[-]")
				end
			end
		else
			clone = gridlist[i]
		end
	end

	if shopid == 106 then
		self.m_Bg:SetWidth(440)
		self.m_Grid:SetLocalPos(Vector3(-178, 15, 0))
	end
	self.m_Lab:SetActive(false)
	self.m_Grid:Reposition()
end


return CShopPointView
