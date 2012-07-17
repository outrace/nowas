package now.container {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import now.base.BusSys;
	import now.nui.ImgBtn;
	import now.nui.UiConst;
	
	/**
	 * 一个tab页面顶部的按钮列表
	 * 使用的是imgBtn
	 */
	public final class TabImgBtn extends Container {
		private var _direct:String;				//方向。目前支持横向和纵向
		private var _gap:int = 0;					//按钮的间隔。也就是box的间隔
		private var _hdl:Function = null;		//点击切换后的处理函数，包含一个参数。就是当前点击按钮的idx
		private var _embed:Boolean = false;		//是否嵌入式图片
		
		private var _btnArr:Vector.<String>;	//按钮数组
		
		private var _idx:int = 0;		//当前激活的idx
		
		private var _loadOk:int = 0;
		
		/**
		 * 构造函数
		 * @param	xpos	x轴
		 * @param	ypos	y轴
		 * @param	hdl		点击切换后的处理函数，包含一个参数：当前点击按钮的idx。0开始
		 * @param	direct	方向UiConst.HORIZONTAL【默认】 和 UiConst.VERTICAL
		 * @param	gap		按钮间隔
		 * @param	embed 是否嵌入式图片
		 */
		public function TabImgBtn(xpos:Number=0, ypos:Number=0,hdl:Function=null,
							   direct:String=UiConst.HORIZONTAL, btnArr:Vector.<String>=null,
							   gap:int=0,embed:Boolean=false) {
			_hdl = hdl;
			_direct = direct;
			_btnArr = btnArr;
			_gap = gap;
			_embed = embed;
			super(xpos,ypos);
			invalidate();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void{
			super.addChildren();
			var btn:ImgBtn;
			var s:String;
			var bstr:String;
			var i:int = 0;
			for each (bstr in _btnArr) {
				if (i == 0){
					s = bstr + "_act.png";
				} else {
					s = bstr + "_def.png";
				}
				if (!_embed){
					s = BusSys.getRes(s);
				}
				btn = new ImgBtn(0,0,s,hdlClick,false);
				btn.addEventListener(Event.COMPLETE, picOk);
				addChild(btn);
				i = i + 1;
			}
		}
		
		private function picOk(e:Event):void{
			(e.currentTarget as ImgBtn).removeEventListener(Event.COMPLETE, picOk);
			_loadOk = _loadOk + 1;
			if (_loadOk == _btnArr.length){
				//对图片进行重新排序
				var max:int = numChildren;
				var i:int;
				var btn:ImgBtn;
				var tmp:int = 0;
				if (_direct == UiConst.HORIZONTAL){
					for (i=0; i<max; i++){
						btn = getChildAt(i) as ImgBtn;
						btn.x = tmp;
						tmp = btn.x + btn.width + _gap;
						btn.y = 0;
					}
				} else {
					for (i=0; i<max; i++){
						btn = getChildAt(i) as ImgBtn;
						btn.x = 0;
						btn.y = tmp;
						tmp = btn.y + btn.height + _gap;
					}
				}
			}
		}
		
		/**
		 * 处理点击事件
		 */
		private function hdlClick(e:MouseEvent):void{
			var btn:ImgBtn = e.currentTarget as ImgBtn;
			
			var max:int = numChildren;
			var thisIdx:int = 0;
			var i:int;
			for (i=0; i<max; i++){
				if (getChildAt(i) == btn){
					if (_idx != i){
						btn.src = (btn.src as String).replace("_def","_act");
						btn = getChildAt(_idx) as ImgBtn;
						btn.src = (btn.src as String).replace("_act","_def");
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
			var btn:ImgBtn = getChildAt(_idx) as ImgBtn;
			btn.src = (btn.src as String).replace("_act","_def");
			
			_idx = val;
			btn = getChildAt(_idx) as ImgBtn;
			btn.src = (btn.src as String).replace("_def","_act");
		}
		public function get idx():int{
			return _idx;
		}
	}
}