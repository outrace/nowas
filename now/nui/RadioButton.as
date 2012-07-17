package now.nui {

	/**
	 * 单选按钮
	 */
	public class RadioButton extends CheckBox {
		
		/**
		 * @inheritDoc
		 */
		public function RadioButton(xpos:Number = 0, ypos:Number = 0, label:String = "", defHdl:Function = null){
			super(xpos, ypos, label, defHdl);
			_name = "RadioButton";
		}
	}
}