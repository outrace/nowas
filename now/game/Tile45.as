package now.game {
	import flash.display.Shape;
	import flash.geom.Point;
	import now.nui.UiConst;

	/**
	 * 45度角的Tile
	 */
	public final class Tile45 {
		/**
		 * 该类型是一个钻石形状，四个边角会无法使用
		 */
		public static const TYPE_DIAMOND:String = "diamond";
		/**
		 * 该类型是彻底网状结构，可用面积更多
		 */
		public static const TYPE_STAGGERED:String = "staggered";

		public static var width:int = 32;
		public static var height:int = 16;
		public static var halfWidth:int = 16;
		public static var halfHeight:int = 8;

		private static var tileType:String = "staggered"; //
		private static var rows:int = 13; //行数
		private static var cols:int = 10; //列数。如果是diamond类型，则此数忽略。
		private static var changeX:int = 0;
		private static var changeY:int = 0;

		/**
		 * 初始化Tile
		 * @param	_width	单个tile格子的宽度
		 * @param	_height	单个tile格子的高度
		 * @param	_rows	tile的行数
		 * @param	_cols	tile的列数
		 * @param	_tileType	tile45的类型。目前支持 Tile45.TYPE_DIAMOND 和 Tile45.TYPE_STAGGERED
		 */
		public static function initTile(_width:int, _height:int, _rows:int, _cols:int = 0, _tileType:String = TYPE_STAGGERED):void {
			Tile45.width = _width;
			Tile45.height = _height;
			Tile45.halfWidth = Tile45.width / 2;
			Tile45.halfHeight = Tile45.height / 2;

			Tile45.rows = _rows;
			Tile45.cols = _cols;
			Tile45.tileType = _tileType;
			if (Tile45.tileType == Tile45.TYPE_STAGGERED){
				if (Tile45.rows % 2 == 0){
					throw new Error("只支持单数行");
				}
				Tile45.changeX = ((Tile45.rows + 1) / 2 - 1) * Tile45.halfWidth;
				Tile45.changeY = ((Tile45.rows + 1) / 2 - 1) * Tile45.halfHeight + Tile45.halfHeight;
			}
		}

		/**
		 * 根据当前的x轴和y轴得到它在哪个X/Y的格子上
		 * @param	p		原始坐标点
		 * @return	Point
		 */
		public static function pos2tile(p:Point):Point {
			var np:Point = new Point(0, 0);
			var old:Point = new Point(p.x, p.y);
			if (Tile45.tileType == Tile45.TYPE_STAGGERED){
				old.x = p.x + Tile45.changeX;
				old.y = p.y - Tile45.changeY;
			}
			np.x = int(old.x / Tile45.width - old.y / Tile45.height);
			np.y = int(old.x / Tile45.width + old.y / Tile45.height);
			old = null;
			return np;
		}

		/**
		 * 根据当前tile的x/y格子信息，得到该格子中心点的x轴、y轴坐标
		 * @param	p		格子坐标点
		 * @param	site	物品所占格子大小，默认1*1
		 * @return	Point
		 */
		public static function tile2pos(p:Point, size:int = 1):Point {
			var np:Point = new Point(0, 0);
			np.x = int(width / 2 * (p.x + p.y + 1)) + Tile45.halfWidth * (size - 1);
			np.y = int(height / 2 * (p.y - p.x));
			if (Tile45.tileType == Tile45.TYPE_STAGGERED){
				np.x = np.x - Tile45.changeX;
				np.y = np.y + Tile45.changeY;
			}
			return np;
		}
		

		/**
		 * 得到一个绘制好的网格
		 */
		public static function getGrid():Shape {
			var shape:Shape = new Shape();
			var i:int = 0;
			if (Tile45.tileType == Tile45.TYPE_DIAMOND){
				shape.graphics.clear();
				shape.graphics.beginFill(0xa6c529, 0.2);
				shape.graphics.drawRect(0, -Tile45.rows * Tile45.halfHeight, Tile45.rows * Tile45.width, Tile45.rows * Tile45.height);

				shape.graphics.lineStyle(0.4, 0x565715, 0.3);
				var disw:Number = Tile45.rows * Tile45.halfWidth;
				var dish:Number = Tile45.rows * Tile45.halfHeight;
				for (i = 0; i < Tile45.rows + 1; i++){
					shape.graphics.moveTo(i * Tile45.halfWidth, -i * Tile45.halfHeight);
					shape.graphics.lineTo(i * Tile45.halfWidth + disw, -i * Tile45.halfHeight + dish);
					shape.graphics.moveTo(i * Tile45.halfWidth, i * Tile45.halfHeight);
					shape.graphics.lineTo(i * Tile45.halfWidth + disw, i * Tile45.halfHeight - dish);
				}
				shape.y = Tile45.rows * Tile45.halfHeight;
				shape.graphics.endFill();
			} else {
				var gheight:int = (Tile45.rows + 1) * Tile45.halfHeight;
				var gwidth:int = Tile45.cols * Tile45.width + Tile45.halfWidth
				shape.graphics.clear();
//				shape.graphics.beginFill(0xa6c529,0.2);
				shape.graphics.drawRect(0, 0, gwidth, gheight);

				var xnum:int = Tile45.cols * Tile45.rows;
				var ynum:int = int(Tile45.rows / 2) + 2;

				var hh:int = 1;
				var ww:int = 1;
				var th:int = 1;
				shape.graphics.lineStyle(0.4, 0x565715, 0.4);
				
				var tmpx:int;
				var tmpy:int;
				var ew:int;
				var ey:int;
				var tt:int;
				for (i = 1; i < xnum; i++){
					tmpx = Tile45.halfWidth * (i * 2 - 1);
					tmpy = Tile45.halfHeight * (i * 2 - 1);

					ew = 0;
					ey = 0;
					tt = 0;

					if (tmpx > gwidth){
						tmpx = gwidth;
						ew = (ww * Tile45.height);
						ww = ww + 1;
					}
					if (tmpy > gheight){
						tmpy = gheight;
						ey = (hh * 2 - 1) * Tile45.halfWidth;
						hh = hh + 1;
					}

					if (ew <= gheight){
						shape.graphics.moveTo(tmpx, ew);
						shape.graphics.lineTo(ey, tmpy);

						shape.graphics.moveTo(tmpx, gheight - ew);
						shape.graphics.lineTo(ey, gheight - tmpy);
					}

				}
				shape.graphics.endFill();
			}
			return shape;
		}
	}
}