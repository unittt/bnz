local CPlotUIEffectCtrl = class("CPlotUIEffectCtrl")

function CPlotUIEffectCtrl.ctor(self, oRoot, dInfo, elapsedTime) 
    self.m_ElapsedTime = elapsedTime
    self.m_Info = dInfo
    self.m_RootObj = oRoot
    self.m_Effect = nil

    self:Init(dInfo)
end

function CPlotUIEffectCtrl.Init(self, dInfo)
    local oSequence = DOTween.Sequence()
    self.m_Sequence = oSequence

    local startTime = dInfo.startTime
    if self.m_ElapsedTime then
        startTime = self.m_ElapsedTime + startTime
    end
    oSequence:AppendInterval(dInfo.endTime - startTime)
    DOTween.OnComplete(oSequence, callback(self, "Dispose"))

    self:CreateEffect(dInfo)
end

function CPlotUIEffectCtrl.CreateEffect(self, dEff, iDuration)
    local vScale = dEff.isScale and dEff.scale
    local vRotate = dEff.isRotate and dEff.rotate
    local iSortingOrder = dEff.isSetOrder and dEff.sortingOrder
    local oEff = CUIEffectScreen.New(self.m_RootObj, dEff.name, vScale, dEff.pos, vRotate, iSortingOrder, nil, dEff.folderName)
    oEff:SetParent(self.m_RootObj.m_Transform)
    self.m_Effect = oEff
end

-- 设置特效Layer，用于截图等
function CPlotUIEffectCtrl.SetEffectLayer(self, iLayer)
    local oEff = self.m_Effect
    if not Utils.IsNil(oEff) then
        local o = oEff.m_Eff
        if not Utils.IsNil(o) then
            -- local childs = o:GetComponentsInChildren(typeof(UnityEngine.Transform), true)
            -- for i = 0, childs.Length-1 do
            --     childs[i].gameObject.layer = iLayer
            -- end
            CObject.SetLayer(o, iLayer, true)
        end
    end
end

function CPlotUIEffectCtrl.Pause(self)
    if self.m_Sequence then 
        self.m_Sequence:Pause()
    end
end

function CPlotUIEffectCtrl.Resume(self)
    if self.m_Sequence then
        self.m_Sequence:Play()
    end
end

function CPlotUIEffectCtrl.Dispose(self)
    if self.m_Sequence then
        self.m_Sequence:Kill(true)
        self.m_Sequence = nil
    end
    if self.m_Effect then
        self.m_Effect:Destroy()
        self.m_Effect = nil
    end
end

return CPlotUIEffectCtrl