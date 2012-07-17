package now.container {
	import flash.display.DisplayObject;
	
	import now.bind.Collection;
	import now.bind.ObjProxy;
	import now.event.UiEvent;
	import now.inter.IItem;
	import now.nui.UiConst;
	
	/**
	 * 最简单的重复显示标签。没有分页
	 * 只显示row * col的数据。多出部分不显示。不足部分。以null替代
	 */
	public final class Rep extends Container {
		private var _collection:Collection;	//数据集合
		private var _itemClass:Class;			//子项类
		private var _hgap:int;						//横向间隔
		private var _vgap:int;						//纵向间隔
		private var _row:int;						//行数
		private var _col:int;						//列数
		
		private var _mdfFun:Function = null;		//数据变更的函数
		
		/**
		 * 构造函数
		 * @param		xpos	x轴
		 * @param		ypos	y轴
		 * @param		itemClass	子项的类
		 * @param		row			行数
		 * @param		col			列数
		 * @param		hgap			横向间隔
		 * @param		vgap			纵向间隔
		 */
		public function Rep(xpos:Number, ypos:Number, itemClass:Class=null, row:int=2, col:int=3, hgap:int=4,vgap:int=4) {
			_itemClass = itemClass;
			_hgap = hgap;
			_vgap = vgap;
			_row = row;
			_col = col;
			super(xpos,ypos);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void{
			super.addChildren();
			var dsp:DisplayObject;
			dsp = new _itemClass();
			
			var i:int = 0;
			var j:int = 0;
			var iw:int = dsp.width;
			var ih:int = dsp.height;
			
			_height = ih * _row + _vgap * (_row - 1);
			var bh:int = 0;
			for (i = 0; i < _row; i++){
				bh = i * ih + i * _vgap;
				for (j = 0; j < _col; j++){
					if (i != 0 || j != 0){
						dsp = new _itemClass();
					}
					dsp.x = j*iw + j*_hgap;
					dsp.y = bh;
					addChild(dsp);
				}
			}
		}
		

		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			if (_collection){
				_collection.removeEventListener(UiEvent.BIND_ITEM_ADD,itemAdd);
				_collection.removeEventListener(UiEvent.BIND_ITEM_DEL,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_CLEAR,itemSort);
				_collection.removeEventListener(UiEvent.BIND_ITEM_SORT,itemSort);
			}
			
			var max:int = numChildren;
			var item:IItem;
			var op:ObjProxy;
			var i:int;
			for (i=0; i<max; i++){
				item = getChildAt(i) as IItem;
				op = item.data;
				if (op){
					op.removeEventListener(UiEvent.BIND_VAL_MDF, item.dataChange);
					if (_mdfFun != null){
						op.removeEventListener(UiEvent.BIND_VAL_MDF, _mdfFun);
					}
				}
			}
			super.dispose();
		}
		
		/**
		 * 重设界面
		 */
		private function resetUi():void{
			var op:ObjProxy;
			var item:IItem;
			var i:int;
			var max:int = _row * _col;
			var len:int = _collection.length;
			
			//重新设置
			for (i = 0; i< max; i++){
				item = getChildAt(i) as IItem;
				if (item.data != null){
					item.data.removeEventListener(UiEvent.BIND_VAL_MDF, item.dataChange);
					if (_mdfFun != null){
						item.data.removeEventListener(UiEvent.BIND_VAL_MDF, _mdfFun);
					}
				}
				
				if ( i < len){
					op = _collection.getItem(i);
					item.data = op;
					op.addEventListener(UiEvent.BIND_VAL_MDF,item.dataChange);
					if (_mdfFun != null){
						op.addEventListener(UiEvent.BIND_VAL_MDF, _mdfFun);
					}
				} else {
					item.data = null;
				}
			}
		}
		
		/**
		 * 增加一项。如果
		 */
		private function itemAdd(e:UiEvent):void{
			//如果只有一页，或者是最后一页。并且有空余的话，那么我们补充一笔
			var max:int = _row * _col;
			var len:int = _collection.length - 1;
			
			if (len < max){
				var item:IItem;
				var op:ObjProxy;
				item = getChildAt(len) as IItem;
				op = _collection.getItem(len);
				item.data = op;
				op.addEventListener(UiEvent.BIND_VAL_MDF,item.dataChange);
				if (_mdfFun != null){
					op.addEventListener(UiEvent.BIND_VAL_MDF, _mdfFun);
				}
			}
			
		}
		
		/**
		 * 删除一笔，清空所有数据，重新排序，我们都全部重排
		 */
		private function itemSort(e:UiEvent=null):void{
			resetUi();
		}
		
		public function get mdfFun():Function{
			return _mdfFun;
		}
		public function set mdfFun(fun:Function):void{
			_mdfFun = fun;
		}
		
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