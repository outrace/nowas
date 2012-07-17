package now.event
{
	import flash.events.Event;
	
	/**
	 * 聊天相关的事件
	 */
	public class MapEvent extends Event
	{
		private var _data:* = "";
		
		public function get data():*{
			return _data;
		}
		
		public function MapEvent(type:String,data:*=null){
			if (data != null){
				_data = data;
			}
			super(type,false,false);
		}
	}
}