package now.manager {
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.system.ApplicationDomain;
	
	/**
	 * 声音管理类
	 */
	public final class SoundManager {
		private static var _ready:Boolean = false;			//是否已经就绪
		private static var _loader:LoaderInfo = null;		//音乐文件
		private static var _clsCache:Object = { };			//声音文件
		
		private static var _musicSound:Sound = null;				//背景音乐
		private static var _musicPosition:int = -1;					//背景音乐暂停的位置	
		private static var _musicChannel:SoundChannel = null;		//背景声音通道
		
		private static var _enableAudio:Boolean = true;		//是否起效音效
		private static var _enableMusic:Boolean = true;		//是否起效循环背景音乐
		
		/**
		 * 初始化声音
		 * @param	url		嵌入了音乐的swf
		 * @param	okFun	成功后的回调
		 * @param	enable	是否起效
		 */
		public static function init(url:String, okFun:Function=null):void {
			RequestManager.getRes(url,'loader', function(ret:*, data:* = null):void {
				_loader = ret;
				_ready = true;
				if (okFun != null) {
					okFun();
				}
			});
		}
		
		/**
		 * 设置启用的东西
		 * @param	enableAudio		是否启用音效
		 * @param	enableMusic		是否启用背景音乐
		 */
		public static function setEnable(enableAudio:Boolean, enableMusic:Boolean):void {
			if (_enableAudio != enableAudio) {
				_enableAudio = enableAudio;
			}
			if (_enableMusic != enableMusic) {
				if (_enableMusic) {
					pause();
				} else {
					again();
				}
				_enableMusic = enableMusic;
			}
		}
		
		
		/**
		 * 暂停某个循环的音乐
		 * @param	sound
		 */
		public static function pause():void {
			if (_musicChannel != null) {
				_musicPosition = _musicChannel.position;
				_musicChannel.stop();
				_musicChannel.removeEventListener(Event.SOUND_COMPLETE,replay);
				_musicChannel = null;
			}
		}
		
		/**
		 * 重开某个循环的音乐
		 * @param	sound
		 */
		public static function again():void {
			if (_musicSound){
				_musicChannel = _musicSound.play(_musicPosition);
				_musicChannel.addEventListener(Event.SOUND_COMPLETE,replay);
			}
		}
		
		private static function replay(e:Event):void{
			_musicChannel.stop();
			_musicChannel.removeEventListener(Event.SOUND_COMPLETE,replay);
			_musicChannel = _musicSound.play(0);
			_musicChannel.addEventListener(Event.SOUND_COMPLETE,replay);
		}
		
		
		/**
		 * 播放某个标识的声音
		 * @param	sound
		 */
		public static function play(sound:String,loop:Boolean=false):void {
			if (!_ready) {
				return;
			}
			var domain:ApplicationDomain;
			var cls:Class;
			if (loop && _enableMusic) {
				if (_musicSound == null) {
					domain = _loader.applicationDomain;
					cls = domain.getDefinition(sound) as Class;
					_musicSound = new cls() as Sound;
					_musicChannel = _musicSound.play(0);
					_musicChannel.addEventListener(Event.SOUND_COMPLETE,replay);
				} else {
					_musicChannel.stop();
					_musicChannel.removeEventListener(Event.SOUND_COMPLETE,replay);
					_musicSound = null;
					_musicPosition = 0;
					
					domain = _loader.applicationDomain;
					cls = domain.getDefinition(sound) as Class;
					_musicSound = new cls() as Sound;
					_musicChannel = _musicSound.play(0);
					_musicChannel.addEventListener(Event.SOUND_COMPLETE,replay);
				}
			} else if (_enableAudio) {
				if (_clsCache[sound] == undefined) {
					domain = _loader.applicationDomain;
					if(domain.hasDefinition(sound)){
						cls = domain.getDefinition(sound) as Class;
						_clsCache[sound] = new cls();
					}else {
						trace("no sound:" + sound);
						return;
					}
				}
				(_clsCache[sound] as Sound).play();
			}
		}
	}
}