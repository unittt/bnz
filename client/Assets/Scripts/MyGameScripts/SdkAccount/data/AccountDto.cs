using System.Collections.Generic;

namespace SdkAccountDto
{
    public class LoginSessionDto
    {
        //充值相关
        //游戏名字
        public string name;
        //游戏币名字
        public string currencyName;
        //1元兑换游戏币数量
        public float currencyRate;

        /** 是否实名认证*/
        public bool realNameAuthed;

        //登录会话ID.
        public string sid;
        public string uid;
        public string nickname;
        public string accountId;
        public string accountName;
        //账号会话加密信息，用于快速登录选择的账号
        public string accountSession;
        public bool accountBound;
    }


    public class LoginResponseDto: ResponseDto
    {
        public LoginSessionDto item;
    }

    //客户端使用
    public class AccountDto
    {
        //0自由；1手机；2邮箱；3设备；4QQ登录；5微信登录
        public enum AccountType
        {
            free,
            phone,//自平台（手机）
            mail,
            device,//设备号
            qq,
            weixin,
        }
        //AccountType
        public AccountType type;

        private string _name;
        public string name {
            get
            {
                if (!string.IsNullOrEmpty(_name)) return _name;

                if (loginSeesionDto == null)
                {
                    return "null";
                }

                if (type == AccountType.qq)
                {
                    return loginSeesionDto.nickname;
                }
                return loginSeesionDto.accountName;
            }
            set { _name = value;}
        }

        private string _uid;
        public string UID
        {
            get
            {
                if (!string.IsNullOrEmpty(_uid)) return _uid;

                return loginSeesionDto.uid;
            }
            set { _uid = value; }
        }

        private string _sid;
        public string Sid
        {
            get
            {
                if (!string.IsNullOrEmpty(_sid)) return _sid;

                return loginSeesionDto.sid;
            }
            set { _sid = value; }
        }

        private string _accountSeesion;

        //保持账号密码登录，seesion参数已废弃，这里只是为了兼容旧用户数据保留文件的读写使用
        public string AccountSeesion
        {
            get
            {
                if (!string.IsNullOrEmpty(_accountSeesion))
                    return _accountSeesion;

                if (loginSeesionDto != null)
                {
                    return loginSeesionDto.accountSession;
                }

                return "";
            }
            set { _accountSeesion = value; }
        }

        public LoginSessionDto loginSeesionDto;

        public AccountDto() { }

        public AccountDto(LoginResponseDto dto)
        {
            this.loginSeesionDto = dto.item;
        }
    }
}
