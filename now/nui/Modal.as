package now.nui {

	/**
	 * 一个蒙层，用来遮挡
	 * 专门给PopManager用的，其他地方不要直接new出来放在容器中
	 */
	public final class Modal extends Ui {
		
		/**
		 * @inheritDoc
		 */
		public function Modal(xpos:Number = 0, ypos:Number = 0){
			super(xpos, ypos);
			_name="Modal";
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();

			this.graphics.clear();
			this.graphics.beginFill(getStyle("bgColor"));
			this.graphics.drawRect(0, 0, _width, _height);
			this.graphics.endFill();
			this.alpha = getStyle("bgAlpha");
		}
	}
}