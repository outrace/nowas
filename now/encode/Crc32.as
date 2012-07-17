package now.encode {
	import flash.utils.ByteArray;

	/**
	 * 提供crc32的哈希
	 */
	public final class Crc32 {
		private static var crcTable2:Vector.<uint> = null;

		/**
		 * 获取crc32的字符表。在png编码的时候，也会用到这个字符表
		 */
		public static function getCrcTable():Vector.<uint> {
			_initCRCTable2();
			return crcTable2;
		}

		/**
		 * 初始化CRC32的字符表
		 */
		private static function _initCRCTable2():void {
			if (crcTable2 == null){
				crcTable2 = new Vector.<uint>();
				var i:int;
				var crc:uint;
				var j:int;
				for (i = 0; i < 256; i++){
					crc = i;
					for (j = 0; j < 8; j++){
						crc = (crc & 1) ? (crc >>> 1) ^ 0xEDB88320 : (crc >>> 1);
					}
					crcTable2.push(crc);
				}
			}
		}

		/**
		 * 获得crc32哈希的值
		 * 得到的结果可能是正，也可能是负的。
		 * @param	str		需要计算哈希的字符串
		 */
		public static function encode(str:String):int {
			_initCRCTable2();
			var buffer:ByteArray = new ByteArray();
			buffer.writeUTFBytes(str);
			var offset:int = 0;
			var length:int = buffer.length;
			var crc:uint = ~0;
			var i:int;
			for (i = offset; i < length; i++){
				crc = crcTable2[(crc ^ buffer[i]) & 0xFF] ^ (crc >>> 8);
			}
			return ~crc & 0xFFFFFFFF;
		}

	}
}