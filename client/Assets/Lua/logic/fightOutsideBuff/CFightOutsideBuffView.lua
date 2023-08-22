local CFightOutsideBuffView = class("CFightOutsideBuffView", CViewBase)


function CFightOutsideBuffView.ctor(self, cb)

    CViewBase.ctor(self, "UI/FightOutsideBuff/FightOutsideBuffView.prefab", cb)
    self.m_GroupName = "sub"
    self.m_ExtendClose = "ClickOut"    

end

function CFightOutsideBuffView.OnCreateView(self)


    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_Table = self:NewUI(2, CTable)
    self.m_BuffItem = self:NewUI(3, CFightOutsideBuffBox)
    self.m_Bg = self:NewUI(4, CSprite)
    self.m_ItemBg = self:NewUI(5, CSprite)

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

    g_FightOutsideBuffCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshAll"))

    self:CreateBuffItemList()

    self:RefreshShowArea()

end

--创建buff列表
function CFightOutsideBuffView.CreateBuffItemList(self)
	
	local data = g_FightOutsideBuffCtrl.m_buffDataList
	local buffList = {}
	if data and next(data) then 
		for k, v in ipairs(data) do 
			if v.hide ~= "1" then 
				table.insert(buffList, v)
			end 
		end 
	end 

	for k , v in ipairs(buffList) do 
		local box = self.m_Table:GetChild(k)
		if box == nil then 
			box = self.m_BuffItem:Clone()
			self.m_Table:AddChild(box)
		end 
		box:SetData(v)
		box:SetActive(true)
	end
	 
end

function CFightOutsideBuffView.RefreshAll(self, oCtrl)
	
	self:RefreshBuffItemList(oCtrl)
	self:RefreshShowArea()

end

function CFightOutsideBuffView.RefreshBuffItemList(self, oCtrl)

	if oCtrl.m_EventID == define.FightOutsideBuff.Event.StateChange then 
		self:HideAllBuffItem()
		local data = g_FightOutsideBuffCtrl.m_buffDataList
		local buffList = {}
		if data and next(data) then 
			for k, v in ipairs(data) do 
				if v.hide ~= "1" then 
					table.insert(buffList, v)
				end 
			end 
		end 

		for k , v in ipairs(buffList) do 
			local box = self.m_Table:GetChild(k)
			if box ~= nil then 
				box:SetData(v)
				box:SetActive(true)
			end 
		end

	end

end

function CFightOutsideBuffView.RefreshShowArea(self)
	
	local childList = self.m_Table:GetChildList()
	local paddingY = self.m_Table:GetPadding().y
	local height = self.m_ItemBg:GetHeight() + paddingY
	local count = #childList
	if count < 3 then 
		self.m_Bg:SetHeight(height * 3)
	elseif (count >= 3) and (count < 5) then 
		self.m_Bg:SetHeight(height * count)
	else
		self.m_Bg:SetHeight(height * (4.5))
	end 

end

function CFightOutsideBuffView.HideAllBuffItem(self)

	for k , v in pairs(self.m_Table:GetChildList()) do 

		v:SetActive(false)

	end 

end

return CFightOutsideBuffView