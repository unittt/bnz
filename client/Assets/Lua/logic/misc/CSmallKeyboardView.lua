local CSmallKeyboardView = class("CSmallKeyboardView", CViewBase)

function CSmallKeyboardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/SmallKeyboardView.prefab", cb)
    -- self.m_ExtendClose = "ClickOut"
    self.m_DepthType = "Fourth"
    self.m_NumberList = {}
    self.m_HasInput = false
end

function CSmallKeyboardView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_KeyBoardGrid = self:NewUI(2, CGrid)
    self.m_Bg = self:NewUI(3, CSprite)

    self.m_MinFloatMsg = "输入数字超出范围"
    self.m_MaxFloatMsg = "输入数字超出范围"

    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnTouchOutDetect"))
    self:InitGrid()
end

function CSmallKeyboardView.OnTouchOutDetect(self)
    self:AdjustNumberList()
    self:CloseView()
end

-------------------------数据初始化和获取------------------------------
--input:输入
--keyCallback：数字按键回调
--confirm：确定按钮回调
--side:锚点对位
--min:限制的最小数值
--max:限制的最大数值
function CSmallKeyboardView.SetData(self, input, keyCallback, confirmCb, side, min, max, defaultValue)
    self.m_Input = input
    self.m_KeyCallback = keyCallback
    self.m_ConfirmCb = confirmCb
    self.m_Limit = {min = min or 1, max = max or 99}
    local anchorSide = enum.UIAnchor.Side.Top
    local count = tonumber(self.m_Input:GetText())
    self:SetNumber(count or defaultValue)
    if side ~= nil then
        anchorSide = side
    end
    UITools.NearTarget(self.m_Input, self.m_Bg, anchorSide, Vector3.New(-25, 18, 0))
end

function CSmallKeyboardView.SetNumber(self, value)
    self.m_NumberList = {}
    while true do
        local remainder = value%10
        value = math.floor(value/10)
        table.insert(self.m_NumberList, 1, remainder)
        if value == 0 then
            break
        end
    end
end

function CSmallKeyboardView.GetNumber(self)
    local str = self:CoverNumberListToString()
    if str == "" then
        return 1
    end
    return tonumber(str)
end

--调整numberlist限制在可输入范围内
function CSmallKeyboardView.AdjustNumberList(self) 
    if self.m_Input then
        local iValue = self:GetNumber()
        if iValue > self.m_Limit.max then
            self:SetNumber(self.m_Limit.max)
            self.m_Input:SetText(self.m_Limit.max)
        elseif iValue < self.m_Limit.min then
            self:SetNumber(self.m_Limit.min)
            self.m_Input:SetText(self.m_Limit.min)
        end
        if self.m_ConfirmCb then
            self.m_ConfirmCb(self)    
        end
    end
end

function CSmallKeyboardView.SetWarningMsg(self, sMin, sMax)
    self.m_MinFloatMsg = sMin
    self.m_MaxFloatMsg = sMax
end

--------------------------UI初始化---------------------------------------
function CSmallKeyboardView.InitGrid(self)
    local lBtnList = {1,2,3,11,4,5,6,10,7,8,9,12}
    local function init(obj, idx)
        local oBtn = CButton.New(obj)
        local iBtn = lBtnList[idx]
        oBtn:AddUIEvent("click", callback(self, "OnKeyboard", iBtn))
        oBtn:SetGroup(self.m_KeyBoardGrid:GetInstanceID())
        return oBtn
    end
    self.m_KeyBoardGrid:InitChild(init)
end


---------------------------点击监听--------------------------------------
function CSmallKeyboardView.OnKeyboard(self, idx)
    if idx < 10 then
        if not self.m_HasInput then
            self.m_NumberList = {}
            self.m_HasInput = true
        end
        table.insert(self.m_NumberList, idx)
    elseif idx == 10 then
        if #self.m_NumberList < 1 then
            table.insert(self.m_NumberList, 1)
        end
        table.insert(self.m_NumberList, 0)
    elseif idx == 11 then
        self:OnDelInput()
    else 
        self:AdjustNumberList()
        if self.m_ConfirmCb then
            self.m_ConfirmCb(self)    
        end
        self.m_NumberList = nil
        self:OnClose()
        return    
    end
    local iValue = self:GetNumber()
    if iValue > self.m_Limit.max or self.m_Limit.max == 0 then
        g_NotifyCtrl:FloatMsg(self.m_MaxFloatMsg or "输入数字超出范围")
        self:SetNumber(self.m_Limit.max)
    end
    local str = self:CoverNumberListToString()
    if self.m_Input then
        if self:CheckLimit() then
            self.m_Input:SetText(string.format("[c]#R%s#n", str))
            g_NotifyCtrl:FloatMsg(self.m_MinFloatMsg or "输入数字超出范围")
        else
            self.m_Input:SetText(str)
        end
        if self.m_KeyCallback then
            self.m_KeyCallback(self)
        end
    end
end

function CSmallKeyboardView.OnDelInput(self)
    local iCnt = #self.m_NumberList
    if iCnt >= 1 then
        if iCnt==1 then
            if self.m_NumberList[1] == 1 then
                self:ShowRangeOutMsg()
            end
            self.m_HasInput = false
        elseif iCnt==2 and self.m_NumberList[1]==1 then
            self.m_HasInput = false
            table.remove(self.m_NumberList)
        elseif not self.m_HasInput then
            self.m_HasInput = true
        end
        table.remove(self.m_NumberList)
    else
        self:ShowRangeOutMsg()
    end
end

function CSmallKeyboardView.ShowRangeOutMsg(self)
    g_NotifyCtrl:FloatMsg(string.format("输入范围%d~%d", self.m_Limit.min, self.m_Limit.max))
end

function CSmallKeyboardView.CoverNumberListToString(self)
    local str = ""
    for i,v in ipairs(self.m_NumberList) do
       str = str..v    
    end
    if str == "" then
        str = self.m_Limit.min
    end
    return str
end

function CSmallKeyboardView.CheckLimit(self)
    if self.m_Input then
        local iValue = self:GetNumber()
        return iValue < self.m_Limit.min or iValue > self.m_Limit.max
    end
    return false
end
return CSmallKeyboardView