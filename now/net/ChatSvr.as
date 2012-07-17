package now.net {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import now.encode.Json;
	import now.event.ChatEvent;

	/**
	 * 聊天客户端
	 */
	public final class ChatSvr extends EventDispatcher {
		private var _sock:Socket;
		private var _lastStr:String = "";	//未处理得字符串
		private var _ptLen:int = 6;			//协议中，头部信息的长度
		private var _ptNum:int = 100000;	//比最大值多一位的数
		
		public var tryDis:int = 5;	//如果发生网络异常，则间隔多长时间【单位秒】进行重连。
		
		private var _host:String;
		private var _port:int;
		private var _app:String;
		private var _uid:String;
		private var _rand:String;
		private var _code:String;
		private var _group:Array;
		
		private var _interval:int = -1;
		private var _isConn:Boolean = false;	//是否已经连接
		private var _isLogin:Boolean = false;	//是否已经登录
		private var _isCodeErr:Boolean = false;	//是否连接码错误，如果是连接码错误，那么我们不再重连
		private var _isOnReconn:Boolean = false; //是否正在重连
		
		/**
		 * 构造函数
		 * @param	host	服务器地址
		 * @param	port	端口
		 * @param	app		应用名称
		 * @param	uid		玩家id
		 * @param	code	登陆码
		 * @param	group	玩家所在的群组【比如行会】
		 */
		public function ChatSvr(host:String, port:int, app:String, uid:String, 
								rand:String, code:String, group:Array){
			_host = host;
			_port = port;
			_app = app;
			_uid = uid;
			_rand = rand;
			_code = code;
			_group = group;
		}
		
		/**
		 * 连接到服务器
		 */
		public function conn():void {
			_sock = new Socket();
			_sock.addEventListener(Event.CLOSE, hdlClose);
			_sock.addEventListener(Event.CONNECT, hdlConn);
			_sock.addEventListener(IOErrorEvent.IO_ERROR, hdlErr);
			_sock.addEventListener(SecurityErrorEvent.SECURITY_ERROR, hdlErr);
			_sock.addEventListener(ProgressEvent.SOCKET_DATA, hdlData);
			_sock.connect(_host, _port);
		}
		
		/**
		 * 进行聊天
		 * @param	to	接收方，如果是空表示所有在线用户，如果以下[_]开始，表示群组，其他表示个人
		 * @param	msg	聊天消息，最大99999长度的字符串
		 */
		public function chat(to:String, msg:String):void{
			var obj:Object = {
				"cmd":"chat",
				"from":_uid,
				"to":to,
				"msg":msg
			};
			_send(obj);
		}
		
		/**
		 * 清空socket信息
		 */
		private function clearSocket():void{
			if (_sock){
				try {
					_sock.removeEventListener(Event.CLOSE, hdlClose);
					_sock.removeEventListener(Event.CONNECT, hdlConn);
					_sock.removeEventListener(IOErrorEvent.IO_ERROR, hdlErr);
					_sock.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, hdlErr);
					_sock.removeEventListener(ProgressEvent.SOCKET_DATA, hdlData);
					_sock.close();
					_sock = null;
				} catch (err:Error){
					//do nothing
				}
			}
		}
		
		/**
		 * 数据发送的方法
		 */
		private function _send(data:Object):void{
			var msg:String = Json.serialize(data);
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(msg,"utf-8");
			byte.position=0;
			var msgLen:int = byte.bytesAvailable;
			if (msgLen >= _ptNum){
				return;
			}
			msgLen = _ptNum + msgLen;
			_sock.writeUTFBytes(msgLen.toString() + msg);
			_sock.flush();
		}
		
		/**
		 * 发生了异常
		 */
		private function hdlErr(e:*):void{
			_isConn = false;
			_isLogin = false;
			clearSocket();
		}
		
		/**
		 * 连接成功的回调。在回调中，我们进行登录操作
		 */
		private function hdlConn(e:Event):void{
			_isConn = true;
			if (_isOnReconn){
				_isOnReconn = false;
				clearInterval(_interval);
				_interval = -1;
			}
			//进行登录
			var obj:Object = {
				"cmd":"login",
				"uid":_uid,
				"app":_app,
				"rand":_rand,
				"code":_code,
				"group":_group
			};
			_send(obj);
		}
		
		/**
		 * 处理关闭
		 */
		private function hdlClose(e:Event):void{
			clearSocket();			
			if (_isConn && !_isCodeErr){//说明是客户端的网络异常引起的断线
				_interval = setInterval(reConn, tryDis*1000);//每隔一定时间进行一次重连，直到连接成功
				_isOnReconn = true;
			}
			_isConn = false;
			_isLogin = false;
		}
		
		/**
		 * 进行重新连接
		 */
		private function reConn():void{
			conn();
		}
		
		/**
		 * 处理消息接收
		 */
		private function hdlData(e:*):void{
			var maxLen:Number = _sock.bytesAvailable;
			_lastStr = _lastStr + _sock.readUTFBytes(maxLen);
			
			//数据量太少，直接返回
			var strLen:int = _lastStr.length;
			if (strLen < _ptLen){
				return;
			}
			
			var msgLen:int;
			var msg:Object;
			while(true){
				msgLen = int(_lastStr.substr(1,5));
				//消息实体不全，直接返回
				if (strLen - _ptLen < msgLen){
					break;
				}
				msg = Json.deserialize(_lastStr.substr(_ptLen, msgLen));
				if (msg['cmd'] == "login"){//登录处理
					if (msg["ret"] == "y"){
						_isCodeErr = false;
						_isLogin = true;
						dispatchEvent(new ChatEvent(ChatEvent.CHAT_LOGIN));
					} else {
						_isCodeErr = true;
						_isLogin = false;
						_sock.close();
					}
				} else if(msg["cmd"] == "chat") {//来了聊天消息
					dispatchEvent(new ChatEvent(ChatEvent.CHAT_DATA,msg));
				}
				
				//移动到下一笔数据
				_lastStr = _lastStr.substr(msgLen + _ptLen);
				strLen = _lastStr.length;
			}
		}
	}
}