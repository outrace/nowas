package now.nui {
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import now.inter.ITip;
	import now.manager.StyleManager;
	import now.util.UiUtil;

	/**
	 * 默认的TIP显示组件
	 */
	public final class Tip extends Ui implements ITip {
		protected var _text:String = "";
		protected var _tf:TextField;
		protected var _direct:String = UiConst.TOP;
		
		protected var _border:Shape;
		protected var _borderColor:int = 0xdea357;
		protected var _borderThickness:int = 2;
		protected var _borderDistance:int = 10;
		protected var _borderBackgroundColor:int = 0x160b10;
		protected var _borderBackgroundAlpha:Number = 0.8;
		protected var _padding:int = 4;
		protected var _conerLen:int = 10;
		
		protected var _distance:Number = 0;
		

		/**
		 * 构造函数
		 * @param	xpos	X轴
		 * @param	ypos	Y轴
		 * @param	text	显示的提示信息
		 */
		public function Tip(xpos:Number = 0, ypos:Number = 0, text:String = "",distance:int=0){
			_text = text;
			super(xpos, ypos);
			_name = "Tip";
		}

		/**
		 * 增加子组件
		 */
		override protected function addChildren():void {
			super.addChildren();
			_tf = new TextField();
			_tf.selectable = false;
			_tf.mouseEnabled = false;
			mouseEnabled = false;
			mouseChildren = false;
//			_tf.embedFonts = Style.embedFonts;
			_tf.multiline = true;
			_tf.htmlText = _text;
			addChild(_tf);
		}

		/**
		 * 进行界面绘制
		 */
		override public function draw():void {
			super.draw();
			
			_tf.defaultTextFormat = new TextFormat(getStyle("fontName"), getStyle("fontSize"), getStyle("color"));
			_tf.htmlText = _text;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			
			if(_border !=null){
				removeChild(_border);
			}
			_border = UiUtil.drawTipBorder(_this,_tf,_direct,_borderColor,_borderThickness,_borderDistance,_borderBackgroundColor,_borderBackgroundAlpha,_padding,_conerLen);
			addChildAt(_border,0);
		}


		//实现ITip相关的接口

		public function set data(t:*):void {
			if (t == null){
				t = "";
			}
			if (_text != t){
				_text = t;
				invalidate();
			}
		}
//
		public function get data():* {
			return _text;
		}
//
		public function set direct(s:String):void {
			_direct = s;
		}
//
		public function get direct():String {
			return _direct;
		}

		
		public function get boderDistance():int {
			return _borderDistance;
		}
		
		public function set distance(dis:Number):void {
			if(_distance != dis){
				_distance = dis;
				invalidate();
			}
		}
		
		public function get distance():Number {
			return _distance;
		}

	}
}