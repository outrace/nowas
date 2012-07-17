package now.manager {
	import flash.display.MovieClip;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	/**
	 * 为一个mc设置独立的fps
	 * 一般用于在一个主swf上，跑不同帧的mc。
	 */
	public final class FpsManager {
		
		/**
		 * 设置帧频.如果只有1帧，或者帧频为24，我们不处理，因为一般而言，系统帧频就是24
		 * @param		mc	动画mc
		 * @param		fps	帧频。默认10
		 */
		public static function setFps(mc:MovieClip,fps:int = 10):void{
			var len:int = mc.totalFrames;
			if (len == 1 || fps == 24){
				return;
			}
			mc.gotoAndStop(0);
			
			if (mc["setFps"] == undefined){
				mc["_fpsInter"] = -1;
				mc["_nowFrame"] = 1;
				mc["_ttl"] = len;
				mc["setFps"] = function(fps:int):void{
					var _this:* = this;
					if (_this._fpsInter != -1){
						_this._nowFrame = 1;
						clearInterval(_this._fpsInter);
						_this["_fpsInter"] = -1;
					}
					
					_this._fpsInter = setInterval(function():void{
						MovieClip(_this).gotoAndStop(_this._nowFrame);
						if (_this._nowFrame >= _this["_ttl"]){
							_this._nowFrame = 0;
						}
						_this._nowFrame = _this._nowFrame + 1;
					},1000/fps);
				};
			}
			mc["setFps"](fps);
		}
	}
}