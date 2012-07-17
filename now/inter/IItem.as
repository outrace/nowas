package now.inter {
	import now.bind.ObjProxy;
	import now.event.UiEvent;
	
	/**
	 * 数据容器接口
	 */
	public interface IItem {
		
		/**
		 * 数据变更
		 */
		function dataChange(e:UiEvent=null):void;
		
		/**
		 * 设置显示数据
		 * @param	obj		数据内容
		 */
		function set data(obj:ObjProxy):void;
		
		/**
		 * 获取数据
		 */
		function get data():ObjProxy;
	}
}