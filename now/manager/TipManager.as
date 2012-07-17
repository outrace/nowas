package now.manager {
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import now.inter.ITip;
	import now.nui.Tip;
	import now.nui.Ui;
	import now.nui.UiConst;

	/**
	 * 提供提示相关的全局方法
	 */
	public final class TipManager {
		/**
		 * 显示的延时时间，单位毫秒
		 */
		public static var delay:int = 0;

		/**
		 * 是否使用淡入淡出效果
		 */
		public static var effect:Boolean = false;

		public static var _defTip:Tip = null;
		
		public static var _otherTip:Ui;

		/**
		 * 移入
		 * @param	e
		 */
		private static function rollOver(e:MouseEvent):void {
			var ui:Ui = e.currentTarget as Ui;
			ui.addEventListener(MouseEvent.ROLL_OUT, rollOut);
			showTipMsg(ui, ui.tipData[0],ui.tipData[1],ui.tipData[2],ui.tipData[3],ui.tipData[4]);
		}
		
		/**
		 * 移开
		 * @param	e
		 */
		private static function rollOut(e:MouseEvent):void {
			e.currentTarget.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
			removeTip();
		}
		
		
		/**
		 * 解除tip绑定
		 * @param	ui		需要解除tip绑定的ui
		 */
		public static function unbindTip(ui:Ui):void {
			if (ui.bindTip){
				ui.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
				ui.tipData = null;
				ui.bindTip = false;
			}
		}
		
		/**
		 * 进行tip绑定
		 * @param	ui				需要绑定tip的ui组件
		 * @param	direct			绑定的方向
		 * @param	msg				显示内容
		 * @param	distance		显示距离
		 */
		public static function bindTip(ui:Ui, direct:String, msg:*, distance:Number = 2, cls:Class=null,parent:Ui=null):void {
			if (ui.bindTip) {
				ui.tipData = [direct, msg, distance,cls,parent];
			} else {
				ui.tipData = [direct, msg, distance,cls,parent];
				ui.bindTip = true;
				ui.addEventListener(MouseEvent.ROLL_OVER, rollOver);
			}
		}
		
		/**
		 * 设置TIP的显示位置
		 * @param	ui		目标UI组件
		 * @param	p		tip要显示的坐标点
		 * @param	tip		需要调整的Tip组件
		 * @param	direct	TIP的显示方向
		 */
		private static function resetPos(target:Ui,p:Point, tip:Ui, direct:String):void {
			if (direct == UiConst.LEFT){
				tip.x = p.x - tip.width - 2 - (tip as ITip).distance;
				tip.y = p.y + target.height / 2 - tip.height / 2;
			} else if (direct == UiConst.RIGHT){
				tip.x = p.x + target.width + 2 + (tip as ITip).distance;
				tip.y = p.y + target.height / 2 - tip.height / 2;
			} else if (direct == UiConst.BOTTOM){
				tip.x = p.x + target.width / 2 - tip.width / 2;
				tip.y = p.y + target.height + 2 + (tip as ITip).distance;
			} else {
				tip.x = p.x + target.width / 2 - tip.width / 2;
				tip.y = p.y - tip.height - 2 - (tip as ITip).distance;
			}
		}

		/**
		 * 移除tip
		 * @param	tip		Tip窗体
		 */
		public static function removeTip():void {
			if (_defTip !=  null) {
				PopManager.removePop(_defTip);
				_defTip.visible = false;
			}
			if (_otherTip != null){
				PopManager.removePop(_otherTip);
				_otherTip.dispose();
				_otherTip = null;
			}
		}

		/**
		 * 显示文字的tip
		 * @param	target		需要显示tip的ui组件
		 * @param	msg			tip文字内容
		 * @param	direct		显示位置。支持UiConst.LELT/RIGHT/TOP/BOTTOM
		 */
		private static function showTipMsg(target:Ui, direct:String, msg:*, distance:Number = 0, cls:Class = null, parent:Ui = null):void {
			var p:Point;
			if(parent==null){//如果parent等于null，把坐标转成全局
				p = target.localToGlobal(new Point(0, 0));
			}else {
				p = new Point(target.x, target.y);
			}
			removeTip();
			if (cls == null){
				if (_defTip == null) {
					_defTip = new Tip();
				}
				_defTip.direct = direct;
				_defTip.distance = distance;
				_defTip.data = msg;
				_defTip.height = 60;
				_defTip.draw();
				_defTip.visible = true;
				resetPos(target, p,_defTip, direct);
				PopManager.addPop(_defTip, false, false,parent);
			} else{
				_otherTip = new cls();
				_otherTip["direct"] = direct;
				_otherTip["distance"] = distance;
				_otherTip["data"] = msg;
				_otherTip.draw();
				resetPos(target,p, _otherTip, direct);
				PopManager.addPop(_otherTip, false, false,parent);
			}
		}
		
		public static function showTip(target:Ui, direct:String, msg:*, distance:Number = 0, cls:Class = null, delay:int=1000,parent:Ui=null):void {
			var _defTip:Tip;
			var _otherTip:Ui;
			var p:Point;
			if(parent==null){
				p = target.localToGlobal(new Point(0, 0));
			}else {
				p = new Point(target.x, target.y);
			}
			if (cls == null){
				_defTip = new Tip();
				_defTip.direct = direct;
				_defTip.distance = distance;
				_defTip.data = msg;
				_defTip.height = 60;
				_defTip.draw();
				resetPos(target,p,_defTip, direct);
				PopManager.addPop(_defTip, false, false,parent);
			} else{
				_otherTip = new cls();
				_otherTip["direct"] = direct;
				_otherTip["distance"] = distance;
				_otherTip["data"] = msg;
				_otherTip.draw();
				resetPos(target,p,_otherTip, direct);
				PopManager.addPop(_otherTip, false, false,parent);
			}
			
			var func:Function = function():void {
				if (cls == null) {
					PopManager.removePop(_defTip);
					_defTip.dispose();
					_defTip = null;
				}else {
					PopManager.removePop(_otherTip);
					_otherTip.dispose();
					_otherTip = null;
				}
			}
			setTimeout(func, delay);
		}
	}
}