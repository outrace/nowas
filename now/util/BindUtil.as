package now.util {
	import now.bind.Collection;
	import now.bind.ObjProxy;
	import now.event.UiEvent;
	
	/**
	 * 一些进行绑定辅助的方法
	 */
	public final class BindUtil {
		
		/**
		 * 进行简单对象的数据绑定
		 * @param source	数据源
		 * @param srcpro	数据源的key
		 * @param target	绑定目标
		 * @param tarpro	绑定目标的属性,如果为空，则target为function
		 * @param def		默认值，如果key未定义，则使用此默认值
		 *
		 */
		public static function bindObj(source:ObjProxy, srcpro:String, target:*, tarpro:String, def:* = null):void {
			var init:* = source[srcpro];
			var val:*;
			if (init != undefined) {
				val = init;
			} else {
				val = def;
			}
			
			if(tarpro!=null){
				target[tarpro] = val;
			}else {
				target(def);
			}
			
			source.addEventListener(UiEvent.BIND_VAL_MDF, function(e:UiEvent):void {
					var arr:Array = e.data as Array //[key,old_val,new_val]
					if (arr[0] == srcpro) {
						if(tarpro!=null){
							target[tarpro] = arr[2];
						}else {
							target(arr[2]);
						}
					}
				});
		}
		
		/**
		 * 绑定一个函数
		 * @param source	数据源
		 * @param fun		处理函数
		 */
		public static function bindFun(source:ObjProxy, fun:Function):void {
			if (source){
				fun(new UiEvent(UiEvent.BIND_VAL_MDF,null));
			}
			source.addEventListener(UiEvent.BIND_VAL_MDF, fun);
		}
		
		/**
		 * 移除函数绑定
		 * @param source	数据源
		 * @param fun		处理函数
		 */
		public static function unbindFun(source:ObjProxy,fun:Function):void{
			if (source){
				source.removeEventListener(UiEvent.BIND_VAL_MDF,fun);
			}
		}
		
		/**
		 * 将一个数组转换成Collection
		 * @param	arr
		 * @return	转换成的Collection
		 */
		public static function arr2col(arr:*):Collection {
			var col:Collection = new Collection();
			if (arr is Array) {
				var item:Object;
				for each (item in arr){
					col.addItem(new ObjProxy(item));
				}
			}
			return col;
		}
		
		/**
		 * 将一个obj类型的数据转成collection
		 * @param	obj		k/v的对象。v也是一个k/v的object
		 * @param	id		ID名称。
		 * @return	结果
		 */
		public static function obj2col(obj:Object, id:String):Collection {
			var col:Collection = new Collection();
			var k:String;
			var tmp:ObjProxy;
			for (k in obj){
				tmp = new ObjProxy(obj[k]);
				tmp[id] = k;
				col.addItem(tmp);
			}
			return col;
		}
	}
}