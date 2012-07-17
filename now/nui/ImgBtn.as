package now.nui {
	import flash.events.MouseEvent;
	
	import now.manager.SoundManager;

	/**
	 * 图形按钮
	 */
	public class ImgBtn extends Img {

		/**
		 * 失效时候的滤镜
		 */
		protected var _disableFilter:* = null;
		/**
		 * 鼠标划过时候的滤镜
		 */
		protected var _hoverFilter:* = null;
		/**
		 * 点击处理函数
		 */
		private var _hdl:Function = null;
		
		
		private var _useHover:Boolean = true;
		
		private var _onClick:Boolean = false;
		
		/**
		 * 构造函数
		 * @param	xpos	X轴坐标
		 * @param	ypos	Y轴坐标
		 * @param	src		图片地址
		 * @param	hdl		点击按钮的处理函数
		 */
		public function ImgBtn(xpos:Number = 0, ypos:Number = 0, src:* = null, hdl:Function = null, useHover:Boolean=true){
			_hdl = hdl;
			super(xpos, ypos, src);
			_name = "ImgBtn";
			buttonMode = true;
			useHandCursor = true;
			_useHover = useHover;
			if(hdl !=null){
				addEventListener(MouseEvent.CLICK, clickHdl);
			}
			if (_useHover){
				addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			}
		}
		
		/**
		 * 设置鼠标点击处理函数
		 */ 
		public function set hdl(hdl:Function):void {
			_hdl = hdl;
			if (!hasEventListener(MouseEvent.CLICK)) {
				addEventListener(MouseEvent.CLICK, clickHdl);
			}
		}
		
		private function clickHdl(e:MouseEvent):void {
			if (_onClick){
				return;
			}
			_onClick = true;
			if (_hdl != null) {
				_hdl(e);
			}
			SoundManager.play(UiConst.SOUND_BTN);
			_onClick = false;
		}

		/**
		 * 鼠标覆盖上来时候的处理函数
		 * @param	e
		 */
		protected function onMouseOver(e:MouseEvent):void {
			if (enabled){
				addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
				this.filters = [_hoverFilter == null ? UiConst.hoverFilter : _hoverFilter];
			}
		}
		/**
		 * 鼠标离开时候的处理函数
		 * @param	e
		 */
		protected function onMouseOut(e:MouseEvent):void {
			if (enabled){
				removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
				this.filters = [];
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			if (_hdl != null) {
				removeEventListener(MouseEvent.CLICK, _hdl);
			}
			removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			super.dispose();
		}

		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			if (!enabled){
				this.filters = [_disableFilter == null ? UiConst.disableFilter : _disableFilter];
			} else {
				this.filters = [];
			}
		}
		
		/**
		 * 设置/获取  失效时候的滤镜
		 */
		public function get disableFilter():* {
			return _disableFilter;
		}
		public function set disableFilter(value:*):void {
			_disableFilter = value;
		}

		/**
		 * 设置/获取  鼠标划过时候的滤镜
		 */
		public function get hoverFilter():* {
			return _hoverFilter;
		}
		public function set hoverFilter(value:*):void {
			_hoverFilter = value;
		}
		

	}
}