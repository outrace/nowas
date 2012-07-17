package now.manager {
	import flash.display.DisplayObject;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import now.base.Model;
	import now.container.Container;
	import now.event.UiEvent;
	import now.nui.Walk;
	
	/**
	 * 走动的npc的容器
	 */
	public class WalkManager {
		private static var _interval:int = -1;		//定时器
		private static var _bnum:int = 6;				//缓存的对象的数量
		private static var _nowNum:int = 0;			//当前使用中的walk对象数量
		private static var _con:Container;			//行走的对象所在的容器
		
		private static var _clickAble:Boolean = false;	//行走小人是否可点击
		private static var _stopNum:int = -1;				//小人停留几帧,-1表示不会停留，会一直走
		
		private static var _walkArr:Array = new Array();
		
		public static var INTERVAL_TIME:int = 180;	//每隔多少毫秒，执行一次帧数更新
		public static var distance:int = 4;			//每次行走，小人移动的距离
		public static var stopRate:int = 4;			//停顿的千分概率，每次行走，我们只选择一个小人进行停顿
//		public static var walkFunc:Function;			//每行走一步要做的事项
		
		/**
		 * 返回walk数组
		 * @return
		 */
		public static function getWalkArr():Array {
			return _walkArr;
		}
		
		/**
		 * 更新状态
		 */
		private static function updateStatus():void {
			var walk:Walk;
			var noStop:Boolean = true;
			for each(walk in _walkArr){
				if (walk.visible) {
					if (_stopNum > -1 && noStop && walk.stopNum ==0){//如果还没有人停留
						//我们进行随机确认是否要做停留
						if (Math.random() * 1000 < stopRate){
							//Model.instance().dispatchEvent(new UiEvent(UiEvent.WALK_STOP,walk));
							walk.stop();
							walk.stopNum = _stopNum;
							noStop = false;
						}
					}
					walk.go();
//					if (walkFunc != null) {
//						walkFunc(walk);
//					}
				}
			}
		}
		
		/**
		 * 初始化走动管理器
		 * @param	con			显示小人的容器
		 * @param	bnum		缓存多少个walk对象
		 */
		public static function init(con:Container,bnum:int=10,clickAble:Boolean=false,stopNum:int=-1):void {
			_con = con;
			_bnum = bnum;
			_clickAble = clickAble;
			_stopNum = stopNum;
		}
		
		/**
		 * 清空行走的组件资源
		 */
		public static function clear():void{
			clearInterval(_interval);
			_interval = -1;
			_nowNum = 0;
			
			var walk:Walk;
			for each(walk in _walkArr){
				_con.removeChild(walk);
				walk.dispose();
				walk = null;
			}
			_walkArr = new Array();
		}
			
		/**
		 * 增加一个行走的角色
		 */
		public static function addWalk(bitmapArr:Array, roadPoint:Array,yDis:int,data:*=null,addFunc:Function=null,clickFunc:Function=null,overFunc:Function=null,outFunc:Function=null,stopFunc:Function=null,dispearFunc:Function=null):void {
			//(bitmapArr:Array, roadPoint:Array, _distance:int=5, frameRate:int=2){
			var walk:Walk;
			if (_nowNum < _bnum) {
				_nowNum++;
				walk = new Walk(bitmapArr, roadPoint, yDis,distance,data);
				walk.enabled = _clickAble;
				_walkArr.push(walk);
				_con.addChild(walk);
			} else {
				//查找是否有可复用的行走组件
				var flag:Boolean = false;
				for each(walk in _walkArr){
					if (walk.visible == false) {
						walk.reuse(bitmapArr, roadPoint,yDis,distance,data);
						walk.enabled = _clickAble;
						walk.visible = true;
						flag = true;
						break;
					}
				}
				if (!flag) {//如果没有可复用的。那么我们新实例化一个
					_nowNum++;
					walk = new Walk(bitmapArr, roadPoint, yDis,distance,data);
					walk.enabled = _clickAble;
					_walkArr.push(walk);
					_con.addChild(walk);
				}
			}
			
			walk.clickFunc = clickFunc;
			walk.overFunc = overFunc;
			walk.outFunc = outFunc;
			walk.dispearFunc = dispearFunc;
			walk.stopFunc = stopFunc;
			if (addFunc != null) {
				addFunc(walk);
			}
			run();
		}
		
		private static function run():void {
			if (_interval == -1) {
				_interval = setInterval(updateStatus, INTERVAL_TIME);
			}
		}

	}
}