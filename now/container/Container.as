package now.container {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import now.manager.ImgManager;
	import now.nui.Content;
	import now.nui.Ui;
	import now.nui.UiConst;
	import now.util.UiUtil;

	/**
	 * 所有Container的基类。默认提供的启示是x/y的绝对定位布局
	 */
	public class Container extends Ui {
		/**
		 * 背景是否变更了，如果变更了，在draw的时候会对背景进行重绘
		 */
		protected var _bgChange:Boolean = true;

		/**
		 * 我们分了2个层，内容层，背景层
		 * 对于普通用户而言，并不需要了解背景层【用于设置背景颜色，背景图片，边框】
		 * 普通用户会以为只有内容层[conent]
		 */
		protected var _content:Content;
		protected var _bg:Sprite = null;

		/**
		 * 构造函数
		 * @param xpos x轴
		 * @param ypos y轴
		 */
		public function Container(xpos:Number = 0, ypos:Number = 0){
			super(xpos, ypos);
			this.addEventListener(Event.RESIZE, resetBackground);
		}

		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			_content = new Content();
			super.addChild(_content);
			super.addChildren();
			_name = "Container";
		}

		/**
		 * 覆盖了addChild方法，我们总是把最后增加的child放在末尾
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			return addChildAt(child, numChildren);
		}

		/**
		 * 覆盖了addChildAt方法，我们把增加的child放在中间的content层上。
		 * 其实我们在前面和后面还有另外的层
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			_content.addChildAt(child, index);
			return child;
		}

		/**
		 * 覆盖了getChildAt方法，从content层取
		 */
		override public function getChildAt(index:int):DisplayObject {
			return _content.getChildAt(index);
		}

		/**
		 * 覆盖了getChildByName方法，从content层取
		 */
		override public function getChildByName(name:String):DisplayObject {
			return _content.getChildByName(name);
		}

		/**
		 * 覆盖了getChildIndex方法，从content层取
		 */
		override public function getChildIndex(child:DisplayObject):int {
			return _content.getChildIndex(child);
		}

		/**
		 * 覆盖了removeChild方法，我们只是从content层移除了child
		 * 并根据child是否Ui组件，来进行资源释放
		 */
		override public function removeChild(child:DisplayObject):DisplayObject {
			_content.removeChild(child);
			mvChild(child);
			return child;
		}

		/**
		 * 覆盖了removeChildAt方法，我们只是从content层移除了child
		 * 并根据child是否Ui组件，来进行资源释放
		 */
		override public function removeChildAt(index:int):DisplayObject {
			var child:DisplayObject = _content.removeChildAt(index);
			mvChild(child);
			return child;
		}

		/**
		 * 移除自组件后，都会调用这里
		 * 子类可通过覆盖此方法来处理一些子组件移除的事情。
		 */
		protected function mvChild(child:DisplayObject):void {
		}

		/**
		 * 设置子组件的排序位置
		 */
		override public function setChildIndex(child:DisplayObject, index:int):void {
			_content.setChildIndex(child, index);
		}

		/**
		 * 移除所有子组件
		 */
		public function removeAllChildren(dispose:Boolean=true):void {
			var max:int = _content.numChildren;
			var dsp:DisplayObject;
			while (max > 0){
				dsp = removeChildAt(0);
				if (dispose && dsp is Ui){
					Ui(dsp).dispose();
				}
				dsp = null;
				max = max - 1;
			}
		}


		/**
		 * 覆盖了numChildren方法，返回的是content层的数据
		 */
		override public function get numChildren():int {
			return _content.numChildren;
		}
		
		/**
		 * 重设背景层。可以用一个scale9的元件来做背景。也可以指定背景颜色
		 */
		private function resetBackground(e:Event=null):void {
			//根据是否有设置背景图片或者背景颜色，来绘制背景
			if (!_bg){
				_bg = new Sprite();
				super.addChildAt(_bg, 0);
			}
			if (_bg.numChildren > 0){
				_bg.removeChildAt(0);
			}
			var bgStyle:* = getStyle("bgImg");
			if (bgStyle != undefined){
				if (bgStyle is String) {
					if (bgStyle == "") {
						return;
					}
					ImgManager.getImg(bgStyle, function(ret:DisplayObject):void {
							var rep:String = getStyle("bgRepeat");
							if (rep == "Y") {
								UiUtil.repeatDis(ret, _bg,_width,_height);
							} else {
								ret.width = _width;
								ret.height = _height;
								_bg.addChild(ret);
							}
							_bg.width = _width;
							_bg.height = _height;
						});
				} else {
					bgStyle.width = _width;
					bgStyle.height = _height;
					_bg.addChild(bgStyle);
					_bg.width = _width;
					_bg.height = _height;
				}
			} else {
				bgStyle = getStyle("bgColor");
				if (bgStyle != undefined) {
					if (bgStyle == "") {
						return;
					}
					var round:int = getStyle("bgRound");
					if (isNaN(round)) {
						round = 0;
					}
					var border:int = getStyle("border");	//边框的宽度
					var borderColor:int = getStyle("borderColor");
					if (isNaN(border) || border < 0 ) {
						border = 0
					}
					UiUtil.rectangle(_bg,_width,_height,bgStyle,round,border,borderColor);
				}
			}
			var bgAlpha:* = getStyle("bgAlpha");
			if (bgAlpha != undefined){
				_bg.alpha = bgAlpha as Number;
			}
			_bgChange = false;
		}

		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			if (_bgChange){
				resetBackground();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			removeEventListener(Event.RESIZE, resetBackground);
			var i:int = numChildren - 1;
			var child:DisplayObject;
			while (i > -1) {
				child = removeChildAt(0);
				if (child is Ui) {
					Ui(child).dispose();
				}
				child = null;
				i = i - 1;
			}
			_content.dispose();
			
			var bgStyle:* = getStyle("bgImg");
			if (bgStyle != undefined){
				if (bgStyle is String) {
					ImgManager.mvImg(bgStyle);
				}
			}
			super.dispose();
			_content = null;
			_bg = null;
		}

		/**
		 * 设置样式，我们覆盖了此方法，以便确认是否需要重绘背景
		 * @param	key		样式名称
		 * @param	value	样式内容
		 */
		override public function setStyle(key:String, value:*):void {
			if (_this.getStyle(key) == value){
				return;
			}
			if (key == "bgColor" || key == "bgImg" || key == "border" || key == "borderColor" || key == "bgRound"){
				_bgChange = true;
			}
			super.setStyle(key, value);
		}

	}
}