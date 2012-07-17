package now.util
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;

	/**
	 * 一些常用的矩阵变换
	 */
	public final class MatrixUtil
	{
		/**
		 * 对目标UI组件进行旋转
		 * @param	target		目标组件
		 * @param	val			旋转角度
		 */
		public static function setAngle(target:DisplayObject, val:int):void{
			var angle:Number = val * Math.PI /180;
			var sin:Number = Math.sin(angle);
			var cos:Number = Math.cos(angle); 
			var tempMatrix:Matrix = target.transform.matrix;
			tempMatrix.a = cos;
			tempMatrix.b = sin;
			tempMatrix.c = -sin;
			tempMatrix.d = cos;
			target.transform.matrix =  tempMatrix;
		}
		
		public static function hflip(dsp:DisplayObject):void{
			var matrix:Matrix = dsp.transform.matrix;
			matrix.a = -1;
			matrix.tx = dsp.width + dsp.x;
			dsp.transform.matrix=matrix;
		}
		
		public static function vflip(dsp:DisplayObject):void{
			var matrix:Matrix = dsp.transform.matrix;
			matrix.d = -1;
			matrix.ty = dsp.height + dsp.y;
			dsp.transform.matrix=matrix;
		}
		
		public static function leftFlip(dsp:DisplayObject):void{
			
		}
		
		public static function rightFlip(dsp:DisplayObject):void{
			
		}
	}
}