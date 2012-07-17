package now.nui {
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * 一些UI常量
	 */
	public class UiConst {
		public static const DRAW:String = "draw"; //绘制界面事件的名称
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const CENTER:String = "center";
		
		public static const TOP:String = "top";
		public static const MIDDLE:String = "middle";
		public static const BOTTOM:String = "bottom";
		
		public static const ABSOLUTE:String = "a"; //绝对值定位
		public static const HORIZONTAL:String = "h"; //水平定位
		public static const VERTICAL:String = "v"; //垂直定位
		
		public static const DATA_ADD:String = "add"; //数据增加
		public static const DATA_MDF:String = "mdf"; //数据更新
		public static const DATA_DEL:String = "del"; //数据移除
		
		public static var SOUND_BTN:String = "btn";			//按钮的点击声音
		public static var SOUND_PAGE:String = "page";		//翻页的点击声音
		public static var SOUND_TAB:String = "tab";			//切换tab页的点击声音
		
		/**
		 * 灰色半透明滤镜
		 */
		public static const grayAlphaFilter:ColorMatrixFilter = new ColorMatrixFilter([.33, .33, .33, 0, 0, .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, 0, 0, 0, .5, 0]);
		
		/**
		 * 灰色滤镜，用于disable
		 */
		public static const disableFilter:ColorMatrixFilter = new ColorMatrixFilter([.33, .33, .33, 0, 0, .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, 0, 0, 0, 1, 0]);
		/**
		 * 发光滤镜，用于mouse over
		 */
		public static const hoverFilter:GlowFilter = new GlowFilter(0xe8f600, 0.7, 6, 6, 10);
	}
}