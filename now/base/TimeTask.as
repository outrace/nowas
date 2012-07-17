package now.base {
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * 一些定时任务，
	 */
	public final class TimeTask {
		public static var TASK_PER_1:int = 1; //每隔1秒执行一次
		public static var TASK_PER_60:int = 60; //每隔1分执行一次
		public static var TASK_PER_300:int = 300; //每隔5分执行一次

		private static var _begin:Boolean = false;
		private static var _taskNum:int = 0;

		private static var _second:int = 0; //内部秒计数
		private static var _minute:int = 0; //内部分钟技术
		private static var _id:int = 0; //setInterval 的id

		private static var _task1:Object = {}
		private static var _task60:Object = {}
		private static var _task300:Object = {}

		/**
		 * 新增一个任务
		 */
		public static function addTask(type:int, key:String, fun:Function, repeat:int = 0):void {
			try {
				if (type == 1){
					_task1[key] = [fun, repeat, 0]; //函数，重复次数，第几次
					_taskNum++;
					begin();
				} else if (type == 60){
					_task60[key] = [fun, repeat, 0]; //函数，重复次数，第几次
					_taskNum++;
					begin();
				} else if (type == 300){
					_task300[key] = [fun, repeat, 0]; //函数，重复次数，第几次
					_taskNum++;
					begin();
				}
			} catch (err:Error){
				trace("TimeTask.addTask error:" + err.message);
			}
		}

		/**
		 * 删除一个任务
		 */
		public static function delTask(type:int, key:String):void {
			try {
				if (type == 1 && key in _task1){
					delete _task1[key];
					_taskNum--;
				} else if (type == 60 && key in _task60){
					delete _task60[key];
					_taskNum--;
				} else if (type == 300 && key in _task300){
					delete _task300[key];
					_taskNum--;
				}
				if (_taskNum == 0){
					end();
				}
			} catch (err:Error){
				trace("TimeTask.delTask error:" + err.message);
			}
		}

		/**
		 * 执行任务
		 */
		private static function doTask():void {
			try {
				//加秒
				//处理每秒执行一次的任务
				var rmkey:Array = []; //需要删除的key
				var k:String = "";
				var rk:String = "";
				
				_second = _second + 1;
				if (_second == 61){
					_second = 0;
					
					//处理每分钟执行一次的任务
					for (k in _task60){
						if (_task60[k][1] > 0){ //有执行次数
							_task60[k][2] = _task60[k][2] + 1; //执行次数+1
							if (_task60[k][1] <= _task60[k][2]){
								rmkey.push(k);
							}
						}
						_task60[k][0](_task60[k][2]);
					}
					for each(rk in rmkey){
						delete _task60[rk];
						_taskNum--;
					}
					rmkey = [];
					
					_minute = _minute + 1;
					if (_minute == 6){
						_minute = 0;
						
						//处理每5分执行一次的任务
						for (k in _task300){
							if (_task300[k][1] > 0){ //有执行次数
								_task300[k][2] = _task300[k][2] + 1; //执行次数+1
								if (_task300[k][1] <= _task300[k][2]){
									rmkey.push(k);
								}
							}
							_task300[k][0](_task300[k][2]);
						}
						for each(rk in rmkey){
							delete _task300[rk];
							_taskNum--;
						}
						rmkey = [];
					}
				}

				//处理每秒执行一次的任务
				for (k in _task1) {
					if (_task1[k][1] > 0){ //有执行次数
						_task1[k][2] = _task1[k][2] + 1; //执行次数+1
						if (_task1[k][1] <= _task1[k][2]){
							rmkey.push(k);
						}
					}
					//trace(k);
					_task1[k][0](_task1[k][2]);
				}
				for each(rk in rmkey){
					delete _task1[rk];
					_taskNum--;
				}
				rmkey = [];


			} catch (err:Error){
				trace("TimeTask.doTask error:" + err.message);
			}
		}


		/**
		 * 开始运行TimeTask
		 */
		private static function begin():void {
			if (_begin){ //已经启动了
				return;
			}
			if (_taskNum == 0){ //没有任务，不开始
				return;
			}
			_begin = true;
			_id = setInterval(doTask, 1000);
		}

		/**
		 * 结束定时任务
		 */
		private static function end():void {
			_second = 0;
			_minute = 0;
			if (_begin && _taskNum > 0 && _id != 0){
				try {
					clearInterval(_id);
				} catch (err:Error){
					trace("TimeTask.end error:" + err.getStackTrace());
				}
			}
		}
	}
}