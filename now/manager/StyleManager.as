package now.manager {
	import now.base.MdlNow;

	/**
	 * 提供样式管理全局方法
	 */
	public final class StyleManager {

		/**
		 * 根据UI的类型和对应的样式key来获取样式定义信息
		 * @param	ui　	UI名称。比如Label，Button
		 * @param	key	　	样式名称，比如：color/fontSize
		 * @return	对应的样式信息。比如color的样式，返回的是对应int颜色。比如Button的up反悔的是一个DisplayObject
		 */
		public static function getStyleByName(ui:String, key:String):* {
			if (ui == ""){
				ui = "App";
			}
			var ret:* = undefined;
			if (MdlNow.skin[ui] == undefined){
				if (MdlNow.skin["App"][key] == undefined){
					return undefined;
				}
				ret = MdlNow.skin.App[key];
			} else if (MdlNow.skin[ui][key] == undefined){
				if ((ui == "RichText" || ui == "TextArea") && MdlNow.skin["Text"][key] != undefined){ //RichText和TextArea继承自Text，将继承Text的样式信息
					ret = MdlNow.skin["Text"][key];
				} else if (MdlNow.skin.App[key] != undefined){
					ret = MdlNow.skin.App[key];
				} else {
					return undefined;
				}
			} else {
				ret = MdlNow.skin[ui][key];
			}
			return ret;
		}

		public static function changeStyle():void {

		}
	}
}