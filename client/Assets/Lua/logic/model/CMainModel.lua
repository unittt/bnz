local CMainModel = class("CMainModel", CModelBase, CGameObjContainer)

function CMainModel.ctor(self, obj)

	CModelBase.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	
	self.m_TopMount = self:GetContainTransform(1)
	self.m_MidMount = self:GetContainTransform(2)
	self.m_BottomMount = self:GetContainTransform(3)

	self.m_WeaponMount = self:GetContainTransform(4)

	self.m_MaskMount = self:GetContainTransform(6)

	--扩展模型使用
	self.m_Model_Ex = self:GetContainTransform(7)

	--精灵挂点
	self.m_Sprite = self:GetContainTransform(8)

	--翅膀挂点
	self.m_Wing = self:GetContainTransform(9)

end

--挂载武器
function CMainModel.EquipWeapon(self, weaponModel)
	
	if self.m_WeaponMount then 
		weaponModel:SetParent(self.m_WeaponMount)
	end 

end

--挂载精灵
function CMainModel.AddSprite(self, spriteModel)
	
	if self.m_Sprite then 
		spriteModel:SetParent(self.m_Sprite)
	end 

end

--挂翅膀
function CMainModel.AddWing(self, wingModel)
	
	if self.m_Wing then 
		wingModel:SetParent(self.m_Wing)
	end 

end

function CMainModel.ShowMask(self, isShow)
	
	if self.m_MaskMount then 
		self.m_MaskMount.gameObject:SetActive(isShow)
	end 

end



return CMainModel