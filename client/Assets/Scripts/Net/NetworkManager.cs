using System.Collections.Generic;
using System.Collections;
using UnityEngine;


public class NetworkManager : MonoBehaviour
{
    private List<TcpClient> tcpList;
    private List<TcpClient> delList;
    private List<TcpClient> addList;

    public static NetworkManager Instance
    {
        get;
        private set;
    }

    public static void CreateInstance()
    {
        if (Instance != null)
        {
            Debug.LogError("NetworkManager.Instance already exist");
            return;
        }

        GameObject go = new GameObject("NetworkManager");
        GameObject.DontDestroyOnLoad(go);
        Instance = go.AddComponent<NetworkManager>();
    }
    
    public NetworkManager()
    {
        tcpList = new List<TcpClient>();
        delList = new List<TcpClient>();
        addList = new List<TcpClient>();
    }

    public void CallUpdate()
    {
        for(int i = 0; i < addList.Count; i++)
        {
            tcpList.Add(addList[i]);
        }
        addList.Clear();

        for(int i = 0; i < delList.Count; i++)
        {
            tcpList.Remove(delList[i]);
            delList[i].Close();
        }
        delList.Clear();

        for(int i = 0; i < tcpList.Count; i++)
        {
            if(tcpList[i] != null)
            {
                tcpList[i].Update();
            }
        }
    }

    public void AddTcpClient(TcpClient socket)
    {
        if(!addList.Contains(socket))
        {
            addList.Add(socket);
        }
    }

    public void RemoveTcpClient(TcpClient socket)
    {
        if(!delList.Contains(socket))
        {
            delList.Add(socket);
        }
    }

    public void OnDestroy()
    {
        for(int i = 0; i < addList.Count; i++)
        {
            addList[i].Close();
        }
        addList.Clear();

        for(int i = 0; i < delList.Count; i++)
        {
            delList[i].Close();
        }
        delList.Clear();

        for(int i = 0; i < tcpList.Count; i++)
        {
            tcpList[i].Close();
        }
        tcpList.Clear();

        StopAllCoroutines();
    }
}
