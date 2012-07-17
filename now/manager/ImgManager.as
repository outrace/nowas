package now.manager {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	import now.base.BusSys;
	import now.base.MdlNow;

	/**
	 * 提供图片和swf内容相关的辅助方法
	 * 对以前的方法进行了简化，不再嵌入普通图片资源，如果需要嵌入，请放在mc中。另外mc中的嵌入资源
	 * 载入之后，立刻注册进来。以方便与phone版统一
	 */
	public final class ImgManager {
		/**
		 * 非嵌入式的图片资源缓存
		 */
		public static var imgCache:Object = {};

		/**
		 * 非嵌入式的图片资源引用计数，当计数=0，则销毁此图片缓存
		 */
		public static var imgCacheNum:Object = {};

		/**
		 * 请求的缓存
		 */
		private static var reqCache:Object = {};

		
		private static function retFun(url:String, okFun:Function):void {
			imgCacheNum[url] = imgCacheNum[url] + 1;
			var tmp:* = imgCache[url];
			if (tmp is BitmapData) {
				var bm:Bitmap = new Bitmap(imgCache[url]);
				bm.smoothing = true;
				okFun(bm);
			} else {
				var ld:Loader = new Loader();
				var ldOk:Function = function(e:*):void {
					ld.contentLoaderInfo.removeEventListener(Event.COMPLETE, ldOk);
					okFun(ld);
				};
				ld.contentLoaderInfo.addEventListener(Event.COMPLETE, ldOk);
				ld.loadBytes(tmp);
			}
		}
		
		/**
		 * 把embed的图片地址切换到资源地址
		 * @param	url
		 * @return
		 */
		private static function changeUrl(url:String):String {
			if (url.substr(0, 4) != "http") {
				if (url.substr(0, 4) == "win_") {
					url = url.substr(4);
				}
				url = url.replace("_", "/");
				return BusSys.getRes("ui/" + url + ".png");//把第一个下划线变成斜杠
			}else {
				return url;
			}
		}
		
		/**
		 * 获取image/swf信息，这些信息都是一个引用
		 * @param	url		图片路径
		 * @param	okFun	成功后的回调，回调会包含一个bitmap类型参数
		 */
		public static function getImg(url:String, okFun:Function):void {
			var embed:Boolean = (url.substr(0, 5) != "http:" && url.substr(0, 1) != ".");
			if (embed){
				var ret:* = getEmbed(url);
				if (ret != null) {
					okFun(ret);
				}else {
					getImg(changeUrl(url), okFun);
				}
				return;
			}
			var tlen:int = url.indexOf("?");
			var suf:String;
			if (tlen > -1){
				suf = url.substr(tlen-3,3);
			} else {
				suf = url.substr(-3);
			}
			var type:String = (suf == "swf") ? "swf" : "img";
			if (type == "swf" && MdlNow.platform != "pc"){
				okFun( MdlNow.res.getFlash(url.substr(0,-3)));
				return;
			}
				
			if (imgCacheNum[url] != undefined){
				retFun(url,okFun);
			} else {
				
				if (ImgManager.reqCache[url] != undefined){
					ImgManager.reqCache[url].push(okFun);
					return;
				} else {
					ImgManager.reqCache[url] = [];
				}
					
				RequestManager.getRes(url, type, function(ret:*, data:* = null):void {
						imgCache[url] = ret; //当是swf的时候，ret是一个byteArray,当是img的时候，返回的是bitmapData。存为bytearray的意义在于缩小存放体积，并且Loader不能复用
						imgCacheNum[url] = 0;
						retFun(url,okFun);
						var fun:Function;
						for each (fun in ImgManager.reqCache[url]) {
							retFun(url,fun);
						}
						delete ImgManager.reqCache[url];
					});
			}
		}

		/**
		 * 获取嵌入的swf或者图片资源
		 * @param	key		嵌入式资源的名称
		 * @return	如果是图片类型，返回一个bitmap。否则应该是一个movieclip
		 */
		public static function getEmbed(key:String):DisplayObject{
			if (imgCacheNum[key] != undefined){ //有一份cache了
				imgCacheNum[key] = imgCacheNum[key] + 1;
				var bm:Bitmap = new Bitmap(imgCache[key]);
				return bm;
			} else {//获取嵌入式的图片
				var ret:* = MdlNow.mc.getEmebed(key);
				if (ret is BitmapData){
					imgCacheNum[key] = 1;
					imgCache[key] = ret;
					return new Bitmap(imgCache[key]);
				} else {
					return ret;
				}
			}
		}

		/**
		 * 清空图片资源
		 * @param	url		图片对应的路径
		 */
		public static function mvImg(url:String):void {
			if (imgCacheNum[url] != undefined){
				imgCacheNum[url] = imgCacheNum[url] - 1;

				if (imgCacheNum[url] <= 0){
					if (imgCache[url] is BitmapData){
						(imgCache[url] as BitmapData).dispose();
					}
					imgCacheNum[url] = null;
					delete imgCacheNum[url];
					imgCache[url] = null;
					delete imgCache[url];
				}
			}
		}

	}
}