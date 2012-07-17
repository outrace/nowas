package now.nui {

	/**
	 * 富文本。也就是会使用htmlText
	 */
	public class RichText extends Text {
		/**
		 * 构造函数
		 * @param xpos x轴
		 * @param ypos y轴
		 * @param text 文字内容
		 */
		public function RichText(xpos:Number = 0, ypos:Number = 0, text:String = ""){
			super(xpos, ypos, text);
			_name = "RichText";
			_html = true;
			setSize(200, 100);
		}

	}
}