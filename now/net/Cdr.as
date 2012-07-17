package now.net {
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	/**
	 * 提供给js做一些跨域请求用的
	 */
	public final class Cdr {
		/**
		 * 当跨域请求完成后，需要调用的前端回调函数名称
		 */
		public static var callback:String = "cdr.call";

		/**
		 * 初始化一个跨域请求监听
		 * @param	asCallBack	flash提供给JS调用的方法名
		 * @param	jsCallBack	当请求完成后，回调JS的方法名
		 */
		public static function init(asCallBack:String, jsCallBack:String):void {
			Cdr.callback = jsCallBack;
			ExternalInterface.addCallback(asCallBack, Cdr.send);
		}

		/**
		 * 发送跨域请求
		 * @param	url		请求的绝对路径
		 * @param	data	请求的参数，默认是使用post请求
		 * @param	id		唯一标识一个请求的ID。JS自己确定
		 */
		public static function send(url:String, data:String, id:String):void {
			var req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.POST;
			req.data = data;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
					ExternalInterface.call(Cdr.callback, id, e.target.data);
				});
			loader.load(req);
		}
	}
}