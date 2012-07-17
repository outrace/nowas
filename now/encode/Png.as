package now.encode {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.utils.ByteArray;
	
	/**
	 * 将BitmapData转成PNG格式的ByteArray。
	 * 如果需要保存到后台，可以直接保存ByteArray【使用amf3格式】
	 * 我们一般会用再将此ByteArray转成Base64然后存到后台数据库中
	 */
	public final class Png {
		
		/**
		 * 将BitmapData转成Png格式的ByteArray
		 * @param image 	需要转成Png格式的BitmapData图像
		 * @return PNG编码后的ByteArray
		 */
		public static function encode(img:BitmapData):ByteArray {
			// Create output byte array
			var png:ByteArray = new ByteArray();
			// Write PNG signature
			png.writeUnsignedInt(0x89504e47);
			png.writeUnsignedInt(0x0D0A1A0A);
			// Build IHDR chunk
			var IHDR:ByteArray = new ByteArray();
			IHDR.writeInt(img.width);
			IHDR.writeInt(img.height);
			IHDR.writeUnsignedInt(0x08060000); // 32bit RGBA
			IHDR.writeByte(0);
			writeChunk(png, 0x49484452, IHDR);
			// Build IDAT chunk
			var IDAT:ByteArray = new ByteArray();
			
			var imgh:uint = img.height;
			var imgw:uint = img.width;
			
			var i:int;
			var p:uint;
			var j:int;
			
			for (i = 0; i < imgh; i++){
				// no filter
				IDAT.writeByte(0);
				if (!img.transparent){
					for (j = 0; j < imgw; j++){
						p = img.getPixel(j, i); //这里可以优化
						IDAT.writeUnsignedInt(uint(((p & 0xFFFFFF) << 8) | 0xFF));
					}
				} else {
					for (j = 0; j < imgw; j++){
						p = img.getPixel32(j, i); //这里可以优化
						IDAT.writeUnsignedInt(uint(((p & 0xFFFFFF) << 8) | (p >>> 24)));
					}
				}
			}
			IDAT.compress();
			writeChunk(png, 0x49444154, IDAT);
			// Build IEND chunk
			writeChunk(png, 0x49454E44, null);
			// return PNG
			return png;
		}
		
		private static function writeChunk(png:ByteArray, type:uint, data:ByteArray):void {
			var crcTable:Vector.<uint> = Crc32.getCrcTable();
			var len:uint = 0;
			if (data != null){
				len = data.length;
			}
			png.writeUnsignedInt(len);
			var p:uint = png.position;
			png.writeUnsignedInt(type);
			if (data != null){
				png.writeBytes(data);
			}
			var e:uint = png.position;
			png.position = p;
			var c:uint = 0xffffffff;
			var imax:uint = e - p;
			var i:int;
			for (i = 0; i < imax; i++){
				c = uint(crcTable[(c ^ png.readUnsignedByte()) & uint(0xff)] ^ uint(c >>> 8));
			}
			c = uint(c ^ uint(0xffffffff));
			png.position = e;
			png.writeUnsignedInt(c);
		}
	}
}
