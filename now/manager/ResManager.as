package now.manager {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import now.base.BusSys;
	import now.base.LocalShare;
	import now.base.MdlNow;
	import now.container.Alert;
	import now.encode.Json;

	/**
	 * 资源加载工具
	 */
	public final class ResManager {
		private static var urlRes:Object = {};
		private static var reqQueue:Object = { };
		
		/**
		 * 加载配置文件,语言配置和皮肤配置，我们放在框架中，其他为各游戏自己的配置信息
		 * @param		targetObj		需要将配置存放的位置
		 * @param		okFun			加载完成之后的回调
		 */
		public static function loadSet(url:String, targetObj:Class, okFun:Function,kind:String="url"):void {
			var _deal:Function = function(obj:Object):void{
				var k:String;
				for (k in obj){
					if (k == "lang" || k == "skin"){
						MdlNow[k] = obj[k];
					} else {
						targetObj[k] = obj[k];
					}
				}
				obj = null;
				okFun();
			}
			if (kind == "url"){
				RequestManager.getRes(url, "js", function(ret:Object, d:*):void {
					_deal(ret);
				});
			} else {
				var ret:Object = Json.deserialize(url);
				_deal(ret);
			}
		}

		/**
		 * 获取某个URL的资源
		 * @param		url		资源地址
		 * @param		key	链接名
		 * @param		okFun	回调函数
		 */
		public static function getUrlRes(url:String, key:String, okFun:Function):void {
			if (url == ""){
				return;
			}
			var _ok:Function = function(u:String, k:String,f:Function):void{
//				if (c is MovieClip){
//					FpsManager.setFps(c,LoaderInfo(urlRes[url]).frameRate);
//				}
				var domain:ApplicationDomain = urlRes[u].applicationDomain;
				var cls:Class = domain.getDefinition(k) as Class;
				var ret:* = new cls();
				if (ret is BitmapData){
					f(new Bitmap(ret));
				}else{
					f(ret);
				}
			}
			
			if (MdlNow.platform != "pc"){	//非Pc端，我们会把资源嵌入到一个地方
				okFun(MdlNow.res.getRes(url,key));
			} else {
				if (urlRes[url] != undefined){
					_ok(url,key,okFun);
				} else {
					if (reqQueue[url] != undefined){
						(reqQueue[url] as Array).push([key, okFun]);
						return;
					}
	
					reqQueue[url] = [];
	
					RequestManager.getRes(BusSys.getRes(url), 'loader', function(ret:*, data:* = null):void {
							urlRes[url] = ret;
							_ok(url,key,okFun);
	
							var arr:Array;
							for each (arr in reqQueue[url]){
								_ok(url,arr[0],arr[1]);
							}
							reqQueue[url] = null;
							delete reqQueue[url];
						});
				}
			}
		}
	}
}