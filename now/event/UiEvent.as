package now.event {
	import flash.events.Event;

	/**
	 * 界面相关的事件
	 */
	public class UiEvent extends Event {
		/**
		 * 样式变更
		 */
		public static const CHANGE_STYLE:String = "change_style";
		/**
		 * 分页变更
		 */
		public static const CHANGE_PAGE:String = "change_page";

		/**
		 * 绑定的ObjProxy的值有变动
		 */
		public static const BIND_VAL_MDF:String = "bind_val_mdf";
		/**
		 * Collection增加了新的项目
		 */
		public static const BIND_ITEM_ADD:String = "bind_item_add";
		/**
		 * Collection删除了一个项目
		 */
		public static const BIND_ITEM_DEL:String = "bind_item_del";
		/**
		 * Collection数据清空
		 */
		public static const BIND_ITEM_CLEAR:String = "bind_item_clear";
		
		/**
		 * Collection重新进行了排序
		 */
		public static const BIND_ITEM_SORT:String = "bind_item_sort";
		
		/**
		 * TAB页被点击
		 */
		public static const TAB_NAV_CLICK:String = "tab_nav_click";
		
		
		/**
		 * 网络异常
		 */
		public static const SYS_ERROR:String = "sys_error";
		
		/**
		 * 新版本发布
		 */
		public static const SYS_VERSION:String = "sys_version";
		
		/**
		 * SESSION错误
		 */
		public static const SYS_SESSION:String = "sys_session";
				
		///**
		 //* 行走小人进行短暂停留
		 //*/
		//public static const WALK_STOP:String = "walk_stop";
		//
		///**
		 //* 行走小人被点击
		 //*/
		//public static const WALK_CLICK:String = "walk_click";
		//
		///**
		 //* 行走小人消失
		 //*/
		//public static const WALK_DISAPEAR:String = "walk_disapear";
		
		///**
		 //* 行走小人被鼠标覆盖
		 //*/
		//public static const WALK_OVER:String = "walk_over";
		//
		///**
		 //* 行走小人鼠标离开
		 //*/
		//public static const WALK_OUT:String = "walk_out";

		private var _data:* = "";
		private var _type:String = "";
		
		public function set data(data:*):void {
			_data = data;
		}

		public function get data():* {
			return _data;
		}

		public function UiEvent(type:String, data:* = null){
			if (data != null){
				_data = data;
			}
			_type = type;
			super(type, false, false);
		}
	}
}