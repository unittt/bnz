local CPlotEffectMask = class("CPlotEffectMask")

function CPlotEffectMask.ctor(self)
    self.m_RefDict = {}
    self.m_MaskObj = nil
end

function CPlotEffectMask.ShowMask(self, id)
    self.m_RefDict[id] = true
    if self.m_MaskObj then
        self.m_MaskObj:SetActive(true)
    else
        self:CreateMask()
    end
end

function CPlotEffectMask.CreateMask(self)
    local obj = UnityEngine.GameObject.New("PlotEffMask")
    local oCam = g_CameraCtrl:GetMainCamera() 
    local cam = oCam.m_Camera
    obj.transform:SetParent(oCam.m_Transform, false)
    obj.transform.localPosition = Vector3(0,0,0)
    local w, h = cam.pixelWidth, cam.pixelHeight
    local pos = cam:ScreenToWorldPoint(Vector3(w, h, 0))
    local origin = cam:ScreenToWorldPoint(Vector3(0, 0, 0))
    pos = pos - origin

    local mesh = self:CreateMesh(pos.x/2 + 0.1, pos.y/2 + 0.1)
    self:DrawMesh(mesh, obj)

    self.m_MaskObj = obj
end

function CPlotEffectMask.CreateMesh(self, w, h)
    local mesh = UnityEngine.Mesh.New()
    mesh:Clear()
    mesh.vertices = {
        Vector3(-w,-h,0),
        Vector3(w,-h,0),
        Vector3(-w,h,0),
        Vector3(w,h,0),
    }
    mesh.uv = {
        Vector2(0,0),
        Vector2(0,1),
        Vector2(1,1),
        Vector2(1,0)
    }
    mesh.triangles = {0,3,1,0,2,3}
    mesh:RecalculateBounds()
    mesh:RecalculateNormals()
    return mesh
end

function CPlotEffectMask.DrawMesh(self, mesh, obj)
    local mf = obj:AddComponent(typeof(UnityEngine.MeshFilter))
    local mr = obj:AddComponent(typeof(UnityEngine.MeshRenderer))
    local mat = UnityEngine.Material.New(UnityEngine.Shader.Find("Game/Particles/Particle Blended"))
    mat:SetColor("_TintColor", Color.RGBAToColor("00000041"))
    mr.material = mat
    mf.mesh = mesh
end

function CPlotEffectMask.RemoveMask(self, id)
    self.m_RefDict[id] = nil
    if not next(self.m_RefDict) then
        if self.m_MaskObj then
            self.m_MaskObj:SetActive(false)
        end
    end
end

function CPlotEffectMask.Destroy(self)
    if self.m_MaskObj then
        self.m_MaskObj:Destroy()
        self.m_MaskObj = nil
    end
end

return CPlotEffectMask