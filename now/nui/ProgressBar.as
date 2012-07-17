package now.nui {
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.engine.FontWeight;
	
	import now.inter.IProgress;

	/**
	 * 进行进度显示的UI组件
	 */
	public class ProgressBar extends Ui implements IProgress {
		protected var _back:Shape;//背景色
		protected var _bar:Shape;//进度条
		protected var _mask:Shape;//挖空圆角
		
		protected var _value:Number = 0;
		protected var _max:Number = 1;
		
		protected var _wRound:Number = 6;
		protected var _yRound:Number = 6;
		protected var _boderSize:int = 2;
		
		private var _dblSize:int = 4;
		private var _showBack:Boolean = true;
		
		protected var _lbl:Label;

		/**
		 * @inheritDoc
		 */
		public function ProgressBar(xpos:Number = 0, ypos:Number = 0,
									wRound:Number=6,yRound:Number=6,boderSize:int=2,showBack:Boolean=true){
			_wRound = wRound;
			_yRound = yRound;
			_boderSize = boderSize;
			_dblSize = _boderSize * 2;
			_showBack = showBack;
			super(xpos, ypos);
			setSize(80, 18);
		}

		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "ProgressBar";
			_back = new Shape();
			addChild(_back);

			_bar = new Shape();
			_bar.x = _boderSize;
			_bar.y = _boderSize;
			addChild(_bar);
			
			_mask = new Shape();
			addChild(_mask);
		}
		
		public function setText(text:String,size:int=10,color:int=0xFFFFFF,fontName:String=""):void {
			if (_lbl == null) {
				_lbl = new Label(0, 0, text);
				_lbl.width = this.width;
				_lbl.height = _height;
				_lbl.hAlign = UiConst.CENTER;
				_lbl.vAlign = UiConst.MIDDLE;
//				_lbl.setStyle("fontWeight",FontWeight.BOLD);
				_lbl.setStyle("color", color);
				_lbl.setStyle("fontSize",size);
				if (fontName != ""){
					_lbl.setStyle("fontName",fontName);
				}
				_lbl.draw();
				addChild(_lbl);
			}else{
				_lbl.text = text;
			}
		}

		/**
		 * 更新
		 */
		protected function update():void {
			_bar.scaleX = _value / _max;
		}


		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			if (_showBack){
				_back.graphics.clear();
				_back.graphics.beginFill(getStyle("bgColor"));
				_back.graphics.drawRoundRect(0, 0, _width, _height,_wRound,_yRound);
				_back.graphics.endFill();
			}

			_bar.graphics.clear();
			_bar.graphics.beginFill(getStyle("barColor"));
			_bar.graphics.drawRect(0, 0, _width - _dblSize, _height - _dblSize);
			_bar.graphics.endFill();
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(getStyle("borderColor"));
			_mask.graphics.drawRoundRect(0, 0, _width, _height,_wRound,_yRound);
			_mask.graphics.drawRoundRect(_boderSize, _boderSize, _width - _dblSize, _height - _dblSize, _wRound*0.5,_yRound*0.5);
			_mask.graphics.endFill();
			update();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_back = null;
			_bar = null;
			_mask = null;
		}


		/**
		 * 设置/获取 最大值
		 */
		public function set max(m:int):void {
			_max = m;
			_value = Math.min(_value, _max);
			update();
		}
		public function get max():int {
			return _max;
		}

		/**
		 * 设置/获取 当前值
		 */
		public function set value(v:int):void {
			_value = Math.min(v, _max);
			update();
		}
		public function get value():int {
			return _value;
		}
	}
}