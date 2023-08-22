using System.Collections.Generic;

public class LoginAccountDto
{
	public int code;
	public string msg;
	public string token;
	public string uid;//渠道或代理对应的唯一id
    public bool firstRegister;
    public long accountId;//游戏自定义的唯一id
    public bool white; //白名单账户
    public List<AccountPlayerDto> players = new List<AccountPlayerDto>();
}