package now.container {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.InlineGraphicElement;
	
	import now.bind.Collection;
	import now.bind.ObjProxy;
	import now.event.UiEvent;
	import now.inter.IItem;
	import now.nui.ImgBtn;
	import now.nui.UiConst;

	/**
	 * 一个左右滚动的页面。
	 * SNS游戏中常用的下方好友列表容器
	 */
	public final class RPage extends Container {
		private var _collection:Collection; 		//所有数据
		
		private var _itemGap:int = 0; 		//每个子项的间隔
		private var _btnGap:int = 0;		//两边的翻页按钮的纵向间距
		private var _conGap:int = 0;		//左边翻页box，中间数据，右边翻页box，他们之间的横向间距
		private var _pageSize:int = 2;		//每页显示内容
		private var _nowPos:int = 0; 		//当前位置
		private var _oldPos:int = 0;			//旧的位置
		
		private var _itemClass:Class = null; //
		private var _boxChange:Boolean = true;

		private var _preBox:VBox;
		private var _nextBox:VBox;
		private var _itemCon:Container;

		private var _btnPreRec:ImgBtn = null;
		private var _btnPrePage:ImgBtn = null;
		private var _btnNextRec:ImgBtn = null;
		private var _btnNextPage:ImgBtn = null;
		
		private var _itemArr:Array = [];
		
		/**
		 * 构造函数
		 */
		public function RPage(xpos:Number = 0, ypos:Number = 0, itemClass:Class=null, pageSize:int = 2, itemGap:int = 0, btnGap:int = 4, conGap:int = 4){
			_itemClass = itemClass
			_pageSize = pageSize;
			_itemGap = itemGap;
			_btnGap = btnGap
			_conGap = conGap;
			super(xpos, ypos);
		}

		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "RPage";
			_itemCon = new Container(0,0);
			addChild(_itemCon);
			
			var tmp:int;
			var dsp:DisplayObject;
			for (tmp=0; tmp<_pageSize; tmp++){
				dsp = new _itemClass();
				dsp.x = 0;
				dsp.y = 0;
				_itemCon.addChild(dsp);
				_itemArr.push(dsp);
			}
			
			_nextBox = new VBox(0, 0, _btnGap);
			_btnNextRec = new ImgBtn(0, 0, "skin_rpage_one", doAction);
			_btnNextRec.id = "nextRec";
			_btnNextRec.imgFlip = UiConst.HORIZONTAL;
			_btnNextRec.draw();
			_nextBox.addChild(_btnNextRec);
			_btnNextPage = new ImgBtn(0, 0, "skin_rpage_page", doAction);
			_btnNextPage.id = "nextPage";
			_btnNextPage.imgFlip = UiConst.HORIZONTAL;
			_btnNextPage.draw();
			_nextBox.addChild(_btnNextPage);
			addChild(_nextBox);
			
			_preBox = new VBox(0, 0, _btnGap);
			_btnPreRec = new ImgBtn(0, 0, "skin_rpage_one", doAction);
			_btnPreRec.addEventListener(Event.COMPLETE, resetPos);
			_btnPreRec.id = "preRec";
			_btnPreRec.draw();
			_preBox.addChild(_btnPreRec);
			_btnPrePage = new ImgBtn(0, 0, "skin_rpage_page", doAction);
			_btnPrePage.id = "prePage";
			_btnPrePage.draw();
			_preBox.addChild(_btnPrePage);
			addChild(_preBox);
		}
		
		/**
		 * 重设位置
		 */
		private function resetPos(e:Event):void{
			_btnPreRec.removeEventListener(Event.COMPLETE, resetPos);
			
			var tmp:int;
			var dsp:DisplayObject;
			var all:int = 0;
			dsp = _itemCon.getChildAt(0);
			var itemWidth:int  = dsp.width;
			
			//设置位置
			tmp = dsp.height * 0.5 - (_btnPreRec.height * 2 + _btnGap) * 0.5;
			_preBox.x = 0;
			_preBox.y = tmp;
			
			all = all + _btnPreRec.width + _conGap;
			for (tmp=0; tmp<_pageSize; tmp++){
				dsp = _itemCon.getChildAt(tmp);
				dsp.x = all;
				dsp.y = 0;
				all = all + itemWidth + _itemGap;
			}
			all = all - _itemGap + _conGap; 
			
			_nextBox.x = all;
			_nextBox.y = _preBox.y;
			width = all + _btnPreRec.width;
			height = dsp.height;
		}

		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			if(_collection){
				_collection.removeEventListener(UiEvent.BIND_ITEM_ADD,itemAdd);
				_collection.removeEventListener(UiEvent.BIND_ITEM_DEL,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_CLEAR,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_SORT,itemSort);
			}
			var max:int = _itemCon.numChildren;
			var item:IItem;
			var i:int = 0;
			for (i=0; i<max; i++){
				item = _itemCon.getChildAt(i) as IItem;
				if (item.data){
					item.data.removeEventListener(UiEvent.BIND_VAL_MDF, item.dataChange);
				}
			}
			super.dispose();
			_preBox = null;
			_nextBox = null;
			_btnPreRec = null;
			_btnPrePage = null;
			_btnNextRec = null;
			_btnNextPage = null;
			_itemCon = null;
		}
		
		/**
		 * 处理分页
		 * @param	e	MouseEvent
		 */
		private function doAction(e:MouseEvent):void {
			var act:String = e.currentTarget.id;
			if (act == "preRec"){ //点击上一笔
				_nowPos = _nowPos + 1;
			} else if (act == "prePage"){ //点击上一页
				_nowPos = _nowPos + _pageSize;
			} else if (act == "nextRec"){ //下一笔
				_nowPos = _nowPos - 1;
			} else { //下一页
				_nowPos = _nowPos - _pageSize;
			}
			resetBtn();
			resetUi();
		}
		
		/**
		 * 重设UI
		 */
		private function resetUi():void{
			var end:int = Math.min(_nowPos + _pageSize, _collection.length);
			var op:ObjProxy;
			var item:IItem;
			var i:int;
			var j:int = 0;
			
			//重新设置
			for (i = 0; i< _pageSize; i++){
				j = _nowPos + i;
				item = _itemCon.getChildAt(i) as IItem;
				if (item.data != null){
					item.data.removeEventListener(UiEvent.BIND_VAL_MDF, item.dataChange);
				}
				
				if ( j < end){
					op = _collection.getItem(j);
					item.data = op;
					op.addEventListener(UiEvent.BIND_VAL_MDF,item.dataChange);
				} else {
					item.data = null;
				}
			}
		}
		
		/**
		 * 重设按钮状态
		 */
		private function resetBtn():void{
			var tmp:int = _collection.length - _pageSize;
			if (_nowPos > tmp){
				_nowPos = tmp;
			}
			if (_nowPos < 0){
				_nowPos = 0;
			}
			var flag:Boolean = (_nowPos > 0);
			_btnPreRec.enabled = flag;
			_btnPrePage.enabled = flag;
			
			flag = (tmp > _nowPos)
			_btnNextPage.enabled = flag;
			_btnNextRec.enabled = flag;
		}
		
		/**
		 * 增加一项。如果
		 */
		private function itemAdd(e:UiEvent):void{
			//  1 2 3 0 0  
			//  0 + 5 - 3 = 2      = 5 -2 = 3
			// 2 3 4 5 6 [7]
			// 1 + 5 - 7 = - 1    = 5 - -1 = 6
			// 4 5 6 7 0
			// 3 + 5 - 7 = 1     = 5 - 1 = 4
			// 7 0 0 0 0
			//6 + 5 - 7  = 4    = 5 - 4 = 1
			var j:int = _collection.length - _nowPos;
			var op:ObjProxy;
			var idc:IItem;
			if (j < _pageSize){	//还有剩余的笔数大于1页
				op = _collection.getItem(_collection.length-1);
				idc = _itemCon.getChildAt(j) as IItem;
				idc.data = op;
				op.addEventListener(UiEvent.BIND_VAL_MDF,idc.dataChange);
				
			}
			resetBtn();
		}
		
		/**
		 * 删除一笔，清空所有数据，重新排序，我们都全部重排
		 */
		private function itemSort(e:UiEvent=null):void{
			_nowPos = 0;
			resetBtn();
			resetUi();
		}
		
		//-------------------------------------------
		//一些setter和getter
		//-------------------------------------------

		/**
		 * 设置/获取 数据集合
		 */
		public function get collection():Collection {
			return _collection;
		}
		public function set collection(value:Collection):void {
			if (_collection == value){//如果是同一个Collection,不处理
				return;
			}
			if (_collection){
				_collection.removeEventListener(UiEvent.BIND_ITEM_ADD,itemAdd);
				_collection.removeEventListener(UiEvent.BIND_ITEM_DEL,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_CLEAR,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_SORT,itemSort);
			}
			_collection = value;
			if (_collection){
				_collection.addEventListener(UiEvent.BIND_ITEM_ADD,itemAdd);
				_collection.addEventListener(UiEvent.BIND_ITEM_DEL,itemSort);
				_collection.addEventListener(UiEvent.BIND_ITEM_CLEAR,itemSort);
				_collection.addEventListener(UiEvent.BIND_ITEM_SORT,itemSort);
			}
			itemSort();
		}

	}
}