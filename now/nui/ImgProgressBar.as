package now.nui {
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * 进行进度显示的UI组件
	 */
	public final class ImgProgressBar extends Ui {
		private var _head:Img;
		private var _bar:Img;
		private var _tail:Img;
		private var _headsrc:String;
		private var _barsrc:String;
		private var _tailsrc:String;
		private var _value:Number = 0;
		private var _max:Number = 1;
		
		private var _barW:Number = 0;//中间的宽度
		
		private var _loadNo:int = 0;
		
		/**
		 * @inheritDoc
		 */
		public function ImgProgressBar(xpos:Number = 0, ypos:Number = 0, headsrc:String="", barsrc:String="", tailsrc:String="") {
			_headsrc = headsrc;
			_barsrc = barsrc;
			_tailsrc = tailsrc;
			
			super(xpos, ypos);
			setSize(100, 10);
		}

		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "ProgressBar";
			_head = new Img(0, 0, _headsrc);
			_head.addEventListener(Event.COMPLETE,loadOk);
			_head.visible = false;
			addChild(_head);
			
			_bar = new Img(0, 0, _barsrc);
			_head.addEventListener(Event.COMPLETE,loadOk);
			_bar.visible = false;
			addChild(_bar);
			
			_tail = new Img(0, 0, _tailsrc);
			_tail.visible = false;
			addChild(_tail);
			
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		private function loadOk(e:Event):void{
			_loadNo = _loadNo + 1;
			if (_loadNo == 2){
				_bar.x = _head.width;
			}
		}

		/**
		 * 更新
		 */
		private function update():void {
			_barW = _this.width - _head.width - _tail.width;//计算中间的宽度
			_tail.x = _this.width - _tail.width;
			if (_value <= 0 ) {
				_head.visible = false;
				_bar.visible = false;
				_tail.visible = false;
			}else if (_value < _max) {
				_head.visible = true;
				_bar.visible = true;
				_tail.visible = false;
			}else {
				_head.visible = true;
				_bar.visible = true;
				_tail.visible = true;
			}
			
			_bar.scaleX = (_value / _max) * _barW;
		}


		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			update();
		}

		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_head = null;
			_bar = null;
			_tail = null;
		}
		

		/**
		 * 设置/获取 最大值
		 */
		public function set maximum(m:Number):void {
			if(m != _max){
				_max = m;
				_value = Math.min(_value, _max);
				update();
			}
		}
		public function get maximum():Number {
			return _max;
		}

		/**
		 * 设置/获取 当前值
		 */
		public function set value(v:Number):void {
			if(v != _value){
				_value = Math.min(v, _max);
				update();
			}
		}
		public function get value():Number {
			return _value;
		}
		
//		public function setBarSrc(headsrc:String = null, barsrc:String = null, tailsrc:String = null):void {
//			_headsrc = headsrc;
//			_barsrc = barsrc;
//			_tailsrc = tailsrc;
//			
//			_head.src = _headsrc;
//			_bar.src = barsrc;
//			_tail.src = tailsrc;
//		}
	}
}