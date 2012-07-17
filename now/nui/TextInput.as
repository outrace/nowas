package now.nui {
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import now.util.UiUtil;
	
	/**
	 * 输入框，这个还需要继续改善，以便支持有背景的输入框
	 */
	public final class TextInput extends Ui {
		protected var _back:Shape;
		protected var _password:Boolean = false;
		protected var _text:String = "";
		protected var _tf:TextField;
		
		/**
		 * 构造函数
		 * @param xpos x轴
		 * @param ypos y轴
		 * @param text 默认显示的文本内容
		 */
		public function TextInput(xpos:Number = 0, ypos:Number = 0, text:String = ""){
			super(xpos, ypos);
			_name = "TextInput";
			_text = text;
			setSize(80, 16);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_back = new Shape();
			addChild(_back);
			
			_tf = new TextField();
			_tf.selectable = true;
			_tf.type = TextFieldType.INPUT;
			addChild(_tf);
			
			_tf.addEventListener(Event.CHANGE, onChange);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			
			_back.graphics.clear();
			var bgColor:* = getStyle("bgColor");
			var borderColor:* = getStyle("borderColor");
			var borderSize:* =  getStyle("borderSize");
			
			if (bgColor != undefined && borderColor != undefined && borderSize != undefined){
				UiUtil.rectangle(_back, _width,_height, bgColor, 0, borderSize, borderColor, 1);
			}
			
			_tf.defaultTextFormat = new TextFormat(getStyle("fontName"), getStyle("fontSize"), getStyle("color"));
			_tf.displayAsPassword = _password;
			
			if (_text != null){
				_tf.text = _text;
			} else {
				_tf.text = "";
			}
			_tf.width = _width - 4;
			if (_tf.text == ""){
				_tf.text = "X";
				_tf.height = Math.min(_tf.textHeight + 4, _height);
				_tf.text = "";
			} else {
				_tf.height = Math.min(_tf.textHeight + 4, _height);
			}
			_tf.x = 2;
			_tf.y = Math.round(_height / 2 - _tf.height / 2);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_back = null;
			_tf = null;
		}
		
		/**
		 * 处理文字改变的事件
		 * @param event 用户输入的系统事件
		 */
		protected function onChange(event:Event):void {
			_text = _tf.text;
		}
		
		/**
		 * 设置/获取  文本内容
		 */
		public function set text(t:String):void {
			if (t == null){
				t = "";
			}
			if (_text != t){
				_text = t;
				invalidate();
			}
		}
		public function get text():String {
			return _text;
		}
		
		/**
		 * 设置/获取 
		 */
		public function set restrict(str:String):void {
			_tf.restrict = str;
		}
		
		public function get restrict():String {
			return _tf.restrict;
		}
		
		/**
		 * 设置/获取 最大输入字符数
		 */
		public function set maxChars(max:int):void {
			_tf.maxChars = max;
		}
		public function get maxChars():int {
			return _tf.maxChars;
		}
		
		/**
		 * 设置/获取 是否显示为密码方式
		 */
		public function set password(b:Boolean):void {
			if (_password != b){
				_password = b;
				invalidate();
			}
		}
		public function get password():Boolean {
			return _password;
		}
		
		public override function set enabled(value:Boolean):void {
			super.enabled = value;
			_tf.tabEnabled = value;
		}
	}
}