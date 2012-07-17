package now.crypto {

	/**
	 * Xxtea加密解密算法
	 */
	public final class Xxtea {
		/**
		 * 将utf16字符转成utf8字符
		 * @param	char	需要转换的字符串
		 */
		private static function utf16to8(char:String):String {
			var out:Array = new Array();
			var len:uint = char.length;
			var c:int;
			var i:uint;
			for (i = 0; i < len; i++){
				c = char.charCodeAt(i);
				if (c >= 0x0001 && c <= 0x007F){
					out[i] = char.charAt(i);
				} else if (c > 0x07FF){
					out[i] = String.fromCharCode(0xE0 | ((c >> 12) & 0x0F), 0x80 | ((c >> 6) & 0x3F), 0x80 | ((c >> 0) & 0x3F));
				} else {
					out[i] = String.fromCharCode(0xC0 | ((c >> 6) & 0x1F), 0x80 | ((c >> 0) & 0x3F));
				}
			}
			return out.join('');
		}

		/**
		 * 将utf8字符转成utf16字符
		 * @param	char	需要转换的字符串
		 */
		private static function utf8to16(char:String):String {
			var out:Array = new Array();
			var len:uint = char.length;
			var i:uint = 0;
			var char2:int;
			var char3:int;
			var c:int;
			while (i < len){
				c = char.charCodeAt(i++);
				switch (c >> 4){
					case 0:
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
					case 6:
					case 7:
						// 0xxxxxxx  
						out[out.length] = char.charAt(i - 1);
						break;
					case 12:
					case 13:
						// 110x xxxx   10xx xxxx  
						char2 = char.charCodeAt(i++);
						out[out.length] = String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
						break;
					case 14:
						// 1110 xxxx  10xx xxxx  10xx xxxx  
						char2 = char.charCodeAt(i++);
						char3 = char.charCodeAt(i++);
						out[out.length] = String.fromCharCode(((c & 0x0F) << 12) | ((char2 & 0x3F) << 6) | ((char3 & 0x3F) << 0));
						break;
				}
			}
			return out.join('');
		}

		private static function long2str(v:Array, w:Boolean):String {
			var vl:uint = v.length;
			var sl:Number = v[vl - 1] & 0xffffffff;
			var i:uint;
			for (i = 0; i < vl; i++){
				v[i] = String.fromCharCode(v[i] & 0xff, v[i] >>> 8 & 0xff, v[i] >>> 16 & 0xff, v[i] >>> 24 & 0xff);
			}
			if (w){
				return v.join('').substring(0, sl);
			} else {
				return v.join('');
			}
		}

		private static function str2long(s:String, w:Boolean):Array {
			var len:uint = s.length;
			var v:Array = new Array();
			var i:uint;
			for (i = 0; i < len; i += 4){
				v[i >> 2] = s.charCodeAt(i) | s.charCodeAt(i + 1) << 8 | s.charCodeAt(i + 2) << 16 | s.charCodeAt(i + 3) << 24;
			}
			if (w){
				v[v.length] = len;
			}
			return v;
		}

		/**
		 * 加密
		 * @param	char	加密的字符串
		 * @param	key		密钥
		 */
		public static function encrypt(char:String, key:String):String {
			if (char == ""){
				return "";
			}
			var v:Array = str2long(utf16to8(char), true);
			var k:Array = str2long(key, false);
			var n:uint = v.length - 1;

			var z:Number = v[n];
			var y:Number = v[0];
			var delta:Number = 0x9E3779B9;
			var mx:Number;
			var q:Number = Math.floor(6 + 52 / (n + 1))
			var sum:Number = 0;
			var p:uint;
			var e:Number;
			while (q-- > 0){
				sum = sum + delta & 0xffffffff;
				e = sum >>> 2 & 3;
				for (p = 0; p < n; p++){
					y = v[p + 1];
					mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
					z = v[p] = v[p] + mx & 0xffffffff;
				}
				y = v[0];
				mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
				z = v[n] = v[n] + mx & 0xffffffff;
			}
			return long2str(v, false);
		}

		/**
		 * 解密
		 * @param	char	加密过字符串
		 * @param	key		密钥
		 */
		public static function decrypt(char:String, key:String):String {
			if (char == ""){
				return "";
			}
			var v:Array = str2long(char, false);
			var k:Array = str2long(key, false);
			var n:uint = v.length - 1;

			var z:Number = v[n - 1];
			var y:Number = v[0];
			var delta:Number = 0x9E3779B9;
			var mx:Number;
			var q:Number = Math.floor(6 + 52 / (n + 1));
			var sum:Number = q * delta & 0xffffffff;
			var e:Number;
			var p:uint;
			while (sum != 0){
				e = sum >>> 2 & 3;
				for (p = n; p > 0; p--){
					z = v[p - 1];
					mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
					y = v[p] = v[p] - mx & 0xffffffff;
				}
				z = v[n];
				mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
				y = v[0] = v[0] - mx & 0xffffffff;
				sum = sum - delta & 0xffffffff;
			}

			return utf8to16(long2str(v, true));
		}
	}
}