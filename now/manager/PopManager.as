package now.manager {
	import flash.display.DisplayObjectContainer;
	
	import now.container.Alert;
	import now.container.Container;
	import now.nui.Modal;
	import now.nui.Ui;

	/**
	 * 弹出窗体的管理类
	 */
	public final class PopManager {
		/**
		 * 弹出窗口的最顶层容器
		 */
		public static var app:Container = null;
		/**
		 * 蒙层的类，如果为null，当使用蒙层的时候，我们会默认使用nui.Modal作为蒙层类
		 * 如果要自定义蒙层类，请继承Modal
		 */
		public static var modalClass:Class = null;
		/**
		 * 默认的提示框
		 */
		public static var alert:Alert = null;

		/**
		 * 弹出一个提示框
		 * @param	title		标题
		 * @param	msg			提示内容，支持html
		 * @param	act			操作列表。格式为{key:function,key:function} 显示字，点击后操作函数
		 */
		public static function addAlert(title:String, msg:String, act:* = null):Alert {
			if (PopManager.alert == null){
				alert = new Alert("", "");
				alert.draw();
			}

			alert.title = title;
			alert.msg = msg;
			if (act === null) {//如果没有设置act，则给个默认关闭
				act = new Array();
				var closeFun:Function = function(e:* = null):void {
						PopManager.removePop(alert);
						alert.y = 3000;
						alert.visible = false;
					}
				act[0] = [ "skin_ok",closeFun ];
			}
			alert.setAct(act);
			alert.visible = true;
			PopManager.addPop(PopManager.alert);
			return alert;
		}

		/**
		 * 增加一个弹出窗口
		 * @param	ui		ui窗体
		 * @param	md		是否蒙层，默认蒙层
		 * @param	center	是否默认居中，默认为居中
		 * @param	parent	父容器，默认为主App
		 */
		public static function addPop(ui:Ui, mdl:Boolean = true, center:Boolean = true, parent:Ui = null):void {
			if (parent == null){
				parent = PopManager.app;
			}
			if (mdl){ //有蒙层
				var mask:Ui;
				if (modalClass == null){
					mask = new Modal();
				} else {
					mask = new PopManager.modalClass();
				}
				mask.width = parent.width;
				mask.height = parent.height;
				mask.draw();
				parent.addChild(mask);
			}
			parent.addChild(ui);
			if (center){
				ui.x = parent.width / 2 - ui.width / 2;
				ui.y = parent.height / 2 - ui.height / 2;
			}
		}

		/**
		 * 移除弹出窗口
		 * @param	ui		窗体UI
		 */
		public static function removePop(ui:Ui):void {
			var comp:DisplayObjectContainer = ui.parentDoc;
			if (comp != null){
				var n:int = comp.getChildIndex(ui);
				var c:* = comp.getChildAt(n - 1);
				if (c is Modal){
					comp.removeChildAt(n - 1);
				}
				comp.removeChild(ui);
			}
		}
	}
}