package now.container {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import now.bind.Collection;
	import now.bind.ObjProxy;
	import now.event.UiEvent;
	import now.inter.IItem;
	import now.nui.ImgBtn;
	import now.nui.UiConst;
	
	/**
	 * 横向分页组件
	 */
	public final class HPage extends Container {
		private var _collection:Collection;		//数据
		private var _row:int = 2;						//行数
		private var _col:int = 3;						//列数
		
		private var _itemHGap:int = 0; 		//每个子项的横间隔
		private var _itemVGap:int = 0; 		//每个子项的纵间隔
		private var _conGap:int = 0;			//左边翻页box，中间数据，右边翻页box，他们之间的横向间距
		
		
		private var _nowPage:int = 1;
		private var _pageSize:int = 6;		//每页显示内容
		private var _allPage:int = -1;		//总的页数
		
		private var _btnPre:ImgBtn;			//前一页
		private var _btnNext:ImgBtn;			//后一页
		private var _itemCon:Container;		//中间的容器
		private var _itemClass:Class;
		
		/**
		 * 构造函数
		 */
		public function HPage(xpos:Number, ypos:Number, itemClass:Class=null, row:int=2, col:int=3, itemHGap:int = 2, itemVGap:int=2, conGap:int=4) {
			_itemClass = itemClass;
			_row = row;
			_col = col;
			_pageSize = _row * _col;
			_itemHGap = itemHGap;
			_itemVGap = itemVGap;
			_conGap = conGap;
			super(xpos,ypos);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "HPage";
			
			_itemCon = new Container(0,0);
			addChild(_itemCon);
			var i:int = 0;
			var j:int = 0;
			var dsp:DisplayObject;
			for (i = 0; i < _row; i++){
				for (j = 0; j < _col; j++){
					dsp = new _itemClass();
					dsp.x = 0;
					dsp.y = 0;
					_itemCon.addChild(dsp);
				}
			}
			
			_btnPre = new ImgBtn(0, 0, "skin_hpage", doAction);
			_btnPre.addEventListener(Event.COMPLETE, resetPos);
			_btnPre.id = "pre";
			addChild(_btnPre);
			
			_btnNext = new ImgBtn(0, 0, "skin_hpage", doAction);
			_btnNext.imgFlip = UiConst.HORIZONTAL;
			_btnNext.id = "next";
			addChild(_btnNext);
		}
		
		/**
		 * 重设位置
		 */
		private function resetPos(e:Event):void{
			_btnPre.removeEventListener(Event.COMPLETE, resetPos);
			
			var dsp:DisplayObject;
			dsp = _itemCon.getChildAt(0);
			
			var i:int = 0;
			var j:int = 0;
			var iw:int = dsp.width;
			var ih:int = dsp.height;
			
			_height = ih * _row + _itemVGap * (_row - 1);
			_btnPre.x = 0;
			_btnPre.y =_height * 0.5- _btnPre.height * 0.5;
			
			var bw:int = _btnPre.width + _conGap;
			var bh:int = 0;
			var tmp:int = 0;
			for (i = 0; i < _row; i++){
				bh = i * ih + i * _itemVGap;
				for (j = 0; j < _col; j++){
					dsp = _itemCon.getChildAt(tmp);
					dsp.x = j*iw + j*_itemHGap;
					dsp.y = bh;
					tmp = tmp + 1;
				}
			}
			_itemCon.x = bw;
			_itemCon.y = 0;
			
			_btnNext.x = bw + _col * iw + (_col - 1) * _itemHGap + _conGap;
			_btnNext.y = _btnPre.y;
			_width = _btnNext.x + _btnPre.width;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void{
			if (_collection){
				_collection.removeEventListener(UiEvent.BIND_ITEM_ADD,itemAdd);
				_collection.removeEventListener(UiEvent.BIND_ITEM_DEL,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_CLEAR,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_SORT,itemSort);
			}
			var max:int = _itemCon.numChildren;
			var item:IItem;
			var op:ObjProxy;
			for (var i:int=0; i<max; i++){
				item = _itemCon.getChildAt(i) as IItem;
				op = item.data;
				if (op){
					op.removeEventListener(UiEvent.BIND_VAL_MDF, item.dataChange);
				}
			}
			super.dispose();
			_btnPre = null;
			_btnNext = null;
			_itemCon = null;
		}
		
		/**
		 * 进行翻页操作
		 */
		private function doAction(e:MouseEvent):void{
			var act:String = e.currentTarget.id;
			if (act == "pre"){ //点击上一笔
				_nowPage = _nowPage - 1;
			} else if (act == "next"){ //点击上一页
				_nowPage = _nowPage + 1;
			} 
			if (_nowPage < 0){
				_nowPage = 0;
			}
			if (_nowPage > _allPage){
				_nowPage = _allPage;
			}
			resetBtn();
			resetUi();
		}
		
		/**
		 * 重设界面
		 */
		private function resetUi():void{
			var nowPos:int = (_nowPage-1) * _pageSize;
			var end:int = Math.min(nowPos + _pageSize, _collection.length);
			var op:ObjProxy;
			var item:IItem;
			var i:int;
			var j:int = 0;
			
			//重新设置
			for (i = 0; i< _pageSize; i++){
				j = nowPos + i;
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
			_btnPre.enabled = (_nowPage > 1);
			_btnNext.enabled = (_nowPage < _allPage);
		}
		
		/**
		 * 增加一项。如果
		 */
		private function itemAdd(e:UiEvent):void{
			_allPage = Math.ceil(_collection.length / _pageSize);
			//如果只有一页，或者是最后一页。并且有空余的话，那么我们补充一笔
			var item:IItem;
			var op:ObjProxy;
			if (_nowPage == _allPage){
				var tmp:int = _collection.length % _pageSize ;
				if (tmp == 0){
					tmp = _pageSize -1;
				} else {
					tmp = tmp - 1;
				}
				item = _itemCon.getChildAt(tmp) as IItem;
				op = _collection.getItem(_collection.length-1);
				item.data = op;
				op.addEventListener(UiEvent.BIND_VAL_MDF,item.dataChange);
			}
			resetBtn();
		}
		
		/**
		 * 删除一笔，清空所有数据，重新排序，我们都全部重排
		 */
		private function itemSort(e:UiEvent=null):void{
			_nowPage = 1;
			_allPage = Math.ceil(_collection.length / _pageSize);
			resetUi();
			resetBtn();
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