package now.util  {
	import now.base.MdlNow;
	import now.base.TimeTask;
	import now.util.BindUtil;
	
	/**
	 * 计算剩余时间
	 * @author z
	 */
	public final class RestTime {
		private static var _task:Array = new Array();
		private static var _init:Boolean = false;
		/**
		 * @param	类型    支持一种类型一个计数
		 * @param	pertime 每格多少秒重新计数
		 * @param	zeroFun 回调方法，参数（时：分：秒）
		 */
		public static function add(kind:String, pertime:int, initime:int, zeroFun:Function):void {
			if(!RestTime.find(kind)){
				_task.push([kind, pertime, zeroFun, initime]);
			}
			if (!_init) {
				TimeTask.addTask(TimeTask.TASK_PER_1, "task_rest_time", function():void {
					var item:Array;
					var fun:Function;
					var t:int;
					var len:int = _task.length;
					if (len == 0) {
						TimeTask.delTask(TimeTask.TASK_PER_1, "task_rest_time");
						_init = false;
						return;
					}
					for (var i:int = 0; i < len; i++) {
						item = _task[i];
						pertime = item[1];
						fun = item[2];
						t = item[3];
						fun(t);
						t = t-1<0?pertime:t-1;
						item[3] = t;
					}
				});
				_init = true;
			}
		}
		
		private static function find(kind:String):Boolean {
			var item:Array;
			var len:int = _task.length;
			for (var i:int = 0; i < len; i++) {
				item = _task[i];
				if (item[0] == kind) {
					return true;
				}
			}
			return false;
		}
		
		public static function del(kind:String):void {
			var item:Array;
			var len:int = _task.length;
			for (var i:int = 0; i < len; i++) {
				item = _task[i];
				if (item[0] == kind) {
					_task.splice(i, 1);
					break;
				}
			}
		}
	}
}