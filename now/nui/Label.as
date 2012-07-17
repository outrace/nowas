package now.nui {
	import flash.events.Event;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.Kerning;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	import now.manager.StyleManager;
	
	/**
	 * 单行文本
	 */
	public class Label extends Ui {	
		private var _text:String = "";
		private var _fontDesc:FontDescription;
		private var _elementFormat:ElementFormat;
		private var _textElement:TextElement;
		private var _textBlock:TextBlock;
		private var _textLine:TextLine;
		
		private var _vAligh:String = UiConst.MIDDLE;
		private var _hAligh:String = UiConst.LEFT;
		private var _fixWidth:Boolean;
		
		/**
		 * 构造函数
		 * @param	xpos	X轴
		 * @param	ypos	Y轴
		 * @param	text	文本内容
		 * @param   fixWidth 是否当宽度超过设置的width属性时进行截取
		 */
		public function Label(xpos:Number = 0, ypos:Number = 0, text:String = "",fixWidth:Boolean=false){
			_text = text;
			_fixWidth = fixWidth;
			super(xpos, ypos);
			_name = "Label";
			setSize(20, 18);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			if (numChildren > 0) {
				removeChildAt(0);
			}
			if (_text == "") {
				return;
			}
			
			var fname:String = getStyle("fontName");
			_fontDesc = new FontDescription();
			_fontDesc.fontName = fname;
			_fontDesc.fontWeight = getStyle("fontWeight");
			_fontDesc.fontPosture = getStyle("fontPosture");
			_fontDesc.renderingMode = RenderingMode.CFF;
			if(fname == "myfont"){
				_fontDesc.fontLookup = FontLookup.EMBEDDED_CFF; 
			}else{
				_fontDesc.fontLookup = FontLookup.DEVICE; 
			}
			_fontDesc.locked = true;
			
			_elementFormat = new ElementFormat(_fontDesc);
			_elementFormat.fontSize = getStyle("fontSize");
			_elementFormat.kerning = Kerning.ON;
			_elementFormat.color = getStyle("color");
			_elementFormat.alpha = 1;
			
			if(_fixWidth){
				_text = getFixText(_text, _width);
			}
			
			_textElement = new TextElement(_text, _elementFormat);
			
			_textBlock = new TextBlock();			
			_textBlock.content = _textElement;
			
			_textLine = _textBlock.createTextLine(null, 500);
			_textLine.mouseChildren = false;
			_textLine.mouseEnabled = false; 
			
			var resize:Boolean = false;
			if (_width < _textLine.textWidth) {
				_textLine.x = 0;
				_width = _textLine.textWidth;
				resize = true;
			} else {
				if (_hAligh == UiConst.LEFT) {
					_textLine.x = 0;
				} else if (_hAligh == UiConst.CENTER) {
					_textLine.x = _width / 2 - _textLine.textWidth / 2;
				} else {
					_textLine.x = _width - _textLine.textWidth;
				}
			}
			
			var h:int = _textLine.ascent - 1;
			if (_height < h) {
				_textLine.y = h;
				_height = h;
				resize = true;
			} else {
				_textLine.y = h;
				if (_vAligh == UiConst.MIDDLE) {
					_textLine.y += _height / 2 - h / 2;
				} else if (_vAligh == UiConst.BOTTOM) {
					_textLine.y+= _height - h;
				}
			}
			_textLine.mouseChildren = false;
			_textLine.mouseEnabled = false;
			if (resize){
				dispatchEvent(new Event(Event.RESIZE));
			}
			addChild(_textLine);
		}
		
		/**
		 * 截取字符串
		 */ 
		private function getFixText(str:String, w:Number):String {
			while(true){
				_textElement = new TextElement(str, _elementFormat);
				_textBlock = new TextBlock();			
				_textBlock.content = _textElement;
				_textLine = _textBlock.createTextLine(null, 500);
				if (_textLine.textWidth > w) {
					str = str.substr(0, str.length - 1);
				} else {
					break;
				}
			}
			return str;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_fontDesc = null;
			_elementFormat = null;
			_textElement = null;
			_textBlock = null;
			_textLine = null;
		}
		
		/**
		 * 设置/获取 字体大小
		 */
		public function set fontSize(n:int):void {
			setStyle("fontSize", n);
		}
		public function get fontSize():int {
			return getStyle("fontSize");
		}
		
		/**
		 * 设置/获取 文本
		 */
		public function set text(t:*):void {
			if (t == null){
				t = "";
			}
			t = t.toString();
			if (_text != t){
				_text = t;
				invalidate();
			}
		}
		public function get text():String {
			return _text;
		}

		/**
		 * 设置/获取 垂直对齐方式，默认为居中
		 */
		public function get vAlign():String {
			return _vAligh;
		}
		public function set vAlign(str:String):void {
			if (str == _vAligh) {
				return;
			}
			_vAligh = str;
			invalidate();
		}
		
		/**
		 * 设置/获取 水平对齐方式，默认为居中
		 */
		public function get hAlign():String {
			return _hAligh;
		}
		public function set hAlign(str:String):void {
			if (str == _hAligh) {
				return;
			}
			_hAligh = str;
			invalidate();
		}
		
	}
}