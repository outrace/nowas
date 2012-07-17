package now.inter {
	
	/**
	 * 进度条接口
	 */
	public interface IProgress {
		
		function set max(n:int):void;
		
		function get max():int;
		
		function get value():int;
		
		function set value(n:int):void;
		
		function setText(text:String,size:int=12,color:int=0xFFFFFF,fontName:String=""):void;
	}

}