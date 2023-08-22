using UnityEngine;
using System.Collections.Generic;

public class SdkModuleMgr
{
    public static readonly SdkModuleMgr Instance = new SdkModuleMgr();
    
    private SdkModuleType.ModuleType _curModuleType;
    private int _layer;
    public int SdkAcountLayer
    {
        get
        {
            if(_layer == 0)
                _layer = SdkLoginMessage.Instance.GetLayer();
            return _layer;
        }
    }
    public int SdkTopLayer
    {
        get { return SdkAcountLayer + 500; }
    }
    
    public class ModuleCache
    {
        private Dictionary<string, GameObject> _name2Module;
        private List<string> _nameList;
        public int ModuleCount
        {
            get { return _name2Module.Count; }
        }

        public List<string> NameList { get { return _nameList; } }

        public ModuleCache()
        {
            _name2Module = new Dictionary<string, GameObject>();
            _nameList = new List<string>();
        }

        public void Add(string name, GameObject module)
        {
            _name2Module[name] = module;
            if (_nameList.Contains(name))
            {
                _nameList.Remove(name);
            }
            _nameList.Add(name);
        }

        public void Remove(string name)
        {
            if (!_nameList.Contains(name)) return;

            _name2Module.Remove(name);
            _nameList.Remove(name);
        }

        public GameObject GetModule(string name)
        {
            if (_name2Module.ContainsKey(name))
            {
                return _name2Module[name];
            }
            return null;
        }

        public string GetModuleName(GameObject module)
        {
            string moduleName = string.Empty;
            foreach (string sName in _name2Module.Keys)
            {
                if (_name2Module[sName] == module)
                {
                    moduleName = sName;
                    break;
                }
            }
            return moduleName;
        }

        public int GetNextLayer()
        {
            GameObject module = null;
            if(_nameList.Count > 0)
            {
                module = _name2Module[_nameList[_nameList.Count - 1]];
            }

            if(module != null)
            {
                return module.GetComponent<UIPanel>().depth;
            }

            return SdkModuleMgr.Instance.SdkAcountLayer;
        }
    }

    //有区域限制（即type为SmallArea、BigArea）
    private ModuleCache _moduleCache;

    public SdkModuleMgr()
    {
        _moduleCache = new ModuleCache();
    }

    public void InitRoot(GameObject root)
    { 
        if (SdkBaseController.Instance != null) return;

        //xxj begin
        //GameObject module = AssetPipeline.ResourcePoolManager.Instance.LoadUI(SdkBaseView.NAME) as GameObject;
        //xxj end
        GameDebuger.Log("ResourceManager.Load() SdkBaseView.NAME:" + SdkBaseView.NAME);
        GameObject module = ResourceManager.Load(SdkBaseView.NAME) as GameObject;
        module.SetActive(true);
        module = NGUITools.AddChild(root, module);
        module.SetActive(true);
        module.AddMissingComponent<UIPanel>();
        NGUITools.AdjustDepth(module, SdkAcountLayer);

        SdkBaseController.Setup(module);
        SdkLoadingTipController.Setup(module);
        SdkNotifyTipController.Setup(module);
    }
    
    public GameObject OpenModule(string name)
    {
        var type = SdkModuleType.GetModuleType(name);
        SetCurModuleType(type);

        GameObject module = _moduleCache.GetModule(name);

        if (module != null)
        {
            CloseTopperModule(name);
            return module;
        }

        GameObject parent = (type == SdkModuleType.ModuleType.SmallArea) ? SdkBaseController.SmallAreaGo : SdkBaseController.BigAreaGo;

        //xxj begin
        //module = AssetPipeline.ResourcePoolManager.Instance.LoadUI(name) as GameObject;
        //xxj end

        module = ResourceManager.Load(name) as GameObject;
        module.SetActive(true);
        module = NGUITools.AddChild(parent, module);
        module.SetActive(true);
        module.AddMissingComponent<UIPanel>();

        int uiLayer = _moduleCache.GetNextLayer();
        NGUITools.AdjustDepth(module, uiLayer);
        
        _moduleCache.Add(name, module);
        if (uiLayer != SdkAcountLayer)
        {
            MoveIn(module, type);
        }

        CheckBgColliderShow();
        return module;
    }

    //区域类型切换
    public void SetCurModuleType(SdkModuleType.ModuleType type)
    {
        //类型变化，清除之前模块的显示
        if(type != _curModuleType)
            ClearModule();

        _curModuleType = type;
    }

    public void CheckBgColliderShow()
    {
        SdkBaseController.BgColliderGo.SetActive(_moduleCache.ModuleCount != 0);

        if (SdkBaseController.BgBehindLayerGo != null)
        {
            SdkBaseController.BgBehindLayerGo.SetActive(_moduleCache.ModuleCount != 0);
        }

        if (SdkBaseController.BgBehindLayer != null)
        {
            SdkBaseController.BgBehindLayer.depth = GameSetting.DEMI_SDK_UILayer - 1;
        }
    }

    /// <summary>
    /// 关闭比当前模块更上层的界面
    /// </summary>
    /// <param moduleName="moduleName">当前模块名</param>
    public void CloseTopperModule(string moduleName)
    {
        List<string> closeList = new List<string>();
        for(int i =  _moduleCache.NameList.Count-1; i >=0; --i)
        { 
            if (_moduleCache.NameList[i] == moduleName) break;

            closeList.Add(_moduleCache.NameList[i]);
        }
        
        foreach(var closeName in closeList)
        {
            CloseModule(closeName);
        }
    }

    public void MoveIn(GameObject module, SdkModuleType.ModuleType type)
    {
        module.transform.position = (type == SdkModuleType.ModuleType.SmallArea) ? SdkBaseController.SmallAreaHidePos:SdkBaseController.BigAreaHidePos;
        Vector3 des = (type == SdkModuleType.ModuleType.SmallArea) ? SdkBaseController.SmallAreaPos : SdkBaseController.BigAreaPos;
        var com = TweenPosition.Begin(module, 0.5f, des, true);
        com.method = UITweener.Method.Linear;
        com.onFinished.Clear();
    }

    public void MoveOut(GameObject module, SdkModuleType.ModuleType type)
    {
        Vector3 des = (type == SdkModuleType.ModuleType.SmallArea) ? SdkBaseController.SmallAreaHidePos : SdkBaseController.BigAreaHidePos; 
        var com = TweenPosition.Begin(module, 0.5f, des, true);
        com.method = UITweener.Method.Linear;
        EventDelegate.Set(com.onFinished,()=> { CloseModule(module); });
    }

    public void CloseModuleSlow(string name)
    {
        var type = SdkModuleType.GetModuleType(name);
        GameObject module = _moduleCache.GetModule(name);
        if (module != null)
        {
            if (_moduleCache.ModuleCount == 1)
                CloseModule(module);
            else
                MoveOut(module, type);
        }
    }

    public void CloseModule(string moduleName)
    {
        GameObject module = _moduleCache.GetModule(moduleName);
        if (module != null)
        {
            IViewController viewController = GetViewController(module);
            _moduleCache.Remove(moduleName);

            if (viewController != null)
            {
                viewController.Dispose();
            }

            DestroyModule(module);
        }

        CheckBgColliderShow();
    }

    public void CloseModule(GameObject module)
    {
        string moduleName = _moduleCache.GetModuleName(module);

        if (moduleName != string.Empty)
        {
            IViewController viewController = GetViewController(module);
            _moduleCache.Remove(moduleName);

            if (viewController != null)
            {
                viewController.Dispose();
            }

            DestroyModule(module);
        }

        CheckBgColliderShow();
    }

    public void ClearModule()
    {
        List<string> list = new List<string>();
        foreach(var name in _moduleCache.NameList)
        {
            list.Add(name);
        }
        
        foreach (var name in list)
        {
            CloseModule(name);
        }
    }

    public void DestroyModule(GameObject go, bool gc = true)
    {
        if (go != null)
        {
            Object.Destroy(go);
            ResourceManager.UnloadAssetsAndGC();
        }
    }

    private IViewController GetViewController(GameObject module)
    {
        MonoBehaviour[] list = module.GetComponents<MonoBehaviour>();
        for (int i = 0, len = list.Length; i < len; i++)
        {
            MonoBehaviour mono = list[i];
            if (mono is IViewController)
            {
                return mono as IViewController;
            }
        }
        return null;
    }

    public bool IsModuleOpen(string name)
    {
        GameObject module = _moduleCache.GetModule(name);
        return module != null;
    }

    //界面无hide的情况，有则需处理
    public bool HashModuleShow()
    {
        return _moduleCache.ModuleCount > 0;
    }
}
