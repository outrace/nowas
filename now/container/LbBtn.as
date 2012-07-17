package now.container {
	import flash.events.MouseEvent;
	
	import now.manager.SoundManager;
	import now.nui.Img;
	import now.nui.Label;
	import now.nui.UiConst;

	/**
	 * 包含了文字和图片的一个按钮
	 */
	public final class LbBtn extends Container 	{
		private var _disableFilter:* = null;		//失效时候的滤镜
		private var _hoverFilter:* = null;			//鼠标划过时候的滤镜
		
		private var _hdl:Function = null;				//点击处理函数
		private var _useHover:Boolean = true;	//是否处理hover事件
		
		private var _imgUrl:String = "";		//图片地址
		private var _lbText:String = "";				//文字内容
		
		private var _img:Img;
		private var _lb:Label;
		
		private var _txtPaddingLeft:int = 0;
		private var _txtAligh:String = UiConst.CENTER;
		
		/**
		 * 构造函数
		 * @param	xpos		x轴
		 * @param	ypos		y轴
		 * @param	imgUrl		图片路径
		 * @param	lbText		文字内容
		 * @param	hdl			点击时候的处理函数
		 * @param	txtPaddingLeft		label距离左边的距离
		 * @param	txtAligh					label的横向对齐方式，默认为居中对齐
		 * @param	useHover					是否监听hover事件。比如分享窗口的关闭按钮，就是不监听hover事件的
		 */
		public function LbBtn(xpos:Number=0, ypos:Number=0, imgUrl:String="", lbText:String="", hdl:Function=null, 
							  txtPaddingLeft:int=0, txtAligh:String=UiConst.CENTER,  useHover:Boolean=true)	{
			_useHover = useHover;
			_imgUrl = imgUrl;
			_lbText = lbText;
			_txtPaddingLeft = txtPaddingLeft;
			_txtAligh = txtAligh;
			_hdl = hdl;
			
			super(xpos, ypos);
			_name = "LbBtn";
			buttonMode = true;
			useHandCursor = true;
			if(hdl !=null){
				addEventListener(MouseEvent.CLICK, clickHdl);
			}
			if (_useHover){
				addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_img = new Img(0,0,_imgUrl);
			addChild(_img);
			
			_lb = new Label(_txtPaddingLeft,0,_lbText);
			_lb.vAlign = UiConst.MIDDLE;
			_lb.hAlign = _txtAligh;
			addChild(_lb);
		}
		
		/**
		 * 处理点击事件
		 */
		private function clickHdl(e:MouseEvent):void {
			if (enabled){
				if (_hdl != null) {
					_hdl(e);
				}
				SoundManager.play(UiConst.SOUND_BTN);
			}
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
			_img = null;
			_lb = null;
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
			_lb.setSize(_width,_height);
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
		
		/**
		 * 重设图片路径
		 */
		public function set imgUrl(val:String):void{
			if (_imgUrl == val){
				return;
			}
			_imgUrl = val;
			_img.src = val;
		}
		
		public function set lbText(val:String):void{
			if (_lbText == val){
				return;
			}
			_lbText = val;
			_lb.text = _lbText;
		}
		public function get lb():Label{
			return _lb;
		}
	}
}