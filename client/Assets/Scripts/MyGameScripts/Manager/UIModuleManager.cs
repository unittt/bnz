// **********************************************************************
// Copyright (c) 2013 Baoyugame. All rights reserved.
// File     :  UIModuleManager.cs
// Author   : jiaye.lin
// Created  : 2014/11/26
// Purpose  : 
// **********************************************************************
using UnityEngine;
using System.Collections.Generic;
using AssetPipeline;
using System;

public class UIModuleManager
{
    private static readonly UIModuleManager instance = new UIModuleManager();
    public static UIModuleManager Instance
    {
        get
        {
            return instance;
        }
    }

    private static readonly Dictionary<string, UILayerType> uiInfoDic = new Dictionary<string, UILayerType>(); //以后改成配置表 todo fish
    private Dictionary<UILayerType, List<Tuple<string, GameObject>>> _moduleCacheDic; //用于缓存当前UI模块的GameObject对象
    private Dictionary<string, int> _layerCacheDic;           //用于缓存不同层当前模块的名称

    //  用于缓存当前UI模块的子模块GameObject对象
    private Dictionary<string, GameObject> _moduleChildCacheDic;

    public delegate void OnModuleOpen(IViewController vc);
    private Dictionary<string, OnModuleOpen> _openEventDic;

    private UIModuleManager()
    {
        _moduleCacheDic = new Dictionary<UILayerType, List<Tuple<string, GameObject>>>();
        _layerCacheDic = new Dictionary<string, int>();
        _openEventDic = new Dictionary<string, OnModuleOpen>();

        _moduleChildCacheDic = new Dictionary<string, GameObject>();
        _returnModuleList = new List<ModuleRecord>();
    }

    private GameObject GetExistModule(string moduleName) {
        GameObject module = null;

        if (IsModuleCacheContainsModule(moduleName))
        {
            module = GetModuleByName(moduleName);
        }
        return module;
    }
    private GameObject CreateModule(string moduleName, bool addBgMask, bool bgMaskClose = true) {
        GameObject module = null;

        if (UIModulePool.Instance.HasModuleInPool(moduleName))
        {
            module = UIModulePool.Instance.OpenModule(moduleName);
            GameObjectExt.AddPoolChild(LayerManager.Root.UIModuleRoot, module);
        }
        else
        {
            module = ResourcePoolManager.Instance.LoadUI(moduleName) as GameObject;
            module = NGUITools.AddChild(LayerManager.Root.UIModuleRoot, module);
            if (module != null) {
                module.AddMissingComponent<UIPanel>();
                if (addBgMask)
                {
                    AddBgMask(moduleName, module, bgMaskClose);
                }
            }
        }

        if (module != null) {
            module.SetActive(true);
        }

        if (module.transform.Find("BaseWindow") != null || module.transform.Find("BaseTabWindow") != null)
        {
            module.transform.localPosition = new Vector3(module.transform.localPosition.x, module.transform.localPosition.y - 8, module.transform.localPosition.z);
        }

        return module;
    }

    public T OpenFunModule<T>(string moduleName, UILayerType layerType, bool addBgMask, bool bgMaskClose = true)
    where T : MonoController {
        var ui = OpenFunModule(moduleName, layerType, addBgMask, bgMaskClose);
        var controller = ui.GetMissingComponent<T>();
        return controller;
    }

    public GameObject OpenFunModule(string moduleName, UILayerType layerType, bool addBgMask, bool bgMaskClose = true, bool isDelay = false)
    {
        GameDebug.Log("OpenFunModule-------" + moduleName);
        if (string.IsNullOrEmpty(moduleName)) {
            return null;
        }

        uiInfoDic[moduleName] = layerType;

        var depth = GetCurDepthByLayerType(layerType);
        OpenModuleEx(moduleName, depth);
        var module = GetExistModule(moduleName);
        if (module == null)
        {
            module = CreateModule(moduleName, addBgMask, bgMaskClose);
            _layerCacheDic[moduleName] = depth;
        }

        if (module != null) {
            depth = GetCurDepthByLayerType(layerType);
            module.ResetPanelsDepth(depth);
            AddModuleToCacheDic(moduleName, module);
            module.SetActive(true);
        }

        AdjustLayerDepth(layerType);

        //当在游戏loading界面时候,隐藏打开的窗口
        if (isDelay)
        {
            //WorldView worldView = WorldManager.Instance.GetView();
            //if (worldView != null && !worldView.IsInitFinish)
            //{
            //    HideModule(moduleName);
            //    _fadeOutModuleCache.Add(moduleName);
            //    WorldManager.Instance.OnFadeOutFinishEvt += OnFadeOutFinishEvt;
            //}
        }

        return module;
    }

    private List<string> _fadeOutModuleCache = new List<string>();

    private void OnFadeOutFinishEvt()
    {
        //WorldManager.Instance.OnFadeOutFinishEvt -= OnFadeOutFinishEvt;
        //for (int index = 0; index < _fadeOutModuleCache.Count; index++)
        //{
        //    ShowModule(_fadeOutModuleCache[index]);
        //}
        _fadeOutModuleCache.Clear();
    }

    private void AdjustLayerDepth(UILayerType layertype) {
        List<Tuple<string, GameObject>> list = null;
        _moduleCacheDic.TryGetValue(layertype, out list);

        Comparison<Tuple<string, GameObject>> sort = delegate (Tuple<string, GameObject> x, Tuple<string, GameObject> y)
        {
            return x.p2.GetComponentInChildren<UIPanel>().depth - y.p2.GetComponentInChildren<UIPanel>().depth;
        };

        list.Sort(sort);

        var originDepth = LayerManager.Instance.GetOriginDepthByLayerType(layertype);
        list.ForEach(s => {
            if (s != null && s.p2 != null && s.p2.activeSelf) {
                s.p2.ResetPanelsDepth(originDepth);
                //                GameDebuger.LogError(string.Format("name {0} depth = {1}", s.p2.name, s.p2.GetComponentInChildren<UIPanel>().depth));
                originDepth = UIHelper.GetMaxDepthWithPanelAndWidget(s.p2) + 1;
            }
        });
    }
    #region 子面板相关,注意该接口是历史遗留问题,不要调用它,使用 MonoAutoCacher.AddChild
    // TODO用于当前面板中创建子模块面板
    [Obsolete("子面板相关,注意该接口是历史遗留问题,不要调用它,使用 MonoAutoCacher.AddChild")]
    public GameObject AddChildPanel(string childModuleName, Transform parent, int adjustment = 1, bool addBgMask = false, bool bgMaskClose = true)
    {
        if (parent == null) return null;

        GameObject modulePrefab = ResourcePoolManager.Instance.LoadUI(childModuleName) as GameObject;
        if (modulePrefab == null) return null;
        modulePrefab.SetActive(true);
        GameObject module = NGUITools.AddChild(parent.gameObject, modulePrefab);
        UIPanel parentPanel = UIPanel.Find(parent);

        NGUITools.AdjustDepth(module, adjustment + (parentPanel != null ? parentPanel.depth : 0));

        if (addBgMask)
        {
            AddChildPanelBgMask(childModuleName, module, bgMaskClose);
            if (_moduleChildCacheDic.ContainsKey(childModuleName))
            {
                _moduleChildCacheDic[childModuleName] = module;
            }
            else
            {
                _moduleChildCacheDic.Add(childModuleName, module);
            }
        }
        return module;
    }

    public void CloseChildModule(string childModuleName)
    {
        GameObject maskModule;
        _moduleChildCacheDic.TryGetValue(childModuleName, out maskModule);
        // 使用这个作为默认值
        //var depth = UILayerType.DefaultModule;
        if (maskModule != null)
        {
            //var panel = maskModule.GetComponent<UIPanel>();
            //if (panel != null)
            //{
            //    depth = panel.depth;
            //}
            maskModule.SetActive(false);
            IViewController viewController = GetViewController(maskModule);
            if (viewController != null)
            {
                viewController.Dispose();
            }
            _moduleChildCacheDic.Remove(childModuleName);
            UnityEngine.Object.Destroy(maskModule);

            ResourcePoolManager.UnloadAssetsAndGC();
        }

        //      CloseModuleEx(childModuleName, depth);
    }

    private void AddChildPanelBgMask(string childModuleName, GameObject module, bool bgMaskClose)
    {
        //xxj begin
        //GameObject bgMask = NGUITools.AddChild(module, (GameObject)ResourcePoolManager.Instance.LoadUI("ModuleBgBoxCollider"));
        //xxj end

        GameObject bgMask = NGUITools.AddChild(module, ResourceManager.Load("UI/SdkAcccountPrefabs/BaseUI/ModuleBgBoxCollider.prefab") as GameObject);
        if (bgMaskClose)
        {
            UIEventTrigger button = bgMask.GetMissingComponent<UIEventTrigger>();
            EventDelegate.Set(button.onClick, () =>
                {
                    CloseChildModule(childModuleName);
                });
        }
        UIWidget uiWidget = bgMask.GetMissingComponent<UIWidget>();
        uiWidget.depth = -1;
        uiWidget.autoResizeBoxCollider = true;
        uiWidget.SetAnchor(module, -10, -10, 10, 10);
        NGUITools.AddWidgetCollider(bgMask);
        uiWidget.updateAnchors = UIRect.AnchorUpdate.OnStart;
    }
    #endregion

    public void CloseModule(string moduleName, bool withEX = true)
    {
        var module = GetModuleByName(moduleName);
        if (module != null)
        {
            GameDebuger.Log(string.Format("CloseModule " + moduleName));

            module.SetActive(false);
            IViewController viewController = GetViewController(module);
            RemoveElementFromModuleCache(moduleName);

            if (withEX)
            {
                int depth;
                if (!_layerCacheDic.TryGetValue(moduleName, out depth))
                {
                    var panel = module.GetComponent<UIPanel>();
                    if (panel != null)
                    {
                        depth = panel.depth;
                    }
                }
                CloseModuleEx(moduleName, depth);
            }

            if (viewController != null)
            {
                viewController.Dispose();
            }

            //            RemoveBgMask(module);
            UIModulePool.Instance.CloseModule(moduleName, module);

            //if (moduleName == ProxyNewbieGuideModule.DIALOGUE_VIEW
            //    || moduleName == ProxyNewbieGuideModule.HIGHLIGHT_VIEW
            //    || moduleName == ProxyMainUIModule.FUNCTIONOPEN_VIEW)
            //{
            //    return;
            //}

            //有些跳转场景是先关闭界面，再跳。导致切图过程中出现下一个引导，
            //这里等待个0.5f
            //JSTimer.Instance.SetupCoolDown("JudgeEnterOtherScene", 0.5f, null, () =>
            //{
            //    if (CheckOnlyMainUIActive() && !JSTimer.Instance.IsCdExist(NewBieGuideManager.NewGuideWaitASecond))
            //    {
            //        NewBieGuideManager.Instance.Trick();
            //    }
            //});
        }

        //      if (withEX)
        //      {
        //          CloseModuleEx(moduleName, depth);
        //      }
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

    /// <summary>
    /// 判断模块是否加载了
    /// 但是有可能是隐藏的状态
    /// </summary>
    /// <param name="moduleName"></param>
    /// <returns></returns>
    public bool IsModuleCacheContainsModule(string moduleName)
    {
        var check = false;
        UpdateModuleCache(moduleName, delegate (List<Tuple<string, GameObject>> set) {
            check = set.Find<Tuple<string, GameObject>>(s => s.p1 == moduleName) != null;
        });
        return check;
    }

    private void AddModuleToCacheDic(string moduleName, GameObject moduleGO) {
        UpdateModuleCache(moduleName, delegate (List<Tuple<string, GameObject>> set) {
            if (set == null) {
                var ty = UILayerType.Invalid;
                uiInfoDic.TryGetValue(moduleName, out ty);
                if (ty != UILayerType.Invalid) {
                    _moduleCacheDic[ty] = new List<Tuple<string, GameObject>> { Tuple.Create<string, GameObject>(moduleName, moduleGO) };
                }
            }
            else {
                set.ReplaceOrAdd(s => s.p1 == moduleName, Tuple.Create<string, GameObject>(moduleName, moduleGO));
            }
        });

    }
    /// <summary>
    /// 模块打开了并且激活中
    /// </summary>
    /// <param name="moduleName"></param>
    /// <returns></returns>
    public bool IsModuleOpened(string moduleName)
    {
        var module = GetModuleByName(moduleName);
        if (module != null)
        {
            return module.activeSelf;
        }
        return false;
    }

    public GameObject ShowModule(string moduleName)
    {
        var module = GetModuleByName(moduleName);

        if (module != null && !module.activeSelf)
        {
            UILayerType layerType;
            if (uiInfoDic.TryGetValue(moduleName, out layerType))
            {
                var depth = GetCurDepthByLayerType(layerType);
                OpenModuleEx(moduleName, depth);

                module.ResetPanelsDepth(depth);
                AddModuleToCacheDic(moduleName, module);
                module.SetActive(true);

                AdjustLayerDepth(layerType);
            }
        }

        return module;
    }

    public GameObject HideModule(string moduleName)
    {
        var module = GetModuleByName(moduleName);

        if (module != null)
        {
            module.SetActive(false);

            int depth;
            if (!_layerCacheDic.TryGetValue(moduleName, out depth))
            {
                var panel = module.GetComponent<UIPanel>();
                if (panel != null)
                {
                    depth = panel.depth;
                }
            }

            HideModuleEx(moduleName, depth);
        }

        return module;
    }


    /// <summary>
    /// 代替 Instance 做法
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="moduleName"></param>
    /// <returns></returns>
    public T GetModuleController<T>(string moduleName) where T : MonoBehaviour, IViewController
    {
        var go = GetModuleByName(moduleName);
        if (go != null)
        {
            return go.GetComponent<T>();
        }

        return null;
    }

    public GameObject GetModuleByName(string moduleName)
    {
        GameObject go = null;
        UpdateModuleCache(moduleName, delegate (List<Tuple<string, GameObject>> set) {
            var tuple = set.Find<Tuple<string, GameObject>>(s => s.p1 == moduleName);
            if (tuple != null) {
                go = tuple.p2;
            }
        });
        return go;
    }

    private void UpdateModuleCache(string moduleName, Action<List<Tuple<string, GameObject>>> handler) {
        var ty = UILayerType.Invalid;
        uiInfoDic.TryGetValue(moduleName, out ty);

        List<Tuple<string, GameObject>> set = null;
        _moduleCacheDic.TryGetValue(ty, out set);
        GameUtil.SafeRun(handler, set);
    }

    private void RemoveElementFromModuleCache(string moduleName) {
        UpdateModuleCache(moduleName, delegate (List<Tuple<string, GameObject>> set) {
            set.Remove(s => s.p1 == moduleName);
        });
    }

    public void RegisterOpenEvent(string moduleName, OnModuleOpen openCallback)
    {
        _openEventDic[moduleName] = openCallback;
    }

    public void SendOpenEvent(string moduleName, IViewController vc)
    {
        if (_openEventDic.ContainsKey(moduleName))
        {
            OnModuleOpen openAction = _openEventDic[moduleName];
            _openEventDic[moduleName] = null;
            if (openAction != null)
                openAction(vc);
        }
    }

    private float _bgMaskCloseCreateTime;
    private void AddBgMask(string moduleName, GameObject module, bool bgMaskClose)
    {
        //xxj begin
        //GameObject bgMask = NGUITools.AddChild(module, (GameObject)ResourcePoolManager.Instance.LoadUI("ModuleBgBoxCollider"));
        //xxj end
        GameObject bgMask = NGUITools.AddChild(module, ResourceManager.Load("UI/SdkAcccountPrefabs/BaseUI/ModuleBgBoxCollider.prefab") as GameObject);
        
        if (bgMaskClose)
        {
            _bgMaskCloseCreateTime = Time.time;
            UIEventTrigger button = bgMask.GetMissingComponent<UIEventTrigger>();
            EventDelegate.Set(button.onClick, () =>
                {
                    if (Time.time - _bgMaskCloseCreateTime >= 0.3f)
                    {
                        CloseModule(moduleName);
                    }
                });
        }
        UIWidget uiWidget = bgMask.GetMissingComponent<UIWidget>();
        uiWidget.depth = -1;
        uiWidget.autoResizeBoxCollider = true;
        uiWidget.SetAnchor(module, -10, -10, 10, 10);
        NGUITools.AddWidgetCollider(bgMask);
    }

    //    private void RemoveBgMask(GameObject module)
    //    {
    //        var child = module.transform.Find("ModuleBgBoxCollider(Clone)");
    //        if (child != null)
    //        {
    //            Object.Destroy(child.gameObject);
    //        }
    //    }

    public void CloseOtherModuleWhenNpcDialogue()
    {
        var names = new List<string>{
            //ProxyMainUIModule.MAINUI_VIEW
            ProxyLoginModule.NAME
            //, ProxyDialogueModule.NAME
            //, ProxyNewbieGuideModule.DIALOGUE_VIEW
            //, ProxyNewbieGuideModule.HIGHLIGHT_VIEW
            //, ProxyWindowModule.NAME_WindowPrefabForTop
            //, ProxyWindowModule.SIMPLE_NAME_WindowPrefabForTop
            //, ProxyTournamentModule.TournamentPath
            //, ProxyTournamentModule.TournamentV2Path
            //, BattleController.Prefab_Path
            //, ProxyDaTangModule.NAME
        };

        FilterMoudleCacheDic(
            delegate (string name) {
                var str = names.Find(s => s == name);
                return string.IsNullOrEmpty(str);
            }
            , delegate (string name) {
                CloseModule(name);
            });
    }

    public void CloseOtherModuleWhenRelogin()
    {
        var names = new List<string>{
            //ProxyMainUIModule.MAINUI_VIEW
            //, BattleController.Prefab_Path
            //, ProxyRoleCreateModule.NAME
            ProxyLoginModule.NAME};

        FilterMoudleCacheDic(
            delegate (string name) {
                var str = names.Find(s => s == name);
                return string.IsNullOrEmpty(str);
            }
            , delegate (string name) {
                CloseModule(name);
            });
    }

    /// <summary>
    /// 清空所有打开的界面模块（主界面除外）
    /// </summary>
    public void CloseOtherModule(List<string> notCloseView = null)
    {
        var names = notCloseView == null ? new List<string>
        {
            //ProxyMainUIModule.MAINUI_VIEW
        } : notCloseView;

        FilterMoudleCacheDic(
            delegate (string name)
            {
                var str = names.Find(s => s == name);
                return string.IsNullOrEmpty(str);
            }
            , delegate (string name)
            {
                CloseModule(name);
            });
    }

    private IEnumerable<string> FindAllModuleNamesInMoudleCacheDic(Predicate<string> predicate){
        List<string> keys = new List<string>();

        _moduleCacheDic.ForEach(
            delegate(KeyValuePair<UILayerType, List<Tuple<string, GameObject>>> kv) {
            kv.Value.ForEach(delegate(Tuple<string, GameObject> tuple) {
                if (predicate != null && predicate(tuple.p1)){
                    keys.Add(tuple.p1);
                }
            });
        });
        return keys;
    }
    private void FilterMoudleCacheDic(
        Predicate<string> predicate
        , Action<string> handler = null){

        IEnumerable<string> keys = FindAllModuleNamesInMoudleCacheDic (predicate);

        keys.ForEach (s=>GameUtil.SafeRun(handler, s));
    }

    public void CloseOtherButThis(string moduleName)
    {
        List<string> names = new List<string>{
            //ProxyMainUIModule.MAINUI_VIEW
            //, BattleController.Prefab_Path
            //, ProxyRoleCreateModule.NAME
            ProxyLoginModule.NAME
            //, ProxyLoseGuideModule.NAME
            , moduleName
        };

        FilterMoudleCacheDic (
            delegate(string name) {
            var str = names.Find(s=>s == name); 
            return string.IsNullOrEmpty(str);   
        }
            , delegate(string name) {
            CloseModule(name);
        });
    }

    public void CloseOtherModuleWhenGuide()
    {
        List<string> names = new List<string>{
            //ProxyMainUIModule.MAINUI_VIEW
            //, BattleController.Prefab_Path
            //, ProxyChatModule.NAME
            //, ProxyNewbieGuideModule.HIGHLIGHT_VIEW
            //, ProxyMainUIModule.FUNCTIONOPEN_VIEW
            //, ProxyTournamentModule.TournamentPath
            //, ProxyTournamentModule.TournamentV2Path
            //, ProxyGuildCompetitionModule.guildCompetitionExpandPath
            //, ProxyCampWarModule.EXPAND_VIEW_PATH
            //, EscortExpandView.NAME
            //, ProxySnowWorldBossExpandModule.NAME
            //, ProxyDaTangModule.NAME
            //, CSPKMainView.NAME
        };

        FilterMoudleCacheDic (
            delegate(string name) {
            var str = names.Find(s=>s == name); 
            return string.IsNullOrEmpty(str);   
        }
            , delegate(string name) {
            CloseModule(name);
        });
    }

    public void Dispose()
    {
        _openEventDic.Clear();
        CloseOtherModuleWhenRelogin();
        _returnModuleList.Clear();
    }

    #region 弹窗的数据存储

    private class ModuleRecord
    {
        public string ModuleName;
        public int Depth;
        public bool Active;

        public ModuleRecord(string moduleName, int depth, bool active)
        {
            ModuleName = moduleName;
            Depth = depth;
            Active = active;
        }
    }

    private List<ModuleRecord> _returnModuleList;

    /// <summary>
    /// 判断返回界面队列里面是否有该界面
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    private int FindReturnModuleIndexByName(string name)
    {
        return _returnModuleList.FindIndex(record => record.ModuleName == name);
    }

    private int FindMainModuleIndex()
    {
        return _returnModuleList.FindIndex(record =>
            GetUIModuleType(record.ModuleName) ==
            UIModuleDefinition.ModuleType.MainModule);
    }

    private int FindMainModuleLastIndex()
    {
        return _returnModuleList.FindLastIndex(record =>
            GetUIModuleType(record.ModuleName) ==
            UIModuleDefinition.ModuleType.MainModule);
    }
    #endregion

    #region 为了弹窗返回做的临时处理
    // don't need to use depth to check if module can return, check it by layer configuration -- modified by fish
    private bool IsModuleCanReturn(string name)
    {
        if (string.IsNullOrEmpty(name))
        {
            return false;
        }

        return (LayerManager.Instance != null
            && LayerManager.Instance.CurUIMode >= UIMode.GAME
            && (UIModuleDefinition.IsMainModule(name)
                || CheckLayerInRange(name, UILayerType.DefaultModule, UILayerType.FiveModule)));
    }

    private bool CheckLayerInRange(string name, UILayerType low, UILayerType high){
        UILayerType ty = UILayerType.Invalid;
        bool check = uiInfoDic.TryGetValue (name, out ty);
        if (!check) {
            return false;
        } else {
            return ty >= low && ty <= high;
        }
    }

    private UIModuleDefinition.ModuleType GetUIModuleType(string name)
    {
        if (!IsModuleCanReturn (name)) {
            return UIModuleDefinition.ModuleType.None;
        } else {

            var layer = UILayerType.Invalid;
            uiInfoDic.TryGetValue(name, out layer);
            return UIModuleDefinition.GetUIModuleType(name, layer); 
        }

    }

    private void OpenModuleEx(string name, int depth)
    {
        GameDebug.Log("OpenModuleEx-------"+name);
        if (!IsModuleCanReturn(name))
        {
            return;
        }

        var index = FindReturnModuleIndexByName(name);
        var moduleTy = GetUIModuleType (name);

        switch (moduleTy)
        {
            case UIModuleDefinition.ModuleType.MainModule:
                {
                    var firstIndex = FindMainModuleIndex();
                    var lastIndex = FindMainModuleLastIndex();

                    do
                    {
                        if (index >= 0)
                        {
                            // 打开最上层
                            if (index == lastIndex)
                            {
                                _returnModuleList[lastIndex].Depth = depth;
                                var moduleName = _returnModuleList[lastIndex].ModuleName;
                                var module = GetModuleByName(moduleName);
                                module.ResetPanelsDepth(depth);
                                break;
                            }
                            // 打开某个已经隐藏掉的
                            else if (index == firstIndex)
                            {
                                var lastList = _returnModuleList.GetRange(1, lastIndex - 1);
                                _returnModuleList.RemoveRange(0, lastIndex);
                                for (int i = 0; i < lastList.Count; i++)
                                {
                                    var record = lastList[i];
                                    CloseModule(record.ModuleName);
                                }
                                firstIndex = FindMainModuleIndex();
                                lastIndex = FindMainModuleLastIndex();
                            }
                        }
                        // 列表里面什么都没有
                        if (_returnModuleList.Count == 0)
                        {
                            _returnModuleList.Add(new ModuleRecord(name, depth, true));
                        }
                        // 列表里面存着激活的一连串窗口
                        else if (firstIndex < 0 || firstIndex == lastIndex)
                        {
                            var tList = _returnModuleList.ShallowCopyCollection<ModuleRecord, List<ModuleRecord>>();
                            _returnModuleList.Clear();
                            for (int i = 0; i < tList.Count; i++)
                            {
                                var record = tList[i];
                                HideModule(record.ModuleName);
                            }
                            OpenModuleEx(name, depth);

                            for (int i = 0;i< tList.Count; i++)
                            {
                                var record = tList[i];
                                record.Active = false;
                            }
                            _returnModuleList.InsertRange(0, tList);
                        }
                        // 列表里面新旧的列表都有
                        else if (firstIndex != lastIndex)
                        {
                            var tList = _returnModuleList.ToList();
                            for (int i = 0; i < firstIndex + 1; i++)
                            {
                                CloseModule(tList[i].ModuleName);
                            }
                            _returnModuleList = tList.GetRange(lastIndex, tList.Count - lastIndex);
                            // 回调自己，执行上面一个else if
                            OpenModuleEx(name, depth);
                        }
                    } while (false);
                    break;
                }
            case UIModuleDefinition.ModuleType.SubModule:
                {
                    // 对于已经存在过的，交给Open去处理
                    // 这里移除记录就好
                    if (index >= 0)
                    {
                        _returnModuleList.RemoveAt(index);
                    }
                    _returnModuleList.Add(new ModuleRecord(name, depth, true));

                    break;
                }
        }
    }

    private void CloseModuleEx(string name, int depth)
    {
        if (!IsModuleCanReturn(name))
        {
            return;
        }

        var index = FindReturnModuleIndexByName(name);
        if (index < 0)
        {
            return;
        }
        switch (GetUIModuleType(name))
        {
            case UIModuleDefinition.ModuleType.MainModule:
                {
                    //var firstIndex = FindMainModuleIndex();
                    var lastIndex = FindMainModuleLastIndex();

                    if (index >= 0)
                    {
                        // 关闭隐藏掉的，直接移除就好
                        if (index != lastIndex)
                        {
                            _returnModuleList.RemoveAt(index);
                        }
                        // 关闭当前打开的
                        else
                        {
                            // 后一个主面板丢弃
                            var lastList = _returnModuleList.GetRange(lastIndex + 1, _returnModuleList.Count - lastIndex - 1);
                            var firstList = _returnModuleList.GetRange(0, lastIndex);
                            _returnModuleList.Clear();
                            // 前面的重新打开一边
                            for (int i = 0; i < firstList.Count; i++)
                            {
                                var record = firstList[i];
                                // 存在列表中的才打开，否则会引发bug
                                if (IsModuleCacheContainsModule(record.ModuleName))
                                {
                                    ReOpenFunModule(record.ModuleName, false);
                                }
                            }
                            // 把后面的加回去
                            _returnModuleList.AddRange(lastList);
                        }
                    }
                    // 没记录，丢弃
                    break;
                }
            case UIModuleDefinition.ModuleType.SubModule:
                {
                    // 这里移除记录就好
                    if (index >= 0)
                    {
                        _returnModuleList.RemoveAt(index);
                    }

                    break;
                }
        }
    }

    private GameObject ReOpenFunModule(string moduleName, bool addBgMask, bool bgMaskClose = true)
    {
        UILayerType layerType = GetLayerTypeByModuleName(moduleName);
        return OpenFunModule(moduleName, layerType, addBgMask, bgMaskClose);
    }


    private void HideModuleEx(string name, int depth)
    {
        if (!IsModuleCanReturn(name))
        {
            return;
        }

        var index = FindReturnModuleIndexByName(name);
        if (index < 0)
        {
            return;
        }
        switch (GetUIModuleType(name))
        {
            case UIModuleDefinition.ModuleType.MainModule:
                {
                    //var firstIndex = FindMainModuleIndex();
                    //var lastIndex = FindMainModuleLastIndex();

                    // 暂时移除处理
                    if (index >= 0)
                    {
                        //                        _returnModuleList.RemoveRange(0, index + 1);
                        var list = _returnModuleList.GetRange(0, index);
                        _returnModuleList.RemoveRange(0, index + 1);
                        for (int i = 0; i < list.Count; i++)
                        {
                            var record = list[i];
                            CloseModule(record.ModuleName);
                        }
                    }
                    break;
                }
            case UIModuleDefinition.ModuleType.SubModule:
                {
                    // 这里移除记录就好
                    if (index >= 0)
                    {
                        _returnModuleList.RemoveAt(index);
                    }

                    break;
                }
        }

        //if (name == ProxyNewbieGuideModule.DIALOGUE_VIEW
        //    || name == ProxyNewbieGuideModule.HIGHLIGHT_VIEW
        //    || name == ProxyMainUIModule.FUNCTIONOPEN_VIEW
        //    )
        //{
        //    return;
        //}

        //if (CheckOnlyMainUIActive() && !JSTimer.Instance.IsCdExist(NewBieGuideManager.NewGuideWaitASecond))
        //{
        //    NewBieGuideManager.Instance.Trick();
        //}
    }
    #endregion

    private static readonly HashSet<string> BaseViewSet = new HashSet<string>
        {
            "MainUIView",
            "GMTestView",
            "BattleDemoView",
            "BarrageLayer",
            "BattleView"
        };

    //检查是否只有基础的UI，基础UI是指baseList列表的和深度少于UILayerType.DefaultModule的
    // the condition should be change, you can judge UIType by config-- todo fish
    public bool checkIsOnlyBaseModule()
    {
        var set = FindAllModuleNamesInMoudleCacheDic (
            delegate(string moduleName)
            {
                if (!IsModuleOpened(moduleName))
                    return false;

                var ty = GetLayerTypeByModuleName(moduleName);
                return (!BaseViewSet.Contains(moduleName))
                    && ty >= UILayerType.DefaultModule;
            });

        return set.ToList().Count == 0;
    }

    public int GetCurDepthByLayerType(UILayerType type){
        List<Tuple<string, GameObject>> set = new List<Tuple<string, GameObject>>();
        _moduleCacheDic.TryGetValue (type, out set);

        if (set.IsNullOrEmpty ()) {
            return LayerManager.Instance.GetOriginDepthByLayerType (type);
        } else {
            var tuple = set[set.Count - 1];
            return tuple.p2.GetMaxDepthWithPanelAndWidget() + 1;
        }
    }

    private UILayerType GetLayerTypeByModuleName(string moduleName){
        var ty = UILayerType.Invalid;
        bool b = uiInfoDic.TryGetValue (moduleName, out ty);
        return ty;
    }

    public bool CheckOnlyMainUIActive()
    {
        int activeCount = 0;

        if (_moduleCacheDic == null || _moduleCacheDic.Count == 0)
        {
            return false;
        }

        bool hasMainUiView = false;

        foreach (var module in _moduleCacheDic.Values)
        {
            for (int index = 0; index < module.Count; index++)
            {
                Tuple<string, GameObject> tuple = module[index];
                //if (tuple.p1 == ProxyMainUIModule.MAINUI_VIEW)
                //{
                //    hasMainUiView = true;
                //}

                if (tuple.p2.activeSelf)
                {
                    ++activeCount;
                }
            }
        }

        return hasMainUiView && activeCount == 1;
    }
}

