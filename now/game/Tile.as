package now.game {
	import flash.display.Shape;
	import flash.geom.Point;

	/**
	 * 平铺的Tile
	 */
	public final class Tile {
		private static var width:int = 0;
		private static var height:int = 0;
		private static var halfWidth:int = 0;
		private static var halfHeight:int = 0;

		private static var rows:int = 13; //行数
		private static var cols:int = 10; //列数

		/**
		 * 初始化Tile
		 * @param	_width	单个tile格子的宽度
		 * @param	_height	单个tile格子的高度
		 * @param	_rows	tile的行数
		 * @param	_cols	tile的列数
		 */
		public static function initTile(_width:int, _height:int, _rows:int, _cols:int = 0):void {
			Tile.width = _width;
			Tile.height = _height;
			Tile.halfWidth = Tile.width / 2;
			Tile.halfHeight = Tile.height / 2;

			Tile.rows = _rows;
			Tile.cols = _cols;
		}

		/**
		 * 根据当前的x轴和y轴得到它在哪个X/Y的格子上
		 * @param	p		原始坐标点
		 * @return	Tile中的坐标
		 */
		public static function pos2tile(p:Point):Point {
			var np:Point = new Point(0, 0);
			np.x = int(p.x / Tile.width) + 1;
			np.y = int(p.y / Tile.height) + 1;
			return np;
		}

		/**
		 * 根据当前tile的x/y格子信息，得到该格子中心点的x轴、y轴坐标
		 * @param	p		格子坐标点
		 * @param	size	物品所占格子大小，默认1*1
		 * @return	原始的X轴和Y轴坐标点
		 */
		public static function tile2pos(p:Point, size:int = 1):Point {
			var np:Point = new Point(0, 0);
			np.x = width * (p.x - 1) + Tile.halfWidth * (size - 1);;
			np.y = height * (p.y - 1);
			
			np.x = np + Tile.halfWidth * (size - 1);
			return np;
		}

		/**
		 * 得到一个绘制好的网格
		 */
		public static function getGrid():Shape {
			var shape:Shape = new Shape();
			
			var allHeight:int = Tile.cols * Tile.height;
			var allWidth:int = Tile.rows * Tile.width;
			
			shape.graphics.clear();
			shape.graphics.beginFill(0xa6c529, 0.2);
			shape.graphics.drawRect(0, 0, allWidth, allHeight);

			shape.graphics.lineStyle(1, 0x000000, 0.3);
			//绘制四方形格子
			var tmp:int;
			for (var i:int = 0; i < Tile.cols; i++) {
				tmp = i * Tile.width;
				shape.graphics.moveTo(tmp, 0);
				shape.graphics.lineTo(tmp,allHeight);
			}
			for (var j:int = 0; j < Tile.rows; j++) {
				tmp = j * Tile.height;
				shape.graphics.moveTo(0, tmp);
				shape.graphics.lineTo(allWidth,tmp);
			}
			
			shape.graphics.endFill();
			return shape;
		}
	}
}