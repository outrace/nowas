package now.util {
	import now.base.MdlNow;
	
	/**
	 * 提供一些时间，日期相关的辅助函数
	 */
	public final class DateUtil {
		
		
		/**
		 * 将yyyy-mm-dd hh:ii:ss格式的字符串转成timestamp
		 * @param	str		需要转换的那个字符串。必须是yyyy-mm-dd hh:ii:ss格式
		 */
		public static function str2date(str:String):int{
			var y:int = parseInt(str.substr(0,4));
			var m:int = parseInt(str.substr(5,2));
			var d:int = parseInt(str.substr(8,2));
			
			var h:int = 0;
			var i:int = 0;
			var s:int = 0;
			
			if (str.length > 10){
				h = parseInt(str.substr(11,2));
				i = parseInt(str.substr(14,2));
				s = parseInt(str.substr(17,2));
			}			
			
			return int(new Date(y,m,d,h,i,s).getTime() * 0.001);
		}
		
		/**
		 * 将timestamp转换成日期格式
		 * @param	timestamp	时间戳。到秒
		 */
		public static function date2str(timestamp:int,formatStr:String="Y-m-d H:i:s"):String{
			var d:Date = new Date(timestamp*1000);
			return format(formatStr,d);
		}
		
		/**
		 * 当数字小于10，前面加0
		 * @param	n	数字
		 * @return	对应字符串
		 */
		private static function getNumStr(n:int):String {
			if (n < 10){
				return "0" + n.toString();
			} else {
				return n.toString();
			}
		}
		
		/**
		 * 格式化事件，支持Y-m-d H:i:s类型，其他不支持。 效果为2001-01-01 00:00:00
		 * 也就是Y表示年，m表示月，d表示日，H表示小时，i表示分钟，s表示秒
		 * @param	format	比如Y年m月d日
		 * @param	date
		 */
		public static function format(format:String = "Y-m-d H:i:s", date:Date = null):String {
			if (date == null){
				date = new Date();
			}
			format = format.replace("Y", date.fullYear.toString());
			format = format.replace("m", getNumStr(date.month + 1));
			format = format.replace("d", getNumStr(date.date));
			format = format.replace("H", getNumStr(date.hours));
			format = format.replace("i", getNumStr(date.minutes));
			format = format.replace("s", getNumStr(date.seconds));
			
			return format;
		}
		
		/**
		 * 获取当前日期字符串
		 * @param	format	比如Y年m月d日
		 * @return
		 */
		public static function getToday(format:String = "Y-m-d"):String {
			return DateUtil.format(format, new Date(MdlNow.now * 1000));
		}
		
		/**
		 * 将2h/3m/1d/10s这样的格式转换成秒
		 * @param	str		事件格式字符串
		 * @return	换算好的秒
		 */
		public static function getStrTime(str:String):int {
			var type:String = str.substr(-1);
			var num:Number = Number(str.substr(0, -1));
			if (type == "m"){
				num = num * 60;
			} else if (type == "h"){
				num = num * 3600;
			} else if (type == "d"){
				num = num * 86400
			}
			return int(num);
		}
		
		/**
		 * 获取Y-m-d H:i:s格式的日期的某个部分
		 * @param	begin	开始
		 * @param	len		长度
		 * @return	截取后的字符串
		 */
		public static function getSubDate(begin:int, len:int = 30):String {
			var str:String = format("Y-m-d H:i:s");
			return str.substr(begin, len);
		}
		
		/**
		 * 将剩余的描述转成更友好的剩余时间字符串
		 * @param	num		时间距离，单位秒
		 * @param	short	是否短格式显示，短格式显示类似  0:0:2  表示2秒 长的花，会显示类似: 0Hour:12Minute:10Second
		 * @param	lang	显示语言，有3个key  {"h":"小时","m":"分","s":"秒","d":"天"}
		 * @return	获取剩余的时间
		 */
		public static function getLeft(num:int, short:Boolean = true, lang:Object = null):String {
			if (lang == null){
				lang = {"h": "hour", "m": "minute", "s": "second","d":"day"};
			}
			var n1:Number, n2:Number, s1:String, tmp:Number, s:Number;
			if (num < 60){
				if (short){
					return "00:" + (num < 10?"0" + num:num);
				} else {
					return "0" + lang["h"] + "0" + lang["m"] + num + lang["s"];
				}
			} else if (num < 3600){
				n1 = Math.floor(num / 60);
				s = num - n1 * 60;
				if (short) {
					
					return (n1 < 10?"0" + n1:n1) + ":" + (s < 10?"0" + s:s);
				} else {
					return "0" + lang["h"] + n1.toString() + lang["m"] + s + lang["s"];
				}
			} else if (num < 86400) {
				n1 = Math.floor(num / 3600);
				var n3:Number = (num - n1 * 3600);
				n2 = Math.floor(n3 / 60);
				s = n3 - n2 * 60;
				if (short) {
					return (n1 < 10?"0" + n1:n1) + ":" + (n2 < 10?"0" + n2:n2) + ":" + (s < 10?"0" + s:s);
				} else {
					return n1.toString() + lang["h"] + "" + n2.toString() + lang["m"] + s + lang["s"];
				}
			} else {
				n1 =  Math.floor(num / 3600);
				return n1.toString()+lang["d"];
			}
		}
	}
}