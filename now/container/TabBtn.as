package now.container {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import now.nui.Button;
	import now.nui.UiConst;
	
	/**
	 * 使用普通按钮形式的TAB页
	 */
	public final class TabBtn extends Container {
		private var _direct:String;						//方向。目前支持横向和纵向
		private var _gap:int = 0;						//按钮的间隔。也就是box的间隔
		private var _hdl:Function = null;			//点击切换后的处理函数，包含一个参数。就是当前点击按钮的idx
		private var _btnArr:Vector.<String>;	//按钮数组
		private var _skinDef:String = "";			//皮肤文本，我们将这一替代。_def 为默认， _act 为激活。  所以这里传过来的应该是例如：  embed_btn_def    或者 http://a.com/pic_def.png
		private var _skinAct:String = "";			
		private var _idx:int = 0;							//当前激活的idx
		
		/**
		 * 构造函数
		 * @param	xpos		x轴
		 * @param	ypos		y轴
		 * @param	hdl		点击切换后的处理函数，包含一个参数：当前点击按钮的idx。0开始
		 * @param	direct	方向UiConst.HORIZONTAL【默认】 和 UiConst.VERTICAL
		 * @param	gap		按钮间隔
		 * @param	pos      tab的位置，支持UiConst.TOP/BOTTOM/LEFT/RIGHT
		 * @param	skin      图片地址
		 */
		public function TabBtn(xpos:Number=0, ypos:Number=0, hdl:Function=null,
							   direct:String=UiConst.HORIZONTAL, btnArr:Vector.<String>=null,
							   gap:int=0, pos:String=UiConst.TOP, skin:String="") {
			_hdl = hdl;
			_direct = direct;
			_btnArr = btnArr;
			_gap = gap;
			if (skin != ""){
				_skinDef = skin;
				_skinAct = skin.replace("_def","_act");
			} else {
				if ( _direct == UiConst.HORIZONTAL){
					_skinDef = "h_tab_def";
					_skinAct = "h_tab_act";
				} else {
					_skinDef = "v_tab_def";
					_skinAct = "v_tab_act";
				}
			}
			super(xpos,ypos);
			invalidate();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void{
			super.addChildren();
			_addBtn();
		}
		
		/**
		 * 增加按钮
		 */
		private function _addBtn():void{
			var btn:Button;
			var s:String;
			var bstr:String;
			var i:int = 0;
			var max:int = _btnArr.length;
			
			for each (bstr in _btnArr) {
				btn = new Button(0, 0, bstr, hdlClick, false);
				s = (i==0)? _skinAct :  _skinDef;
				i = i + 1;
				if (i == max){
					btn.addEventListener(Event.COMPLETE, resetPos);
				}
				btn.setStyle("skin_btn", s);
				addChild(btn);
			}
		}
		
		/**
		 * 设置按钮位置
		 */
		private function resetPos(e:Event):void{
			var max:int = numChildren;
			var i:int = 0;
			var dsp:DisplayObject;
			var w:int;
			var h:int;
			for (i=0; i < max; i++){
				dsp = getChildAt(i);
				if (i ==0){
					dsp.x = 0;
					dsp.y = 0;
					w = dsp.width;
					h = dsp.height;
				} else {
					if (_direct == UiConst.HORIZONTAL){//横向
						dsp.x = i * w + i * _gap;
						dsp.y = 0;
					} else {
						dsp.x = 0;
						dsp.y = i * h + i * _gap;
					}
				}
			}
		}
		
		/**
		 * 重设按钮列表
		 */
		public final function resetArr(btnArr:Vector.<String>):void{
			_btnArr = btnArr;
			removeAllChildren();
			_addBtn();
		}
		
		/**
		 * 处理点击事件
		 */
		private function hdlClick(e:MouseEvent):void{
			var btn:Button = e.currentTarget as Button;
			
			var max:int = numChildren;
			var thisIdx:int = 0;
			var i:int;
			var s:String;
			for (i=0; i<max; i++){
				if (getChildAt(i) == btn){
					if (_idx != i){
						btn.setStyle("skin_btn", _skinAct);
						btn = getChildAt(_idx) as Button;
						btn.setStyle("skin_btn", _skinDef);
					}
					thisIdx = i;
					break;
				}
			}
			
			//如果相同的idx。我们不往外抛
			if (_hdl  != null && thisIdx != _idx){
				_idx = thisIdx;
				_hdl(_idx);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void{
			super.dispose();
			_btnArr = null;
		}
		
		/**
		 * 设置获取当前的idx
		 */
		public function set idx(val:int):void{
			if (_idx == val){
				return;
			}
			var btn:Button = getChildAt(_idx) as Button;
			btn.setStyle("skin_btn", _skinAct);
			_idx = val;
			btn = getChildAt(_idx) as Button;
			btn.setStyle("skin_btn", _skinDef);
		}
		public function get idx():int{
			return _idx;
		}
	}
}
