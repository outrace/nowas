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
	 * 分页按钮在下方的分页方式
	 */
	public final class VPage extends Container {
		private var _collection:Collection;		//数据
		private var _row:int = 2;						//行数
		private var _col:int = 3;						//列数
		
		private var _itemHGap:int = 0; 		//每个子项的横间隔
		private var _itemVGap:int = 0; 		//每个子项的纵间隔
		private var _conGap:int = 0;			//左边翻页box，中间数据，右边翻页box，他们之间的横向间距
		private var _btnGap:int = 0;			//第一页和上一页，  下一页和最后一页的按钮距离
		private var _btnsGap:int = 0;			//左边分页和右边分页的间距
		
		
		private var _nowPage:int = 1;
		private var _pageSize:int = 6;		//每页显示内容
		private var _allPage:int = -1;		//总的页数
		
		private var _btnPre:ImgBtn;			//前一页
		private var _btnNext:ImgBtn;			//后一页
		private var _btnFirst:ImgBtn;			//第一页
		private var _btnLast:ImgBtn;			//最后一页
		
		private var _last:Boolean = false;	//是否显示第一页和最后一页这2个按钮
		
		private var _itemCon:Container;		//中间的容器
		private var _itemClass:Class;
		
		public function VPage(xpos:Number, ypos:Number, itemClass:Class=null, 
							  row:int=2, col:int=3, itemHGap:int = 2, itemVGap:int=2, 
							  conGap:int=4,btnGap:int=4,btnsGap:int=60, last:Boolean=false) {
			_itemClass = itemClass;
			_row = row;
			_col = col;
			_pageSize = _row * _col;
			_itemHGap = itemHGap;
			_itemVGap = itemVGap;
			_conGap = conGap;
			_btnGap = btnGap;
			_btnsGap = btnsGap;
			_last = last;
			super(xpos,ypos);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			_name = "VPage";
			_itemCon = new Container(0,0);
			addChild(_itemCon);
			var i:int = 0;
			var j:int = 0;
			for (i = 0; i < _row; i++){
				for (j = 0; j < _col; j++){
					_itemCon.addChild(new _itemClass());
				}
			}
			
			_btnPre = new ImgBtn(0, 0, "skin_vpage_one", doAction);
			_btnPre.addEventListener(Event.COMPLETE, resetPos);
			_btnPre.id = "pre";
			addChild(_btnPre);
			
			_btnNext = new ImgBtn(0, 0, "skin_vpage_one", doAction);
			_btnNext.id = "next";
			_btnNext.imgFlip = UiConst.HORIZONTAL;
			addChild(_btnNext);
			
			if (_last){
				_btnFirst = new ImgBtn(0, 0, "skin_vpage_end", doAction);
				_btnFirst.id = "first";
				addChild(_btnFirst);
				_btnLast = new ImgBtn(0, 0, "skin_vpage_end", doAction);
				_btnLast.id = "last";
				_btnLast.imgFlip = UiConst.HORIZONTAL;
				addChild(_btnLast);
			}
		}
		
		/**
		 * 重设位置
		 */
		private function resetPos(e:Event):void{
			_btnPre.removeEventListener(Event.COMPLETE, resetPos);
			var dsp:DisplayObject = _itemCon.getChildAt(0);
			
			var i:int = 0;
			var j:int = 0;
			var iw:int = dsp.width;
			var ih:int = dsp.height;
			var bw:int = 0;
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
			
			//得到所有按钮的宽度。我们假设4个按钮的高度是一样的
			_width = iw * _col + _itemHGap * (_col - 1);
			bh = ih * _row + _itemVGap * (_row -1) 
			_itemCon.setSize(_width,bh);
			
			bh = bh + _conGap;
			bw = _btnPre.width;
			_height = bh  + _btnPre.height;
			if (_last){
				i = bw*2 + bw*2 + _btnGap*2 + _btnsGap;
				j = _width * 0.5 - i * 0.5;
				_btnFirst.x = j;
				_btnFirst.y = bh;
				_btnPre.x = j + bw + _btnGap;
				_btnPre.y = bh;
				
				_btnNext.x = _btnPre.x + bw + _btnsGap;
				_btnNext.y = bh;
				_btnLast.x = _btnNext.x + bw + _btnGap;
				_btnLast.y = bh;
			} else {
				i = bw * 2 + _btnsGap;
				j = _width * 0.5 - i * 0.5;
				_btnPre.x = j;
				_btnPre.y = bh;
				
				_btnNext.x = _btnPre.x + bw + _btnsGap;
				_btnNext.y = bh;
			}
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
			if (_last){
				_btnFirst.enabled = (_nowPage > 1);
				_btnLast.enabled = (_nowPage < _allPage);
			}
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
				var tmp:int = _collection.length % _pageSize;
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
			_btnFirst = null;
			_btnLast = null;
			_itemCon = null;
		}
		
		/**
		 * 进行翻页操作
		 */
		private function doAction(e:MouseEvent):void{
			var act:String = e.currentTarget.id;
			if (act == "pre"){ 			//点击上一页
				_nowPage = _nowPage - 1;
			} else if (act == "next"){ 	//点击下一页 
				_nowPage = _nowPage + 1;
			} else if (act == "first"){	//点击第一页
				_nowPage = 1;
			} else if (act == "last"){		//点击最后一页
				_nowPage = _allPage;
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