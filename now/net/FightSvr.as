package now.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import now.encode.Json;
	import now.event.ChatEvent;

	/**
	 * 战斗socket客户端
	 */
	public class FightSvr extends EventDispatcher {
		
		private var _socket:Socket;	//socket资源
		private var _rand:String;		//登录时候验证code的那个随机数
		private var _code:String;		//登录的code
		private var _host:String;		//socket 服务器的ip地址
		private var _port:int;			//socket 服务器的端口号
		private var _uid:String;		//登录ID
		
		private var _timer:Timer;
		public static var trytimes:Number = 2;//失败后的尝试次数
		
		public static var begin:Boolean = false;//是否已经开启连接
		
		/**
		 * 构造函数
		 * host = 聊天服务器的ip地址
		 * port = 聊天服务器的端口号
		 * uid = 玩家ID
		 * code = 登录码
		 */
		public function FightSvr(host:String,
								port:int,
								uid:String,
								code:String){
			_host = host;
			_port = port;
			_uid = uid;
			var tmp:Array = code.split(" ");
			_rand = tmp[0];
			_code = tmp[1];
		}
		
		
		/**
		 * 连接到聊天服务器
		 */
		public function login():void{
			_socket = new Socket(_host,_port);
			_socket.addEventListener(Event.CLOSE, closeHandler);
			_socket.addEventListener(Event.CONNECT, connectHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, errHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		/**
		 * 发送消息
		 * uids = 如果是字符类型，则是全服广播，否则是对应接收玩家ID数组
		 * msg = 发送的内容
		 */
		public function sendMsg(uids:*, msg:String):void{
			if (!begin){
				return;
			}
			var type:String = uids is Array?"?":"*";//类型个，如果是空，则表示广播
			var data:Array = ["c",type,uids,msg];//发送的数据内容
			_send(data);
		}
		
		/**
		 * 数据发送的方法
		 */
		private function _send(data:Array):void{
			var msgdata:String = Json.serialize(data);
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(msgdata,"utf-8");
			byte.position=0;
			var tmp:String = "00000"+byte.bytesAvailable.toString();
			var msglen:String = tmp.substring(tmp.length - 5);//消息长度
			_socket.writeUTFBytes(msglen+msgdata);
			_socket.flush();
		}
		
		/**
		 * socket连接关闭了
		 */
		private function closeHandler(e:Event):void{
			clearSocket();
			if (begin){//说明是客户端断开了连接,我们进行重连
				_timer = new Timer(5000,trytimes);//每隔5秒重连一次
				_timer.addEventListener(TimerEvent.TIMER,checkConn);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE,checkEnd);
				_timer.start();
			}
			begin = false;
		}
		
		/**
		 * 开始重新连接
		 */
		private function checkConn(e:TimerEvent):void{
			if (!begin){
				login();
			}
		}
		
		/**
		 * 完成检查后清空资源
		 */
		private function checkEnd(e:TimerEvent=null):void{
			if (_timer!=null){
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER,checkConn);
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,checkEnd);
				_timer = null;
			}
		}
		
		/**
		 * 清空socket信息
		 */
		private function clearSocket():void{
			try {
				_socket.removeEventListener(Event.CLOSE, closeHandler);
				_socket.removeEventListener(Event.CONNECT, connectHandler);
				_socket.removeEventListener(IOErrorEvent.IO_ERROR, errHandler);
				_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errHandler);
				_socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
				_socket.close();
				_socket = null;
			} catch (err:Error){
				//do nothing
			}
		}
		
		/**
		 * 进行错误处理
		 */
		private function errHandler(e:*):void{
			clearSocket();
		}
		
		/**
		 * socket来消息了
		 */
		private function socketDataHandler(e:*):void{
			var maxLen:Number = _socket.bytesAvailable;
			var nowLen:Number = 0;
			while (maxLen > nowLen){
				var tmp:String = _socket.readUTFBytes(5);
				trace(tmp);
				var msglen:int = int(tmp);
				nowLen  = nowLen + msglen + 5;
				var msgstr:String = _socket.readUTFBytes(msglen);
				trace(msgstr);
				var msg:Array = Json.deserialize(msgstr);
				if (msg[0] == "e"){//说明是异常
					//发生异常后，我们关闭客户端连接
					clearSocket();
					dispatchEvent(new ChatEvent(ChatEvent.CHAT_DATA,msg[1]));
				} else {//说明来信息了
					dispatchEvent(new ChatEvent(ChatEvent.CHAT_DATA,msg));
				}
			}
		}
		
		/**
		 * 成功建立连接后
		 */
		private function connectHandler(e:Event):void{
			checkEnd();
			var data:Array = ["c","@",_uid,_rand,_code];//发送的数据内容
			_send(data);
			begin = true;
		}
	}
}