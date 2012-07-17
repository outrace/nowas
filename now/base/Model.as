package now.base {
	import flash.events.EventDispatcher;

	/**
	 * 单例类用于收发事件
	 */
	public final class Model extends EventDispatcher {
		private static var _instance:Model;

		public function Model(singletonForce:SingletonForce){
		}

		public static function instance():Model {
			if (!_instance){
				_instance = new Model(new SingletonForce());
			}
			return _instance;
		}
	}
}

class SingletonForce {
}