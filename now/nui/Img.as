package now.nui {
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	
	import now.manager.ImgManager;
	import now.util.MatrixUtil;
	import now.util.UiUtil;

	/**
	 * 提供一个加载图片和swf的容器
	 * todo 待加入loading/加载异常
	 */
	public class Img extends Ui {
		protected var _srcChange:Boolean = true; //图片内容是否发生变更		
		private var _repeat:Boolean = false;
		private var _src:* = null;
		private var _imgFlip:String = ""; //反转类型。可进行UiConst.LEFT/RIGHT/H/V
		
		public var resizeContent:Boolean = false;	//是否每次都根据图片宽高设置当前宽高
		

		/**
		 * 构造函数
		 * @param	xpos	x轴
		 * @param	ypos	y轴
		 * @param	src		图片内容。如果是String类型，则可能代表一个url或者一个嵌入式资源的名称<br/>
		 * 					也可以是一个BitmapData
		 * @param	repeat	是否重复绘制。如果重复绘制则进行重复绘制图形
		 */
		public function Img(xpos:Number = 0, ypos:Number = 0, src:* = null, repeat:Boolean = false){
			_src = src;
			_repeat = repeat;
			super(xpos, ypos);
			_name = "Img";
			if (src){
				invalidate();
			}
		}
		
		/**
		 * 重设宽高
		 */
		private function resetWidthHeight(dis:DisplayObject):void {
			if (_repeat) {
				repeatImg(dis);
			} else {
				var tmp:Number;
				var w:Number;
				var h:Number;

				w = dis.width;
				h = dis.height;

				if (resizeContent || (_width == 0 && _height == 0)){ //如果都不设置，我们以取得的图片或者swf作为组件宽高
					_width = w;
					_height = h;
				} else if (_width != 0){ //否则，我们先以宽为标准，去计算高
					tmp = _width * h / w;
					dis.width = _width;
					dis.height = tmp;
					_height = tmp;
				} else { //如果宽为0，高不为0，我们以高为标准，计算宽
					tmp = _height * w / h;
					dis.width = _width;
					dis.height = _height;
					_width = tmp;
				}
				
				
				if (_imgFlip != ""){
					if (_imgFlip == UiConst.HORIZONTAL){
						MatrixUtil.hflip(dis);
					} else if (_imgFlip == UiConst.VERTICAL){
						MatrixUtil.vflip(dis);
					} else if (_imgFlip == UiConst.LEFT){
						MatrixUtil.leftFlip(dis);
					} else if (_imgFlip == UiConst.RIGHT){
						MatrixUtil.rightFlip(dis);
					}
				}
				addChild(dis);
				dispatchEvent(new Event(Event.COMPLETE));
				dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
		/**
		 * 进行重复显示
		 */
		private function repeatImg(dis:DisplayObject):void {
			UiUtil.repeatDis(dis, this);
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			if (_srcChange){
				showImg();
				_srcChange = false;
			}
		}

		/**
		 * 绘制图片
		 */
		private function showImg():void {
			if (numChildren > 0) {//删除旧图片
				removeChildAt(0);
			}
			if (_src){
				//载入新图片
				if (_src is String){
					ImgManager.getImg(src, function(ret:*):void {
							resetWidthHeight(ret);
						});
				} else {
					resetWidthHeight(_src);
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			if (_src is String && _src != ""){
				ImgManager.mvImg(_src);
			}
			super.dispose();
		}

		/**
		 * 设置图片内容
		 */
		public function set src(value:*):void {
			if (_src == value){
				return;
			}
			if (_src is String && _src != ""){
				ImgManager.mvImg(_src);
			}
			_src = value;
			_srcChange = true;
			invalidate();
		}
		public function get src():* {
			return _src;
		}

		/**
		 * 设置/获取   图片反转角度
		 */
		public function get imgFlip():String {
			return _imgFlip;
		}
		public function set imgFlip(value:String):void {
			_srcChange = true;
			_imgFlip = value;
			invalidate();
		}

	}
}