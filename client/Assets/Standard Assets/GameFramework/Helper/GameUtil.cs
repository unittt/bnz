//#define LOG_MODULE
//#define LOG_REDPOINT
//#define LOG_Fish
using System;
using System.Timers;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;


public static class GameUtil
{
    
    public static void LogFish(string msg){

        #if  LOG_Fish
        GameDebuger.LogError(msg);
        #endif
    }
    public static void LogRedPoint(string msg){

        #if  LOG_REDPOINT
        GameDebuger.LogError(msg);
        #endif
    }

    public static void LOGModule(string msg){
        #if LOG_MODULE
        GameDebuger.LogError(msg);
        #endif
    }
    public static void SafeRun(Action act,Action<Exception> onError = null){
        if (act == null) return;
        try{
            act();
        }catch(Exception e){
            GameDebug.LogException (e);
            if (onError !=null) onError(e);
        }
    }
        
    public static void SafeRun<T>(Action<T> act, T param, Action<Exception> onError = null){
        if (act == null) return;
        try{
            act(param);
        }catch(Exception e){
            GameDebug.LogException(e);
            if (onError !=null) onError(e);
        }
    }


    public static void SafeRun<T, R>(Action<T, R> act, T t, R r){
        if (act != null)
            act(t, r);
    }
    //public static List<T> FiltAndSort<T>(IEnumerable<T> dataSet, 
    //    Predicate<T> predicate
    //    , out int length
    //    , Comparison<T> com = null){
    //    length = 0;

    //    IEnumerable<T> temp = dataSet.Filter(predicate);
    //    if (temp == null)
    //        return null;
    //    else {
    //        List<T> tempSet = temp.ToList();
    //        length = tempSet.Count;
    //        if (com == null) {
    //            return temp.ToList();
    //        }
    //        else{
    //            tempSet.Sort(com);
    //            return tempSet;
    //        }
    //    } 
    //}


}

public static class CollectionExtension{
    public static void AddIfNotExist<T> (
        this List<T> dataSet
        , T t){
        if (dataSet == null || t == null) {
            return;
        }

        if (dataSet.IndexOf (t) < 0) {
            dataSet.Add (t);
        }
    }

    public static void ForEach<T>(this IEnumerable<T> dataset,Action<T> act)
    {
        if (dataset == null) return;
        foreach(var item in dataset)
        {
            GameUtil.SafeRun<T>(act, item);
        }
    }

    public static void ForEachI<T>(this IEnumerable<T> dataset, Action<T, int> act){
        if (dataset == null) return;
        if (act == null) return;

        int i = 0;
        foreach(var data in dataset)
        {
            GameUtil.SafeRun<T, int>(act, data, i);
            i++;
        }
    }

    //public static IEnumerable<R> Map<T, R>(this IEnumerable<T> dataset,  Func<T, R> action){
    //    if (dataset == null || action == null)
    //        yield return default(R);

    //    foreach (var data in dataset)
    //    {
    //        yield return action(data);
    //    }
    //}

    //public static IEnumerable<R> MapI<T, R>(this IEnumerable<T> dataset,  Func<T, int, R> action){
    //    if (dataset == null || action == null)
    //        yield return default(R);

    //    var i = 0;
    //    foreach (var data in dataset)
    //    {
    //        yield return action(data, i);
    //        i++;
    //    }
    //}
    //all methods returning IEnumerable<T> require the predicate must not throw an exception
    //this is required by C# since no try catch block is allow to enclose yield return statements
    //  public static IEnumerable<FP.Tuple<T1,T2>> JoinSearch<T1,T2>(
    //      this IEnumerable<T1> set1,IEnumerable<T2> set2,Predicate<FP.Tuple<T1,T2>> pred){
    //      if (set1 != null && set2 != null)
    //          foreach ( var item1 in set1)
    //              foreach(var item2 in set2){
    //                  var pair = Tuple.Create(item1,item2);
    //                  if (pred(pair))
    //                      yield return pair;
    //              }
    //  }
    //
    //  public static IEnumerable<FP.Tuple<T1,T2>> JoinSearch<T1,T2>(
    //      this IEnumerable<T1> set1,int set1Size,IEnumerable<T2> set2,int set2Size,Predicate<FP.Tuple<T1,T2>> pred){
    //      if (set1Size < set2Size){
    //          foreach(var item in set1.JoinSearch(set2,pred))
    //              yield return item;
    //      }else{
    //          IEnumerable<FP.Tuple<T2,T1>> tmp = set2.JoinSearch<T2,T1>(set1,delegate (FP.Tuple<T2,T1> pair){
    //              return pred(FP.Tuple.Create(pair.p2,pair.p1));
    //          });
    //          foreach(var pair in tmp){
    //              yield return FP.Tuple.Create(pair.p2,pair.p1);
    //          }
    //      }
    //  }

    //public static IEnumerable<T> Filter<T>(this IEnumerable <T> dataset, Predicate<T> predicate){
    //    if (dataset != null) {
    //        foreach (var item in dataset) {
    //            if (predicate != null) {
    //                if (predicate (item)) {
    //                    yield return item;
    //                }
    //            } else {
    //                yield return item;
    //            }
    //        }
    //    } else {
    //        yield return default(T);
    //    }
    //}

    private static T Find<T>(this IEnumerable<T> dataset, Predicate<T> predicate, out int idx)
    {
        idx = -1;

        if (dataset != null && predicate != null) {
            int i = 0;
            foreach(var item in dataset){
                if (predicate(item)){
                    idx = i;
                    return item;
                }
                ++i;
            }
        }

        return default(T);
    }

    public static int FindElementIdx<T>(this IEnumerable<T> dataset, Predicate<T> predicate)
    {
        int idx = -1;
        dataset.Find (predicate, out idx);
        return idx;
    }

    public static R Find<T, R>(this IEnumerable<T> dataset, Predicate<T> predicate, Func<T, R> action)
    {
        int idx = -1;
        var data = dataset.Find (predicate, out idx);
        return action(data);
    }

    public static T Find<T>(this IEnumerable<T> dataset, Predicate<T> predicate)
    {
        int idx = -1;
        return dataset.Find (predicate, out idx);
    }

    public static List<T> ToList<T>(this IEnumerable<T> dataset)
    {
        List<T> list = new List<T>(); 
        if (dataset != null)
            foreach(T item in dataset)
            {
                list.Add(item);
            }
        return list;
    }

    public static List<T2> GetNewList<T1, T2>(this List<T1> pList, Func<T1, T2> pFilteFunc)
    {
        List<T2> tNewList = new List<T2>();
        for (int i = 0; i < pList.Count; ++i)
        {
            tNewList.Add(pFilteFunc(pList[i]));
        }

        return tNewList;
    }

    public static bool Replace<T>(this List<T> dataset, Predicate<T> predicate, T t)
    {
        bool replaceSuccess = false;
        if (!dataset.IsNullOrEmpty () && predicate != null) {
            int idx = -1;
            var item = dataset.Find (predicate, out idx);
            if (item != null) {
                dataset [idx] = t;
                replaceSuccess = true;
            }
        }
        return replaceSuccess;
    }

    public static void ReplaceOrAdd<T>(this List<T> dataset, Predicate<T> predicate, T t)
    {
        if (t == null) return;
        bool isExist = dataset.Replace (predicate, t);
        if (!isExist)
            dataset.Add (t);
    }


    public static bool RemoveItem<T>(this List<T> dataSet, T t)
    {
        if (null == t || dataSet.IsNullOrEmpty())
            return false;
        return dataSet.Remove(t);
    }

    public static bool Remove<T>(this List<T> dataSet, Predicate<T> predicate){
        bool isChange = false;
        var item = dataSet.Find<T> (predicate);
        if (item != null) {
            dataSet.Remove (item);
            isChange = true;
        }
        return isChange;
    }

    //return old value if exists for key
    public static TValue Replace<TKey, TValue>(this Dictionary<TKey, TValue> dict, TKey key, TValue val){
        if (dict == null) return default(TValue);
        TValue old;
        if (dict.TryGetValue(key,out old)){
            dict.Remove(key);
        }
        dict.Add(key,val);
        return old;
    }

    //return true if key is not present and (key value) pair is added
//    public static bool ReplaceOrAdd<TKey, TValue>(this IDictionary<TKey, TValue> dict, TKey key, TValue val){
//        if (dict == null) return false;
//        bool result;
//        if (result == !dict.ContainsKey(key))
//            dict.Add(key,val);
//        return true;
//    }

    public static TValue CreateIfNotExist<TKey, TValue>(this Dictionary<TKey, TValue> dict, TKey key, Func<TValue> createFunc)
        where TKey : class
        where TValue : class
    {
        if (dict == null || key == null)
        {
            return null;
        }

        if (!dict.ContainsKey(key))
        {
            if (createFunc != null)
            {
                var value = createFunc();
                dict.Add(key, value);
                return value;
            }
            else
                return null;
        }
        else if (dict[key] == null && createFunc != null)
        {
            var value = createFunc();
            dict[key] = value;
            return value;
        }
        else
            return dict[key];
    }

    public static R ShallowCopyCollection<T,R>(this  ICollection<T> dataset) where R :   ICollection<T>, new(){
        if (dataset == null) return default(R);
        R result = new R();
        foreach(var item in dataset){
            result.Add(item);
        }
        return result;
    }

    public static bool IsNullOrEmpty<T>(this List<T> dataSet)
    {
        return dataSet == null || dataSet.Count <= 0;
    }

    public static bool TryGetLength<T>(this List<T> set, out int length){
        length = 0;
        if (set == null) {
            return false;
        } else {
            length = set.Count;
            return true;
        }
    }

    public static bool TryGetValue<T>(this List<T> set, int index, out T value){
        value = default(T);
        if (!set.IsNullOrEmpty () && index < set.Count) {
            value = set [index];
            return true;
        } else {
            return false;
        }
    } 

    public static bool IsNullOrEmpty(this ArrayList array){
        return array == null || array.Count <= 0;
    }

}

public static class UIButtonExtension{
    public static void SetClickHandler(this UIButton btn, EventDelegate.Callback callback) {
        if (btn == null || callback == null)
            return;
        EventDelegate.Set(btn.onClick, callback);   
    }

    public static void RemoveClickHandler(this UIButton btn, EventDelegate.Callback callback) {
        if (btn == null || callback == null)
            return;
        EventDelegate.Remove(btn.onClick, callback);    
    }
}

public static class UIWidgetContainerExtension{

    /// <summary>
    /// Updates the cells.
    /// </summary>
    /// <param name="grid">Grid.</param>
    /// <param name="cellSet">Cell set.</param>
    /// <param name="cellCnt">Cell count.</param>
    /// <param name="cellName">Cell name.</param>
    /// <param name="updateCell">Update cell.</param>
    /// <typeparam name="T">The 1st type parameter.</typeparam>
    //  public static void UpdateCells<T>(this UIGrid grid
    //      , ref List<T> cellSet
    //      , int dataLength
    //      , string cellName
    //      , Action<T,int> updateCell) where T: BaseCellView, new() 
    //  {
    //      if (grid == null)
    //          return;
    //      
    //      int i = 0;
    //
    //      while(i < dataLength){
    //          if (i >= cellSet.Count) {
    //              var _cell = BaseCellView.CreateAndSpawn<T>(cellName, grid.gameObject);
    //              cellSet.Add (_cell);
    //          }
    //          var cell = cellSet [i];
    //          cellSet [i].gameObject.SetActive (true);
    //          if (updateCell != null)
    //              updateCell (cell, i);
    //          i++;
    //      }
    //
    //      var cellCnt = grid.transform.childCount;
    //      while (i < cellCnt) {
    //          grid.transform.GetChild (i).gameObject.SetActive(false);
    //      }
    //
    //      grid.Reposition ();
    //  }

    public static void UpdateCellsWithFixGO(this UIGrid grid
        , int dataLength
        , Action<GameObject, int> updateCell)
    {
        if (grid == null)
            return;
        int i = 0;
        var cellCnt = grid.transform.childCount;

        while (i < cellCnt) {
            bool isOverRange = i < dataLength;
            var go = grid.transform.GetChild (i).gameObject;
            go.SetActive(isOverRange);  
            if (isOverRange) {
                updateCell (go, i);
            }
        }
        grid.Reposition ();
    }
}

public static class EnumParserHelper{
    public static T TryParse<T>(string value) where T : struct{
        T result = default(T);
        try {
            result = (T)Enum.Parse(typeof(T),value,true);
        } catch (Exception ex) {
            GameDebug.LogException(ex);
        }
        return result;
    }

    public static T? TryParseOptional<T>(string value) where T : struct{
        T? result = null;
        try {
            result = (T)Enum.Parse(typeof(T),value);
        } catch (Exception ex) {
            GameDebug.LogException(ex);
        }
        return result;
    }
}

public interface IntEnum<T> where T : struct {
    T[] getEnums();
    int getIndex(T e);
}

internal class IntEnumHelper{
    public static T[] getEnums<T>() where T : struct{
        System.Array enums = Enum.GetValues(typeof(T));
        T[] values = new T[enums.Length];
        for(int i = 0; i< enums.Length; i++){
            values[i] = (T)enums.GetValue(i);
        }
        return values;
    }
    public static E Parse<E>(string nm,bool ignoreCase=false) where E : struct{
        Type ty = typeof(E);
        try{
            return (E)Enum.Parse(ty,nm,ignoreCase);
        }catch (Exception e){
            GameDebug.Log(string.Format("can not parse enum:{0} for type<{1}>", nm, ty));
            throw e;
        }
    }

    public static bool tryParse<E>(string nm,bool ignoreCase,ref E enm) where E:struct{
        Type ty = typeof(E);
        try{
            enm = (E)Enum.Parse(ty,nm,ignoreCase);
            return true;
        }catch{
            GameDebug.Log(string.Format("can not parse enum:{0} for type<{1}>", nm, ty));
            return false;
        }
    }
    public static int getIndex(Type enumType, object enumObjWrapper){
        string nm = Enum.GetName(enumType,enumObjWrapper);
        string[] names = Enum.GetNames(enumType);
        for(int i = 0; i< names.Length; i++){
            if (nm.Equals(names[i])){
                return i;
            }
        }
        GameDebug.Log(string.Format("bug, not all enumeration is collected {0}", enumType));
        return -1;
    }
}


public static class ClassExtension
{
    public static void SafeRun(Action act, Action<Exception> onError = null)
    {
        if (act == null) return;
        try
        {
            act();
        }
        catch (Exception e)
        {
            GameDebug.LogException(e);
            if (onError != null)
                onError(e);
        }
    }

    public static void SafeRun<T>(Action<T> act, T param, Action<Exception> onError = null)
    {
        if (act == null) return;
        try
        {
            act(param);
        }
        catch (Exception e)
        {
            GameDebug.LogException(e);
            if (onError != null)
                onError(e);
        }
    }


    public static void SafeRun<T, R>(Action<T, R> act, T t, R r)
    {
        if (act != null)
            act(t, r);
    }
}
