package now.nui {
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	import now.base.MdlNow;
	
	/**
	 * flash子加载器
	 */
	public class RootLoader extends MovieClip {		
		/**
		 * 是否加载完成
		 */
		public var loadCompleted:Boolean = false;
		/**
		 * 主场景名称
		 */
		private var _mainClass:String = "main";

		/**
		 * 构造函数
		 */
		public function RootLoader(cls:String="main"){
			_mainClass = cls;
			
			this.gotoAndStop(1);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			getPara();
			root.loaderInfo.addEventListener(Event.INIT, initHandler);
		}
		
		/**
		 * 初始化事件监听
		 */
		protected function initHandler(event:Event):void {
			dispatchEvent(event);
			root.loaderInfo.removeEventListener(Event.INIT, initHandler);
			root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			root.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			root.loaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		//Complete事件失效时的备用处理
		private function enterFrameHandler(event:Event):void {
			if (root.loaderInfo.bytesLoaded == root.loaderInfo.bytesTotal) {
				completeHandler(new Event(Event.COMPLETE));
			}
		}
		
		protected function completeHandler(event:Event):void {
			if (loadCompleted) {
				return;
			}
			
			this.gotoAndStop(2);
			root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			root.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			root.loaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			dispatchEvent(event);
			loadComplete();
			loadCompleted = true;
		}
		
		protected function progressHandler(event:ProgressEvent):void {
			dispatchEvent(event);			
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(event);
		}
				
		/**
		 * 完成载入，实例化主场景时执行的方法。可以重写这个方法以显示一段进入主场景的动画。
		 */
		protected function loadComplete():void {
			var cls:Class = Class(getDefinitionByName(_mainClass));
			stage.addChildAt(new cls(), 0);
		}
		
		/**
		 * 获取当前应用的参数
		 * 先获取url中的参数
		 * 再获取flashvars中的参数，也就是flashvar中的参数值会覆盖url中的query参数
		 */
		private function getPara():void {
			var k:String;
			var url:String = root.loaderInfo.url;
			var idx:int = url.indexOf("?");
			var arr:Array;
			var arr2:Array;
			var tidx:int;
			var i:int = 0;
			var _para:Object = {};
			if (idx > 1){
				arr = url.substr(idx).split("&");
				for (i = 0; i < arr.length; i++){
					arr2 = arr[i].split("=");
					if (arr2.length == 2){
						_para[arr2[0]] = arr2[1];
					}
				}
			}
			var tmp:Object = root.loaderInfo.parameters;
			for (k in tmp){
				_para[k] = tmp[k];
			}
			MdlNow.para = _para;
		}
	
	}

}