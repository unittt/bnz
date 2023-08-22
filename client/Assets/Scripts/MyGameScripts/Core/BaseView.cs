using UnityEngine;
using System.Collections.Generic;

public abstract class BaseView
{
    public GameObject gameObject;
    #region 兼容旧版本
    public Transform transform
    {
        get { return gameObject.transform; }
    }

    public T GetComponent<T>()
    {
        return gameObject.GetComponent<T>();
    }

    public static bool IsViewDestroy(BaseView view)
    {
        if (view == null || view.gameObject == null)
            return true;
        return false;
    }

    
    #region 处理MonoBehaviour被销毁，view不为空的情况。
    public static bool operator !=(BaseView view1, BaseView view2)
    {
        return !(view1 == view2);
    }

    public static bool operator ==(BaseView view1, BaseView view2)
    {
        if(Equals(view1, null) || view1.gameObject == null)
        {
            if(Equals(view2, null) || view2.gameObject == null)
            {
                return true;
            }
            return false;
        }

        //view1 不为null
        if (Equals(view2, null) || view2.gameObject == null)
        {
            return false;
        }
        
        return Equals(view1, view2);
    }

    public override bool Equals(object obj)
    {
        return base.Equals(obj);
    }

    public override int GetHashCode()
    {
        return base.GetHashCode();
    }
    
    #endregion

    #endregion

    public void Setup(Transform root) { 
        gameObject = root.gameObject; 
        InitElementBinding();
        AfterInitElementBinding();
    }

    protected virtual void InitElementBinding(){
        
    }
    protected virtual void AfterInitElementBinding(){
    }

    protected virtual void OnDispose(){

    }

    public void Dispose(){
        OnDispose ();
    }
}

public static class BaseViewExt
{
    public static T[] GetComponentsInChildren<T> (this BaseView pBaseView, bool pIncludeInactive = false) where T : Component
    {
        if (null == pBaseView) {
            GameDebuger.LogError ("GetComponentsInChildren failed for null == pBaseView !");
            return null;
        }

        if (null == pBaseView.gameObject) {
            GameDebuger.LogError ("GetComponentsInChildren failed for null == pBaseView.gameObject !");
            return null;
        }

        return pBaseView.gameObject.GetComponentsInChildren<T> (pIncludeInactive);
    }

    public static T GetComponent<T> (this BaseView pBaseView) where T : Component
    {
        if (null == pBaseView) {
            GameDebuger.LogError ("GetComponentsInChildren failed for null == pBaseView !");
            return null;
        }

        if (null == pBaseView.gameObject) {
            GameDebuger.LogError ("GetComponentsInChildren failed for null == pBaseView.gameObject !");
            return null;
        }

        return pBaseView.gameObject.GetComponent<T> ();
    }
}