local CWelfareExchangePart = class("CWelfareExchangePart", CPageBase)

function CWelfareExchangePart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    -- self.m_InputGrid = self:NewUI(1,CGrid)
    self.m_ExchangeBtn = self:NewUI(3,CButton)
    -- self.m_CodeBox = self:NewUI(5,CBox)
    self.m_InputObj = self:NewUI(6,CInput)
    -- self.m_Cursor = self:NewUI(7,CSprite)
    self.m_PasteBtn = self:NewUI(8,CButton)
    self.m_UICam = g_CameraCtrl:GetUICamera()
    self.m_CursorPos = 0
    self.m_CursorChecker = nil
end

function CWelfareExchangePart.OnInitPage(self)
    -- self.m_InputObj:SetAlpha(0)
    -- self:InitInputs()
    self.m_InputObj:AddUIEvent("change", callback(self, "OnChange"))
    self.m_InputObj:AddUIEvent("UIInputOnValidate", callback(self, "OnValidate"))
    self.m_InputObj:AddUIEvent("focuschange", callback(self, "OnFocusChange"))
    self.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnClickExchange"))
    self.m_PasteBtn:AddUIEvent("click", callback(self, "OnClickPaste"))
    if Utils.IsIOS() then
        self.m_PasteBtn:SetActive(false)
    end
end

function CWelfareExchangePart.InitInputs(self)
    -- self.m_CodeBox:SetActive(false)
    -- for i = 1, 4 do
    --     local oInput = self.m_InputGrid:GetChild(i)
    --     if not oInput then
    --         oInput = self.m_CodeBox:Clone()
    --         self.m_InputGrid:AddChild(oInput)
    --         oInput.codeL = oInput:NewUI(1,CLabel)
    --     end
    --     oInput:SetActive(true)
    --     oInput:AddUIEvent("click", callback(self, "OnClickCodeBox"))
    -- end
    self:SetCursorPos(0)
    -- self.m_Cursor:SetActive(false)
end

function CWelfareExchangePart.OnChange(self)
    -- self:SumitCode2Boxes()
    self:ResetInputText()
end

function CWelfareExchangePart.OnValidate(self, oInput, char)
    local result = string.gmatch(char, "[0-9a-zA-Z%-]")
    return result()
end

function CWelfareExchangePart.OnClickExchange(self)
    local sCode = self:GetInputCode()
    if sCode then
        netother.C2GSUseRedeemCode(sCode)
        self.m_InputObj:SetText("")
        self:SumitCode2Boxes()
    end
end

function CWelfareExchangePart.OnClickCodeBox(self)
    self.m_InputObj:SetFocus()
    self:SumitCode2Boxes()
end

function CWelfareExchangePart.OnFocusChange(self)
    -- local isFocus = self.m_InputObj:IsFocus()
    -- -- self.m_Cursor:SetActive(isFocus)
    -- if isFocus then
    --     -- self:AddCursorPosChecker()
    -- else
    --     self:DelCursorChecker()
    -- end
end

function CWelfareExchangePart.SumitCode2Boxes(self)
    local sCode = self.m_InputObj:GetText()
    local iLen = string.len(sCode)
    local iCnt = math.ceil(iLen/4)
    -- for i = 1, 4 do
    --     local oInput = self.m_InputGrid:GetChild(i)
    --     if oInput then
    --         if i <= iCnt then
    --             oInput.codeL:SetText(string.sub(sCode, (i-1)*4+1, i*4))
    --         else
    --             oInput.codeL:SetText("")
    --         end
    --     end
    -- end
end

function CWelfareExchangePart.SetCursorPos(self, idx)
    -- self.m_Cursor:SetActive(idx <= 16)
    if idx > 16 then
        return
    end
    local iCnt = math.ceil(idx/4)
    if idx == 0 then
        iCnt = 1
    end
    -- local oInput = self.m_InputGrid:GetChild(iCnt)
    -- if oInput then
    --     local oCodeL = oInput.codeL
    --     local pos = oCodeL:GetPos()
    --     local width = oCodeL:GetSize()
    --     local screenPos = self.m_UICam:WorldToScreenPoint(pos)
    --     local start = idx == 0 and 1 or 0.9
    --     screenPos.x = screenPos.x + width*(start + idx/4 - iCnt)/UITools:GetPixelSizeAdjustment()
    --     local targetPos = self.m_UICam:ScreenToWorldPoint(screenPos)
    --     self.m_Cursor:SetPos(targetPos)
    -- end
end

function CWelfareExchangePart.GetInputCode(self)
    local sCode = self.m_InputObj:GetText()
    if string.len(sCode) < 19 then
        -- printc(sCode,string.len(sCode))
        g_NotifyCtrl:FloatMsg("输入不完整")
        return
    end
    return self:DeInputCode(sCode)
end

function CWelfareExchangePart.OnClickPaste(self)
    local sContent = C_api.Utils.GetClipBoardText()
    -- local sContent = NGUI.NGUITools.clipboard
    local sCode = self:DeInputCode(sContent)
    local rStr = self:EnInputCode(sCode)
    if rStr == "" then
        g_NotifyCtrl:FloatMsg("只能输入字母和数字")
        return
    end
    self.m_InputObj:SetText(rStr)
end

function CWelfareExchangePart.ResetInputText(self)
    local sContent = self.m_InputObj:GetText()
    local sCode = self:DeInputCode(sContent)
    local rStr = self:EnInputCode(sCode)
    self.m_InputObj:SetText(rStr)   
end

function CWelfareExchangePart.DeInputCode(self, sText)
    local sResult = ""
    if sText then
        for str in string.gmatch(sText, "[0-9a-zA-Z]+") do
            sResult = sResult .. str
        end
    end
    return sResult
end

function CWelfareExchangePart.EnInputCode(self, str)
    if string.len(str) > 16 then
        str = string.sub(str, 1, 16)
    end
    local strR = ""
    local gNum = math.ceil(string.len(str)/4)
    for i=1, gNum do
        -- printc((i-1)*4+1, i*4)
        if i < gNum then
            strR = strR .. string.sub(str, (i-1)*4+1, i*4) .. "-"
        else
            strR = strR .. string.sub(str, (i-1)*4+1, i*4)
        end
    end
    -- printc(strR)
    return strR
end

function CWelfareExchangePart.AddCursorPosChecker(self)
    -- self:DelCursorChecker()
    -- self.m_CursorChecker = Utils.AddTimer(function()
    --     self:CheckCursorPos()
    --     printc("=XXX")
    --     return true
    -- end, 0, 0)
end

function CWelfareExchangePart.CheckCursorPos(self)
    -- local cursorPos = self.m_InputObj.m_UIInput.cursorPosition
    -- if cursorPos > 19 then
    --     local text = self.m_InputObj:GetText()
    --     self.m_InputObj:SetText(string.sub(text, 1, 18))
    --     cursorPos = 19
    -- end
    -- if self.m_CursorPos == cursorPos then
    --     return
    -- end
    -- self.m_CursorPos = cursorPos
    -- self:SetCursorPos(cursorPos)
end

function CWelfareExchangePart.DelCursorChecker(self)
    if self.m_CursorChecker then
        Utils.DelTimer(self.m_CursorChecker)
        self.m_CursorChecker = nil
    end
end

function CWelfareExchangePart.Clean(self)
    self:DelCursorChecker()
end

return CWelfareExchangePart