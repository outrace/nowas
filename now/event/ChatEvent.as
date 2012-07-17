package now.event {
	import flash.events.Event;
	
	/**
	 * 聊天相关的事件
	 */
	public class ChatEvent extends Event {
		public static const CHAT_DATA:String = "chat_data";		//来聊天消息了
		public static const CHAT_CLOSE:String = "chat_close";	//断线了
		public static const CHAT_LOGIN:String = "chat_login";	//连上了
		
		private var _data:* = "";
		
		public function get data():*{
			return _data;
		}
		
		public function ChatEvent(type:String,data:*=null){
			if (data != null){
				_data = data;
			}
			super(type,false,false);
		}
	}
}