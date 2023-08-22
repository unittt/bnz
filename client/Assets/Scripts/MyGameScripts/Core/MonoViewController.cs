using System;
using System.Collections.Generic;
using UnityEngine;

public abstract class MonoViewController<T> : MonoAutoCacher
    where T : BaseView, new()
{
    protected T _view;

    public T View {
        get { return _view; }
    }


    /// <summary>
    /// 业务不需要重载此函数
    /// </summary>
    sealed protected override void Setup ()
    {
        if (_view == null) 
        {
            InitUICacheList();

            _view = new T ();
            _view.Setup (transform);
            InitView ();
            RegisterEvent();
        }
    }

    /// <summary>
    /// 业务不需要重载此函数
    /// </summary>
    sealed public override void Dispose ()
    {
        if (_view != null) {
            OnDispose();
            DespawnUIList();
            _view.Dispose();
            _view = null;
        }
        //Dispose的时候自动销毁绑定脚本， 避免下次复用脚本导致无法再Awake进行Setup
        //UnityEngine.Object.Destroy(this);
        UnityEngine.Object.DestroyImmediate(this);
    }

    protected virtual void OnDispose()
    {
    }
}

