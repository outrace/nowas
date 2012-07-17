package now.queue {
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import now.container.Container;
	import now.inter.IProgress;
	import now.manager.SoundManager;
	import now.nui.Ui;
	
	/**
	 * 一个进度条队列
	 */
	public class ProgressQue {
		private static var _queue:Object = {}; 			//{"q1":[[time,point]]
		private static var _queueSet:Object = {}; 		//{"q1":[class,container]}
		private static var _proList:Object = {}; 		//正在进行中的进度
		private static var _sleep:Object = {};			//队列是否在休眠
		private static var _allSleep:Boolean = true; 	//是否全部队列都休眠了
		private static var _interval:int = -1;
		private static var _pros:Object = { };			//进度条列表
		
		/**
		 * 配置一个队列
		 * @param	kind	名称
		 * @param	cls		类
		 * @param	con		容器
		 */
		public static function setQueue(kind:String, cls:Class, con:Ui):void {
			_queue[kind] = [];
			_queueSet[kind] = [cls,con];
			_proList[kind] = null;
			_pros[kind] = null;
			_sleep[kind] = true;
		}
		
		/**
		 * 更新进度状态
		 */
		private static function updateStatus():void {
			var pro:IProgress;
			var k:String;
			var flag:Boolean = false;
			var speed:Number;
			for (k in _proList) {
				if (_proList[k] != null) {
					flag = true;
					pro = _pros[k];
					if (pro != null) {
						Ui(pro).visible = true;
						speed = _queueSet[k][2];
						pro.value = pro.value + 1;
						if (pro.max == pro.value) {
							_proList[k]();
							_proList[k] = null;
							if (_queue[k].length == 0) {
								_sleep[k] = true;//该分类运行完
								if(Ui(pro).parentDoc!=null){//移除进度条
									Ui(pro).parentDoc.removeChild(pro);
								}
							} else {
								Ui(pro).visible = false;//设为false
								run(k);
							}
						}
					}
				}
			}
			
			if(!flag){//没有可运行的，则停止
				_allSleep = true;
				clearInterval(_interval);
				_interval = -1;
			}
		}
		
		/**
		 * 增加进度
		 * @param	kind	名称
		 * @param	max		最大值，我们每隔0.1秒运行一次。如果需要1秒完成，则传入10
		 * @param	point	显示位置
		 * @param	beforeFun 进度开始前执行的函数
		 * @param	okFun	进度完成后执行的函数
		 */
		public static function addProgress(kind:String, max:int, point:Point, beforeFun:Function, okFun:Function = null,text:String="",sound:String=""):void {
			if (_queue[kind] != undefined) {
				_queue[kind].push([max, point, beforeFun, okFun,text,sound]);
				if (_sleep[kind]){
					run(kind);
				}
			}
		}
		
		/**
		 * 取消所有进度
		 */
		public static function cancelAll():void {
			_allSleep = true;
			clearInterval(_interval);
			_interval = -1;
			var pro:IProgress;
			var k:String;
			for (k in _proList) {
				if(_proList[k]!=null){
					pro = _pros[k];
					if (pro != null) {
						if(Ui(pro).parentDoc!=null){
							Ui(pro).parentDoc.removeChild(pro);
						}
					}
					_proList[k] = null;
				}
			}
			
			for (k in _sleep) {
				_queue[k] = [];
				_sleep[k] = true;
			}
		}
		
		/**
		 * 运行某个类型的任务
		 */
		private static function run(kind:String):void {
			_sleep[kind] = false;
			var arr:Array = (_queue[kind] as Array).shift(); //最前面那一笔出队列
			if (arr[2]()) {
				var con:Ui = _queueSet[kind][1];
				var pro:IProgress;
				if (_pros[kind] != null){
					pro = _pros[kind];
					pro.setText(arr[4]);
				}else{
					var cls:Class = _queueSet[kind][0];
					pro = new cls();
					pro.setText(arr[4]);
					_pros[kind] = pro;
				}
				if(Ui(pro).parentDoc != con){
					con.addChild(Ui(pro));
				}
				
				Ui(pro).x = arr[1].x;
				Ui(pro).y = arr[1].y;
				pro.max = arr[0];
				pro.value = 0;
				Ui(pro).draw();
				
				Ui(pro).visible = true;
				_proList[kind] = arr[3];
				if (arr[5] != ""){
					SoundManager.play(arr[5]);
				}
				if (_allSleep){
					_allSleep = false;
					_interval = setInterval(updateStatus, 15);
				}
			}else {
				if (_queue[kind].length == 0) {
					_sleep[kind] = true;
				}else {
					run(kind);//把剩下的队列运行完
				}
			}
		}
	}

}