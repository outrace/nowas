package now.nui {
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * 多行文本
	 */
	public class Text extends Ui {
		protected var _editable:Boolean = false;
		protected var _html:Boolean = false;
		protected var _tf:TextField;
		
		private var _text:String = "";
		private var _selectable:Boolean = false;
		private var _format:TextFormat;
		private var _autoSize:Boolean;

		/**
		 * 构造函数
		 * @param xpos X轴
		 * @param ypos Y轴
		 * @param text 显示文本
		 */
		public function Text(xpos:Number = 0, ypos:Number = 0, text:String = "",autoSize:Boolean=false){
			_autoSize = autoSize;
			_text = text;
			super(xpos, ypos);
			setSize(100, 60);
		}

		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "Text";
			_tf = new TextField();
			_tf.x = 2;
			_tf.y = 2;
			_tf.height = _height;
			_tf.multiline = true;
			_tf.wordWrap = true;
			if (_autoSize){
				_tf.autoSize = TextFieldAutoSize.LEFT;
			}
//			_tf.type = TextFieldType.INPUT;
			_tf.addEventListener(Event.CHANGE, onChange);
			addChild(_tf);
		}


		/**
		 * 绘制UI组件
		 */
		override public function draw():void {
			super.draw();

			_format = new TextFormat(getStyle("fontName"), getStyle("fontSize"), getStyle("color"), getStyle("fontWeight"));
			_format.leading = getStyle("leading");
			_tf.selectable = _selectable;
			_tf.defaultTextFormat = _format;
			
			if (!_autoSize){
				_tf.width = _width - 4;
				_tf.height = _height - 4;
			}
			if (_html){
				_tf.htmlText = _text;
			} else {
				_tf.text = _text;
			}
			if (_editable){
				_tf.mouseEnabled = true;
				_tf.selectable = true;
				_tf.type = TextFieldType.INPUT;
			} else {
				_tf.mouseEnabled = _selectable;
				_tf.selectable = _selectable;
				_tf.type = TextFieldType.DYNAMIC;
			}
//			_tf.setTextFormat(_format);
			if (_autoSize){
				_width = _tf.width;
				_height = _tf.height;
				dispatchEvent(new Event(Event.RESIZE));
			}
			
		}


		/**
		 * 当文字内容变更时候，抛出事件
		 */
		protected function onChange(event:Event):void {
			_text = _tf.text;
			dispatchEvent(event);
		}


		/**
		 * 设置/获取 文字
		 */
		public function set text(txt:String):void {
			_text = txt;
			if (_text == null)
				_text = "";
			invalidate();
		}

		public function get text():String {
			return _text;
		}

		/**
		 * 获取内部的TextField组件
		 */
		public function get textField():TextField {
			return _tf;
		}

		/**
		 * 设置/获取  是否文字可选中.
		 */
		public function set selectable(b:Boolean):void {
			if (_selectable != b){
				_selectable = b;
				invalidate();
			}
		}
		public function get selectable():Boolean {
			return _selectable;
		}

		/**
		 * 设置/获取 是否是Html格式
		 */
		public function set html(value:Boolean):void {
			if (_html != value){
				_html = value;
				invalidate();
			}
		}
		public function get html():Boolean {
			return _html;
		}


		/**
		 * 覆盖设置是否起效状态
		 */
		public override function set enabled(value:Boolean):void {
			super.enabled = value;
			_tf.tabEnabled = value;
		}

	}
}