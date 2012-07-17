package now.util {
	import flash.net.LocalConnection;

	/**
	 * 强制gc
	 */
	public final class GcUtil {
		public static function GC():void {
			try {
				new LocalConnection().connect("foo");
				new LocalConnection().connect("foo");
			} catch (error:Error){
				//trace("GC OK!");
			}
		}
	}
}