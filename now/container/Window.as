package now.container {
	import flash.display.Shape;
	import flash.events.Event;
	
	import now.nui.Img;
	import now.nui.ImgBtn;
	import now.nui.Label;
	import now.nui.UiConst;
	
	/**
	 * 一个窗口，只包含一个标题和一个关闭按钮，不能拖动
	 */
	public class Window extends Container {
		/**
		 * 是否显示关闭按钮
		 */
		private var _showClose:Boolean = true;
		/**
		 * 标题
		 */
		private var _title:String;
		/**
		 * 关闭时候调用函数
		 */
		protected var _closeHdl:Function = null;
		
		/**
		 * 关闭按钮相对顶部的距离
		 */
		protected var _closeBtnY:int = -20;
		/**
		 * 关闭按钮相对右边边线的距离
		 */
		protected var _closeBtnX:int = -40;
		/**
		 * 标题距离顶部的距离
		 */
		protected var _titleY:int = -20;
		
		private var _titleImg:Img;
		private var _closeButton:ImgBtn;
		
		/**
		 * 构造函数
		 * @param	title		标题
		 * @param	showClose	
		 * @param	closeHdl
		 * @param	xpos
		 * @param	ypos
		 */
		public function Window(title:String,showClose:Boolean = true,closeHdl:Function = null,xpos:Number = 0, ypos:Number = 0) {
			_title = title;
			_showClose = showClose;
			_closeHdl = closeHdl;
			super(xpos, ypos);
			setSize(500, 400);
		}
			
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "Window";
			_titleImg = new Img(0, 0);
			addChild(_titleImg);
			
			_closeButton = new ImgBtn(0, 0, "skin_win_close", _closeHdl);
			_closeButton.visible = _showClose;
			addChild(_closeButton);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			
			if (_title == "") {
				_titleImg.src = "";
				_titleImg.visible = false;
			} else {
				_titleImg.addEventListener(Event.COMPLETE,imgOk);
				_titleImg.src = _title;
				_titleImg.y = _titleY;
				_titleImg.draw();
			}
			setChildIndex(_closeButton, numChildren - 1);
			_closeButton.y = _closeBtnY;
			_closeButton.x = _width + _closeBtnX;
		}
		
		/**
		 * 图片加载完成后，将图片显示在中间
		 */
		private function imgOk(e:Event):void{
			_titleImg.removeEventListener(Event.COMPLETE,imgOk);
			_titleImg.x = _width / 2 - _titleImg.width / 2;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			_titleImg.removeEventListener(Event.COMPLETE,imgOk);
			super.dispose();
			_titleImg = null;
			_closeButton = null;
		}
				
		/**
		 * 设置/获取 标题
		 */
		public function set title(str:String):void {
			if (_title == str) {
				return;
			}
			_title = str;
			invalidate();
		}
		public function get title():String {
			return _title;
		}
		
		/**
		 * 设置/获取 标题图片或文字相对于顶部的距离
		 */
		public function set titleY(n:int):void {
			if (_titleY == n) {
				return;
			}
			_titleY = n;
			invalidate();
		}
		public function get titleY():int {
			return _titleY;
		}
		
		/**
		 * 设置/获取 关闭按钮相对于右边边线的距离
		 */
		public function set closeBtnX(n:int):void {
			if (_closeBtnX == n) {
				return;
			}
			_closeBtnX = n;
			invalidate();
		}
		public function get closeBtnX():int {
			return _closeBtnX;
		}
		
		/**
		 * 设置/获取 关闭按钮相对于顶端边线的距离
		 */
		public function set closeBtnY(n:int):void {
			if (_closeBtnY == n) {
				return;
			}
			_closeBtnY = n;
			invalidate();
		}
		public function get closeBtnY():int {
			return _closeBtnY;
		}
		
		/**
		 * 设置/获取 关闭按钮相对于顶端边线的距离
		 */
		public function set showClose(val:Boolean):void {
			if (_showClose == val) {
				return;
			}
			_showClose = val;
			_closeButton.visible = val;
		}
		public function get showClose():Boolean {
			return _showClose;
		}
	}

}