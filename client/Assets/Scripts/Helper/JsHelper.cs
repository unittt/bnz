using System;
using System.Collections.Generic;
using LITJson;
using System.Linq;
using System.Reflection;
using UnityEngine;

public static class JsHelper
{
    public static bool IsInt(this object obj)
    {
        return obj is int;
    }

    public static bool IsFloat(this object obj)
    {
        return obj is float;
    }

    public static string FromCharCode(this char c)
    {
        return c.ToString();
    }

    #region Collection

    public static T Random<T>(this IList<T> list)
    {
        var count = list.Count;

        if (count == 0)
            return default(T);

        return list.ElementAt(UnityEngine.Random.Range(0, count));
    }

    #endregion

    #region Json
    public static T ToObject<T>(string json)
    {
        try
        {
            return JsonMapper.ToObject<T>(json);
        }
        catch (Exception e)
        {
            Debug.LogException(e);
            return default(T);
        }
    }

    public static T ToCollection<T, TChild>(string json)
    {
        return JsonMapper.ToObject<T>(json);
    }


    public static string ToJson(object obj)
    {
        return JsonMapper.ToJson(obj);
    }

    #endregion
}