package now.container {
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TransformGestureEvent;
	
	import now.bind.Collection;
	import now.bind.ObjProxy;
	import now.event.UiEvent;
	import now.inter.IItem;
	import now.nui.Ui;
	
	/**
	 * 针对手机平台些的翻页组件。
	 */
	public class MPage extends Container {
		private var _bitmap:Bitmap;
		private var _bd:BitmapData;
		private var _mask:Shape;
		
		private var _collection:Collection;		//数据
		private var _row:int = 2;						//行数
		private var _col:int = 3;						//列数
		
		private var _itemHGap:int = 0; 		//每个子项的横间隔
		private var _itemVGap:int = 0; 		//每个子项的纵间隔
		
		
		private var _nowPage:int = 1;
		private var _pageSize:int = 6;		//每页显示内容
		private var _allPage:int = -1;			//总的页数
		
		private var _itemCon:Container;		//中间的容器
		private var _allCon:Container;
		private var _itemClass:Class;
		private var _onChangePage:Boolean = false;
		
		/**
		 * 构造函数
		 */
		public function MPage(xpos:Number, ypos:Number, itemClass:Class=null, row:int=2, col:int=3, itemHGap:int = 2, itemVGap:int=2) {
			_itemClass = itemClass;
			_row = row;
			_col = col;
			_pageSize = _row * _col;
			_itemHGap = itemHGap;
			_itemVGap = itemVGap;
			super(xpos,ypos);
			addEventListener(TransformGestureEvent.GESTURE_SWIPE, changePage);
		}
		/**
		 * @inheritDoc
		 */
		override protected function addChildren():void {
			super.addChildren();
			
			_allCon = new Container(0,0);
			addChild(_allCon);
			
			_itemCon = new Container(0,0);
			_allCon.addChild(_itemCon);
			var i:int = 0;
			var j:int = 0;
			var dsp:DisplayObject;
			for (i = 0; i < _row; i++){
				for (j = 0; j < _col; j++){
					dsp = new _itemClass();
					dsp.x = j * dsp.width + j *_itemHGap;
					dsp.y = i * dsp.height + i * _itemVGap;
					_itemCon.addChild(dsp);
				}
			}
			_width = dsp.width * _col + (_col -1 )*_itemHGap;
			_height = dsp.height * _row + (_row -1) * _itemVGap;
			
			_itemCon.width = _width;
			_itemCon.height = _height;
			_allCon.width = _width;
			_allCon.height = _height;
			
			_bitmap = new Bitmap();
			_bitmap.width = _width;
			_bitmap.height = _height;
			_bitmap.visible = false;
			_allCon.addChild(_bitmap);
			
			_bd = new BitmapData(_width,_height);
			_bitmap.bitmapData = _bd;
			addChild(_allCon);
			
			_mask = new Shape();
			_mask.graphics.clear();
			_mask.graphics.beginFill(0, 0.1);
			_mask.graphics.drawRect(0, 0,_width, _height);
			_mask.x = 0;
			_mask.y = 0;
			_mask.width = _width;
			_mask.height = _height;
			_allCon.mask = _mask;
			addChild(_mask);
		}
		
		/**
		 * 进行翻页altKey	如果 Alt 键处于活动状态，则为 true（Windows 或 Linux）。
		bubbles	true
		cancelable	false；没有要取消的默认行为。
		commandKey	在 Mac 中，如果 Command 键处于活动状态，则为 true；如果处于非活动状态，则为 false。在 Windows 中始终为 false。
		controlKey	如果 Ctrl 或 Control 键处于活动状态，则为 true，如果处于非活动状态，则为 false。
		ctrlKey	在 Windows 或 Linux 中，如果 Ctrl 键处于活动状态，则为 true。在 Mac 中，如果 Ctrl 键或 Command 键处于活动状态，则为 true。否则为 false。
		currentTarget	当前正在使用某个事件侦听器处理 Event 对象的对象。
		phase	事件流中的当前阶段。对于滑动事件，调度此事件后，此值始终是 all，与值 GesturePhase.ALL 对应。
		localX	事件发生点相对于所属 Sprite 的水平坐标。
		localY	事件发生点相对于所属 Sprite 的垂直坐标。
		scaleX	显示对象的水平缩放。对于滑动手势，此值是 1
		scaleY	显示对象的垂直缩放。对于滑动手势，此值是 1
		rotation	显示对象沿 Z 轴的当前旋转角度（以度为单位）。对于滑动手势，此值是 0
		offsetX	表示水平方向：1 表示向右，-1 表示向左。
		offsetY	表示垂直方向：1 表示向下，-1 表示向上。
		shiftKey	如果 Shift 键处于活动状态，则为 true；如果处于非活动状态，则为 false。
		target	触摸设备下的 InteractiveObject 实例。target 不一定是显示列表中注册此事件侦听器的对象。请使用 currentTarget 属性来访问显示列表中当前正在处理此事件的对象。
		 */
		private function changePage(e:TransformGestureEvent):void{
			if (_onChangePage){
				return;
			}
			_onChangePage = true;
			
			if (e.offsetX == -1 || e.offsetY == -1){
				_nowPage = _nowPage - 1;
			} else if (e.offsetX == 1 || e.offsetY == 1){
				_nowPage = _nowPage + 1;
			} else {
				_onChangePage = false;
				return;
			}
			
			var end:int;
			if (_nowPage < 0){	//已经是第一页了，晃一晃得了
				_nowPage = 0;
				if (e.offsetX == -1){//往左
					end = - (_width * 0.3);
					TweenLite.to(_itemCon,0.2,{x:end});
					TweenLite.to(_itemCon,0.2,{delay:0.2,x:0,onComplete:function():void{
						_onChangePage = false;
					}});
				} else {//往上
					end = - (_height * 0.3);
					TweenLite.to(_itemCon,0.2,{y:end});
					TweenLite.to(_itemCon,0.2,{delay:0.2,y:0,onComplete:function():void{
						_onChangePage = false;
					}});
				}
			} else if (_nowPage > _allPage){//已经是最后一页了，晃一晃得了
				_nowPage = _allPage;
				if (e.offsetX == 1){//往右
					end = _width * 0.3;
					TweenLite.to(_itemCon,0.2,{x:end});
					TweenLite.to(_itemCon,0.2,{delay:0.2,x:0,onComplete:function():void{
						_onChangePage = false;
					}});
				} else {//往下
					end = _height * 0.3;
					TweenLite.to(_itemCon,0.2,{y:end});
					TweenLite.to(_itemCon,0.2,{delay:0.2,y:0,onComplete:function():void{
						_onChangePage = false;
					}});
				}
			} else {
				var time:Number = 0.4;
				_bd.draw(_itemCon);
				_bitmap.x = 0;
				_bitmap.y = 0;
				_bitmap.visible = true;
				var tweenComp:Function = function():void{
					_bitmap.visible = false;
					_bd.dispose();
					_onChangePage = false;
				};
				resetUi();
				
				if (e.offsetX == -1){//往左
					_itemCon.x = _width;
					_itemCon.y = 0;
					//图片x从0到-width
					TweenLite.to(_bitmap, time, {x:-_width,onComplete:tweenComp});
					//_itemCon  x 从 width 到0
					TweenLite.to(_itemCon, time, {x:0});
				} else if (e.offsetX == 1){//往右
					_itemCon.x = -_width;
					_itemCon.y = 0;
					//图片x从0到width
					TweenLite.to(_bitmap, time, {x:_width,onComplete:tweenComp});
					//_itemCon  x 从 -width 到0
					TweenLite.to(_itemCon, time, {x:0});
				} else if (e.offsetY == -1){//网上
					_itemCon.x = 0;
					_itemCon.y = _height;
					//图片y从0到-height
					TweenLite.to(_bitmap, time, {y:-_height,onComplete:tweenComp});
					//_itemCon  y 从 width 到0
					TweenLite.to(_itemCon, time, {y:0});
				} else {//往下
					_itemCon.x = 0;
					_itemCon.y = -_height;
					//图片y从0到height
					TweenLite.to(_bitmap, time, {y:_height,onComplete:tweenComp});
					//_itemCon  y 从 width 到0
					TweenLite.to(_itemCon, time, {y:0});
				}
			}
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
			var i:int;
			for (i=0; i<max; i++){
				item = _itemCon.getChildAt(i) as IItem;
				op = item.data;
				if (op){
					op.removeEventListener(UiEvent.BIND_VAL_MDF, item.dataChange);
				}
			}
			_bd.dispose();
			_bd = null;
			super.dispose();
			_bitmap = null;
			_itemCon = null;
			_allCon = null;
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
		}
		
		/**
		 * 删除一笔，清空所有数据，重新排序，我们都全部重排
		 */
		private function itemSort(e:UiEvent=null):void{
			_nowPage = 1;
			_allPage = Math.ceil(_collection.length / _pageSize);
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