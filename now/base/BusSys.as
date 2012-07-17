package now.base {

	/**
	 * 系统相关的商业逻辑
	 */
	public final class BusSys {
		
		/**
		 * 获取资源配置
		 * @param	key		资源的key
		 */
		public static function getRes(key:String):String {
			if (MdlNow.platform == "pc"){
				return MdlNow.para["img_url"] + key + "?v=" + MdlNow.para["pv"];
			} else {
				return "./res/"+MdlNow.screen+"/"+key;
			}
		}
		
		/**
		 * 获取语言信息
		 * @param	key		语言的key
		 * @param	para	语言的参数
		 */
		public static function getLang(key:String,para:Object=null):String {
			var lang:String = "";
			var k:String;
			if (MdlNow.lang[key] != undefined){
				lang = MdlNow.lang[key];
				if (para != null){
					for (k in para){
						lang = lang.replace("{"+k+"}",para[k].toString());
					}
				}
			}
			return lang;
		}
	}
}