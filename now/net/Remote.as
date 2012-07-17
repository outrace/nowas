package now.net {
	import flash.errors.IOError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import now.base.Model;
	import now.encode.Crc32;
	import now.encode.Json;
	import now.event.UiEvent;

	/**
	 * 远程服务器端业务请求
	 */
	public final class Remote {
		/**
		 * 连接地址
		 */
		public static var proxy:String = "./";

		/**
		 * 后缀
		 */
		public static var suf:String = "";

		/**
		 * 默认每次发送都会发送的数据
		 */
		public static var defData:Object = {};

		/**
		 * 发送前执行的函数，传入的参数是(uri,data)
		 */
		public static var beforeSendHdl:Function = null;
		
		/**
		 * 执行成功后,传入参数为（uri,ret)
		 */
		public static var afterOkHdl:Function = null;

		/**
		 * 一些特殊返回值的处理
		 */
		protected static var _codeHandle:Object = {};


		/**
		 * 设置一些特殊返回值的对应处理函数
		 * 当返回对应的code的时候。就直接以此函数处理
		 *
		 * 比如错误码是F开头的几个错误码，我们需要刷新前台界面
		 */
		public static function setCodeHandle(code:String, hdl:Function):void {
			_codeHandle[code] = hdl;
		}

		/**
		 * 进行发送数据准备
		 * @param	uri		String		请求路径
		 * @param	obj		Object		发送的数据信息
		 */
		private static function _prepare(uri:String, obj:Object):void {
			for (var k:String in Remote.defData){
				obj[k] = Remote.defData[k];
			}
			if (Remote.beforeSendHdl != null){
				Remote.beforeSendHdl(uri, obj);
			}
		}

		/**
		 * 发送消息
		 * @param uri    请求路径。一般是：app/module/method(.do)
		 * @param obj    发送到后台的对象信息
		 * @param okFun  后台执行成功后的执行函数
		 * @param errFun 后台执行失败后的执行函数，如果不给，那么默认是弹出一个窗口
		 * @param mask	  是否显示遮罩
		 */
		public static function json(uri:String, obj:Object, okFun:Function, errFun:Function):void {
			Remote._prepare(uri, obj);
			var data:String = Json.serialize(obj);
			trace("send data "+data +" to url="+Remote.proxy + uri + Remote.suf);
			var req:URLRequest = new URLRequest(Remote.proxy + uri + Remote.suf);
			
			//增加一个数据签名
			var random:String = new Date().getTime().toString(16);
			var header1:URLRequestHeader = new URLRequestHeader("nowr", random);
			var header2:URLRequestHeader = new URLRequestHeader("nowk", uint(Crc32.encode(data+random)).toString());
			var loader:URLLoader = new URLLoader();

			var _errFun:Function = function(e:* = null):void { //发生网络异常。在这里执行
				errFun({}, "net");
			}

			var _retFun:Function = function(e:*):void {
				trace("get data="+e.target.data);
//				try {
					var ret:Object = Json.deserialize(e.target.data);
					if (ret["_c"] == undefined ||  ret["_c"]  == ""){
						if (Remote.afterOkHdl != null){
							Remote.afterOkHdl(uri, ret);
						}
						okFun(ret);
					} else {
						if (ret.Code in _codeHandle){
							_codeHandle[ret["_c"]](ret);
						}
						errFun(ret, "ret");
					}
//				} catch (err:Error){
					//flash代码异常或者json返回异常
					//trace(err.message,e.target.data);
//					Model.instance().dispatchEvent(new UiEvent(UiEvent.SYS_ERROR));
//				}
			}

			req.method = URLRequestMethod.POST;
			req.data = data;
			req.requestHeaders.push(header1);
			req.requestHeaders.push(header2);

			loader.addEventListener(Event.COMPLETE, _retFun);
			loader.addEventListener(IOErrorEvent.IO_ERROR, _errFun);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _errFun);
			loader.load(req);
		}

	}
}