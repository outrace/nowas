package now.container {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import now.nui.Ui;
	
	import now.manager.ImgManager;
	import now.nui.UiConst;
	
	[Event(name = "resize", type = "flash.events.Event")]
	
	/**
	 * VBox和Hbox的基类。提供了绝对定位，横向，纵向3种定位
	 */
	public class Box extends Container {
		private var _onDispose:Boolean = false;
		
		/**
		 * 间隔距离
		 */
		protected var _gap:int = 2;
		
		/**
		 * 布局方式，可选
		 * <ul>
		 * <li>UiConst.ABSOLUTE	绝对值定位</li>
		 * <li> UiConst.HORIZONTAL 横向布局</li>
		 * <li> UiConst.VERTICAL  纵向布局</li>
		 * </ul>
		 */
		protected var _layout:String = UiConst.ABSOLUTE;
		
		/**
		 * 横向对齐方式，可选
		 * <ul>
		 * <li>UiConst.LEFT	左对齐</li>
		 * <li> UiConst.RIGHT 右对齐</li>
		 * <li> UiConst.CENTER  中间对齐</li>
		 * </ul>
		 */
		protected var _halign:String = UiConst.LEFT;
		
		/**
		 * 纵向对齐方式，可选
		 * <ul>
		 * <li>UiConst.TOP	顶部对齐</li>
		 * <li> UiConst.BOTTOM 底部齐</li>
		 * <li> UiConst.MIDDLE  居中对齐</li>
		 * </ul>
		 */
		protected var _valign:String = UiConst.TOP;
		
		/**
		 * 构造函数
		 * @param	xpos	X轴
		 * @param	ypos	Y轴
		 * @param	gap		子组件之间的间隔
		 */
		public function Box(xpos:Number=0, ypos:Number=0, gap:int = 2) {
			super(xpos, ypos);
			_gap = gap;
		}
		
		/**
		 * 覆盖了addChildAt方法，在增加子组件的时候，监听其RESIZE事件
		 * 以便当resize的时候调整各子组件的坐标
		 * @param	child	子组件
		 * @param	index	所在深度
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject{
			var c:DisplayObject = super.addChildAt(child,index);
			child.addEventListener(Event.RESIZE, onResize);//当子容器重设宽，高，我
			invalidate();
			return c;
		}
		
		/**
		 * 覆盖了mvChild方法,
		 * 以便在移除子组件的时候，移除resize的事件监听，并重绘界面
		 * @param	child	子组件
		 */
		override protected function mvChild(child:DisplayObject):void{
			child.removeEventListener(Event.RESIZE, onResize);
			super.mvChild(child);
			if (!_onDispose) {				
				invalidate();
			}
		}
		
		/**
		 * resize事件的处理函数
		 * @param event		事件
		 */
		protected function onResize(event:Event):void {
			invalidate();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw() : void {
			if (_layout == UiConst.HORIZONTAL){
				hDraw();
			} else if (_layout == UiConst.VERTICAL){
				vDraw();
			} else {
				super.draw();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			_onDispose = true;
			var i:int = numChildren - 1;
			var child:DisplayObject;
			while (i > -1) {
				child = getChildAt(0);
				child.removeEventListener(Event.RESIZE, onResize);
				removeChildAt(0);
				if (child is Ui) {
					Ui(child).dispose();
				}
				child = null;
				i = i - 1;
			}
			super.dispose();
		}
		
		/**
		 * 进行横向的界面绘制
		 * 我们假设用户知道最大的高度和宽度，所以当实际宽高超过设置的宽高，我们延伸它
		 */
		private function hDraw():void{
			var t_height:Number = 0;//最大高度
			var t_width:Number = 0;//最大宽度
			var xpos:Number = 0;//第一个child的x轴
			var child:DisplayObject;
			var i:int = 0;
			var j:int = 0;//
			
			var pTop:int = paddingTop;
			var pBottom:int = paddingBottom;
			var pLeft:int = paddingLeft;
			var pRight:int = paddingRight;
			var resize:Boolean = false;
			
			//计算所有子容器的宽度，并计算子容器带来的最大的高度
			for(i=0;i<numChildren;i++){
				child = getChildAt(i);
				j += (child.width + _gap);//子容器+间隔的总宽度
				t_height = Math.max(t_height, child.height);
			}
			t_height = t_height + pTop + pBottom;
			t_width = j + pLeft + pRight;
			
			if (_height < t_height){
				_height = t_height;
				resize = true;
			}
			if (_width < t_width){
				_width = t_width;
				resize = true;
				xpos = pLeft;
			} else {
				if (_halign == UiConst.LEFT){//左对齐
					xpos = pLeft;
				} else 	if (_halign == UiConst.CENTER){//居中对齐
					xpos = pLeft + (_width - pLeft - pRight - j)/2;
				} else {//右对齐
					xpos = _width - j - pRight;
				}
			}
			
			for(i = 0; i < numChildren; i++) {
				child = getChildAt(i);
				child.x = xpos;
				xpos += child.width;
				xpos += _gap;
				if(_valign == UiConst.TOP) {
					child.y = pTop;
				} else if(_valign == UiConst.BOTTOM) 	{
					child.y = _height - child.height - pBottom;
				} else if(_valign == UiConst.MIDDLE) {
					child.y = pTop + (_height - pTop - pBottom - child.height) / 2;
				}
			}
			if (resize){
				_bgChange = true;
				dispatchEvent(new Event(Event.RESIZE));
			}
			super.draw();
		}
		
		
		/**
		 * 进行垂直布局方式的绘制
		 */
		private function vDraw() : void {
			var t_height:Number = 0;//最大高度
			var t_width:Number = 0;//最大宽度
			var ypos:Number = 0;//第一个child的y轴
			var child:DisplayObject;
			var i:int = 0;
			var j:int = 0;//子容器+间隔带来的高度
			
			var pTop:int = paddingTop;
			var pBottom:int = paddingBottom;
			var pLeft:int = paddingLeft;
			var pRight:int = paddingRight;
			var resize:Boolean = false;
			
			//计算所有子容器的高度，并计算子容器带来的最大的宽度
			for(i=0;i<numChildren;i++){
				child = getChildAt(i);
				j += (child.height + _gap);//子容器+间隔的总宽度
				t_width = Math.max(t_width, child.width);
			}
			t_height = j + pTop + pBottom;
			t_width = t_width + pLeft + pRight;
			
			if (_height < t_height){
				_height = t_height;
				resize = true;
				ypos = pTop;
			} else {
				if (_valign == UiConst.TOP){//顶部对齐
					ypos = pTop;
				} else 	if (_valign == UiConst.MIDDLE){//居中对齐
					ypos = pTop + (_height - pTop - pBottom - j)/2;
				} else {//底部对齐
					ypos = _height - j - pBottom;
				}
			}
			if (_width < t_width){
				_width = t_width;
				resize = true;
			}
			
			for(i = 0; i < numChildren; i++) {
				child = getChildAt(i);
				child.y = ypos;
				ypos += child.height;
				ypos += _gap;
				if(_halign == UiConst.LEFT) {//左对齐
					child.x = pLeft;
				} else if(_halign == UiConst.CENTER) 	{//居中对齐
					child.x = pLeft + (_width - pLeft - pRight - child.width) / 2;
				} else if(_halign == UiConst.RIGHT) {//右对齐
					child.x = _width - child.width + pBottom;
				}
			}
			if (resize){
				_bgChange = true;
				dispatchEvent(new Event(Event.RESIZE));
			}
			super.draw();
		}
		
		/**
		 * 设置/获得  间距
		 */
		public function set gap(num:int):void {
			_gap = num;
			invalidate();
		}
		public function get gap():int {
			return _gap;
		}
		
		
		/**
		 * 设置获取 上边距
		 */
		public function set paddingTop(num:int):void{
			setStyle("paddingTop",num);
		}
		public function get paddingTop():int{
			if (_style["paddingTop"] == undefined){
				return 0;
			} else {
				return _style["paddingTop"];
			}
		}
		/**
		 * 设置获取 下边距
		 */
		public function set paddingBottom(num:int):void{
			setStyle("paddingBottom",num);
		}
		public function get paddingBottom():int{
			if (_style["paddingBottom"] == undefined){
				return 0;
			} else {
				return _style["paddingBottom"];
			}
		}
		/**
		 * 设置/获取 左边距
		 */
		public function set paddingLeft(num:int):void{
			setStyle("paddingLeft",num);
		}
		public function get paddingLeft():int{
			if (_style["paddingLeft"] == undefined){
				return 0;
			} else {
				return _style["paddingLeft"];
			}
		}
		/**
		 * 设置/获取 右边距
		 */
		public function set paddingRight(num:int):void{
			setStyle("paddingRight",num);
		}
		public function get paddingRight():int{
			if (_style["paddingRight"] == undefined){
				return 0;
			} else {
				return _style["paddingRight"];
			}
		}
		
		
		/**
		 * 设置/获取 横向布局的样式
		 * <ul>
		 * <li>UiConst.LEFT	左对齐</li>
		 * <li> UiConst.RIGHT 右对齐</li>
		 * <li> UiConst.CENTER  中间对齐</li>
		 * </ul>
		 */
		public function set halign(value:String):void {
			_halign = value;
			invalidate();
		}
		public function get halign():String {
			return _halign;
		}
		
		/**
		 * 设置/获取 垂直布局的样式
		 * <ul>
		 * <li>UiConst.TOP	顶部对齐</li>
		 * <li> UiConst.BOTTOM 底部齐</li>
		 * <li> UiConst.MIDDLE  居中对齐</li>
		 * </ul>
		 */
		public function set valign(value:String):void {
			_valign = value;
			invalidate();
		}
		public function get valign():String {
			return _valign;
		}
	}
}