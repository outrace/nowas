package now.container {
	import now.nui.UiConst;

	/**
	 * 垂直【纵向】布局容器
	 */
	public final class VBox extends Box {

		/**
		 * 构造函数
		 * @param		xpos		X轴
		 * @param		ypos		Y轴
		 * @param		gap		子组件之间的间隔
		 */
		public final function VBox(xpos:Number = 0, ypos:Number = 0, gap:int = 2){
			super(xpos, ypos);
			_layout = UiConst.VERTICAL;
			_name = "VBox";
			_gap = gap;
		}

	}
}