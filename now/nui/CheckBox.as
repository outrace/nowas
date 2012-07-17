package now.nui {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 复选框
	 */
	public class CheckBox extends Button {
		private var _selected:Boolean = false;
		private var _hdl:Function = null;

		/**
		 * 构造函数
		 * @param	xpos			X轴
		 * @param	ypos			Y轴
		 * @param	label			显示的文字内容
		 * @param	defHdl			点击时候的处理函数
		 */
		public function CheckBox(xpos:Number = 0, ypos:Number = 0, label:String = "", defHdl:Function = null){
			if (defHdl != null){
				_hdl = defHdl;
			}
			super(xpos, ypos, label, selectBox);
		}
		
		override protected function getImg():String{
			var isselected:String = _selected ? "_selected" : "";
			var defSkin:String = (_name == "CheckBox") ? "skin_cb" : "skin_rb";
			var s:String = defSkin+ isselected;
			return getStyle(s,s);
		}
		
		override protected function setBtnSize(e:Event = null):void{
			_img.x = 1;
			_img.y = 1;
			_width = _img.width + 1 + _label.width;
			_height = _img.height;
			dispatchEvent(new Event(Event.RESIZE));
			//移到中间
			_label.move(_img.width + 1,  _height * 0.5 - _label.height * 0.5);
		}
		
		/**
		 * 选中时候出发此事件
		 * @param	e	鼠标事件
		 */
		protected function selectBox(e:MouseEvent):void {
			selected = !_selected;
			if (_hdl != null){
				_hdl(e);
			}
		}

		/**
		 * 设置/获取  是否选中状态
		 */
		public function set selected(b:Boolean):void {
			if (b != _selected){
				_selected = b;
				invalidate();
			}
		}
		public function get selected():Boolean {
			return _selected;
		}
	}
}