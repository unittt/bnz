/*
Copyright (c) 2015-2017 topameng(topameng@qq.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Collections;
using System.Text;
using AssetPipeline;
using LITJson;

namespace LuaInterface
{
    public class LuaFileUtils
    {
        public static LuaFileUtils Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new LuaFileUtils();
                }

                return instance;
            }

            protected set
            {
                instance = value;
            }
        }
        
        protected static LuaFileUtils instance = null;
        public bool isZip = false;
        private string luaPath = null;

        public LuaScript mainLuaScript;
        public LuaZip dataLuaZip;

        public LuaFileUtils()
        {
            instance = this;
            InitScriptMode();
        }

        public virtual void Dispose()
        {

        }


        public string FindFile(string fileName)
        {
            if (fileName == string.Empty)
            {
                return string.Empty;
            }

            if(isZip)
            {
                return string.Format("  scriptZip: {0}.lua", fileName);
            }
            else
            {
                return string.Format(" {0}/{1}.lua", luaPath, fileName);
            }
        }

        public virtual string FindFileError(string fileName)
        {
            if (fileName == string.Empty)
            {
                return string.Empty;
            }
            if (isZip)
            {
                return string.Format(" scriptZip: {0}.lua", fileName);
            }
            else
            {
                return string.Format(" {0}/{1}.lua", luaPath, fileName);
            }
        }

        public class BuildSetting
        {
            public string lua;
        }

        public string GetDevelopLuaPath()
        {
            string path = Application.dataPath;
            int pos = path.LastIndexOf("/");
            string folder = path.Substring(0, pos);
            string filePath = folder + "/setting.txt";
            if(FileHelper.IsExist(filePath))
            {
                BuildSetting data = FileHelper.ReadJsonFile<BuildSetting>(filePath);
                if (data != null)
                {
                    string luaPath = data.lua;
                    if (luaPath.StartsWith("/"))
                    {
                        return Application.dataPath + luaPath;
                    }
                    else
                    {
                        return luaPath;
                    }
                }
            }

            return null;
        }

        public void InitScriptMode()
        {
#if UNITY_EDITOR
            luaPath = Application.dataPath + "/Lua";
            isZip = UnityEditor.EditorPrefs.GetBool("LuaZipMode", false);
#elif UNITY_STANDALONE_WIN
            luaPath = GetDevelopLuaPath();
            if(luaPath == null)
            {
                isZip = true;
            }
#else
            isZip = true;
#endif
            if (isZip)
            {
                string path = Path.Combine(GameResPath.persistentDataPath, GameResPath.SCRIPT_FILE);
                mainLuaScript = LuaScript.CreataFrom(path);
            }
            GameDebug.Log(string.Format("InitScriptMode luaPackage={0}", isZip));
        }

        public virtual byte[] ReadFile(string fileName)
        {
            //Debug.Log("ReadFile " + fileName);

			byte[] buffer = LuaZip.LoadFile(Path.GetFileName(fileName));
			if (buffer != null)
			{
				return buffer;
			} 
			if (isZip)  
            {
				return mainLuaScript.Load(fileName + ".lua");
            }
            else
            {
                string path = string.Format("{0}/{1}.lua", luaPath, fileName);
                buffer = File.ReadAllBytes(path);
                return buffer;
            }
        }

        public byte[] ReadProto(string fileName)
        {
            if (isZip)
            {
                return mainLuaScript.Load(fileName);
            }
            else
            {
                string path = string.Format("{0}/{1}", luaPath, fileName);
                byte[] buffer = File.ReadAllBytes(path);
                return buffer;
            }
        }
    }
}
