package now.game {

	/**
	 * A星寻路算法
	 */
	public class AStar {
		private static var isPathFind:Boolean;
		private static var closeA:Array;
		private static var findA:Array;
		private static var dirA:Array = [[1, 0, 10], [0, 1, 10], [-1, 0, 10], [0, -1, 10], [1, 1, 14], [-1, 1, 14], [-1, -1, 14], [1, -1, 14]];
		private static var openA:Array;
		private static var walkA:Array;
		private static var endX:int;
		private static var endY:int;

		/**
		 * 进行寻路，反悔路点数组
		 * @param	mapArr
		 * @param	ex
		 * @param	ey
		 * @param	sx
		 * @param	sy
		 * @return
		 */
		public static function startSearch(mapArr:Array, ex:int, ey:int, sx:int, sy:int):Array {
			var emptyArray:Array;
			endX = ex;
			endY = ey;
			isPathFind = false;
			setFindA(mapArr);
			if (mapArr && mapArr[ey][ex] == 0 && !(sx == ex && sy == ey)){
				openA = new Array();
				closeA = new Array();
				searchPath(sx, sy, sx, sy, 0);
			}
			if (isPathFind){
				return getPath();
			}

			return emptyArray;
		}

		private static function setFindA(mapArr:Array):void {
			findA = new Array();
			for (var i:String in mapArr){
				findA[i] = new Array();
				for (var j:String in mapArr[i]){
					if (mapArr[i][j] == 0){
						findA[i][j] = 0;
					} else {
						findA[i][j] = 1;
					}
				}
			}
		}

		private static function getPath():Array {
			var i:int = closeA.length - 1;
			var n:int = 0;
			walkA = new Array();
			walkA[0] = new Array(2);
			walkA[0][0] = closeA[i][0];
			walkA[0][1] = closeA[i][1];
			var px:int = closeA[i][2];
			var py:int = closeA[i][3];
			for (var j:Number = i - 1; j >= 0; j--){
				if (px == closeA[j][0] && py == closeA[j][1]){
					n++;
					walkA[n] = new Array(2);
					walkA[n][0] = closeA[j][0];
					walkA[n][1] = closeA[j][1];
					px = closeA[j][2];
					py = closeA[j][3];
				}
			}
			walkA.reverse();
			return walkA;
		}

		private static function searchPath(nx:int, ny:int, px:int, py:int, g:int):void {
			var hval:int = 0;
			var gval:int = 0;
			var min:int = 0;
			var len:int = 0;
			findA[ny][nx] = 1;
			closeA.push([nx, ny, px, py]);
			for (var n:int = 0; n < 8; n++){
				var adjX:Number = nx + dirA[n][0];
				var adjY:Number = ny + dirA[n][1];
				if (adjX < 0 || adjX >= findA.length || adjY < 0 || adjY >= findA.length){
					continue;
				}
				if (adjX == endX && adjY == endY){
					closeA.push([adjX, adjY, nx, ny]);
					isPathFind = true;
					return;
				}
				if (findA[adjY][adjX] == 0){
					hval = 10 * (Math.abs(endX - adjX) + Math.abs(endY - adjY));
					gval = g + dirA[n][2];
					findA[adjY][adjX] = gval;
					openA.push([adjX, adjY, nx, ny, gval + hval, gval]);
				} else if (findA[adjY][adjX] > 1){
					gval = g + dirA[n][2];
					if (gval < findA[adjY][adjX]){
						hval = 10 * (Math.abs(endX - adjX) + Math.abs(endY - adjY));
						for (var j:int = 1; j < openA.length; j++){
							if (openA[j][0] == adjX && openA[j][1] == adjY){
								openA[j] = [adjX, adjY, nx, ny, gval + hval, gval];
								findA[adjY][adjX] = gval;
								break;
							}
						}
					}
				}
			}
			if (openA.length < 1){
				isPathFind = false;
				return;
			} else {
				len = openA.length;
				for (var m:Number = 0; m < len; m++){
					if (openA[min][4] > openA[m][4]){
						min = m; //获取最小F值
					}
				}
				var moveToCloseA:Array = openA.splice(min, 1);
				searchPath(moveToCloseA[0][0], moveToCloseA[0][1], moveToCloseA[0][2], moveToCloseA[0][3], moveToCloseA[0][5]);
			}
		}
	}
}