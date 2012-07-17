package now.nui {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import now.manager.StyleManager;
	import now.manager.TipManager;

	[Event(name="resize",type="flash.events.Event")]
	[Event(name="draw",type="flash.events.Event")]

	/**
	 * 所有UI组件的基类
	 */
	public class Ui extends Sprite{
		public var id:String = "";
		public var bindTip:Boolean = false;		//是否进行了tip绑定
		public var tipData:Array = new Array();		//tip的相关数据		[0=方向，1=内容，2=距离,3=类,4=parent] 如果3不存在则使用默认的
		public var uiData:Object;		//用来存放数据用的

		protected var _name:String = ""; //基础ui的名字，该名字将用于样式的设置
		protected var _width:Number = 0; //宽度
		protected var _height:Number = 0; //高度
		protected var _style:Object = {}; //针对当前实例的特定样式
		
		protected var _this:* = this;	//当前事例
		private var _enabled:Boolean = true; //是否起效		
		
		public var sort:Number = 0;//排序

		/**
		 * 构造函数
		 * @param xpos X轴
		 * @param ypos Y轴
		 */
		public function Ui(xpos:Number = 0, ypos:Number = 0){
			move(xpos, ypos);
			addChildren();
		}
		
		/**
		 * 获取样式信息
		 * @param		key		样式名称
		 * @param		def		默认值
		 * @return	*
		 */
		public function getStyle(key:String,def:*=null):* {
			if (_style[key] == undefined){
				_style[key] = StyleManager.getStyleByName(_name, key);
			}
			if (def != null && _style[key] == undefined){
				return def;
			} else {
				return _style[key];
			}
		}

		/**
		 * 增加子组件
		 */
		protected function addChildren():void {
		}

		/**
		 * 标记当下一帧来的时候重绘界面
		 */
		protected function invalidate():void {
			if (!_this.hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, onInvalidate);
			}
		}

		/**
		 * 移动组件
		 * @param xpos X坐标
		 * @param ypos Y坐标
		 */
		public function move(xpos:Number, ypos:Number):void {
			x = Math.round(xpos);
			y = Math.round(ypos);
		}

		/**
		 * 清除资源
		 */
		public function dispose():void {
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			if (this.bindTip) {
				TipManager.unbindTip(this);
			}
			_style = null;
			_this = null;
			tipData = null;
		}

		/**
		 * 设置宽高
		 * @param w 宽
		 * @param h 高
		 */
		public function setSize(w:Number, h:Number):void {
			if (w != _width || h != _height){
				_width = w;
				_height = h;
				invalidate();
				dispatchEvent(new Event(Event.RESIZE));
			}
		}

		/**
		 * 绘制界面的方法
		 */
		public function draw():void {
			dispatchEvent(new Event(UiConst.DRAW));
		}


		/**
		 * 设置样式
		 * @param	key		样式key
		 * @param	value	样式内容
		 */
		public function setStyle(key:String, value:*):void {
			if (!value){
				return;
			}
			if (getStyle(key) == value){
				return;
			}
			_style[key] = value;
			invalidate();
		}

		/**
		 * 监听到新的一帧来了。进行重绘
		 * @param	event	事件内容
		 */
		private function onInvalidate(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			draw();
		}


		/**
		 * 设置/获取  宽度
		 */
		override public function set width(w:Number):void {
			if (_width == w){
				return;
			}
			_width = w;
			invalidate();
			dispatchEvent(new Event(Event.RESIZE));
		}
		override public function get width():Number {
			return _width;
		}

		/**
		 * 设置/获取 高度
		 */
		override public function set height(h:Number):void {
			if (_height == h){
				return;
			}
			_height = h;
			invalidate();
			dispatchEvent(new Event(Event.RESIZE));
		}
		override public function get height():Number {
			return _height;
		}


		/**
		 * 覆盖了设置x轴的方法，使得它每次移动都占一个完整的像素点
		 * @param	num		x轴
		 */
		override public function set x(num:Number):void {
			super.x = Math.round(num);
		}

		/**
		 * 覆盖了设置y轴的方法，使得它每次移动都占一个完整的像素点
		 * @param	num		y轴
		 */
		override public function set y(num:Number):void {
			super.y = Math.round(num);
		}


		/**
		 * 设置/获取 是否有效
		 * @param	value	是否生效
		 */
		public function set enabled(value:Boolean):void {
			if (value == _enabled){
				return;
			}
			_enabled = value;
			mouseEnabled = mouseChildren = _enabled;
			tabEnabled = value;
			invalidate();
		}
		public function get enabled():Boolean {
			return _enabled;
		}

		/**
		 * 反悔父组件。一般我们用此方法来替代  get parent() 方法<br/>
		 * 因为我们的container容器分了3层（背景、前景、容器）。则container的child。它的parent是container的_content容器。
		 * 而一般，我们希望得到的确实container自身。所以提供了此方法。
		 */
		public function get parentDoc():* {
			if (parent is Content){
				return parent.parent;
			} else {
				return parent;
			}
		}
	}
}