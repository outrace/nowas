package now.bind {
	import flash.events.EventDispatcher;
	
	import now.event.UiEvent;

	[Event(name="bind_item_add",type="now.event.UiEvent")]
	[Event(name="bind_item_del",type="now.event.UiEvent")]
	[Event(name="bind_item_clear",type="now.event.UiEvent")]
	[Event(name="bind_item_sort",type="now.event.UiEvent")]

	/**
	 * 提供一个可绑定的数组数据类型
	 */
	public final class Collection extends EventDispatcher {
		private var _arr:Array = []; //存储数据的数组
		private var _this:* = this;
		private var _listener:Array =[];

		/**
		 * 构造函数
		 * @param arr 传入的数组
		 */
		public function Collection(arr:Array = null){
			if (arr == null){
				_arr = new Array();
			} else {
				_arr = arr;
			}
		}
		
		/**
		 * 覆盖了增加事件监听的方法
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			super.addEventListener(type,listener,useCapture,priority,useWeakReference);
			_listener.push({"type":type,"listener":listener});
		}
		
		/**
		 * 移除事件监听
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			var max:int = _listener.length;
			var obj:Object;
			var i:int;
			for (i = 0; i < max; i++){
				obj = _listener[i];
				if (obj["type"] == type && obj["listener"] == listener) {
					_arr.splice(i, 1);
					break;
				}
			}
			super.removeEventListener(type,listener,useCapture);
		}

		/**
		 * 新增一个元素，放在头
		 * @param	item	需要新增的元素
		 */
		public final function addItem(item:ObjProxy):void {
			_arr.push(item);
			if (_this.hasEventListener(UiEvent.BIND_ITEM_ADD)){
				dispatchEvent(new UiEvent(UiEvent.BIND_ITEM_ADD, item));
			}
		}

		/**
		 * 删除某个元素
		 * @param	item	要删除的元素
		 */
		public final function mvItem(item:ObjProxy):void {
			var max:int = _arr.length;
			var i:int = 0;
			for (i = 0; i < max; i++) {
				if (_arr[i] == item){
					_arr[i] = null;
					_arr.splice(i, 1);
					break;
				}
			}
			if (_this.hasEventListener(UiEvent.BIND_ITEM_DEL)) {
				dispatchEvent(new UiEvent(UiEvent.BIND_ITEM_DEL, item));
			}
		}
		
		/**
		 * 获取原始的位置
		 * @param	item	要删除的元素
		 */
		public final function getItemIndex(item:ObjProxy):int {
			var max:int = _arr.length;
			var i:int;
			for (i = 0; i < max; i++) {
				if (_arr[i] == item){
					return i;
				}
			}
			return -1;
		}

		/**
		 * 更改一个元素
		 * @param	idx		要更改的下标
		 * @param	item	更改的内容
		 */
		public final function mdfItem(idx:int, item:ObjProxy):void {
			_arr[idx] = item;
		}

		/**
		 * 删除某个下标的元素
		 * @param	idx		下标
		 */
		public final function mvItemAt(idx:int):void {
			var item:* = _arr[idx];
			_arr.splice(idx, 1);
			if (_this.hasEventListener(UiEvent.BIND_ITEM_DEL)){
				dispatchEvent(new UiEvent(UiEvent.BIND_ITEM_DEL, item));
			}
		}

		/**
		 * 清空所有数据
		 */
		public final function clear():void {
			_arr = [];
			if (_this.hasEventListener(UiEvent.BIND_ITEM_CLEAR)){
				dispatchEvent(new UiEvent(UiEvent.BIND_ITEM_CLEAR));
			}
		}
		
		/**
		 * 进行了排序
		 */
		public final function sortOn(names:*,options:*=0):void{
			_arr.sortOn(names,options);
			if (_this.hasEventListener(UiEvent.BIND_ITEM_SORT)){
				dispatchEvent(new UiEvent(UiEvent.BIND_ITEM_SORT));
			}
		}

		/**
		 * 获取某个下标的元素
		 * @param	idx		下标
		 * @return	对应的元素内容
		 */
		public final function getItem(idx:int):* {
			return _arr[idx];
		}

		/**
		 * 获取所有元素，并放到一个数组中
		 * @return	所有元素的数组
		 */
		public final function getItems():Array {
			return _arr;
		}


		/**
		 * 获取从start开始，长度为len的一片数据
		 * @param 	start		开始
		 * @param	len			长度
		 * @return 	该范围内的数据
		 */
		public final function getRange(start:int, len:int):Collection {
			var c:Collection = new Collection();
			var max:int = _arr.length;
			if (start >= max){
				return c;
			}
			var i:int;
			var idx:int
			for (i = 0; i < len; i++){
				idx = i + start;
				if (idx >= max){
					break;
				}
				c.addItem(_arr[idx] as ObjProxy);
			}
			return c;
		}


		/**
		 * 从数组中导入数据
		 * @param	arr		需要导入的数组内容
		 * @param	clear	是否清除原来的数据
		 */
		public final function fromArr(arr:*, clear:Boolean = true):void {
			if (clear) {
				this.clear();
			}
			for each (var item:Object in arr){
				this.addItem(new ObjProxy(item));
			}
		}

		/**
		 * 获取集合的笔数
		 * @return	长度
		 */
		public final function get length():int {
			return _arr.length;
		}
		
		/**
		 * 删除符合条件的第一笔记录
		 */
		public final function mvItemByCon(con:Object):void{
			var len:int = _arr.length;
			var i:int;
			var op:ObjProxy;
			var k:String;
			var find:Boolean = false;
			var idx:int = -1;
			for (i = 0; i < len; i++) {
				op = _arr[i];
				find = true;
				for (k in con){
					if (op[k] != con[k]){
						find == false;
						break;
					}
				}
				if (find){
					idx = i;
					break
				}
			}
			if (idx > -1){
				mvItemAt(idx);
			}
		}
		
		/**
		 * 查找符合key/val的第一条记录
		 * @param	condition 符合所有Key值
		 * @return  一条记录或null
		 */
		public final function findItem(condition:Object):ObjProxy {
			var len:int = _arr.length;
			var k:String;
			var f:Boolean;
			var i:int;
			var item:*;
			for (i = 0; i < len; i++) {
				item = _arr[i];
				f = true;
				for(k in condition){
					if (item[k]!=undefined){
						if(item[k] != condition[k]) {
							f = false;
							break;
						}
					}
				}
				if(f){
					return item;
				}
			}
			return null;
		}
		
		/**
		 * 更新符合key/val的第一条记录
		 * @param	condition 符合所有Key值
		 * @param	change  要更新的数据对象
		 */
		public final function updateItem(condition:Object, change:Object):void{
			var obj:ObjProxy = findItem(condition);
			if(obj !=null){
				var k:String;
				for (k in change) {
					obj[k] = change[k];
				}
			}
		}
		
		/**
		 * 更新符合key/val的第一条记录
		 * @param	condition 符合所有Key值
		 * @param	change  要更新的数据对象,change的key值为要inc的值
		 */
		public final function incItem(condition:Object, change:Object,delZero:Boolean=false):void{
			var obj:ObjProxy = findItem(condition);
			if(obj !=null){
				var k:String;
				for (k in change) {
					obj[k] = obj[k] + change[k];
					
					if (delZero && obj[k] == 0) {
						mvItem(obj);
						return;
					}
				}
			}
		}
		
		/**
		 * 把Collection合并到当前的Collection中
		 * @param	col Collection
		 */
		public final function merge(col:Collection):void {
			var arr:Array = col.getItems();
			var item:ObjProxy;
			for each(item in arr) {
				addItem(item);
			}
		}
		
		/**
		 * 做一次项目内容更新，以便唤醒子项的dataChange事件
		 * @param	key		更新的key
		 */
		public final function itemRebind(key:String):void{
			var item:ObjProxy;
			for each(item in _arr) {
				item[key] = item[key];
			}
		}
		
		/**
		 * 清空资源
		 */
		public final function dispose():void{
			_arr = [];
			var max:int = _listener.length;
			var obj:Object;
			var i:int;
			for (i = 0; i < max; i++){
				obj = _listener[i];
				removeEventListener(obj["type"], obj["listener"]);
			}
			_listener = [];
		}
	}
}