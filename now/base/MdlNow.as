package now.base {
	
	import now.bind.ObjProxy;
	import now.container.Container;

	/**
	 * 每个游戏必须用到的基础数据模型
	 */
	public final class MdlNow {	
		
		/**
		 * 游戏主容器
		 */
		public static var main:Container;
		
		/**
		 * flash类型的资源，在pc版不需要嵌入，phone和pad版需要嵌入
		 */
		public static var res:Object;
		
		/**
		 * mc类型的嵌入式资源
		 */
		public static var mc:Object;
		
		/**
		 * 当前时间
		 */
		public static var now:int = 0;
		
		/**
		 * 语言文件
		 */
		public static var lang:Object;
		
		public static var sound:Object = {
			"btn":"",
			"page":"",
			"tab":""
		};
		
		/**
		 * 游戏基本配置,包含以下key
		 * <ul>
		 * <li>v：主游戏版本号</li>
		 * <li>pv：图片资源版本号</li>
		 * <li>ver:版本类型，""=子测试版本,dev=开发版本，test1=内网测试,test2=外网测试,pro=正式</li>
		 * <li>game：游戏名称</li>
		 * <li>site:站点名称，也是平台名称</li>
		 * <li>game_url:游戏服务器url</li>
		 * <li>img_url:图片服务器url</li>
		 * </ul>
		 */
		public static var para:Object;

		/**
		 * 皮肤信息
		 */
		public static var skin:Object;
		
		
		/**
		 * 是否把资源写入shareobject
		 */ 
		public static var ifWriteShareObject:Boolean = true;
		
		/**
		 * 平台类型，分为pc phone pad
		 */ 
		public static var platform:String = "pc";
		
		public static var screen:String = "960";//屏幕类型
	}
}