package now.inter {

	/**
	 * 提示类的接口
	 */
	public interface ITip{
		/**
		 * 设置提示内容
		 * @param	d	提示内容
		 */
		function set data(d:*):void;
		/**
		 * 获取提示内容
		 */
		function get data():*;

		/**
		 * 设置显示方向
		 * @param	d	方向
		 */
		function set direct(d:String):void;

		/**
		 * 获取显示方向
		 */
		function get direct():String;
		
		/**
		 * 设置偏移值
		 * @param	dis	偏移值
		 */
		function set distance(dis:Number):void;

		/**
		 * 获取显示方向
		 */
		function get distance():Number;
	}
}