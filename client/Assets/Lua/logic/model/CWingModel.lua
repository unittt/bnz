local CWingModel = class("CWingModel", CModelBase, CGameObjContainer)

function CWingModel.ctor(self, obj)

	CModelBase.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)

    self.m_EffectObjList = {}

	self.m_EffectContainer = self:NewObjContainer(1, CContainerObject, false)

    if self.m_EffectContainer then
        local lv1 = self.m_EffectContainer:NewObjContainer(1, CContainerObject, false)
        if lv1 then 
            self.m_Lv_1 = lv1:GetAllGameObjects()
            table.insert(self.m_EffectObjList, self.m_Lv_1)
        end 

        local lv2 = self.m_EffectContainer:NewObjContainer(2, CContainerObject, false)
        if lv2 then 
            self.m_Lv_2 = lv2:GetAllGameObjects()
            table.insert(self.m_EffectObjList, self.m_Lv_2)
        end 

        local lv3 = self.m_EffectContainer:NewObjContainer(3, CContainerObject, false)
        if lv3 then 
            self.m_Lv_3 = lv3:GetAllGameObjects()
            table.insert(self.m_EffectObjList, self.m_Lv_3)
        end 
     end 

    -- self.m_IsShowEffect = true

    self.m_AlphaTimer = nil
    self.m_AlphaDelta = 0.09
    self.m_UpdateRate = 1/30
    self.m_CurAlpha = 1
    self.m_WingMat = nil
end

function CWingModel.ShowWingEffect(self, lv)

    if not self.m_EffectContainer then 
        return      
    end 

    if not next(self.m_EffectObjList) then 
        return
    end

    -- self.m_IsShowEffect = lv == define.Performance.Level.high

    local show = function (objList, isShow)
        if objList then 
            for k, v in pairs(objList) do 
                v:SetActive(isShow)
            end 
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
    elseif lv == define.Performance.Level.high then 
        show(self.m_EffectObjList[1], true)
        show(self.m_EffectObjList[2], true)
        show(self.m_EffectObjList[3], true)
    end 
end

function CWingModel.AddAlphaTimer(self)
    if self.m_AlphaTimer then return end
    self.m_AlphaTimer = Utils.AddTimer(callback(self, "SetWingAlpha"), self.m_UpdateRate, 0)
end

function CWingModel.DelAlphaTimer(self)
    if self.m_AlphaTimer then
        Utils.DelTimer(self.m_AlphaTimer)
        self.m_AlphaTimer = nil
    end
    self:RecoverModelAlpha()
end

function CWingModel.SetWingAlpha(self)
    if (self.m_CurAlpha>=1 and self.m_AlphaDelta>0) or (self.m_CurAlpha<=0 and self.m_AlphaDelta<0) then
        self.m_AlphaDelta = -self.m_AlphaDelta
    end
    local delta = self.m_AlphaDelta * math.max(self.m_CurAlpha, 0.03)
    self.m_CurAlpha = self.m_CurAlpha + delta
    if not self.m_WingMat and self.m_SkinnedMeshRenderer then
        self.m_WingMat = self.m_SkinnedMeshRenderer.material
    end
    if self.m_WingMat then
        self.m_WingMat:SetColor("_Alpha", Color.New(1,1,1,self.m_CurAlpha))
    end
    return true
end

function CWingModel.Recycle(self)
    self:DelAlphaTimer()
    -- if not self.m_IsShowEffect then
    --     self:ShowWingEffect(define.Performance.Level.high)
    -- end
    CModelBase.Recycle(self)
end

function CWingModel.Destroy(self)
    self:DelAlphaTimer()
    CModelBase.Destroy(self)
    CGameObjContainer.Destroy(self)
end

function CWingModel.ClearEffect(self)
    self:ShowWingEffect()
end

return CWingModel