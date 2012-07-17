package now.container {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	
	import now.event.UiEvent;
	import now.manager.ImgManager;
	import now.manager.SoundManager;
	import now.manager.TipManager;
	import now.nui.Img;
	import now.nui.Label;
	import now.nui.Ui;
	import now.nui.UiConst;
	
	/**
	 * tab导航。
	 * 一个TAB导航分为，
	 * 顶部菜单列表。中间容器背景。
	 * 所以需要特别注意，在TabNav的child会比想象中多2个，1头，1尾。0=中间容器的背景。len=第内部菜单列表
	 * 这个类要抛弃了，因为后来实际开发中，基本都是一个TabBtn+一个Container，然后自己处理切换更省事
	 */
	public final class TabNav extends Container {
		private var _idx:int = 0;
		private var _topMenu:Container;
		private var _ydis:int = 0;
		public var hgap:Number = 0;
		public var tabs:Array = [];
		
		/**
		 * 构造函数
		 * @param	xpos	X轴
		 * @param	ypos	Y轴
		 */
		public function TabNav(xpos:Number = 0, ypos:Number = 0){
			super(xpos, ypos);
			setSize(400, 300);
		}
				
		/**
		 * 增加子组件
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "TabNav";
			_topMenu = new Container(0, 0);
			_topMenu.draw();
			addChild(_topMenu);
		}
		
		/**
		 * 点击tab页按钮，进行界面切换
		 */
		private function itemChange(e:MouseEvent):void {
			SoundManager.play(UiConst.SOUND_TAB);
			//_idx初始值为0，菜单index最高
			var from_img:Img =  _topMenu.getChildAt(_idx) as Img;
			var to_img:Img = e.currentTarget as Img;
			var newIdx:int = _topMenu.getChildIndex(to_img);
			if (newIdx == _idx){
				return;
			}
			
			var from_tab:Array = tabs[_idx];
			getChildAt(from_tab[3]).visible = false;
			
			var to_tab:Array = tabs[newIdx];
			var ch:Container;
			if (to_tab[3]==-1) {//未初始化过
				ch = new to_tab[1](to_tab[2]) as Container;
				ch.draw();
				var tidx:int = numChildren - 1;
				addChildAt(ch,tidx);//放在倒数第二，topmenu最后
				to_tab[3] = tidx;
			}else {
				ch = getChildAt(to_tab[3]) as Container;
				ch.visible = true;
			}
			
			//topmenu的_idx切换为def，newIdx切换为act
			from_img.src = from_tab[0] + "_def";
			to_img.src = to_tab[0] + "_act";
			
			_idx = newIdx;
			this.dispatchEvent(new UiEvent(UiEvent.TAB_NAV_CLICK, _idx));
		}
		
		public function addTab(img:String,cls:Class,lblCls:*):void {
			tabs.push([img,cls,lblCls,-1]);//-1为未初始化过,否则为container的idx
		}
		
		public function setToolTip(idx:int, tip:String):void {
			var img:Img = _topMenu.getChildAt(idx) as Img;
			TipManager.bindTip(img,UiConst.TOP,tip);
		}
				
		/**
		 * 进行界面绘制
		 */
		override public function draw():void {
			super.draw();
			var len:int = tabs.length;
			if (len == 0){//没有tab页
				return;
			}
			//显示tab页
			_topMenu.removeAllChildren();
			var i:int = 0;
			var nx:int = 0;
			var lbl:String;
			var img:Img;
			var src:String;
			var arr:Array;
			for (i = 0; i < len; i++) {
				arr = tabs[i];
				lbl = arr[0];
				src = (i == _idx) ? lbl + "_act" : lbl + "_def";
				img = new Img(0, 0, src);
				img.resizeContent = true;
				img.addEventListener(MouseEvent.CLICK, itemChange);
				img.draw();
				img.x = nx;
				nx = nx + img.width + hgap;
				_topMenu.addChild(img);
			}
			
			var con:Container;
			for (i = 0; i < numChildren - 1; i++) {//最后一个为tabmenu
				con = getChildAt(i) as Container;
				con.visible = false;
			}
				
			arr = tabs[_idx];
			if (arr[3] == -1) {//还未初始化过
				con = new arr[1](arr[2]) as Container;
				con.draw();
				var tidx:int = numChildren - 1;
				addChildAt(con, tidx);
				arr[3] = tidx;//idx为tidx
			}else {//显示第一个
				con = getChildAt(arr[3]) as Container;
				con.visible = true;
			}
		}
		
		/**
		 * 设置/获取 当前激活的子页面索引
		 */
		public function get idx():int {
			return _idx;
		}
		public function set idx(value:int):void {
			if (_idx == value){
				return;
			} else {
				_idx = value;
				invalidate();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			var img:DisplayObject;
			var i:int = _topMenu.numChildren;
			while (i > 0) {
				img = _topMenu.removeChildAt(0);
				img.removeEventListener(MouseEvent.CLICK, itemChange);
				Img(img).dispose();
				img = null;
				i = i - 1;
			}
			super.dispose();
			_topMenu = null;
			tabs = null;
		}
	}
}