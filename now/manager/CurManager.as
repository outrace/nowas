package now.manager {
	import flash.events.MouseEvent;
	
	import now.container.Container;
	import now.nui.Img;
	
	/**
	 * 鼠标手势管理
	 */
	public final class CurManager 	{
		public static var container:Container;
		private static var _imgCur:Img;
		private static var _nowKey:String = "";
		
		/**
		 * 显示某种鼠标手势，我们要求其在嵌入式资源中已经有了
		 * @param	key	鼠标图片名称
		 */
		public static function show(key:String):void{
			if (_imgCur == null){
				_imgCur = new Img(0,0);
				container.addChild(_imgCur);
				container.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
			if (_nowKey == key){
				return;
			}
			if (_nowKey == ""){
				container.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
			_nowKey = key;
			_imgCur.src = key;
			_imgCur.visible = true;
		}
		
		/**
		 * 隐藏鼠标手势
		 */
		public static function hide():void{
			if (_nowKey != ""){
				container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				_nowKey = "";
				_imgCur.visible = false;
			}
		}
		
		/**
		 * 鼠标移动
		 */
		private static function onMove(e:MouseEvent):void{
			_imgCur.x = container.mouseX + 5;
			_imgCur.y = container.mouseY + 10;
		}
		
	}
}