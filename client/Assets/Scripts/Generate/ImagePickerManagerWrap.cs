﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ImagePickerManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ImagePickerManager), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("GetTexture2DFromString", GetTexture2DFromString);
		L.RegFunction("DecodeString", DecodeString);
		L.RegFunction("ConvertPixelToPoint", ConvertPixelToPoint);
		L.RegFunction("SaveTextureToCameraRoll", SaveTextureToCameraRoll);
		L.RegFunction("SaveScreenshotToCameraRoll", SaveScreenshotToCameraRoll);
		L.RegFunction("GetVideoPathFromAlbum", GetVideoPathFromAlbum);
		L.RegFunction("PickImage", PickImage);
		L.RegVar("Instance", get_Instance, null);
		L.RegVar("ScreenWidth", get_ScreenWidth, null);
		L.RegVar("ScreenHeight", get_ScreenHeight, null);
		L.RegVar("OnImagePicked", get_OnImagePicked, set_OnImagePicked);
		L.RegVar("OnImageSaved", get_OnImageSaved, set_OnImageSaved);
		L.RegVar("OnVideoPathPicked", get_OnVideoPathPicked, set_OnVideoPathPicked);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTexture2DFromString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			UnityEngine.Texture2D o = ImagePickerManager.GetTexture2DFromString(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DecodeString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			byte[] o = ImagePickerManager.DecodeString(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ConvertPixelToPoint(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 1);
			bool arg1 = LuaDLL.luaL_checkboolean(L, 2);
			int o = ImagePickerManager.ConvertPixelToPoint(arg0, arg1);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SaveTextureToCameraRoll(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			ImagePickerManager obj = (ImagePickerManager)ToLua.CheckObject(L, 1, typeof(ImagePickerManager));
			UnityEngine.Texture2D arg0 = (UnityEngine.Texture2D)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Texture2D));
			obj.SaveTextureToCameraRoll(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SaveScreenshotToCameraRoll(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ImagePickerManager obj = (ImagePickerManager)ToLua.CheckObject(L, 1, typeof(ImagePickerManager));
			obj.SaveScreenshotToCameraRoll();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetVideoPathFromAlbum(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			ImagePickerManager obj = (ImagePickerManager)ToLua.CheckObject(L, 1, typeof(ImagePickerManager));
			obj.GetVideoPathFromAlbum();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PickImage(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			ImagePickerManager obj = (ImagePickerManager)ToLua.CheckObject(L, 1, typeof(ImagePickerManager));
			ImagePickerManager.ImageSource arg0 = (ImagePickerManager.ImageSource)(int)LuaDLL.lua_tonumber(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			float arg2 = (float)LuaDLL.luaL_checknumber(L, 4);
			bool arg3 = LuaDLL.luaL_checkboolean(L, 5);
			obj.PickImage(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Instance(IntPtr L)
	{
		try
		{
			ToLua.Push(L, ImagePickerManager.Instance);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ScreenWidth(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, ImagePickerManager.ScreenWidth);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ScreenHeight(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, ImagePickerManager.ScreenHeight);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_OnImagePicked(IntPtr L)
	{
		ToLua.Push(L, new EventObject("ImagePickerManager.OnImagePicked"));
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_OnImageSaved(IntPtr L)
	{
		ToLua.Push(L, new EventObject("ImagePickerManager.OnImageSaved"));
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_OnVideoPathPicked(IntPtr L)
	{
		ToLua.Push(L, new EventObject("ImagePickerManager.OnVideoPathPicked"));
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_OnImagePicked(IntPtr L)
	{
		try
		{
			ImagePickerManager obj = (ImagePickerManager)ToLua.CheckObject(L, 1, typeof(ImagePickerManager));
			EventObject arg0 = null;

			if (LuaDLL.lua_isuserdata(L, 2) != 0)
			{
				arg0 = (EventObject)ToLua.ToObject(L, 2);
			}
			else
			{
				return LuaDLL.luaL_throw(L, "The event 'ImagePickerManager.OnImagePicked' can only appear on the left hand side of += or -= when used outside of the type 'ImagePickerManager'");
			}

			if (arg0.op == EventOp.Add)
			{
				System.Action<bool,string> ev = (System.Action<bool,string>)DelegateFactory.CreateDelegate(typeof(System.Action<bool,string>), arg0.func);
				obj.OnImagePicked += ev;
			}
			else if (arg0.op == EventOp.Sub)
			{
				System.Action<bool,string> ev = (System.Action<bool,string>)LuaMisc.GetEventHandler(obj, typeof(ImagePickerManager), "OnImagePicked");
				Delegate[] ds = ev.GetInvocationList();
				LuaState state = LuaState.Get(L);

				for (int i = 0; i < ds.Length; i++)
				{
					ev = (System.Action<bool,string>)ds[i];
					LuaDelegate ld = ev.Target as LuaDelegate;

					if (ld != null && ld.func == arg0.func)
					{
						obj.OnImagePicked -= ev;
						state.DelayDispose(ld.func);
						break;
					}
				}

				arg0.func.Dispose();
			}

			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_OnImageSaved(IntPtr L)
	{
		try
		{
			ImagePickerManager obj = (ImagePickerManager)ToLua.CheckObject(L, 1, typeof(ImagePickerManager));
			EventObject arg0 = null;

			if (LuaDLL.lua_isuserdata(L, 2) != 0)
			{
				arg0 = (EventObject)ToLua.ToObject(L, 2);
			}
			else
			{
				return LuaDLL.luaL_throw(L, "The event 'ImagePickerManager.OnImageSaved' can only appear on the left hand side of += or -= when used outside of the type 'ImagePickerManager'");
			}

			if (arg0.op == EventOp.Add)
			{
				System.Action<bool> ev = (System.Action<bool>)DelegateFactory.CreateDelegate(typeof(System.Action<bool>), arg0.func);
				obj.OnImageSaved += ev;
			}
			else if (arg0.op == EventOp.Sub)
			{
				System.Action<bool> ev = (System.Action<bool>)LuaMisc.GetEventHandler(obj, typeof(ImagePickerManager), "OnImageSaved");
				Delegate[] ds = ev.GetInvocationList();
				LuaState state = LuaState.Get(L);

				for (int i = 0; i < ds.Length; i++)
				{
					ev = (System.Action<bool>)ds[i];
					LuaDelegate ld = ev.Target as LuaDelegate;

					if (ld != null && ld.func == arg0.func)
					{
						obj.OnImageSaved -= ev;
						state.DelayDispose(ld.func);
						break;
					}
				}

				arg0.func.Dispose();
			}

			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_OnVideoPathPicked(IntPtr L)
	{
		try
		{
			ImagePickerManager obj = (ImagePickerManager)ToLua.CheckObject(L, 1, typeof(ImagePickerManager));
			EventObject arg0 = null;

			if (LuaDLL.lua_isuserdata(L, 2) != 0)
			{
				arg0 = (EventObject)ToLua.ToObject(L, 2);
			}
			else
			{
				return LuaDLL.luaL_throw(L, "The event 'ImagePickerManager.OnVideoPathPicked' can only appear on the left hand side of += or -= when used outside of the type 'ImagePickerManager'");
			}

			if (arg0.op == EventOp.Add)
			{
				System.Action<string> ev = (System.Action<string>)DelegateFactory.CreateDelegate(typeof(System.Action<string>), arg0.func);
				obj.OnVideoPathPicked += ev;
			}
			else if (arg0.op == EventOp.Sub)
			{
				System.Action<string> ev = (System.Action<string>)LuaMisc.GetEventHandler(obj, typeof(ImagePickerManager), "OnVideoPathPicked");
				Delegate[] ds = ev.GetInvocationList();
				LuaState state = LuaState.Get(L);

				for (int i = 0; i < ds.Length; i++)
				{
					ev = (System.Action<string>)ds[i];
					LuaDelegate ld = ev.Target as LuaDelegate;

					if (ld != null && ld.func == arg0.func)
					{
						obj.OnVideoPathPicked -= ev;
						state.DelayDispose(ld.func);
						break;
					}
				}

				arg0.func.Dispose();
			}

			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
