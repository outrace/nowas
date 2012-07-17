package now.container {
	
	import now.bind.ObjProxy;
	import now.event.UiEvent;
	import now.inter.IItem;
	
	/**
	 * 所有数据子项的基类。实现了一些最基本的方法。
	 */
	public class Item extends Container implements IItem {
		protected var _data:ObjProxy = null;
		
		/**
		 * 构造函数
		 */
		public function Item(xpos:Number, ypos:Number) {
			super(xpos,ypos);
		}
		
		/**
		 * 数据变更
		 */
		public function dataChange(e:UiEvent=null):void{
			
		}
		
		/**
		 * 设置数据项
		 * @param obj 数据内容
		 */
		public function set data(obj:ObjProxy):void{
			_data = obj;
			dataChange();
		}
		/**
		 * 获取数据项
		 */
		public function get data():ObjProxy{
			return _data;
		}
	}
}