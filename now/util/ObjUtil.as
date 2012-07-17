package now.util {
	
	/**
	 * 一些对象的辅助函数
	 */
	public final class ObjUtil {
		
		/**
		 * 获取对象的key数量
		 */
		public static function getLen(obj:Object):int{
			var ret:int = 0;
			var k:*;
			for (k in obj){
				ret = ret +1;
			}
			return ret;
		}
	}
}