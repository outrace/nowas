package now.nui {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import now.base.Model;
	import now.event.UiEvent;
	import now.manager.TipManager;
	
	/**
	 * 一个45度人物走动的组件
	 * 暂时支持：4方向走动，传过来的bitmapdata序列为：左上，左下，右上，右下
	 *           8方向走动，传过来的bitmapdata序列为：左上，左下，右上，右下，向上，向下，向左，向右
	 * 一般由WalkManager控制
	 */
	public class Walk extends Ui {
		private var _bitmap:Bitmap;	
		private var _bitmapArr:Array;			//行走的序列图数组
		private var _roadPoint:Array;			//路点列表
		private var _distance:int = 6;			//每50毫秒移动的直线距离
		private var _frameLen:int = 0;			//帧数
		private var _step:int = 0;				//步数，也就是需要走几步到达拐点
		private var _nowPos:int = 0;			//当前八方图的位置，
		private var _nowFrame:int = 0;			//当前图形的帧序列
		private var _nowXDis:int = 0;
		private var _nowYDis:int = 0;
		
		private var _yDis:int = 0;				//y偏移值，用于使中心点设置在脚下中心
		
		private var _stopNum:int = 0;			//当前停留的阶段。0为走动阶段
		private var _stopFlag:Boolean = false;  //当设置stopFlag为true时，stopNum将无效
		
		private var _data:* = null;		    //保存的数据
		
		private var _clickFunc:Function;
		private var _overFunc:Function;
		private var _outFunc:Function;
		private var _stopFunc:Function;
		private var _dispearFunc:Function;
		
		/**
		 * 构造函数
		 * @param	bitmapArr		行走的位图序列
		 * @param	roadPoint		路点列表,第一个路点为起始点
		 * @param	yDis			y偏移值，用于使中心点设置在脚下中心
		 * @param	distance		每帧移动的距离
		 * @param	data			小人所代表的数据
		 */
		public function Walk(bitmapArr:Array, roadPoint:Array, yDis:int, distance:int=6,data:*=null){
			_bitmapArr = bitmapArr;
			_frameLen = (_bitmapArr[0] as Array).length;
			_yDis = yDis;
			_distance = distance;
			_roadPoint = roadPoint;
			_data = data;
			super(_roadPoint[0][0], _roadPoint[0][1]);
			addEventListener(MouseEvent.CLICK,walkClick);
			addEventListener(MouseEvent.ROLL_OVER, walkOver);
			getDirect();
		}
		
		public function get data():* {
			return _data;
		}
		
		public function set data(d:*):void {
			_data = d;
		}
		
		private function walkClick(e:MouseEvent):void{
			if(_clickFunc!=null){
				_clickFunc(_this);
			}
		}
				
		private function walkOver(e:MouseEvent):void{
			_stopNum = 9000;
			if(_overFunc!=null){
				_overFunc(_this);
			}
			addEventListener(MouseEvent.ROLL_OUT,walkOut);
		}
		
		private function walkOut(e:MouseEvent):void{
			removeEventListener(MouseEvent.ROLL_OUT, walkOut);
			_stopNum = 2;
			if(_outFunc!=null){
				_outFunc(_this);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */		
		override public function dispose():void{
			removeEventListener(MouseEvent.CLICK,walkClick);
			super.dispose();	
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_bitmap = new Bitmap();
			var bm:BitmapData = _bitmapArr[0][0];
			_bitmap.x = - bm.width / 2;
			_bitmap.y = - bm.height + _yDis; 
			bm = null;
			addChild(_bitmap);
		}
		
		/**
		 * 获取下一个路点的方向
		 * 左上，左下，右上，右下
		 */
		private function getDirect():void {
			var nowPoint:Point = new Point(_roadPoint[0][0], _roadPoint[0][1]);
			var nextPoint:Point = new Point(_roadPoint[1][0], _roadPoint[1][1]);
			if (nextPoint.x > nowPoint.x) {//从左边走
				if (nextPoint.y > nowPoint.y) {//向下走
					_nowPos = 1;	//左下
					_nowYDis = _distance;
				} else if (nextPoint.y == nowPoint.y) {//不变，只是向右
					_nowPos = 7;
					_nowYDis = 0;
				} else {
					_nowPos = 0; //左上
					_nowYDis = - _distance;
				}
				_step = int((nextPoint.x - nowPoint.x) / _distance) + 1;
				_nowXDis = _distance;
			} else if (nextPoint.x == nowPoint.x) {//直接向上走，只出现在8方向走动的时候
				if (nextPoint.y > nowPoint.y) {//向下走
					_nowPos = 5;
					_step = int((nextPoint.y - nowPoint.y) / _distance) + 1;
					_nowYDis = _distance;
				} else if (nextPoint.y < nowPoint.y) {//向上走
					_nowPos = 4;
					_step = int((nowPoint.y - nextPoint.y) / _distance) + 1;
					_nowYDis = - _distance;
				}
				_nowXDis = 0;
			} else {//从右边走
				if (nextPoint.y > nowPoint.y) {//向下走
					_nowPos = 3;
					_nowYDis = _distance;
				} else if (nextPoint.y == nowPoint.y) {//不变，只是向左
					_nowPos = 6;
					_nowYDis = 0;
				} else {//向上走
					_nowPos = 2;
					_nowYDis = - _distance;
				}
				_step = int((nowPoint.x - nextPoint.x) / _distance) + 1;
				_nowXDis = - _distance;
			}
			_nowYDis = _nowYDis * 0.5;
			
			_bitmap.bitmapData = _bitmapArr[_nowPos][0];
			move(nowPoint.x, nowPoint.y);
			_nowFrame = _nowFrame + 1;
			
//			trace(this.id,_step);
			_roadPoint.shift();
		}
		
		/**
		 * 走到下一步
		 */
		public final function go():void {
			if (_stopFlag) {
				return;
			}
			//如果在停顿期间，我们直接返回
			if(_stopNum > 0){
				_stopNum = _stopNum - 1;
				return;
			}
			
			_step = _step - 1;
			_bitmap.bitmapData = _bitmapArr[_nowPos][_nowFrame];
			//_nowFrame = _nowFrame + 1;
			if (++_nowFrame >= _frameLen) {//播放完了，重头播放
				_nowFrame = 0;
			}
			
			this.x = this.x + _nowXDis;
			this.y = this.y + _nowYDis;
			
			
			
			if (_roadPoint.length == 1 && _step < 4) {//最后几步，渐变消失
				this.alpha = (_step + 1) * 0.1;
			}
			
			if (_step == 0) {//进入拐点了
				if (_roadPoint.length > 1) {//还有下一个拐点
					getDirect();
//					trace(_this.id,"转弯了");
				} else {//没有了
//					trace(_this.id,"消失了");
					_bitmap.bitmapData = null;
					_bitmapArr = null;
					_roadPoint = null;
					//Model.instance().dispatchEvent(new UiEvent(UiEvent.WALK_DISAPEAR,_this));
					if(_dispearFunc!=null){
						_dispearFunc(_this);
					}
					_this.visible = false;
					_this.alpha = 1;
				}
			}
		}
		
		/**
		 * 对行走的小人进行复用
		 * @param	bitmapArr		行走的位图序列
		 * @param	roadPoint		路点列表,第一个路点为起始点
		 * @param	yDis			y偏移值，用于使中心点设置在脚下中心
		 * @param	distance		每帧移动的距离
		 * @param	data			小人所代表的数据
		 */
		public final function reuse(bitmapArr:Array, roadPoint:Array, yDis:int, distance:int=6, data:*=null):void{
			_bitmapArr = bitmapArr;
			_frameLen = (_bitmapArr[0] as Array).length;
			_distance = distance;
			_roadPoint = roadPoint;
			_nowXDis = 0;
			_nowYDis = 0;
			_yDis = yDis;
			_step = 0;
			_data = data;
			_stopNum = 0;
			move(_roadPoint[0][0], _roadPoint[0][1]);
			var bm:BitmapData = _bitmapArr[0][0];
			_bitmap.x = - bm.width / 2;
			_bitmap.y = - bm.height + _yDis; 
			bm = null;
			getDirect();
		}
		
		public final function stop():void{
			if(_stopFunc!=null){
				_stopFunc(_this);
			}
		}

		public function get stopNum():int
		{
			return _stopNum;
		}

		public function set stopNum(value:int):void
		{
			_stopNum = value;
		}

		public function get clickFunc():Function
		{
			return _clickFunc;
		}

		public function set clickFunc(value:Function):void
		{
			_clickFunc = value;
		}

		public function get overFunc():Function
		{
			return _overFunc;
		}

		public function set overFunc(value:Function):void
		{
			_overFunc = value;
		}

		public function get outFunc():Function
		{
			return _outFunc;
		}

		public function set outFunc(value:Function):void
		{
			_outFunc = value;
		}

		public function get dispearFunc():Function
		{
			return _dispearFunc;
		}

		public function set dispearFunc(value:Function):void
		{
			_dispearFunc = value;
		}

		public function get stopFunc():Function
		{
			return _stopFunc;
		}

		public function set stopFunc(value:Function):void
		{
			_stopFunc = value;
		}

		public function get stopFlag():Boolean
		{
			return _stopFlag;
		}

		public function set stopFlag(value:Boolean):void
		{
			_stopFlag = value;
		}

		
	}

}