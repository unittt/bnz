local CLotteryPlateBox = class("CLotteryPlateBox", CBox)

function CLotteryPlateBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_TurnWgt = self:NewUI(1, CWidget)
    self.m_SelWgt = self:NewUI(2, CWidget)
    self.m_LotteryTex = self:NewUI(3, CTexture)
    self.m_LotteryCntL = self:NewUI(4, CLabel)
    self.m_LotteryLSpr = self:NewUI(5, CSprite)
    self.m_MoneySpr = self:NewUI(6, CSprite)
    self.m_LotteryCnt2L = self:NewUI(7, CLabel)
    self.m_ArrowSpr = self:NewUI(8, CSprite)
    self.m_IsRotating = false
end

function CLotteryPlateBox.AddClickEvent(self, cb)
    self.m_LotteryTex:AddUIEvent("click", cb)
end

function CLotteryPlateBox.SetAmount(self, iAmount)
    self.m_LotteryCntL:SetText(iAmount)
    self.m_LotteryCnt2L:SetText(iAmount)
end

function CLotteryPlateBox.SetMidPartGrey(self, bGrey)
    self.m_LotteryCntL:SetActive(not bGrey)
    self.m_LotteryCnt2L:SetActive(bGrey)
    self.m_LotteryTex:SetGrey(bGrey)
    self.m_LotteryLSpr:SetGrey(bGrey)
    self.m_MoneySpr:SetGrey(bGrey)
    self.m_ArrowSpr:SetGrey(bGrey)
end

function CLotteryPlateBox.GetDegreeByIndex(self, index)
    local degree = ((2 * index) - 1) * 22.5 * -1
    return degree
end

function CLotteryPlateBox.StartPlay(self, iStart, iEnd, endCb)
    if self.m_IsRotating then
        return
    end
    local degree = self:GetDegreeByIndex(iStart)
    self.m_SelWgt:SetActive(false)
    local tween = DOTween.DORotate(self.m_TurnWgt.m_Transform, Vector3.New(0, 0, degree + (-360 *2)), 2, 1)
    self.m_IsRotating = true
    local function onEnd()
        self.m_IsRotating = false
        self.m_SelWgt:SetActive(true)
        if endCb then
            endCb()
        end
    end
    DOTween.OnComplete(tween, onEnd)
end

function CLotteryPlateBox.IsPlaying(self)
    return self.m_IsRotating
end

return CLotteryPlateBox