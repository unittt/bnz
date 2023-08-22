local CDetailImageBox = class("CDetailImageBox", CBox)

function CDetailImageBox.ctor(self, obj)
    CBox.ctor(self, obj)
    self.m_Texture = self:NewUI(1, CTexture)
    self:AddUIEvent("click", callback(self, "OnImageLink")) 
    self.m_Texture:SetActive(false)   
end

function CDetailImageBox.SetData(self, info)
    self.m_ImageData = info
    self.m_Texture:SetWidth(self.m_ImageData.width)
    self.m_Texture:SetHeight(self.m_ImageData.height)
    self.m_Texture:AddUIEvent("click", callback(self, "OnImageLink", self.m_ImageData.link))
    --self.m_Texture:SetAnchorTarget(target, 0, 0, self.m_ImageData.width, self.m_ImageData.height)
    --self.m_Texture:SetAnchor("topAnchor", 0, 1)  
    local texture = UnityEngine.Texture2D.New(self.m_ImageData.width, self.m_ImageData.height)
    g_ImageCtrl:GetImageByKey(self.m_ImageData.key, function (bytes)    
    	texture:LoadImage(bytes)
        self.m_Texture:SetMainTexture(texture)
        self.m_Texture:SetActive(true)
    end)
end

function CDetailImageBox.OnImageLink(self, link)
    if link then
        UnityEngine.Application.OpenURL(link)
    end
end

return CDetailImageBox