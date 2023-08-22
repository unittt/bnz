﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_ParticleSystemWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.ParticleSystem), typeof(UnityEngine.Component));
		L.RegFunction("SetParticles", SetParticles);
		L.RegFunction("GetParticles", GetParticles);
		L.RegFunction("Simulate", Simulate);
		L.RegFunction("Play", Play);
		L.RegFunction("Stop", Stop);
		L.RegFunction("Pause", Pause);
		L.RegFunction("Clear", Clear);
		L.RegFunction("IsAlive", IsAlive);
		L.RegFunction("Emit", Emit);
		L.RegFunction("New", _CreateUnityEngine_ParticleSystem);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("startDelay", get_startDelay, set_startDelay);
		L.RegVar("isPlaying", get_isPlaying, null);
		L.RegVar("isStopped", get_isStopped, null);
		L.RegVar("isPaused", get_isPaused, null);
		L.RegVar("loop", get_loop, set_loop);
		L.RegVar("playOnAwake", get_playOnAwake, set_playOnAwake);
		L.RegVar("time", get_time, set_time);
		L.RegVar("duration", get_duration, null);
		L.RegVar("playbackSpeed", get_playbackSpeed, set_playbackSpeed);
		L.RegVar("particleCount", get_particleCount, null);
		L.RegVar("startSpeed", get_startSpeed, set_startSpeed);
		L.RegVar("startSize", get_startSize, set_startSize);
		L.RegVar("startColor", get_startColor, set_startColor);
		L.RegVar("startRotation", get_startRotation, set_startRotation);
		L.RegVar("startRotation3D", get_startRotation3D, set_startRotation3D);
		L.RegVar("startLifetime", get_startLifetime, set_startLifetime);
		L.RegVar("gravityModifier", get_gravityModifier, set_gravityModifier);
		L.RegVar("maxParticles", get_maxParticles, set_maxParticles);
		L.RegVar("simulationSpace", get_simulationSpace, set_simulationSpace);
		L.RegVar("scalingMode", get_scalingMode, set_scalingMode);
		L.RegVar("randomSeed", get_randomSeed, set_randomSeed);
		L.RegVar("useAutoRandomSeed", get_useAutoRandomSeed, set_useAutoRandomSeed);
		L.RegVar("emission", get_emission, null);
		L.RegVar("shape", get_shape, null);
		L.RegVar("velocityOverLifetime", get_velocityOverLifetime, null);
		L.RegVar("limitVelocityOverLifetime", get_limitVelocityOverLifetime, null);
		L.RegVar("inheritVelocity", get_inheritVelocity, null);
		L.RegVar("forceOverLifetime", get_forceOverLifetime, null);
		L.RegVar("colorOverLifetime", get_colorOverLifetime, null);
		L.RegVar("colorBySpeed", get_colorBySpeed, null);
		L.RegVar("sizeOverLifetime", get_sizeOverLifetime, null);
		L.RegVar("sizeBySpeed", get_sizeBySpeed, null);
		L.RegVar("rotationOverLifetime", get_rotationOverLifetime, null);
		L.RegVar("rotationBySpeed", get_rotationBySpeed, null);
		L.RegVar("externalForces", get_externalForces, null);
		L.RegVar("collision", get_collision, null);
		L.RegVar("trigger", get_trigger, null);
		L.RegVar("subEmitters", get_subEmitters, null);
		L.RegVar("textureSheetAnimation", get_textureSheetAnimation, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_ParticleSystem(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.ParticleSystem obj = new UnityEngine.ParticleSystem();
				ToLua.Push(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.ParticleSystem.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetParticles(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystem));
			UnityEngine.ParticleSystem.Particle[] arg0 = ToLua.CheckObjectArray<UnityEngine.ParticleSystem.Particle>(L, 2);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
			obj.SetParticles(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetParticles(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.CheckObject(L, 1, typeof(UnityEngine.ParticleSystem));
			UnityEngine.ParticleSystem.Particle[] arg0 = ToLua.CheckObjectArray<UnityEngine.ParticleSystem.Particle>(L, 2);
			int o = obj.GetParticles(arg0);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Simulate(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(float)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				float arg0 = (float)LuaDLL.lua_tonumber(L, 2);
				obj.Simulate(arg0);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(float), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				float arg0 = (float)LuaDLL.lua_tonumber(L, 2);
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				obj.Simulate(arg0, arg1);
				return 0;
			}
			else if (count == 4 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(float), typeof(bool), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				float arg0 = (float)LuaDLL.lua_tonumber(L, 2);
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				bool arg2 = LuaDLL.lua_toboolean(L, 4);
				obj.Simulate(arg0, arg1, arg2);
				return 0;
			}
			else if (count == 5 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(float), typeof(bool), typeof(bool), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				float arg0 = (float)LuaDLL.lua_tonumber(L, 2);
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				bool arg2 = LuaDLL.lua_toboolean(L, 4);
				bool arg3 = LuaDLL.lua_toboolean(L, 5);
				obj.Simulate(arg0, arg1, arg2, arg3);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystem.Simulate");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Play(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				obj.Play();
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				obj.Play(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystem.Play");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Stop(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				obj.Stop();
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				obj.Stop(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystem.Stop");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Pause(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				obj.Pause();
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				obj.Pause(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystem.Pause");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Clear(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				obj.Clear();
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				obj.Clear(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystem.Clear");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsAlive(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				bool o = obj.IsAlive();
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(bool)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				bool o = obj.IsAlive(arg0);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystem.IsAlive");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Emit(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(int)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				obj.Emit(arg0);
				return 0;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(UnityEngine.ParticleSystem), typeof(UnityEngine.ParticleSystem.EmitParams), typeof(int)))
			{
				UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)ToLua.ToObject(L, 1);
				UnityEngine.ParticleSystem.EmitParams arg0 = (UnityEngine.ParticleSystem.EmitParams)ToLua.ToObject(L, 2);
				int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
				obj.Emit(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UnityEngine.ParticleSystem.Emit");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startDelay(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.startDelay;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startDelay on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isPlaying(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool ret = obj.isPlaying;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isPlaying on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isStopped(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool ret = obj.isStopped;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isStopped on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isPaused(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool ret = obj.isPaused;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isPaused on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_loop(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool ret = obj.loop;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index loop on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_playOnAwake(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool ret = obj.playOnAwake;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index playOnAwake on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_time(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.time;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index time on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_duration(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.duration;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index duration on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_playbackSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.playbackSpeed;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index playbackSpeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_particleCount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			int ret = obj.particleCount;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index particleCount on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.startSpeed;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startSpeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.startSize;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startSize on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startColor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.Color ret = obj.startColor;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startColor on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startRotation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.startRotation;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startRotation on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startRotation3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.Vector3 ret = obj.startRotation3D;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startRotation3D on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.startLifetime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_gravityModifier(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float ret = obj.gravityModifier;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index gravityModifier on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_maxParticles(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			int ret = obj.maxParticles;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index maxParticles on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_simulationSpace(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystemSimulationSpace ret = obj.simulationSpace;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index simulationSpace on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_scalingMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystemScalingMode ret = obj.scalingMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index scalingMode on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_randomSeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			uint ret = obj.randomSeed;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index randomSeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_useAutoRandomSeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool ret = obj.useAutoRandomSeed;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index useAutoRandomSeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_emission(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.EmissionModule ret = obj.emission;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index emission on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_shape(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.ShapeModule ret = obj.shape;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index shape on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_velocityOverLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.VelocityOverLifetimeModule ret = obj.velocityOverLifetime;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index velocityOverLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_limitVelocityOverLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.LimitVelocityOverLifetimeModule ret = obj.limitVelocityOverLifetime;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index limitVelocityOverLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_inheritVelocity(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.InheritVelocityModule ret = obj.inheritVelocity;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index inheritVelocity on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_forceOverLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.ForceOverLifetimeModule ret = obj.forceOverLifetime;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index forceOverLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_colorOverLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.ColorOverLifetimeModule ret = obj.colorOverLifetime;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index colorOverLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_colorBySpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.ColorBySpeedModule ret = obj.colorBySpeed;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index colorBySpeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sizeOverLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.SizeOverLifetimeModule ret = obj.sizeOverLifetime;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index sizeOverLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sizeBySpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.SizeBySpeedModule ret = obj.sizeBySpeed;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index sizeBySpeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rotationOverLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.RotationOverLifetimeModule ret = obj.rotationOverLifetime;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rotationOverLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rotationBySpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.RotationBySpeedModule ret = obj.rotationBySpeed;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rotationBySpeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_externalForces(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.ExternalForcesModule ret = obj.externalForces;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index externalForces on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_collision(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.CollisionModule ret = obj.collision;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index collision on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_trigger(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.TriggerModule ret = obj.trigger;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index trigger on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_subEmitters(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.SubEmittersModule ret = obj.subEmitters;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index subEmitters on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_textureSheetAnimation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystem.TextureSheetAnimationModule ret = obj.textureSheetAnimation;
			ToLua.PushValue(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index textureSheetAnimation on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startDelay(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startDelay = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startDelay on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_loop(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.loop = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index loop on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_playOnAwake(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.playOnAwake = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index playOnAwake on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_time(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.time = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index time on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_playbackSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.playbackSpeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index playbackSpeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startSpeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startSpeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startSize = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startSize on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startColor(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.Color arg0 = ToLua.ToColor(L, 2);
			obj.startColor = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startColor on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startRotation(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startRotation = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startRotation on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startRotation3D(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			obj.startRotation3D = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startRotation3D on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startLifetime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startLifetime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startLifetime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_gravityModifier(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.gravityModifier = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index gravityModifier on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_maxParticles(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.maxParticles = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index maxParticles on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_simulationSpace(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystemSimulationSpace arg0 = (UnityEngine.ParticleSystemSimulationSpace)(int)LuaDLL.lua_tonumber(L, 2);
			obj.simulationSpace = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index simulationSpace on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_scalingMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			UnityEngine.ParticleSystemScalingMode arg0 = (UnityEngine.ParticleSystemScalingMode)(int)LuaDLL.lua_tonumber(L, 2);
			obj.scalingMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index scalingMode on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_randomSeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			uint arg0 = (uint)LuaDLL.luaL_checknumber(L, 2);
			obj.randomSeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index randomSeed on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_useAutoRandomSeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.ParticleSystem obj = (UnityEngine.ParticleSystem)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.useAutoRandomSeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index useAutoRandomSeed on a nil value" : e.Message);
		}
	}
}

