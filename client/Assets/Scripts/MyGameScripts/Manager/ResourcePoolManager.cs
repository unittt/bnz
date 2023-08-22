using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using PathologicalGames;

namespace AssetPipeline
{
    public class PrefabPoolConfig
    {
        public const string POOLCONFIG_FILE = "PoolConfig";

        public Dictionary<string, PrefabPoolOption> config;
        private PrefabPoolOption defaultPoolOption;
        public PrefabPoolConfig()
        {
            config = new Dictionary<string, PrefabPoolOption>();
        }

        public PrefabPoolOption GetPoolOption(string bundleName)
        {
            if (config == null) return null;
            PrefabPoolOption poolOption;
            config.TryGetValue(bundleName, out poolOption);
            if (poolOption == null)
            {
                poolOption = GetDefaultOption();
            }
            return poolOption;
        }
        public PrefabPoolOption GetDefaultOption()
        {
            if (defaultPoolOption != null)
            {
                return defaultPoolOption;
            }
            PrefabPoolOption value;
            if (config.TryGetValue("Default", out value) == false)
            {
                value = new PrefabPoolOption(1, true, 10, 30, 5, false, 100, true);
            }
            return defaultPoolOption = value;
        }
    }

    public class PrefabPoolOption
    {
        /// <summary>
        /// The number of instances to preload
        /// 创建池时预加载数量
        /// </summary>
        public int preloadAmount = 1;

        /// <summary>
        /// Displays the 'preload over time' options
        /// 是否分时预加载池对象
        /// </summary>
        public bool preloadTime = false;

        /// <summary>
        /// The number of frames it will take to preload all requested instances
        /// 用多少帧来实例化所有的预加载对象
        /// </summary>
        public int preloadFrames = 2;

        /// <summary>
        /// The number of seconds to wait before preloading any instances
        /// 分时预加载启动延迟
        /// </summary>
        public float preloadDelay = 0;

        /// <summary>
        /// Limits the number of instances allowed in the game. Turning this ON
        ///	means when 'Limit Amount' is hit, no more instances will be created.
        /// CALLS TO SpawnPool.Spawn() WILL BE IGNORED, and return null!
        ///
        /// This can be good for non-critical objects like bullets or explosion
        ///	Flares. You would never want to use this for enemies unless it makes
        ///	sense to begin ignoring enemy spawns in the context of your game.
        /// 是否限制池对象总数量,开启之后超过限制数量时,将会返回空对象
        /// </summary>
        public bool limitInstances = false;

        /// <summary>
        /// This is the max number of instances allowed if 'limitInstances' is ON.
        /// 只要limitInstances开启时有效,限制该池对象的最大数量
        /// </summary>
        public int limitAmount = 100;

        /// <summary>
        /// FIFO stands for "first-in-first-out". Normally, limiting instances will
        /// stop spawning and return null. If this is turned on (set to true) the
        /// first spawned instance will be despawned and reused instead, keeping the
        /// total spawned instances limited but still spawning new instances.
        /// 开启这个选项后,超过限制总数时,将会把第一个生成的池对象先Despawn,然后再进行Spawn操作,保持总数量不变
        /// </summary>
        public bool limitFIFO = false;  // Keep after limitAmount for auto-inspector

        /// <summary>
        /// Turn this ON to activate the culling feature for this Pool. 
        /// Use this feature to remove despawned (inactive) instances from the pool
        /// if the size of the pool grows too large. 
        ///	
        /// DO NOT USE THIS UNLESS YOU NEED TO MANAGE MEMORY ISSUES!
        /// This should only be used in extreme cases for memory management. 
        /// For most pools (or games for that matter), it is better to leave this 
        /// off as memory is more plentiful than performance. If you do need this
        /// you can fine tune how often this is triggered to target extreme events.
        /// 
        /// A good example of when to use this would be if you you are Pooling 
        /// projectiles and usually never need more than 10 at a time, but then
        /// there is a big one-off fire-fight where 50 projectiles are needed. 
        /// Rather than keep the extra 40 around in memory from then on, set the 
        /// 'Cull Above' property to 15 (well above the expected max) and the Pool 
        /// will Destroy() the extra instances from the game to free up the memory. 
        /// 
        /// This won't be done immediately, because you wouldn't want this culling 
        /// feature to be fighting the Pool and causing extra Instantiate() and 
        /// Destroy() calls while the fire-fight is still going on. See 
        /// "Cull Delay" for more information about how to fine tune this.
        /// 是否自动剔除池对象
        /// </summary>
        public bool cullDespawned = false;

        /// <summary>
        /// The number of TOTAL (spawned + despawned) instances to keep. 
        /// 当池对象总数大于这个阈值时,将会开始剔除冗余的Despawned状态下的对象
        /// </summary>
        public int cullAbove = 50;

        /// <summary>
        /// The amount of time, in seconds, to wait before culling. This is timed 
        /// from the moment when the Queue's TOTAL count (spawned + despawned) 
        /// becomes greater than 'Cull Above'. Once triggered, the timer is repeated 
        /// until the count falls below 'Cull Above'.
        /// 当池对象总数大于cullAbove时,将会触发剔除计时器,进行剔除操作,计时器会一直重复触发直到池对象总数降回合理的数值
        /// </summary>
        public int cullDelay = 60;

        /// <summary>
        /// The maximum number of instances to destroy per this.cullDelay
        /// 每次触发剔除操作时,销毁池对象的最大值
        /// </summary>
        public int cullMaxPerPass = 5;

        /// <summary>
        /// 在跳转场景时检查是否移除该PrefabPool
        /// </summary>
        public bool unloadChangeScene;

        public PrefabPoolOption()
        {

        }

        public PrefabPoolOption(int preloadAmount, bool cullDespawned, int cullAbove, int cullDelay, int cullMaxPerPass, bool limitInstances, int limitAmount, bool limitFIFO, bool unloadChangeScene = true)
        {
            this.preloadAmount = preloadAmount;
            this.cullDespawned = cullDespawned;
            this.cullAbove = cullAbove;
            this.cullDelay = cullDelay;
            this.cullMaxPerPass = cullMaxPerPass;
            this.limitInstances = limitInstances;
            this.limitAmount = limitAmount;
            this.limitFIFO = limitFIFO;
            this.unloadChangeScene = unloadChangeScene;
        }

        public void CopyTo(PrefabPool prefabPool)
        {
            prefabPool.preloadAmount = this.preloadAmount;
            prefabPool.preloadTime = this.preloadTime;
            prefabPool.preloadFrames = this.preloadFrames;
            prefabPool.preloadDelay = this.preloadDelay;

            prefabPool.limitInstances = this.limitInstances;
            prefabPool.limitAmount = this.limitAmount;
            prefabPool.limitFIFO = this.limitFIFO;

            prefabPool.cullDespawned = this.cullDespawned;
            prefabPool.cullAbove = this.cullAbove;
            prefabPool.cullDelay = this.cullDelay;
            prefabPool.cullMaxPerPass = this.cullMaxPerPass;
        }
    }

    public class ResourcePoolManager : MonoBehaviour
    {
#if UNITY_IPHONE
        public const int WARNING_MEMORY = 70;
#else
        public const int WARNING_MEMORY = 70;
#endif
        private const float ForceUnloadInterval = 300f;
        private const string ClearDestroyPoolItemTimer = "ClearDestroyPoolItemTimer";
        /// <summary>
        /// 缓存池类型
        /// </summary>
        public enum PoolType
        {
            UI,
            Model,
            Effect,
            //Audio,
            Scene,
        }

        private static ResourcePoolManager _instance;
        private static bool _isQuit = false;

        public static ResourcePoolManager Instance
        {
            get
            {
                if (_instance == null && !_isQuit)
                {
                    GameObject go = new GameObject("ResourcePoolManager");
                    _instance = go.AddComponent<ResourcePoolManager>();
                    DontDestroyOnLoad(go);
                }
                return _instance;
            }
        }

        private Transform _poolMgrTrans;
        private Dictionary<PoolType, SpawnPool> _spawnPools;
        public PrefabPoolConfig _poolConfig;
        private float lastUnloadAssetTime;
        void Awake()
        {
            _poolMgrTrans = this.transform;
            JSTimer.Instance.SetupTimer(ClearDestroyPoolItemTimer, ClearDestroyPoolItem, 5f);
        }
        void OnApplicationQuit()
        {
            _isQuit = true;
            Debug.Log("ResourcePoolManager OnApplicationQuit");
            Dispose();
        }


        public void Setup()
        {
            if (_poolConfig == null)
            {
                //xxj begin
                //var textAsset = AssetManager.Instance.LoadAsset(PrefabPoolConfig.POOLCONFIG_FILE, ResGroup.Config) as TextAsset;
                //if (textAsset != null)
                //{
                //    _poolConfig = JsHelper.ToObject<PrefabPoolConfig>(textAsset.text);
                //}
                
                //AssetManager.Instance.UnloadBundle(PrefabPoolConfig.POOLCONFIG_FILE, ResGroup.Config);
                //xxj end
            }

            if (_spawnPools == null)
            {
                _spawnPools = new Dictionary<PoolType, SpawnPool>(5);
                var typeNames = Enum.GetNames(typeof(PoolType));
                var typeValues = Enum.GetValues(typeof(PoolType));
                for (int i = 0; i < typeValues.Length; i++)
                {
                    var poolType = (PoolType)typeValues.GetValue(i);
                    var pool = PoolManager.Pools.Create(typeNames[i]);
                    pool.group.parent = _poolMgrTrans;
                    _spawnPools.Add(poolType, pool);
                }
            }

            //xxj begin
            //GameEventCenter.AddListener(GameEvent.OnSceneChangeEnd, OnChangeScene);
            //xxj end
        }

        public void Dispose()
        {
            //xxj begin
            //GameEventCenter.RemoveListener(GameEvent.OnSceneChangeEnd, OnChangeScene);
            //xxj end
            JSTimer.Instance.CancelTimer(ClearDestroyPoolItemTimer);
        }

        public void OnChangeScene()
        {
            UnloadUnusedPoolAndAsset();
        }

        private void ClearDestroyPoolItem()
        {
            foreach (var keyValue in _spawnPools)
            {
                keyValue.Value.ClearDestroyItem();
            }
        }

        #region 缓存池资源释放接口
        /// <summary>
        /// 销毁spawnedList.Count == 0 的对象池
        /// </summary>
        public void UnloadUnusedPool(PoolType poolType)
        {
            if (_spawnPools == null) return;

            SpawnPool spawnPool;
            if (_spawnPools.TryGetValue(poolType, out spawnPool))
            {
                var prefabPools = spawnPool.prefabPoolList;
                List<PrefabPool> removeList = null;
                foreach (var prefabPool in prefabPools)
                {
                    var poolOption = _poolConfig.GetPoolOption(prefabPool.bundleName);
                    if (poolOption != null && poolOption.unloadChangeScene)
                    {
                        if (prefabPool.spawnedCount == 0)
                        {
                            if (removeList == null)
                            {
                                removeList = new List<PrefabPool>();
                            }
                            removeList.Add(prefabPool);
                        }
                    }
                }

                if (removeList != null && removeList.Count > 0)
                {
                    foreach (var prefabPool in removeList)
                    {
                        spawnPool.DestroyPrefabPool(prefabPool);
                        string bundleName = prefabPool.bundleName;

                        //xxj begin
                        //AssetManager.Instance.UnloadDependencies(bundleName);
                        //xxj end
                    }
                }
            }
        }
        private void UnloadUnusedPoolAndAsset()
        {
            UnloadUnusedPool(PoolType.Effect);
            UnloadUnusedPool(PoolType.Scene);
            UnloadUnusedPool(PoolType.Model);
            UnloadUnusedPool(PoolType.UI);
            UnloadAssetsAndGC(true);
            lastUnloadAssetTime = Time.realtimeSinceStartup;
        }

        public static void TryUnloadPoolAndAsset()
        {
            if (_instance == null)
                return;
            if(Instance.CheckCanUnload())
                Instance.UnloadUnusedPoolAndAsset();
        }

        private bool CheckCanUnload()
        {
            //xxj begin

            //xxj end
            return false;
        }
        public static AsyncOperation UnloadAssetsAndGC(bool forceGC = false)
        {
            AsyncOperation asyncOp = null;

            //xxj begin
            //if (Application.isMobilePlatform && !forceGC)
            //{
            //    //如果剩余内存小于50mb,才进行回收
            //    long memory = BaoyugameSdk.getFreeMemory() / 1024;
            //    if (memory < WARNING_MEMORY)
            //    {
            //        asyncOp = Resources.UnloadUnusedAssets();
            //        Debug.Log("AssetManager UnloadUnusedAssets and GC");
            //    }
            //}
            //else
            //{
            //    if (forceGC)
            //    {
            //        Debug.Log("AssetManager UnloadUnusedAssets and GC");
            //        asyncOp = Resources.UnloadUnusedAssets();
            //    }
            //}
            //xxj end

            return asyncOp;
        }

#endregion
#region 内部缓存池相关
        private Transform SpawnSync(string assetPath, PoolType poolType, PrefabPoolOption poolOption)
        {
            if (_spawnPools == null) return null;

            var pool = _spawnPools[poolType];
            if (pool == null) return null;
            Transform prefab;
            if (pool.prefabs.TryGetValue(assetPath, out prefab))
            {
                return pool.Spawn(prefab);
            }

            var assetGo = (GameObject)AssetManager.Instance.LoadAsset(assetPath, typeof(GameObject));

            //xxj begin
            //AssetManager.Instance.UnloadDependencies(bundleName);
            //xxj end

            if (assetGo != null)
            {
                prefab = assetGo.transform;
                //设置对象池参数,根据项目情况进行配置
                PrefabPool prefabPool = new PrefabPool(prefab, assetPath);
                if (poolOption != null)
                {
                    poolOption.CopyTo(prefabPool);
                }
                pool.CreatePrefabPool(prefabPool);
                return pool.Spawn(prefab);
            }

            return null;
        }
        private void CacheAsync(string assetPath, PoolType poolType, PrefabPoolOption poolOption)
        {
            SpawnAsync(assetPath, poolType, null, null, poolOption, AssetLoadPriority.Cache, true);
        }
        private AssetHandler SpawnAsync(string assetPath, PoolType poolType, Action<GameObject> getter, OnLoadError onError, PrefabPoolOption poolOption, float priority, bool unloadBundle = false)
        {
            if (_spawnPools == null) return null;

            var pool = _spawnPools[poolType];
            if (pool == null) return null;
            Transform prefab;
            if (pool.prefabs.TryGetValue(assetPath, out prefab))
            {
                if (getter != null)
                {
                    var instance = pool.Spawn(prefab);
                    var instanceGo = instance != null ? instance.gameObject : null;
                    getter(instanceGo);
                }
            }
            else
            {
                //string replaceBundleName;
                //检查该资源是否是小包资源
                //if (AssetManager.Instance.TryGetReplaceRes(bundleName, out replaceBundleName))
                //{
                //    if (!string.IsNullOrEmpty(replaceBundleName))
                //    {
                //        //有替代资源时,先触发资源静默下载,然后再加载替代资源
                //        CreatePrefabPool(pool, bundleName, assetName, null, onError, poolOption, priority, unloadBundle);
                //        return CreatePrefabPool(pool, replaceBundleName, Path.GetFileName(replaceBundleName), getter,
                //            onError, poolOption, priority, unloadBundle);
                //    }
                //}
                //替代资源为空时,只触发资源静默下载,等待资源下载完毕后再触发加载流程
                return CreatePrefabPool(pool, assetPath, getter, onError, poolOption, priority, unloadBundle);
            }

            return null;
        }

        private AssetHandler CreatePrefabPool(SpawnPool pool, string assetPath, Action<GameObject> getter, OnLoadError onError, PrefabPoolOption poolOption, float priority, bool unloadBundle)
        {
            OnLoadError newOnError = null;
            if (unloadBundle)
            {
                newOnError = () =>
                {
                    AssetManager.Instance.AddUnloadBundleToQueue(assetPath);
                    if (onError != null)
                        onError();
                };
            }
            else
            {
                newOnError = onError;
            }
            return AssetManager.Instance.LoadAssetAsync(assetPath, asset =>
            {
                Transform prefab;
                Transform instance;
                GameObject instanceGo;
                //同时加载多个相同资源时,需要先判断是否已经创建了该Prefab对应的池,如果已经创建直接从池中取
                if (pool.prefabs.TryGetValue(assetPath, out prefab))
                {
                    if (getter != null)
                    {
                        instance = pool.Spawn(prefab);
                        instanceGo = instance != null ? instance.gameObject : null;
                        getter(instanceGo);
                    }
                }
                else
                {
                    var assetGo = (GameObject)asset;
                    if (assetGo != null)
                    {
                        prefab = assetGo.transform;
                        //设置对象池参数,根据项目情况进行配置
                        PrefabPool prefabPool = new PrefabPool(prefab, assetPath);
                        if (poolOption != null)
                        {
                            poolOption.CopyTo(prefabPool);
                        }

                        pool.CreatePrefabPool(prefabPool);
                        if (unloadBundle)
                            AssetManager.Instance.AddUnloadBundleToQueue(assetPath);
                        if (getter != null)
                        {
                            instance = pool.Spawn(prefab);
                            instanceGo = instance != null ? instance.gameObject : null;
                            getter(instanceGo);
                        }
                    }
                    else
                    {
                        if (onError != null)
                            onError();
                    }
                }
            }, newOnError, typeof(GameObject), priority);
        }
        private PrefabPool DespawnInternal(Transform instance, PoolType poolType)
        {
            if (instance == null)
                return null;
            if (_spawnPools == null) return null;

            var pool = _spawnPools[poolType];
            if (pool == null) return null;

            return pool.Despawn(instance);
        }
        private void DespawnAndUnloadAssets(Transform instance, PoolType poolType, bool unloadAssetImmediate)
        {
            if(instance == null)
                return;
            PrefabPool prefabPool = DespawnInternal(instance, poolType);
            if (unloadAssetImmediate && prefabPool != null && prefabPool.spawnedCount == 0)
            {
                string bundleName = prefabPool.bundleName;
                prefabPool.spawnPool.DestroyPrefabPool(prefabPool);

                //xxj begin
                //AssetManager.Instance.UnloadDependencies(bundleName, true);
                //xxj end
            }
        }
        #endregion

        #region Model
        public void CacheModel(string assetPath)
        {
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Model);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Model);
            var poolOption = _poolConfig.GetPoolOption(assetPath);
            CacheAsync(assetPath, PoolType.Model, poolOption);
        }

        public GameObject SpawnModelGo(string prefabName, GameObject parent = null)
        {
            var node = SpawnModel(prefabName);
            if (node != null)
            {
                var nodeGo = node.gameObject;
                if (parent != null)
                    GameObjectExt.AddPoolChild(parent, nodeGo);
                return nodeGo;
            }
            return null;
        }

        public Transform SpawnModel(string assetPath)
        {
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Model);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Model);
            var poolOption = _poolConfig.GetPoolOption(assetPath);

            return SpawnSync(assetPath, PoolType.Model, poolOption);
        }

        public AssetHandler SpawnModelAsync(string assetPath, Action<GameObject> getter, OnLoadError onError = null, float priority = AssetLoadPriority.Model)
        {
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Model);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Model);
            var poolOption = _poolConfig.GetPoolOption(assetPath);
            return SpawnAsync(assetPath, PoolType.Model, getter, onError, poolOption, priority, true);
        }

        public void DespawnModel(Transform instance)
        {
            if (instance == null)
                return;
            DespawnInternal(instance, PoolType.Model);
        }

        public void DespawnModel(GameObject go)
        {
            if(go == null)
                return;
            DespawnInternal(go.transform, PoolType.Model);
        }
#endregion

#region Effect
        public GameObject SpawnEffectGo(string prefabName, GameObject parent = null)
        {
            var node = SpawnEffect(prefabName);
            if (node != null)
            {
                var nodeGo = node.gameObject;
                if (parent != null)
                    GameObjectExt.AddPoolChild(parent, nodeGo);
                return nodeGo;
            }
            return null;
        }

        public Transform SpawnEffect(string assetPath)
        {
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Effect);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Effect);
            var poolOption = _poolConfig.GetPoolOption(assetPath);

            return SpawnSync(assetPath, PoolType.Effect, poolOption);
        }

        public AssetHandler SpawnEffectAsync(string assetPath, Action<GameObject> getter, OnLoadError onError = null, float priority = AssetLoadPriority.Default)
        {
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Effect);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Effect);
            var poolOption = _poolConfig.GetPoolOption(assetPath);

            return SpawnAsync(assetPath, PoolType.Effect, getter, onError, poolOption, priority, true);
        }
        /// <summary>
        /// 场景特效加载
        /// </summary>
        public AssetHandler SpawnSceneEffectAsync(string assetPath, Action<GameObject> getter, OnLoadError onError = null)
        {
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Effect);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Effect);
            var poolOption = _poolConfig.GetPoolOption(assetPath);

            return SpawnAsync(assetPath, PoolType.Effect, getter, onError, poolOption, AssetLoadPriority.Default);
        }
        public void DespawnEffect(GameObject go, bool unloadAssetImmediate = false)
        {
            if(go == null)
                return;
            DespawnAndUnloadAssets(go.transform, PoolType.Effect, unloadAssetImmediate);
        }

        public void CacheEffect(string assetPath)
        {
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Effect);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Effect);
            var poolOption = _poolConfig.GetPoolOption(assetPath);
            CacheAsync(assetPath, PoolType.Effect, poolOption);
        }
        #endregion


        #region AudioSource
        //public GameObject LoadAudio(string audioName)
        //{
        //    string bundleName = AssetManager.GetBundleName(audioName, ResGroup.Audio);
        //    var assetGo = (GameObject)AssetManager.Instance.LoadAsset(bundleName, audioName, typeof(GameObject));
        //    //UIPrefab间一般不存在依赖关系,所以加载完后就可以立刻Unload掉了
        //    //如果不Unload掉,过多的UIPrefab包产生的SerialiedFile也会占不少内存
        //    AssetManager.Instance.UnloadBundle(bundleName);
        //    return assetGo;
        //}

        //public Transform SpawnAudio(string audioName)
        //{
        //    string bundleName = AssetManager.GetBundleName(audioName, ResGroup.Audio);
        //    var poolOption = _poolConfig.GetPoolOption(bundleName);
        //    return SpawnSync(bundleName, audioName, PoolType.Audio, poolOption);
        //}


        //public AssetManager.AssetHandler SpawnAudioAsync(string audioName, Action<GameObject> getter, AssetManager.OnLoadError onError, float priority = AssetLoadPriority.Default)
        //{
        //    string bundleName = AssetManager.GetBundleName(audioName, ResGroup.Audio);
        //    var poolOption = _poolConfig.GetPoolOption(bundleName);
        //    return SpawnAsync(bundleName, audioName, PoolType.Audio, getter, onError, poolOption, priority);
        //}

        //public void DespawnAudio(Transform instance)
        //{
        //    DespawnInternal(instance, PoolType.Audio);
        //}

        //public void DespawnAudio(GameObject go)
        //{
        //    DespawnInternal(go.transform, PoolType.Audio);
        //}

        #endregion


        #region UI
        /// <summary>
        /// 直接加载UIPrefab返回,不进行池缓存
        /// </summary>
        /// <returns></returns>
        public GameObject LoadUI(string assetPath)
        {
            string bundleName = AssetManager.GetBundleName(assetPath, ResGroup.UI);
            var assetGo = (GameObject)AssetManager.Instance.LoadAsset(assetPath, typeof(GameObject));
            //UIPrefab间一般不存在依赖关系,所以加载完后就可以立刻Unload掉了
            //如果不Unload掉,过多的UIPrefab包产生的SerialiedFile也会占不少内存
            //xxj begin
            //AssetManager.Instance.UnloadDependencies(bundleName);
            //xxj end
            return assetGo;
        }

        public Transform SpawnUI(string assetPath)
        {
            string bundleName = AssetManager.GetBundleName(assetPath, ResGroup.UI);
            var poolOption = _poolConfig.GetPoolOption(assetPath);
            return SpawnSync(assetPath, PoolType.UI, poolOption);
        }

        public GameObject SpawnUIGo(string prefabName, GameObject parent = null)
        {
            var node = SpawnUI(prefabName);
            if (node != null)
            {
                var nodeGo = node.gameObject;
                nodeGo.SetActive(true);
                if (parent != null)
                    GameObjectExt.AddPoolChild(parent, nodeGo);
                return nodeGo;
            }
            return null;
        }

        public AssetHandler SpawnUIAsync(string assetPath, Action<GameObject> getter, OnLoadError onError = null, float priority = AssetLoadPriority.Default)
        {
            string bundleName = AssetManager.GetBundleName(assetPath, ResGroup.UI);
            var poolOption = _poolConfig.GetPoolOption(assetPath);
            return SpawnAsync(assetPath, PoolType.UI, getter, onError, poolOption, priority);
        }

        /// <summary>
        /// 归还UI实例对象到池中
        /// </summary>
        /// <param go="instance"></param>
        public void DespawnUI(GameObject go)
        {
            if(go == null)
                return;

            //xxj begin
            //UIHelper.RemoveNGUIEvent(go);
            //xxj end
            DespawnInternal(go.transform, PoolType.UI);
        }

#endregion
#region Scene
        public AssetHandler LoadScene(string assetName, OnLoadFinish onFinish, OnLoadError onError = null, float priority = AssetLoadPriority.Default)
        {
            //xxj begin
            //return AssetManager.Instance.LoadAssetAsync(assetName, ResGroup.Scene, asset =>
            //{
            //    AssetManager.Instance.UnloadBundle(assetName, ResGroup.Scene);
            //    if (onFinish != null)
            //    {
            //        onFinish(asset);
            //    }
            //}, () =>
            //{
            //    AssetManager.Instance.UnloadBundle(assetName, ResGroup.Scene);
            //    if (onError != null)
            //        onError();
            //});
            //xxj end
            return null;
        }
        public AssetHandler SpawnSceneAsync(string prefabName, Action<GameObject> getter, OnLoadError onError = null, float priority = AssetLoadPriority.Default)
        {
            //xxj begin
            //prefabName = PathHelper.ReplacePrefabName(prefabName, ResGroup.Scene);
            //string bundleName = AssetManager.GetBundleName(prefabName, ResGroup.Scene);
            //var poolOption = _poolConfig.GetPoolOption(bundleName);
            //return SpawnAsync(bundleName, prefabName, PoolType.Scene, getter, onError, poolOption, priority);
            //xxj end

            return null;
        }

        public void DespawnScene(GameObject instance, bool unloadAssetImmediate = false)
        {
            if(instance == null)
                return;
            DespawnAndUnloadAssets(instance.transform, PoolType.Scene, unloadAssetImmediate);
        }
#endregion
#region 2D场景加载接口
        //xxj begin
        //private Dictionary<string, AssetManager.AssetHandler> _sceneTileCoroutines;
        //public void LoadSceneTileMap(string resInfoKey, AssetManager.OnLoadFinish finishCallback, AssetManager.OnLoadError errorCallback = null, int limitCount = 0)
        //{
        //    if (_sceneTileCoroutines == null)
        //    {
        //        //目前场景最多同时触发加载80块
        //        _sceneTileCoroutines = new Dictionary<string, AssetManager.AssetHandler>(80);
        //    }
        //    ReleaseSceneTileMap(resInfoKey);
        //    AssetManager.OnLoadFinish newFinishCallBack = asset =>
        //    {
        //        ReleaseSceneTileMap(resInfoKey);
        //        finishCallback(asset);
        //    };
        //    AssetManager.OnLoadError newErrorCallBack = () =>
        //    {
        //        ReleaseSceneTileMap(resInfoKey);
        //        errorCallback();
        //    };

        //    AssetManager.AssetHandler task;
        //    if (AssetManager.ResLoadMode == AssetManager.LoadMode.EditorLocal)
        //    {
        //        task = LoadSceneTileMapAsync(resInfoKey, newFinishCallBack, newErrorCallBack);
        //    }
        //    else
        //    {
        //        task = AssetManager.Instance.LoadSceneTileMapByWWW(resInfoKey, newFinishCallBack, newErrorCallBack, limitCount);
        //    }
        //    _sceneTileCoroutines.Add(resInfoKey, task);
        //}

        //public void ReleaseSceneTileMap(string resInfoKey)
        //{
        //    if (_sceneTileCoroutines == null) return;
        //    AssetManager.AssetHandler task;
        //    if (_sceneTileCoroutines.TryGetValue(resInfoKey, out task))
        //    {
        //        task.Dispose();
        //        _sceneTileCoroutines.Remove(resInfoKey);
        //    }
        //}
        //AssetManager.AssetHandler LoadSceneTileMapAsync(string bundleName, AssetManager.OnLoadFinish onFinish, AssetManager.OnLoadError onError = null)
        //{
        //    return AssetManager.Instance.LoadAssetAsync(bundleName, ResGroup.TileMap, asset =>
        //    {
        //        AssetManager.Instance.UnloadBundle(bundleName, ResGroup.TileMap);
        //        if (onFinish != null)
        //        {
        //            onFinish(asset);
        //        }
        //    }, () =>
        //    {
        //        AssetManager.Instance.UnloadBundle(bundleName, ResGroup.TileMap);
        //        if (onError != null)
        //            onError();
        //    }, priority: AssetLoadPriority.Scene2DTitleMap);
        //}
        //xxj end
#endregion


        //public AssetManager.AssetHandler LoadConfig(string configName, AssetManager.OnLoadFinish onFinish, AssetManager.OnLoadError onError = null, float priority = AssetLoadPriority.Default)
        //{
        //    return AssetManager.Instance.LoadAssetAsync(configName, ResGroup.Config, asset =>
        //    {
        //        AssetManager.Instance.UnloadBundle(configName, ResGroup.Config);
        //        if (onFinish != null)
        //        {
        //            onFinish(asset);
        //        }
        //    }, () =>
        //    {
        //        AssetManager.Instance.UnloadBundle(configName, ResGroup.Config);
        //        if (onError != null)
        //            onError();
        //    }, priority: priority);
        //}

        //public void LoadImage(string imageName, AssetManager.OnLoadFinish onFinish, AssetManager.OnLoadError onError = null)
        //{
        //    AssetManager.Instance.LoadAssetAsync(imageName, ResGroup.Image, asset =>
        //    {
        //        AssetManager.Instance.UnloadBundle(imageName, ResGroup.Image);
        //        if (onFinish != null)
        //        {
        //            onFinish(asset);
        //        }
        //    }, () =>
        //    {
        //        AssetManager.Instance.UnloadBundle(imageName, ResGroup.Image);
        //        if (onError != null)
        //            onError();
        //    });
        //}


        //TODO:兼容以前加载音频资源的接口,直接加载AudioClip资源,可以将AudioClip做成一个个AudioSource的Prefab进行打包,然后用池来管理这些AudioSource
        //public void LoadAudioClip(string clipName, AssetManager.OnLoadFinish onFinish, AssetManager.OnLoadError onError = null)
        //{
        //    AssetManager.Instance.LoadAssetAsync(clipName, ResGroup.Audio, asset =>
        //    {
        //        AssetManager.Instance.UnloadBundle(clipName, ResGroup.Audio);
        //        if (onFinish != null)
        //        {
        //            onFinish(asset);
        //        }
        //    }, () =>
        //    {
        //        AssetManager.Instance.UnloadBundle(clipName, ResGroup.Audio);
        //        if (onError != null)
        //            onError();
        //    });
        //}

    }
}
