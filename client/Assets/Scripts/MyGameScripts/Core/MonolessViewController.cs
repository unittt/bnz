using System;
using System.Collections.Generic;
using UnityEngine;

public abstract class MonolessViewController<T1, T2> : MonolessViewController<T1>
    where T1 : BaseView, new()
{

    public readonly T2 master;

    public MonolessViewController(GameObject _gameObject, T2 _master)
        : base(_gameObject)
    {
        master = _master;
    }
}

public abstract class MonolessViewController<T1> : MonolessAutoCacher
    where T1 : BaseView, new()
{
    protected T1 _view;
    public readonly GameObject gameObject;
    public readonly Transform transform;

    public MonolessViewController(GameObject _gameObject)
    {
        gameObject = _gameObject;
        transform = gameObject.transform;
        Setup();
    }

    public T1 View
    {
        get { return _view; }
    }

    /// <summary>
    /// 业务不需要重载此函数
    /// </summary>
    private void Setup()
    {
        if (_view == null)
        {
            InitUICacheList();
            AutoCacherHelper.AddToUIControllerCacheList(this);

            _view = new T1();
            _view.Setup(transform);

            InitView();
            RegisterEvent();
        }
    }

    /// <summary>
    /// 业务不需要重载此函数
    /// </summary>
    sealed public override void Dispose()
    {
        if (_view != null)
        {
            DespawnUIList();
            OnDispose();
            _view.Dispose();
            _view = null;
        }
    }
}