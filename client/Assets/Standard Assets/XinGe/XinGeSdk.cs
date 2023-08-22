
using UnityEngine;

public class XinGeSdk
{
	public static void Setup()
	{
		GameDebug.Log("XinGeSdk:Setup");
		switch (Application.platform)
		{
			case RuntimePlatform.Android:
				{
					XinGeAndroidSdk.Setup();
					break;
				}
			case RuntimePlatform.IPhonePlayer:
				{
					XinGeIOSSdk.Setup();
					break;
				}
		}
	}


	public static void Register()
	{
		GameDebug.Log("XinGeSdk:Register");
		switch (Application.platform)
		{
			case RuntimePlatform.Android:
				{
					XinGeAndroidSdk.Register();
					break;
				}
			case RuntimePlatform.IPhonePlayer:
				{
					XinGeIOSSdk.Register();
					break;
				}
		}
	}


	public static void EnableDebug(bool enable)
	{
		GameDebug.Log("XinGeSdk:EnableDebug");
		switch (Application.platform)
		{
			case RuntimePlatform.Android:
				{
                    XinGeAndroidSdk.EnableDebug(enable);
					break;
				}
			case RuntimePlatform.IPhonePlayer:
				{
					XinGeIOSSdk.EnableDebug(enable);
					break;
				}
		}
	}


	public static void RegisterWithAccount(string account)
	{
		GameDebug.Log("XinGeSdk:RegisterWithAccount");
		switch (Application.platform)
		{
			case RuntimePlatform.Android:
				{
					XinGeAndroidSdk.RegisterWithAccount(account);
					break;
				}
			case RuntimePlatform.IPhonePlayer:
				{
					XinGeIOSSdk.RegisterWithAccount(account);
					break;
				}
		}
	}


	public static void SetTag(string tagName)
	{
		GameDebug.Log("XinGeSdk:SetTag"+tagName);
		switch (Application.platform)
		{
			case RuntimePlatform.Android:
				{
					XinGeAndroidSdk.SetTag(tagName);
					break;
				}
			case RuntimePlatform.IPhonePlayer:
				{
					XinGeIOSSdk.SetTag(tagName);
					break;
				}
		}
	}


	public static void DeleteTag(string tagName)
	{
		GameDebug.Log("XinGeSdk:DeleteTag"+tagName);
		switch (Application.platform)
		{
			case RuntimePlatform.Android:
				{
					XinGeAndroidSdk.DeleteTag(tagName);
					break;
				}
			case RuntimePlatform.IPhonePlayer:
				{
					XinGeIOSSdk.DeleteTag(tagName);
					break;
				}
		}
	}
}
