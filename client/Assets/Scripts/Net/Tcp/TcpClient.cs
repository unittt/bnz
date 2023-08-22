using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Runtime.InteropServices;
using LuaInterface;


public enum TcpEvent
{
    ConnnectSuccess = 1,
    ConnnectFail = 2,
    SendSuccess = 4,
    ReceiveSuccess = 5,
    Exception = 6,
    Disconnect = 7,
    SendFail = 8,
    ReceiveFail = 9,
    ReceiveMessage = 255,
}


public class TcpClient
{
    public string serverIp
    {
        get;
        private set;
    }

    public int serverPort
    {
        get;
        private set;
    }

    public bool isConnected
    {
        get
        {
            return socket != null && socket.Connected;
        }
    }
    
    private TcpParser tcpParser;
    private byte[] receiveBuffer;
    private const int BUFFER_SIZE = 8192;


    public int frameProcessCount = 20;
    private Socket socket;
    private bool isClosed;

    private TcpSafeQueue<TcpReceiveMsg> recvQueue;
    private LuaFunction luaCallback;

    public TcpClient()
    {
        tcpParser = new TcpParser();
        receiveBuffer = new byte[BUFFER_SIZE];
        NetworkManager.Instance.AddTcpClient(this);
        recvQueue = new TcpSafeQueue<TcpReceiveMsg>(2048);
    }
    
    public void Update()
    {
        if (isClosed || luaCallback == null)
        {
            return;
        }
           
        
        TcpReceiveMsg revMsg = null;
        while (true)
        {
            revMsg = recvQueue.Dequeue();
            if (revMsg == null)
                break;

            try
            {
                if (revMsg.data != null)
                {
                    luaCallback.BeginPCall();
                    luaCallback.Push(revMsg.tcpEvent);
                    luaCallback.PushByteBuffer(revMsg.data, revMsg.length);
                    luaCallback.PCall();
                    luaCallback.EndPCall();
                }
                else
                {
                    luaCallback.BeginPCall();
                    luaCallback.Push(revMsg.tcpEvent);
                    luaCallback.PCall();
                    luaCallback.EndPCall();
                }
            }
            catch(Exception e)
            {
                GameDebug.LogError(e.Message);
            }
            TcpReceiveMsg.Recycle(revMsg);
        }
    }

    public void SetCallback(LuaFunction func)
    {
        if(luaCallback != null)
        {
            luaCallback.Dispose();
        }
        luaCallback = func;
    }
    
    private void AddReceiveMsg(TcpEvent tcpEvent, byte[] data, int length)
    {
        TcpReceiveMsg revMsg = TcpReceiveMsg.Get();
        revMsg.tcpEvent = tcpEvent;
        revMsg.data = data;
        revMsg.length = length;
        recvQueue.Enqueue(revMsg);
    }


    public string Connect(string ip, int port)
    {
        if(socket != null)
        {
            Close();
        }

        try
        {
            serverIp = ip;
            serverPort = port;

            IPAddress[] address = Dns.GetHostAddresses(ip);
            if(address == null)
            {
                GameDebug.Log("获取GetHostAddresses失败");
            }

            if(address != null && address.Length > 0 && address[0].AddressFamily == AddressFamily.InterNetworkV6)
            {
                socket = new Socket(AddressFamily.InterNetworkV6, SocketType.Stream, ProtocolType.Tcp);
                socket.BeginConnect(address, port, OnConnect, null);
            }
            else
            {
                socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                socket.BeginConnect(address, port, OnConnect, null);
            }
        }
        catch(Exception ex)
        {
            PrintException(ex, TcpEvent.ConnnectFail);
            return ex.Message;
        }
        return null;
    }

    private void OnConnect(IAsyncResult ar)
    {
        try
        {
            if(socket == null)
            {
                throw new Exception("TCP OnConnect Error! socket不存在");
            }
            socket.EndConnect(ar);
            AddReceiveMsg(TcpEvent.ConnnectSuccess, null, 0);
        }
        catch(Exception ex)
        {
            PrintException(ex, TcpEvent.ConnnectFail);
        }
        Receive();
    }

    private void Receive()
    {
        try
        {
            if(!isConnected)
            {
                throw new Exception("TCP Receive Error! 未与服务器建立连接");
            }
            socket.BeginReceive(receiveBuffer, 0, BUFFER_SIZE, SocketFlags.None, OnReceive, null);
        }
        catch(Exception ex)
        {
            PrintException(ex, TcpEvent.Exception);
        }
    }

    private void OnReceive(IAsyncResult ar)
    {
        if (isClosed)
        {
            return;
        }
        try
        {
            if(!isConnected)
            {
                throw new Exception("TCP OnReceive Error! 当前未连接到服务器");
            }
            int length = socket.EndReceive(ar);
            if (length > 0)
            {
                ParseReceive(length);
            }

            Array.Clear(receiveBuffer, 0, BUFFER_SIZE);   //清空数组
            Receive();
        }
        catch(Exception ex)
        {
            PrintException(ex, TcpEvent.Exception);
        }
    }

    private void ParseReceive(int length)
    {
        tcpParser.Receive(receiveBuffer, length);
        byte[] data;
        while(true)
        {
            int dataLength = tcpParser.Unpack(out data);
            if (dataLength == 0)
            {
                break;
            }
            AddReceiveMsg(TcpEvent.ReceiveMessage, data, dataLength);
        }
    }


    public static void PrintByteData(byte[] data)
    {
        StringBuilder sb = new StringBuilder();
        for(int i = 0; i < data.Length; i++)
        {
            sb.Append(data[i].ToString("X2"));
        }
        UnityEngine.Debug.Log(sb.ToString());
    }
    
    public void Send(IntPtr ptr, int len)
    {
        try
        {
            if(!isConnected)
            {
                throw new Exception("TCP Send Error! 没有连接到服务器");
            }
            byte[] data;
            int length = tcpParser.Pack(ptr, len, out data);
            if(data == null || length <= 0 || data.Length < length)
            {
                throw new Exception(string.Format("参数错误，无法生成数据包: data {0} length {1}", (data == null) ? -1 : data.Length, length));
            }
            TcpSendMsg sendMsg = TcpSendMsg.Get();
            sendMsg.data = data;
            sendMsg.length = length;
            socket.BeginSend(data, 0, length, SocketFlags.None, OnSend, sendMsg);
        }
        catch(Exception ex)
        {
            PrintException(ex, TcpEvent.SendFail);
        }
    }

    private void OnSend(IAsyncResult ar)
    {
        try
        {
            if(ar != null)
            {
                TcpSendMsg sendMsg = (TcpSendMsg)ar.AsyncState;
                TcpSendMsg.Recycle(sendMsg);
            }
            if(!isConnected)
            {
                throw new Exception("TCP OnSend Error! 没有连接到服务器");
            }
            socket.EndSend(ar);
        }
        catch(Exception ex)
        {
            PrintException(ex, TcpEvent.SendFail);
        }
    }

    public void Release()
    {
        isClosed = true;
        NetworkManager.Instance.RemoveTcpClient(this);
    }

    public void Close()
    {
        if(socket != null)
        {
            try
            {
                if (socket.Connected)
                {
                    socket.Shutdown(SocketShutdown.Both);
                }
                socket.Close();
            }
            catch(Exception ex)
            {
                PrintException(ex, TcpEvent.Exception);
            }
            socket = null;
            //GameDebug.Log(string.Format("TCP Close ip={0} port={1}", serverIp, serverPort));
        }
        if(tcpParser != null)
        {
            tcpParser.Release();
            tcpParser = null;
        }

        if(luaCallback != null)
        {
            luaCallback.Dispose();
            luaCallback = null;
        }
    }

    private void PrintException(Exception ex, TcpEvent eventType, string msg = "")
    {
        if(ex == null)
        {
            return;
        }
        string str = null;
        if(string.IsNullOrEmpty(ex.Message))
        {
            if(string.IsNullOrEmpty(msg))
            {
                str = ex.ToString();
            }
            else
            {
                str = string.Format("{0} {1}", msg, ex.ToString());
            }
        }
        else
        {
            if(string.IsNullOrEmpty(msg))
            {
                str = ex.Message;
            }
            else
            {
                str = string.Format("{0} {1}", msg, ex.Message);
            }
        }
        byte[] data = System.Text.Encoding.UTF8.GetBytes(str);
        AddReceiveMsg(eventType, data, data.Length);
        GameDebug.LogErrorInMainThread(string.Format("{0}\n{1}", ex.Message, ex.StackTrace));
    }

}
