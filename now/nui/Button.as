package now.nui {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import now.manager.ImgManager;
	
	/**
	 * 普通按钮
	 */
	public class Button extends Ui {
		protected var _label:Label;
		private var _imgUrl:String = "";
		protected var _img:DisplayObject = null;
		private var _imgWidth:int;
		private var _imgHeight:int;
		private var _labelText:String = "";
		private var _hdl:Function = null;
		
		/**
		 * 鼠标划过时候的滤镜
		 */
		protected var _hoverFilter:* = null;
		
		/**
		 * 构造函数
		 * @param	xpos			X轴
		 * @param	ypos			Y轴
		 * @param	label			显示的文字内容
		 * @param	defHdl			点击时候的处理函数
		 */
		public function Button(xpos:Number = 0, ypos:Number = 0, label:String = "",
							   				defHdl:Function = null, useHover:Boolean=true){
			_labelText = label;
			if (defHdl != null){
				_hdl = defHdl;
			}
			super(xpos, ypos);
			addEventListener(MouseEvent.CLICK, hdlClick);
			if (useHover){
				addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			}
			draw();
		}
		
		/**
		 * 选中时候出发此事件
		 * @param	e	鼠标事件
		 */
		protected function hdlClick(e:MouseEvent):void {
			if (_hdl != null){
				_hdl(e);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			_name = "Button";
			super.addChildren();
			
			_label = new Label(0, 0);
			_label.addEventListener(Event.RESIZE, setBtnSize);
			_label.text = _labelText;
			addChild(_label);
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
		 * 设置按钮的长宽
		 */
		protected function setBtnSize(e:Event = null):void{
			if (_imgUrl == ""){
				return;
			}
			if (_label.width > _imgWidth){
				_img.width = _label.width + 8;
			}
			if (_label.height > _imgHeight){
				_img.height = _label.height + 4;
			}
			if (_width != _img.width && _height != _img.height){
				_width = _img.width;
				_height = _img.height;
				dispatchEvent(new Event(Event.RESIZE));
			}
			
			//文字移动到中间
			_label.move(_width*0.5 - _label.width*0.5, _height * 0.5 - _label.height * 0.5);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 得到图片路径
		 */
		protected function getImg():String {
			return getStyle("skin_btn","skin_btn");
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			
			var img:String = getImg();
			if (_imgUrl != img){
				_imgUrl = img;
				ImgManager.getImg(_imgUrl, function(ret:*):void {
					if (_img != null){
						removeChild(_img);
					}
					_img = ret;
					_imgWidth = _img.width;
					_imgHeight = _img.height;
					setBtnSize();
					addChildAt(_img, 0);
				});
			}
			
			if (!enabled){
				this.filters = [UiConst.disableFilter];
			} else {
				this.filters = [];
			}
		}
		
		/**
		 * 清空资源
		 */
		override public function dispose():void {
			removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			removeEventListener(MouseEvent.CLICK, hdlClick);
			removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			super.dispose();
			_label = null;
			_img = null;
		}
		
		/**
		 * 设置/获取  显示文字
		 */
		public function set label(txt:String):void {
			_labelText = txt;
			_label.text = _labelText;
		}
		public function get label():String {
			return _labelText;
		}
	}
}