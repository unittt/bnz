using UnityEngine;

public class MonoController : MonoBehaviour, IViewController, IPoolController
{
    //启动Controller的所有逻辑。注意业务中切勿调用本方法。
    public void BindComponent()
    {
        Setup();
    }

    protected virtual void Setup()
    {
    }

    //处理U层初始化的，一个UI生命周期只会执行一次
    protected virtual void InitView()
    {
    }

    /// <summary>
    /// 注册回调
    /// </summary>
    protected virtual void RegisterEvent()
    {
    }

    public virtual void Dispose()
    {
    }

    public virtual void Spawn()
    {
    }

    public virtual void Despawn()
    {
    }
}
