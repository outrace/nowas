package now.bind {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import now.event.UiEvent;
	
	[Event(name="bind_val_mdf",type="now.event.UiEvent")]
	
	/**
	 * 参考了flex sdk的ObjectProxy。提供一个包含事件抛出的object对象<br/>
	 * 但是只是第一层的。不支持更深层次的事件抛出
	 */
	public final class ObjProxy extends Proxy implements IEventDispatcher {
		private var _item:Object = {};
		private var _itemList:Array = [];
		private var _dispatcher:EventDispatcher;
		
		/**
		 * 构造函数
		 * @param	obj		默认的对象
		 */
		public function ObjProxy(obj:Object = null){
			super();
			_dispatcher = new EventDispatcher(this);
			if (obj != null){
				fromObj(obj);
			}
		}
		
		/**
		 * 重设某个key的值
		 * @param	k	key
		 * @param	v	值
		 */
		private final function setkv(k:*, v:*):void {
			var oldVal:* = _item[k];
			if (oldVal !== k){
				_item[k] = v;
				if (_dispatcher.hasEventListener(UiEvent.BIND_VAL_MDF)){
					_dispatcher.dispatchEvent(new UiEvent(UiEvent.BIND_VAL_MDF, [k, oldVal, v]));
				}
			}
		}
		
		/**
		 * 从Object中导入数据到ObjProxy
		 * @param	src		原始对象
		 * @param	dispatch	是否依次分派事件。默认为只分发最后一个k/v
		 */
		public final function fromObj(src:Object, dispatch:Boolean=false):void {
			var k:String;
			if (dispatch){
				for (k in src){
					setkv(k, src[k]);
				}
			} else {
				for (k in src){
					_item[k] = src[k];
				}
				if (_dispatcher.hasEventListener(UiEvent.BIND_VAL_MDF)){
					_dispatcher.dispatchEvent(new UiEvent(UiEvent.BIND_VAL_MDF, [k,null,_item[k]]));
				}
			}
		}
		
		/**
		 * 复制一份
		 */
		public final function copy():ObjProxy{
			return new ObjProxy(_item);
		}
		
		/**
		 * 得到一份浅拷贝的对象
		 */
		public final function getObj():Object{
			var obj:Object = {};
			var k:String;
			for (k in _item){
				obj[k] = _item[k];
			}
			return obj;
		}
		
		/**
		 * 清空资源
		 */
		public final function clear():void {
			_item = {};
			_itemList = [];
			if (_dispatcher.hasEventListener(UiEvent.BIND_VAL_MDF)){
				_dispatcher.dispatchEvent(new UiEvent(UiEvent.BIND_VAL_MDF, ["",null,null]));
			}
		}
		
		//下面覆盖了 Proxy相关的方法，实现普通Object的map类型读写
		override flash_proxy function getProperty(name:*):* {
			return _item[name];
		}
		
		override flash_proxy function callProperty(name:*, ... rest):* {
			return _item[name].apply(_item, rest);
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean {
			var flag:Boolean = delete _item[name];
			return flag;
		}
		
		override flash_proxy function setProperty(name:*, value:*):void {
			setkv(name, value);
		}
		
		override flash_proxy function hasProperty(name:*):Boolean {
			return (name in _item);
		}
		
		override flash_proxy function nextName(index:int):String {
			return _itemList[index - 1];
		}
		
		override flash_proxy function nextNameIndex(index:int):int {
			if (index == 0){
				resetItemList();
			}
			if (index < _itemList.length){
				return index + 1;
			} else {
				return 0;
			}
		}
		
		override flash_proxy function nextValue(index:int):* {
			return _item[_itemList[index - 1]];
		}
		
		private function resetItemList():void {
			_itemList = [];
			for (var k:String in _item){
				_itemList.push(k);
			}
		}
		
		//下面实现了IEventDispatcher相关的接口
		
		public final function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public final function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public final function dispatchEvent(event:Event):Boolean {
			return _dispatcher.dispatchEvent(event);
		}
		
		public final function hasEventListener(type:String):Boolean {
			return _dispatcher.hasEventListener(type);
		}
		
		public final function willTrigger(type:String):Boolean {
			return _dispatcher.willTrigger(type);
		}
	}
}