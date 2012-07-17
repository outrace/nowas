package now.base {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import now.event.UiEvent;
	import now.net.Remote;

	/**
	 * 一个队列任务，提供顺序执行后台请求的方法
	 */
	public final class Qsvr {
		/**
		 * 队列是否在休眠
		 */
		private static var _sleep:Boolean = true;

		/**
		 * 队列列表
		 */
		private static var _taskList:Array = new Array();

		/**
		 * 发生网络异常时候的处理方式
		 */
		private static var _netErrHdl:Function = function():void {
		};

		/**
		 * 发生网络异常时候的处理方式
		 */
		private static var _netOkHdl:Function = function():void {
		};

		/**
		 * 默认的错误处理函数
		 */
		private static var _defErrHdl:Function = function(ret:*):void {
		};

		/**
		 * 网络异常后，我们重连的间隔事件，单位毫秒
		 */
		private static var _netTryStep:Number = 1500;

		/**
		 * 当前是否正在进行重连
		 */
		private static var _onTry:Boolean = false;

		/**
		 * 进行重连的一个计时器
		 */
		private static var _tryTimer:Timer = null;

		/**
		 * 初始化队列信息
		 * @param	tryStep			重连的间隔事件
		 * @param	netErrHdl		发生网络异常时候的处理函数
		 * @param	netOkHdl		网络恢复正常时候的处理函数
		 * @param	defErrHdl		默认的错误处理函数
		 */
		public static function initQueue(tryStep:Number = 1200, netErrHdl:Function = null, netOkHdl:Function = null, defErrHdl:Function = null):void {
			_netTryStep = tryStep;
			if (netErrHdl != null){
				_netErrHdl = netErrHdl;
			}
			if (netOkHdl != null){
				_netOkHdl = netOkHdl;
			}
			if (defErrHdl != null){
				_defErrHdl = defErrHdl;
			}
		}


		/**
		 * 新增一个任务进入队列
		 * @param	uri		路径
		 * @param	obj		参数内容
		 * @param	okFun	执行成功后的回调。回调函数，包含一个参数：后端返回的结果，Object类型
		 * @param	errFun	后台返回异常时候的处理函数
		 * @param	mask	是否需要一个遮罩
		 */
		public static function add(uri:String, obj:Object, okFun:Function = null, errFun:Function = null, mask:Boolean = false):void {
			_taskList.push([uri, obj, okFun, errFun, mask]);
			if (_sleep){
				_sleep = false;
				begin();
			}
		}


		/**
		 * 先执行流程，然后执行下一个任务
		 * @param	type	类型
		 * @param	obj		参数对象
		 */
		private static function doTask(type:String, obj:*):void {
			var dic:Object = {"error": 3, "ok": 2}
			if (_taskList[0][dic[type]] != null){ //根据队列中的okFun和errFun进行流程处理
				//				try{
				_taskList[0][dic[type]](obj);
					//				} catch (err:Error){
					//				}
			} else {
				if (type == "error"){ //未定义errFun
					_defErrHdl(obj);
				} else { //未定义okFun

				}
			}
			_taskList.shift();
			if (_taskList.length > 0){
				begin(); //继续执行下一个任务
			} else {
				_sleep = true;
			}
		}

		/**
		 * 执行错误处理流程
		 * @param	obj		返回的结果
		 * @param	type	错误类型net=网络异常，不然就是逻辑异常
		 */
		private static function errFun(obj:*, type:String):void {
			if (type == "net"){
				if (_onTry){
					return;
				}
				_netErrHdl();
				_tryTimer = new Timer(_netTryStep);
				_tryTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
						_onTry = true;
					//begin();
					});
				_tryTimer.start();
			} else {
				if (_onTry){
					_netOkHdl();
					_onTry = false;
					_tryTimer.stop();
					_tryTimer = null;
				}
				if (obj["_c"] == "900"){//session错误
					Model.instance().dispatchEvent(new UiEvent(UiEvent.SYS_SESSION));
				} else { //否则，我们处理异常
					doTask("error", obj);
				}
			}
		}

		/**
		 * 执行返回函数
		 * 执行结束之后。如果有新的任务进来了，则继续执行，否则结束
		 */
		private static function retFun(obj:*):void {
			if (_onTry){
				_netOkHdl();
				_onTry = false;
				_tryTimer.stop();
				_tryTimer = null;
			}
			if (obj["_v"] != undefined && MdlNow.para["v"] != undefined){
				var tmp:String = obj["_v"].toString();
				if (MdlNow.para["v"] == undefined){
					MdlNow.para["v"] = tmp;
				} else if (tmp != MdlNow.para["v"]) {
					Model.instance().dispatchEvent(new UiEvent(UiEvent.SYS_VERSION));
				}
			}
			doTask("ok", obj);
		}

		/**
		 * 开始执行一个任务
		 */
		private static function begin():void {
			var obj:* = _taskList[0]; //uri,obj,okFun,errFun,mask
			Remote.json(obj[0], obj[1], retFun, errFun);
		}
	}
}