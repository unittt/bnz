using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

namespace AssetPipeline
{
    /// <summary>
    /// 对游戏运行时已加载的Bundle实体进行封装
    /// </summary>
    public class AssetBundleInfo
    {
        public readonly string bundleName;
        public AssetBundle assetBundle;

        public Object onlyAsset 
        { 
            get; 
            private set;
        }

        public Object[] assetList 
        { 
            get;
            private set;
        }

        //AssetBundle加载引用
        public int loadingCount;

        //AssetBundle持续引用
        //public int refCount;

        public Dictionary<string, int> refBundles
        {
            get;
            private set;
        }

        //图集相关
        public static List<AssetBundleInfo> atlasAssetBundleList = new List<AssetBundleInfo>();

        private List<UIAtlas> atlasList = null;

        private string atlasName = null;

        private static HashSet<string> unloadedSet = new HashSet<string>();

        public AssetBundleInfo(string bundleName, AssetBundle ab)
        {
            this.bundleName = bundleName;
            assetBundle = ab;
            refBundles = new Dictionary<string, int>();
        }

        public void AddLoadingCount()
        {
            loadingCount += 1;
        }

        public void DelLoaingCount()
        {
            loadingCount -= 1;
        }

        public int LoadingCount
        {
            get
            {
                return loadingCount;
            }
        }

        public void AddRef(string assetPath)
        {
            if(refBundles.ContainsKey(assetPath))
            {
                refBundles[assetPath] += 1;
            }
            else
            {
                refBundles[assetPath] = 1;
            }
        }

        public void DelRef(string assetPath)
        {
            if (refBundles.ContainsKey(assetPath))
            {
                refBundles[assetPath] -= 1;
                if(refBundles[assetPath] == 0)
                {
                    refBundles.Remove(assetPath);
                }
            }
        }

        public int refCount
        {
            get
            {
                return refBundles.Count;
            }
        }

        public void LoadAtlas()
        {
            if (bundleName.StartsWith("atlas/"))
            {
                atlasList = new List<UIAtlas>();
                GameObject[] atlases = assetBundle.LoadAllAssets<GameObject>();
                //打包机制保证不会同一个AB包出现2张图集，这里为了不用Load(assetName)如此处理
                for (int i = 0; i < atlases.Length; i++)
                {
                    UIAtlas uiAtlas = atlases[i].GetComponent<UIAtlas>();
                    atlasList.Add(uiAtlas);

                    Texture mainTex = uiAtlas.texture;
                    if (mainTex != null)
                    {
                        atlasName = mainTex.name;
                    }

                }
                atlasAssetBundleList.Add(this);
            }
        }

        public static void UnloadUnusedAtlas(bool unloadAll = false)
        {
            unloadedSet.Clear();
            HashSet<string> unusedNameSet = UIDrawCall.GetUnnsedTextureNameSet();
            if (unloadAll)
            {
                for (int i = 0; i < atlasAssetBundleList.Count; i++)
                {
                    atlasAssetBundleList[i].UnloadAtlas();
                }
            }
            else
            {
                for (int i = 0; i < atlasAssetBundleList.Count; i++)
                {
                    string name = atlasAssetBundleList[i].atlasName;
                    if (unusedNameSet.Contains(name) && !unloadedSet.Contains(name))
                    {
                        atlasAssetBundleList[i].UnloadAtlas();
                        unloadedSet.Add(name);
                    }
                }
            }
        }

        public bool UnloadAtlas()
        {
            //Debug.Log("UnloadAtlas " + bundleName);
            if (atlasList == null || loadingCount > 0)
            {
                return false;
            }

            Texture mainTex = null;
            Texture alphaTex = null;

            for (int i = 0; i < atlasList.Count; i++)
            {
                mainTex = atlasList[i].texture;
                if (mainTex != null)
                {
                    Resources.UnloadAsset(mainTex);
                }

                alphaTex = atlasList[i].alphaTextue;
                if(alphaTex != null)
                {
                    Resources.UnloadAsset(alphaTex);
                }
            }
            return true;
        }

        public void Load(AssetBundle ab)
        {
            assetBundle = ab;
            LoadAtlas();
        }

        public bool Unload(bool unloadAll = false)
        {
            //Debug.Log(bundleName + "  loadingcount " + loadingCount + "   ref " + refCount);
            if (loadingCount > 0 || refCount > 0)
            {
                return false;
            }

            if (assetBundle != null)
            {
                assetBundle.Unload(unloadAll);
                assetBundle = null;
            }
            return true;
        }

        public bool Contains(string assetName)
        {
            if (assetBundle == null)
                return false;

            return assetBundle.Contains(assetName);
        }

        public Object LoadAsset(string assetName, System.Type type)
        {
            if (assetBundle == null)
                return null;

            if (string.IsNullOrEmpty(assetName))
                return null;

            assetName = Path.GetFileNameWithoutExtension(assetName);
            return assetBundle.LoadAsset(assetName, type);
        }

        public AssetBundleRequest LoadAssetAsync(string assetName, System.Type type)
        {
            if (assetBundle == null)
                return null;

            if (string.IsNullOrEmpty(assetName))
                return null;

            return assetBundle.LoadAssetAsync(assetName, type);
        }

        public Object[] LoadAllAsset()
        {
            if (assetBundle == null)
                return null;

            return assetBundle.LoadAllAssets();
        }

        /// <summary>
        /// 异步加载Bundle内的所有资源,并缓存下来
        /// </summary>
        /// <returns></returns>
        internal IEnumerator CacheAllAssetAsync()
        {
            if (assetBundle == null)
                yield break;

            var request = assetBundle.LoadAllAssetsAsync();
            if (request != null)
            {
                yield return request;
                var allAssets = request.allAssets;
                if (allAssets != null && allAssets.Length > 0)
                {
                    if (allAssets.Length > 1)
                    {
                        assetList = allAssets;
                    }
                    else
                    {
                        onlyAsset = allAssets[0];
                    }
                }
            }
        }

        public Object FindAsset(string assetName, System.Type type)
        {
            if (assetList == null) return null;
            assetName = Path.GetFileNameWithoutExtension(assetName);

            for (int i = 0; i < assetList.Length; i++)
            {
                var asset = assetList[i];
                if (asset.name == assetName)
                {
                    //没有指定资源类型,只要名字相同就返回,否则需要判断资源类型
                    if (type == typeof(UnityEngine.Object))
                        return asset;

                    var assetType = asset.GetType();
                    if (assetType == type) return asset;
                }
            }

            return null;
        }
    }
}
