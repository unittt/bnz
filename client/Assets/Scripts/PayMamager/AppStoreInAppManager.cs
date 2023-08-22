using UnityEngine;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using LuaInterface;

public class AppStoreInAppManager : MonoBehaviour
{
    static AppStoreInAppManager _instance = null;
    public static AppStoreInAppManager Instance
    {
        get
        {
            return _instance;
        }
    }

    private bool _hasInit = false;

    //delegates

    public delegate void OnProductListReceived();
    public OnProductListReceived onProductListReceived;

    public delegate void OnProductListRequestFailed();
    public OnProductListRequestFailed onProductListRequestFailed;

    public delegate void OnAppStorePurchaseSuccessed();
    public OnAppStorePurchaseSuccessed onAppStorePurchaseSuccessed;

    public delegate void OnAppStorePurchaseFailed(string error);
    public OnAppStorePurchaseFailed onAppStorePurchaseFailed;

    public delegate void OnAppStorePurchaseCancel(string error);
	public OnAppStorePurchaseCancel onAppStorePurchaseCancel;

	public LuaFunction onAppStorePurchaseRecove = null;

	public string payUrl = "https://isdk.demigame.com/v1/sdkc/integration/appstore/1048";

    //properies
    public bool CanMakePayments
    {
        get
        {
            return IOSInAppPurchaseManager.JsbInstance.IsInAppPurchasesEnabled;
        }
    }

    public bool ProductListHasReceived
    {
        get
        {
            return IOSInAppPurchaseManager.JsbInstance.Products != null && IOSInAppPurchaseManager.JsbInstance.Products.Count > 0;
        }
    }

    //create
    public static void Setup()
    {
        Debugger.Log("AppStoreInAppManager Setup...");
        if (GameObject.Find("AppStoreInAppManager") == null)
        {
            GameObject obj = new GameObject("AppStoreInAppManager");
            obj.AddComponent<AppStoreInAppManager>();
            DontDestroyOnLoad(obj);
        }
    }

    void Awake()
    {
		GameDebug.Log("AppStoreInAppManager Awake...");
        _instance = this;
    }

    void OnDestroy()
    {
		GameDebug.Log("AppStoreInAppManager OnDestroy...");

        Destroy();

        _instance = null;
    }

    public void Init(string[] productIdentifiers)
    {
		Debugger.Log ("AppStoreInAppManager.Init:" + productIdentifiers.ToString() + " | _hasInit:" + _hasInit);
        if (!_hasInit)
        {
            _hasInit = true;

            for (int i = 0; i < productIdentifiers.Length; i++)
            {
                IOSInAppPurchaseManager.JsbInstance.AddProductId(productIdentifiers[i]);
            }

            IOSInAppPurchaseManager.OnStoreKitInitComplete += OnStoreKitInitComplete;
            IOSInAppPurchaseManager.OnTransactionComplete += OnTransactionComplete;

            IOSInAppPurchaseManager.JsbInstance.LoadStore();
        }
    }

    public void Destroy()
    {
        if (_hasInit)
        {
            IOSInAppPurchaseManager.OnStoreKitInitComplete -= OnStoreKitInitComplete;
            IOSInAppPurchaseManager.OnTransactionComplete -= OnTransactionComplete;
        }
    }

    void OnEnable()
    {
        GameDebug.Log("AppStoreInAppManager OnEnable...");
        // Listens to all the StoreKit events.  All event listeners MUST be removed before this object is disposed!
    }

    void OnDisable()
    {
        GameDebug.Log("AppStoreInAppManager OnDisable...");
        // Remove all the event handlers
    }


    /// <summary>
    /// SDK初始化完毕
    /// </summary>
    /// <param name="result"></param>
    private void OnStoreKitInitComplete(ISN_Result result)
    {
        if (result.IsSucceeded)
        {
            GameDebug.Log("OnStoreKitInitComplete Success");

            var products = IOSInAppPurchaseManager.JsbInstance.Products;
            for (int i = 0; i < products.Count; i++)
            {
                GameDebug.Log(products[i].ToString());
            }
        }
        else
        {
            GameDebug.LogError("Error code: " + result.Error.Code + "\n" + "Error description:" + result.Error.Description);
        }
    }

    private void OnTransactionComplete(IOSStoreKitResult result)
    {
        GameDebug.Log("OnTransactionComplete: " + result.ProductIdentifier);
        GameDebug.Log("OnTransactionComplete: state: " + result.State);
        GameDebug.Log("OnTransactionComplete: transactionIdentifier " + result.TransactionIdentifier);

        switch (result.State)
        {
            case InAppPurchaseState.Purchased:
                productPurchaseAwaitingConfirmationEvent(result);
                break;
            case InAppPurchaseState.Restored:
                //Our product been succsesly purchased or restored
                //So we need to provide content to our user depends on productIdentifier

                // 对于不合法的重复购买，会被调用到
                productPurchaseAwaitingConfirmationEvent(result);
                //FinishTransaction(result.TransactionIdentifier);
                break;
            case InAppPurchaseState.Deferred:
                //iOS 8 introduces Ask to Buy, which lets parents approve any purchases initiated by children
                //You should update your UI to reflect this deferred state, and expect another Transaction Complete  to be called again with a new transaction state 
                //reflecting the parent’s decision or after the transaction times out. Avoid blocking your UI or gameplay while waiting for the transaction to be updated.

                // 不做处理，一直等待刷新状态
                break;
            case InAppPurchaseState.Failed:
                //Our purchase flow is failed.
                //We can unlock intrefase and repor user that the purchase is failed. 
                GameDebug.Log("Transaction failed with error, code: " + result.Error.Code);
                GameDebug.Log("Transaction failed with error, description: " + result.Error.Description);

                // 失败也要终结订单
                FinishTransaction(result.TransactionIdentifier);
                RaiseAppStorePurchaseFailed(result.Error.Description);
                break;
        }
    }


    private void FinishTransaction(string transactionIdentifier)
    {
        Debug.Log("FinishTransaction, transactionIdentifier: " + transactionIdentifier);
        IOSInAppPurchaseManager.JsbInstance.FinishTransaction(transactionIdentifier);
    }

	public void RestoreCompletedTransactions(LuaFunction cb)
    {
        Debug.Log("RestoreCompletedTransactions hasWaitRestoredPurchases:");
		onAppStorePurchaseRecove = cb;
		IOSInAppPurchaseManager.JsbInstance.RestorePurchases();
    }

    private Dictionary<string, string> _orderDic = new Dictionary<string, string>();

    public void PurchaseProduct(string productIdentifier, int quantity, string orderId)
    {
        if (_orderDic.ContainsKey(productIdentifier))
        {
            _orderDic[productIdentifier] = orderId;
        }
        else
        {
            _orderDic.Add(productIdentifier, orderId);
        }
        GameDebug.Log("PurchaseProduct .. productIdentifier: " + productIdentifier + ", quantity: " + quantity + ", orderId: " + orderId);
        //      StoreKitBinding.purchaseProduct( productIdentifier, quantity );
        IOSInAppPurchaseManager.JsbInstance.BuyProduct(productIdentifier);
    }

	public void StartCoroutineSendReceiptToServer(IOSStoreKitResult result, string orderId, bool delay) {
		StartCoroutine(SendReceiptToServer(result, orderId, delay));
	}

	public void ResetCallbackURL(string purl) {
		payUrl = purl;
	}

    private void productPurchaseAwaitingConfirmationEvent(IOSStoreKitResult result)
    {
        if (_orderDic.ContainsKey(result.ProductIdentifier))
        {
            string orderId = _orderDic[result.ProductIdentifier];
            _orderDic.Remove(result.ProductIdentifier);
            StartCoroutine(SendReceiptToServer(result, orderId, false));
        }
        else
        {
            // 一般跑进这里是购买恢复
            // 恢复购买需要角色Id，如果没有的话不允许恢复，做个标记，登陆之后才允许调用
			if (onAppStorePurchaseRecove != null) {
				onAppStorePurchaseRecove.BeginPCall();
				onAppStorePurchaseRecove.Push(result);
				onAppStorePurchaseRecove.Push(result.ProductIdentifier);
				onAppStorePurchaseRecove.PCall();
				onAppStorePurchaseRecove.EndPCall();
			}
//            ServiceProviderManager.RequestOrderId(GameSetting.Channel, 
//                ModelManager.Player.GetPlayerId().ToString(), 
//                result.ProductIdentifier, 0, GameSetting.LoginWay, 
//                GameSetting.CiluChannel,
//                GameSetting.APP_ID, 
//                BaoyugameSdk.getUUID(), 
//                ModelManager.Player.GetPlayerLevel(), 
//                ServerManager.Instance.payExt, SdkLoginMessage.Instance.GetCurAccountType(), ModelManager.Player.GetPlayer().faction.name, delegate (OrderJsonDto dto) {
//                    if (dto.code == 0) {
//                        OrderItemJsonDto itemJsonDto = PayManager.Instance.GetOrderItemWithStringId(result.ProductIdentifier);
//                        string payAmount = "";
//                        if (itemJsonDto != null)
//                        {
//                            payAmount = itemJsonDto.cent.ToString();
//                        }
//                        RequestDemiOrderId(result, dto.orderId, payAmount);
//                    }
//                    else
//                    {
//                        GameDebug.Log(dto.msg);
//                        TipManager.AddTip(dto.msg);
//                        RequestLoadingTip.Reset();
//                    }
//                }
//			);
        }
    }

    private void RequestDemiOrderId(IOSStoreKitResult result, string orderId, string payAmount)
    {
//        ServiceProviderManager.RequestDemiOrderId(
//            "appstore",
//            GameSetting.APP_ID.ToString(), 
//            ServerManager.Instance.sid,
//            orderId,
//            ServerManager.Instance.GetServerInfo().serverId.ToString(),
//            ModelManager.Player.GetPlayerId().ToString(),
//            "",
//            "",
//            payAmount,
//            delegate (DemiOrderJsonDto dto)
//            {
//                if (dto.code == 0 && dto.item != null)
//                {
//                    StartCoroutine(SendReceiptToServer(result, dto.item.orderId, true));
//                }
//                else
//                {
//                    GameDebug.Log(dto.msg);
//                    TipManager.AddTip(dto.msg);
//                    RequestLoadingTip.Reset();
//                }
//            }
//		);
    }

    private IEnumerator SendReceiptToServer(IOSStoreKitResult result, string orderId, bool delay)
    {
        if (delay)
        {
            yield return new WaitForSeconds(2f);
        }

        IOSProductTemplate tpl = IOSInAppPurchaseManager.JsbInstance.GetProductById(result.ProductIdentifier);

        string receipt = result.Receipt;

        string local = tpl==null?"":tpl.CountryCode;
        string price = tpl==null?"":(tpl.CurrencyCode + "_" + tpl.Price);

        WWWForm form = new WWWForm();
        form.AddField("receipt", receipt);
        form.AddField("orderId", orderId);
        form.AddField("appId", GameSetting.APP_ID);
		form.AddField("deviceId", PlatformAPI.GetDeviceUID());
        if (tpl != null)
        {
            form.AddField("local", local);
            form.AddField("price", price);
        }

        string realPayUrl = "errorPayUrl";
        if (GameSetting.Channel == "demi")
        {
            realPayUrl = GameSetting.DEMISDK_SERVER + "/sdkc/pay/appstore";
        }
        else
        {
            realPayUrl = payUrl;
        }
        GameDebug.Log(string.Format("payUrl={0} receipt={1} orderId={2}", realPayUrl, receipt, orderId));

        using (WWW www = new WWW(realPayUrl, form))
        {
            yield return www;

			GameDebug.Log("purchased product id = " + result.ProductIdentifier);

            if (string.IsNullOrEmpty(www.error))
            {
                if (!string.IsNullOrEmpty(www.text))
				{
                    string json = www.text;
					GameDebug.Log("SendReceiptToServer json: " + json);
					ValidateJsonDto dto = (ValidateJsonDto)JsonHelper.ToObject<ValidateJsonDto>(json);
                    GameDebug.Log("SendReceiptToServer dto.code: " + dto.code + " dto.msg:" + dto.msg);
                    if (dto.code == 0) {
						FinishTransaction (result.TransactionIdentifier);
						RaiseAppStorePurchaseSuccessed ();
//                        RequestLoadingTip.Reset();
					}
					else if (dto.code == 2)
					{
						// 该订单不存在
						GameDebug.Log("该订单不存在 SendReceiptToServer Result Identifier: " + result.TransactionIdentifier);
						FinishTransaction(result.TransactionIdentifier);
//	                        RequestLoadingTip.Reset();
					}
					else if (dto.code == 8)
					{
						// 该订单之前已经付费，终止订单不做处理
                        FinishTransaction(result.TransactionIdentifier);
//                        RequestLoadingTip.Reset();
                    }
					else
					{
                        RaiseAppStorePurchaseFailed("statusCode=" + dto.msg);
                    }
                }
                else
				{
                    RaiseAppStorePurchaseFailed(null);
                }
            }
            else
			{
                RaiseAppStorePurchaseFailed(www.error);
            }
        }
    }



    //helper
    void RaiseAppStorePurchaseSuccessed()
    {
        if (onAppStorePurchaseSuccessed != null)
        {
            onAppStorePurchaseSuccessed();
        }
    }

    void RaiseAppStorePurchaseFailed(string error)
    {
//        RequestLoadingTip.Reset();
        if (onAppStorePurchaseFailed != null)
        {
            onAppStorePurchaseFailed(error);
        }
    }

    void RaiseBaoyugamePurchaseCancel(string error)
    {
//        RequestLoadingTip.Reset();
        if (onAppStorePurchaseCancel != null)
        {
            onAppStorePurchaseCancel(error);
        }
    }

}