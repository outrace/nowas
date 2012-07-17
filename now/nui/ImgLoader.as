package now.nui {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;

	
	/**
	 * 可绕开安全沙箱的_loader。
	 */
	public final class ImgLoader extends Loader {
		
		private var _loader:Loader;
		
		/**
		 * 构造函数
		 */
		public function ImgLoader(){
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override final public function load(request:URLRequest, context:LoaderContext = null):void {
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_loader.load(request, context);
		}
		
		/**
		 * 移除事件监听
		 */
		private final function removeHandler():void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		/**
		 * 加载完成后的处理
		 * @param	event
		 */
		private final function loadCompleteHandler(event:Event):void {
			removeHandler();
			var lc : LoaderContext = new LoaderContext();
			if(lc["allowCodeImport"]!=undefined){
				lc["allowCodeImport"] = true;
			}
			loadBytes((event.currentTarget as LoaderInfo).bytes, lc);
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesCompleteHandler);
		}
		
		/**
		 * 重新Load字节后的处理
		 * @param	event
		 */
		private final function loadBytesCompleteHandler(event:Event):void {
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadBytesCompleteHandler);
			this.dispatchEvent(event);
			_loader.unloadAndStop();
			_loader = null;
		}
		
		/**
		 * 错误处理
		 * @param	event
		 */
		private final function ioErrorHandler(event:IOErrorEvent):void {
			removeHandler();
			this.dispatchEvent(event);
		}
		
		/**
		 * 进度处理
		 * @param	event
		 */
		private final function progressHandler(event:ProgressEvent):void {
			this.dispatchEvent(event);
		}
		
		/**
		 * 获取_loaderInfo
		 */
		public final function get imageLoadInfo():LoaderInfo {
			return _loader ? _loader.contentLoaderInfo : null;
		}
	
	}

}