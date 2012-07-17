package now.util {
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import now.encode.Md5;

	/**
	 * 一些字符串的辅助函数
	 */
	public final class StringUtil {
		private static var counter:Number = 0;
		
		/**
		 * 首字母大写
		 */
		public static function firstUp(str:String):String{
			return str.substr(0,1).toUpperCase() + str.substr(1);
		}
		
		/**
		 * 得到一个随机字符串
		 */
		public static function randStr():String{
			var dt:Date = new Date();  
			var id1:Number = dt.getTime();  
			var id2:Number = Math.random()*1000000;  
			var id3:String = Capabilities.serverString;  
			return Md5.encrypt((id1 + id2 + counter).toString() + id3);
		}
		
		/**
		 * 得到字符长度
		 */
		public static function getByteLen(str:String, encode:String="gbk"):int{
			var ba :ByteArray = new ByteArray();
			ba.writeMultiByte(str, "gbk");
			return ba.length;
		}
	}
}