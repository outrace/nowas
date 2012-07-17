package now.base {
	import flash.net.SharedObject;
	
	/**
	 * 用于ShareObject管理
	 * @author ...
	 */
	public final class LocalShare {
		private var _myso:SharedObject;
		
		/**
		 * 构造函数
		 * @param name  名称
		 * @param path  本地存放路径
		 */
		public function LocalShare(localPath:String = "/",secure:Boolean=false):void {
			_myso = SharedObject.getLocal(MdlNow.para["game"], localPath, secure);
		}
		
		/**
		 * 立即保存值
		 * @param key   键
		 * @param value  键值
		 */
		public function saveValue(key:String, value:*):void {
			_myso.data[key] = value;
			flush();
		}
		
		/**
		 * 获取值
		 * @param key   指定的键名
		 * @return  objcet
		 */
		public function getValue(key:String):* {
			return _myso.data[key];
		}
		
		/**
		 * 删除值
		 * @param key   指定要删除的键
		 */
		public function deleteValue(key:String):void {
			delete _myso.data[key];
		}
		
		/**
		 * 清除所有数据并删除共享对象
		 */
		public function destroy():void {
			_myso.clear();
		}
		
		/**
		 * 立即写入本地
		 */
		protected function flush():void {
			try {
				_myso.flush();
			} catch (e:Error){
				trace(e.message);
			}
		}
	}
}