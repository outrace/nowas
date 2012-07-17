package now.manager {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import now.base.BusSys;
	import now.nui.ImgLoader;
	import now.encode.Json;
	
	/**
	 * 提供一个统一的方法进行远程资源的获取
	 */
	public final class RequestManager {
		private static var queueSize:int = 8; //并发连接数
		private static var errHdl:Function = null; //网络异常处理函数
		private static var resCache:Object = {}; //资源缓存列表
		private static var nowSize:int = 1;
		private static var urlQueue:Array = [];
		
		/**
		 * 初始化请求管理器
		 * @param	queueSize	队列大小
		 * @param	errHdl		网络异常的处理函数,回调时候会传入一个url
		 */
		public static function init(queueSize:int = 6, errHdl:Function = null):void {
			RequestManager.queueSize = queueSize;
			RequestManager.errHdl = errHdl;
		}
		
		/**
		 * 获取资源
		 * @param 	url		资源地址
		 * @param	type	资源类型，支持：swf/loader/img/amf/js/html
		 * @param	okFun	成功后的回调。参数为img=bitmapdata swf=contentLoaderInfo loader=loader amf=object,js=object html=string
		 * @param	data	附加的数据，会跟随回调一起返回。
		 */
		public static function getRes(url:String, type:String, okFun:Function, data:* = null):void {
			var tmp:Array;
			if (RequestManager.resCache[url] is Array){ //已经有一个进程正在加载了，等待该进程结束后，直接返回
				(RequestManager.resCache[url] as Array).push([okFun, data]);
			} else if (nowSize > queueSize){ //如果当前请求的队列超过了排队数，我们等待
				RequestManager.urlQueue.push([url, type, okFun, data]);
			} else { //否则，我们开始请求
				RequestManager.resCache[url] = [];
				nowSize = nowSize + 1;
				var error:Function = function(e:*):void {
					if (errHdl != null){
						errHdl(url);
					} else {
						trace("error to load:" + url);
					}
				}
				var ok:Function = function(e:*):void {
					var retContent:*;
					if (type == "swf" || type == "loader" || type=="img"){
						imgloader.removeEventListener(Event.COMPLETE, ok);
						imgloader.removeEventListener(IOErrorEvent.IO_ERROR, error);
						imgloader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
						
						if (type == "img") {
							retContent = new BitmapData(imgloader.width, imgloader.height,true, 0x00ffffff);
							retContent.draw(imgloader);
							(imgloader as Object).unloadAndStop();
						} else if (type == "swf"){
							retContent = imgloader.contentLoaderInfo.bytes;
							(imgloader as Object).unloadAndStop();
						} else { //反回定义
							retContent = imgloader.contentLoaderInfo;
						}
						imgloader = null;
					}   else {
						urlLoader.removeEventListener(Event.COMPLETE, ok);
						urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, error);
						urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, error); 
						
						if (type == "amf"){
							retContent = ByteArray(e.target.data).readObject();
						} else if (type == "js"){
							retContent = Json.deserialize(e.target.data);
						} else {
							retContent = e.target.data;
						}
						urlLoader = null;
					}
					okFun(retContent, data);
					for each (tmp in RequestManager.resCache[url]){
						tmp[0](retContent, tmp[1]);
					}
					RequestManager.resCache[url] = null;
					delete RequestManager.resCache[url];
					var next:Array = RequestManager.urlQueue.shift();
					nowSize = nowSize - 1;
					if (next){
						RequestManager.getRes(next[0], next[1], next[2], next[3]);
					}
				}
				
				var req:URLRequest = new URLRequest(url);
				var imgloader:Loader;
				var urlLoader:URLLoader;
				req.method = URLRequestMethod.GET;
				if (type == "swf" || type == "loader" || type == "img") {
					//var context:LoaderContext = new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain));
					imgloader = new ImgLoader();
					imgloader.addEventListener(Event.COMPLETE, ok);
					imgloader.addEventListener(IOErrorEvent.IO_ERROR, error);
					imgloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
					imgloader.load(req);
				} else {
					urlLoader = new URLLoader();
					if (type == "amf"){
						urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					}
					urlLoader.addEventListener(Event.COMPLETE, ok);
					urlLoader.addEventListener(IOErrorEvent.IO_ERROR, error);
					urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
					urlLoader.load(req);
				}
			}
		}
	}
}