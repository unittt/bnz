using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LITJson;


public class JsonHelper
{
    public static string ToJson(object obj)
    {
        return JsonMapper.ToJson(obj);
    }

    public static T ToObject<T>(string json)
    {
        try
        {
            return JsonMapper.ToObject<T>(json);
        }
        catch (Exception e)
        {
            GameDebug.LogError(e.ToString());
            return default(T);
        }
    }

}

