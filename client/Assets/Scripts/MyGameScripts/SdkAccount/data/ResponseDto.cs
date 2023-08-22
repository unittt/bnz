namespace SdkAccountDto
{
    public class ResponseDto
    {
        //登录会话失效
        public const int ACCOUNT_SESSION_EXPIRED = 101;

        public int code;
        public string msg;
    }
}