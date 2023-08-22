local CRideModel = class("CRideModel", CModelBase, CGameObjContainer)

function CRideModel.ctor(self, obj)

	CModelBase.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)

	self.m_TopMount = self:GetContainTransform(1)
	self.m_MidMount = self:GetContainTransform(2)
	self.m_BottomMount = self:GetContainTransform(3)
	self.m_RideMount = self:GetContainTransform(4)
	self.m_EffectContainer = self:NewObjContainer(5, CContainerObject, false)

	self.m_EffectObjList = {}

	if self.m_EffectContainer then

	 	local lv1 = self.m_EffectContainer:NewObjContainer(1, CContainerObject)
	 	if lv1 then 
	 		self.m_Lv_1 = lv1:GetAllGameObjects()
	 		table.insert(self.m_EffectObjList, self.m_Lv_1)
	 	end 

	 	local lv2 = self.m_EffectContainer:NewObjContainer(2, CContainerObject)
	 	if lv2 then 
	 		self.m_Lv_2 = lv2:GetAllGameObjects()
	 		table.insert(self.m_EffectObjList, self.m_Lv_2)
	 	end 

	 	local lv3 = self.m_EffectContainer:NewObjContainer(3, CContainerObject)
	 	if lv3 then 
	 		self.m_Lv_3 = lv3:GetAllGameObjects()
	 		table.insert(self.m_EffectObjList, self.m_Lv_3)
	 	end 
	 end 	

	 self:UnActiveEffect()
	
end

function CRideModel.UnActiveEffect(self)
	
	for k, objList in pairs(self.m_EffectObjList) do 
		for _, obj in pairs(objList) do
			obj:SetActive(false)
		end 
	end 

end

--骑乘
function CRideModel.SetOnRide(self, walkerModel)
	
	if walkerModel then 
		walkerModel:SetParent(self.m_RideMount)
	end 

end

function CRideModel.ShowRideEffect(self, lv)

	if not self.m_EffectContainer then 
		return		
	end 

	if not next(self.m_EffectObjList) then 
		return
	end 

	local show = function (objList, isShow)
		for k, v in pairs(objList) do 
			v:SetActive(isShow)
		end 
	end 

	if not lv or lv == define.Performance.Level.default then
		for k, objList in pairs(self.m_EffectObjList) do 
			show(objList, false)
		end 
		return
	end 

	if lv == define.Performance.Level.low then 
		show(self.m_EffectObjList[1], true)
		show(self.m_EffectObjList[2], false)
		show(self.m_EffectObjList[3], false)
	elseif lv == define.Performance.Level.mid then 
		show(self.m_EffectObjList[1], true)
		show(self.m_EffectObjList[2], true)
		show(self.m_EffectObjList[3], false)
	elseif lv ==  define.Performance.Level.high then 
		show(self.m_EffectObjList[1], true)
		show(self.m_EffectObjList[2], true)
		show(self.m_EffectObjList[3], true)
	end 

end

function CRideModel.ClearEffect(self)
	self:ShowRideEffect()
end

return CRideModel