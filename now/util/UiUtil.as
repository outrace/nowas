package now.util {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import now.inter.ITip;
	import now.manager.RequestManager;
	import now.nui.Ui;
	import now.nui.UiConst;
	
	/**
	 * UI相关的辅助函数
	 */
	public final class UiUtil {
		
		/**
		 * 对于部分url进行预加载
		 */
		public static function preload(urls:Vector.<String>):void {
		}
		
		/**
		 * 画一个可以带圆角的四边形
		 */
		public static function rectangle(ui:*, width:int, height:int,color:Number=0xff00ff,round:int=0, border:int=1,borderColor:Number=0x000000, alpha:Number=1.0):void{
			ui.graphics.clear();
			ui.graphics.beginFill(color,alpha);
			ui.graphics.drawRoundRect(0, 0, width, height,round,round);
			ui.graphics.endFill();
			
			if (border > 0) {
				if (isNaN(borderColor)) {
					borderColor = 0x000000;
				}
				ui.graphics.lineStyle(border, borderColor);
				ui.graphics.drawRoundRect(0, 0, width, height,round, round);
			}
		}
		
		/** 
		 * 进行重复显示
		 * @param	dis		需要重绘的位图  一般是bitmap
		 * @param	con		需要放进去的容器
		 * @param	getWidth	宽度。如果con是新new出来的Sprte，那么con.width是0，所以需要传递过来一个宽度和高度
		 * @param	getHeight	高度
		 */
		public static function repeatDis(dis:DisplayObject,con:DisplayObjectContainer,getWidth:Number=-1,getHeight:Number=-1):void {
			if (! dis is Bitmap) {
				throw new Error("重复显示的图形必须是位图");
			}
			var w:Number;
			var h:Number;
			w = dis.width;
			h = dis.height;
			var _width:Number = (getWidth == -1) ? con.width : getWidth;
			var _height:Number = (getHeight == -1) ? con.height : getHeight;
			
			if (_width < w || _height < h) {
				throw new Error("宽高必须都大于重复位图的宽高");
			}
						
			//进行重复的位图拷贝
			var bd:BitmapData = Bitmap(dis).bitmapData;
			var col:Number = 0;
			var row:Number = 0;
			var tmpCol:Number;
			var tmpRow:Number;
			var twidth:Number;
			var theight:Number;
			var bm:Bitmap;
			var addBd:BitmapData;
			while (col < _width) {//一列一列向右推移
				tmpCol = col + w;
				if (tmpCol < _width) {//说明还没有到最后一个格子，是用整个宽度
					twidth = w;
				} else {
					twidth = _width - col;
				}
				row = 0;
				while (row < _height) {//一行一行向下推移
					tmpRow = row + h;
					if (tmpRow < _height) {
						theight = h;
					} else {
						theight = _height - row;
					}
					if (twidth == w && theight == h) {
						bm = new Bitmap(bd);
						bm.x = col;
						bm.y = row;
						con.addChild(bm);
					} else {
						addBd = new BitmapData(twidth, theight);
						addBd.copyPixels(bd, new Rectangle(0, 0, twidth, theight),new Point(0,0));
						bm = new Bitmap(addBd);
						bm.x = col;
						bm.y = row;
						con.addChild(bm);
					}
					row = tmpRow;
				}
				col = tmpCol;
			}
		}
		
		/**
		 * Ui加入border
		 * @param	ui	                        要加入Border的UI
		 * @param	content                     包含再border内的UI内部显示对象
		 * @param	_direct                     显示方向
		 * @param	_borderColor                边框颜色
		 * @param	_borderThickness            边框厚度
		 * @param	_borderDistance             ToolTip突出的高度
		 * @param	_borderBackgroundColor      背景颜色
		 * @param	_borderBackgroundAlpha      背景透明度
		 * @param	_padding                    边框和内部显示对象的距离
		 * @param	_conerLen                   ToolTip突出的宽度
		 * @return
		 */
		public static function drawTipBorder(ui:DisplayObject,content:DisplayObject,_direct:String=UiConst.TOP,_borderColor:int=0xc4a37a,_borderThickness:int = 2,_borderDistance:int = 10,_borderBackgroundColor:int=0xfffcd3,_borderBackgroundAlpha:Number=0.7,_padding:int=4,_conerLen:int=10):Shape {
			var _border:Shape = new Shape();
			_border.graphics.clear();
			_border.graphics.lineStyle(_borderThickness, _borderColor);
			_border.graphics.beginFill(_borderBackgroundColor, _borderBackgroundAlpha);
			if (_direct == UiConst.TOP) {
				ui.width = content.width + _padding * 2;
				ui.height = content.height + _borderDistance + _padding * 2;
				content.x = _padding;
				content.y = _padding;
			
				_border.graphics.moveTo(0, 0);
				_border.graphics.lineTo(ui.width, 0);
				_border.graphics.lineTo(ui.width, ui.height - _borderDistance);
				_border.graphics.lineTo(ui.width/2+_conerLen, ui.height - _borderDistance);
				_border.graphics.lineTo(ui.width/2, ui.height);
				_border.graphics.lineTo(ui.width/2-_conerLen, ui.height - _borderDistance);
				_border.graphics.lineTo(0, ui.height - _borderDistance);
				_border.graphics.lineTo(0, 0);
			}else if (_direct == UiConst.BOTTOM) {
				ui.width = content.width + _padding * 2;
				ui.height = content.height + _borderDistance + _padding * 2;
				content.x = _padding;
				content.y = _padding + _borderDistance;
				
				_border.graphics.moveTo(0, _borderDistance);
				_border.graphics.lineTo(ui.width/2-_conerLen, _borderDistance);
				_border.graphics.lineTo(ui.width/2, 0);
				_border.graphics.lineTo(ui.width/2+_conerLen, _borderDistance);
				_border.graphics.lineTo(ui.width, _borderDistance);
				_border.graphics.lineTo(ui.width, ui.height);
				_border.graphics.lineTo(0, ui.height);
				_border.graphics.lineTo(0, _borderDistance);
			}else if (_direct == UiConst.LEFT) {
				ui.width = content.width + _borderDistance + _padding * 2;
				ui.height = content.height + _padding * 2;
				content.x = _padding;
				content.y = _padding;
				
				_border.graphics.moveTo(0, 0);
				_border.graphics.lineTo(ui.width - _borderDistance, 0);
				_border.graphics.lineTo(ui.width - _borderDistance, ui.height / 2 - _conerLen);
				_border.graphics.lineTo(ui.width, ui.height / 2);
				_border.graphics.lineTo(ui.width - _borderDistance, ui.height / 2 + _conerLen);
				_border.graphics.lineTo(ui.width - _borderDistance, ui.height);
				_border.graphics.lineTo(0, ui.height);
				_border.graphics.lineTo(0, 0);
			}else if (_direct == UiConst.RIGHT) {
				ui.width = content.width + _borderDistance + _padding * 2;
				ui.height = content.height + _padding * 2;
				content.x = _padding + _borderDistance;
				content.y = _padding;
				
				_border.graphics.moveTo(_borderDistance, 0);
				_border.graphics.lineTo(_borderDistance, ui.height / 2 - _conerLen);
				_border.graphics.lineTo(0, ui.height / 2);
				_border.graphics.lineTo(_borderDistance, ui.height / 2 + _conerLen);
				_border.graphics.lineTo(_borderDistance, ui.height);
				_border.graphics.lineTo(ui.width, ui.height);
				_border.graphics.lineTo(ui.width, 0);
				_border.graphics.lineTo(_borderDistance, 0);
			}
			_border.graphics.endFill();
			
			return _border;
		}
		
	
	}

}