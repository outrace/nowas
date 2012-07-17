package now.container {
	import now.manager.PopManager;
	import now.nui.ImgBtn;
	import now.nui.Label;
	import now.nui.RichText;
	import now.nui.Text;
	import now.nui.UiConst;
	
	/**
	 * 一个简单的弹出提示框
	 */
	public final class Alert extends Container {
		private var _title:String = "";
		private var _msg:String = "";
		
		private var _lbTitle:Label;
		private var _txtContent:RichText;
		private var _hboxAct:HBox; //底部的操作按钮列表
		
		private var _bgPaddingLeft:int;
		private var _bgPaddingRight:int;
		private var _bgPaddingTop:int;
		private var _bgPaddingBottom:int;
		
		/**
		 * 提示框的构造函数
		 * @param	title		标题
		 * @param	msg		正文
		 */
		public function Alert(title:String, msg:String){
			_title = title;
			_msg = msg;
			super(0, 0);
			
			_bgPaddingLeft = getStyle("paddingLeft");
			_bgPaddingRight = getStyle("paddingRight");
			_bgPaddingTop = getStyle("paddingTop");
			_bgPaddingBottom = getStyle("paddingBottom");
			_width = getStyle("width");
			_height = getStyle("height");
		}
		
		/**
		 * 移除弹出窗口
		 */
		public final function removeAlert():void {
			PopManager.removePop(this);
			this.visible = false;
		}
				
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "Alert";
			
			_lbTitle = new Label(0, 0);
			_lbTitle.setStyle("fontName", getStyle("titleFontName"));
			_lbTitle.setStyle("fontWeight", getStyle("titleFontWeight"));
			_lbTitle.setStyle("fontSize", getStyle("titleFontSize"));
			_lbTitle.setStyle("color", getStyle("titleFontColor"));
			addChild(_lbTitle);
			
			_txtContent = new RichText(0, 0);
			_txtContent.setStyle("fontName", getStyle("contentFontName"));
			_txtContent.setStyle("fontWeight", getStyle("contentFontWeight"));
			_txtContent.setStyle("fontSize", getStyle("contentFontSize"));
			_txtContent.setStyle("color", getStyle("contentFontColor"));
			addChild(_txtContent);
			
			_hboxAct = new HBox(0, 0, 10);
			_hboxAct.halign = UiConst.CENTER;
			addChild(_hboxAct);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			
			_lbTitle.text = _title;
			_lbTitle.x = _bgPaddingLeft;
			_lbTitle.y = _bgPaddingTop;
			_lbTitle.draw();
			
			_txtContent.text = _msg;
			_txtContent.x = _bgPaddingLeft;
			_txtContent.y = _bgPaddingTop + 45;
			_txtContent.width = _width - _txtContent.x - _bgPaddingRight;
			_txtContent.height = _height - _txtContent.y - _bgPaddingBottom;
			_txtContent.draw();
						
			_hboxAct.draw();
			_hboxAct.x = _width - _bgPaddingRight - _hboxAct.width;
			_hboxAct.y = _height - _bgPaddingBottom;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			super.dispose();
			_lbTitle = null;
			_txtContent = null;
			_hboxAct = null;
		}
		
		/**
		 * 设置操作区域的按钮及响应函数
		 * @param act	操作列表
		 */
		public final function setAct(act:* = null):void {
			_hboxAct.removeAllChildren();
			if (act){
				var xpos:int = 0;
				var tmp:ImgBtn;
				var k:int;
				for (k = 0; k < act.length; k++){
					tmp = new ImgBtn(xpos, 0, act[k][0], act[k][1]);
					tmp.draw();
					xpos -= 50;
					_hboxAct.addChild(tmp);
				}
			}
		}
		
		/**
		 * 设置/获取 提示信息
		 */
		public function get msg():String {
			return _msg;
		}
		public function set msg(value:String):void {
			if(_msg == value){
				return;
			}
			_msg = value;
			invalidate();
		}
		
		/**
		 * 设置/获取 标题
		 */
		public function get title():String {
			return _title;
		}
		public function set title(value:String):void {
			if (_title == value){
				return;
			}
			_title = value;
			invalidate();
		}
	
	}
}