package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import org.flixel.FlxPoint;
	import org.flixel.FlxState;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	import flash.display.Shape;
	/**
	* ...
	* @author Thomas Liu
	*/
	public class GameState extends FlxState
	{
		[Embed (source = "../data/tiles.png")] private var tilesImage:Class;
		public var player:Player;
		public var map:FlxTilemap;
		public var shadowMap:BitmapData; 
		public function GameState() 
		{
			super();
			shadowMap = new BitmapData(FlxG.width, FlxG.height, true, 0x55000000);
			player = new Player(50, 50);
			add(player);
			bgColor = 0xfff4f0ff;
			map = new FlxTilemap();
			var tilemap:String = ( <![CDATA[
			1,1,1,1,1,1,1,1,1,1,1,1
			1,0,0,0,0,0,1,0,0,0,0,1
			1,0,0,0,1,0,1,0,0,0,0,1
			1,0,0,0,0,0,0,0,0,1,0,1
			1,1,1,1,0,0,0,0,0,0,0,1
			1,1,1,0,0,0,0,0,0,1,0,1
			1,1,0,0,0,1,0,0,0,1,0,1
			1,0,0,0,0,1,0,0,0,0,0,1
			1,0,0,0,0,0,0,0,0,0,0,1
			1,0,0,0,0,1,1,1,0,0,0,1
			1,0,1,0,0,1,0,1,1,0,0,1
			1,0,1,0,0,1,0,1,1,0,0,1
			1,0,1,0,0,1,0,1,1,0,0,1
			1,0,1,0,0,0,0,0,0,0,0,1
			1,0,0,0,0,0,0,1,0,0,1,1
			1,1,1,1,1,1,1,1,1,1,1,1

			]]> ).toString();
			map.loadMap(tilemap, tilesImage, 8, 8);
			add(map);
		}
		override public function update():void 
		{
			super.update();
			FlxU.collide(player, map);
			shadowMap.fillRect(new Rectangle(0, 0, FlxG.width, FlxG.height), 0x55000000);
			drawShadows();
		}
		override public function postProcess():void 
		{
			FlxG.buffer.draw(shadowMap);
			super.postProcess();
		}
		public function getTilesOnScreen():Array
		{
			//map.g
			return map._data;
		}
		public function drawShadows():void 
		{
			var px:int = player.x + 4;
			var py:int = player.y + 4;

			var s:Shape = new Shape();
			for (var r:int = 0; r < map.widthInTiles; r++) {
				for (var c:int = 0; c < map.heightInTiles; c++) {
					var corners:Array = getCorners(r, c);
					if (map.getTile(r, c) != 0) {
						var rect:Array = new Array();
						var tl:FlxPoint = corners[0];
						var tr:FlxPoint = corners[1];
						var bl:FlxPoint = corners[2];
						var br:FlxPoint = corners[3];
						var extra:FlxPoint = null;
						if (px <= tl.x && py <= tl.y) {
							rect.push(tr);
							rect.push(bl);
							extra = new FlxPoint(br.x, br.y);
						} else if (py <= tr.y && px > tl.x && px < tr.x) {
							rect.push(bl);
							rect.push(br);
						} else if (px >= tr.x && py <= tr.y) {
							rect.push(tl);
							rect.push(br);
							extra = new FlxPoint(bl.x, bl.y);
						} else if (px <= tl.x && py < bl.y && py > tl.y) {
							rect.push(tr);
							rect.push(br);
						} else if (px >= tr.x && py < br.y && py > tr.y) {
							rect.push(tl);
							rect.push(bl);
						} else if (px <= bl.x && py >= bl.y) {
							rect.push(tl);
							rect.push(br);
							extra = new FlxPoint(tr.x, tr.y);
						} else if (px > bl.x && px < br.x && py >= bl.y) {
							rect.push(tl);
							rect.push(tr);
						} else if (px >= br.x && py  >= br.y) {
							rect.push(bl);
							rect.push(tr);
							extra = new FlxPoint(tl.x, tl.y);
						}
						

					
						var corner1:FlxPoint = rect[0] as FlxPoint;
						var corner2:FlxPoint = rect[1] as FlxPoint;
						var corner3:FlxPoint = new FlxPoint((corner1.x - px) * 100 + corner1.x, (corner1.y - py) * 100 + corner1.y);
						var corner4:FlxPoint = new FlxPoint((corner2.x - px) * 100 + corner2.x, (corner2.y - py) * 100 + corner2.y);
						
						

						s.graphics.beginFill(0x000000, 0.5);
						s.graphics.lineStyle(1, 0x55000000, 0.2);
						
						// 1 2 4 3
						s.graphics.moveTo(corner1.x, corner1.y);
						if (extra != null) {
							s.graphics.lineTo(extra.x, extra.y);
						}
						s.graphics.lineTo(corner2.x, corner2.y);
						s.graphics.lineTo(corner4.x, corner4.y);
						s.graphics.lineTo(corner3.x, corner3.y);
						

						s.graphics.endFill();
						
						
					}
				}
			}
			var q:Shape = new Shape();
			for (r = 0; r < map.widthInTiles; r++) {
				for (c = 0; c < map.heightInTiles; c++) {
					if (map.getTile(r, c) != 0) {
						var res:FlxPoint = new FlxPoint(-1, -1);
						map.ray(px, py, r * map._tileWidth + map._tileWidth / 2, c * map._tileHeight + map._tileHeight / 2, res);
						if (res.x > -1 && res.y > -1) {
							
							q.graphics.beginFill(0xffff0000);
							//q.graphics.drawRect(res.x * map._tileHeight, res.y * map._tileWidth, map._tileWidth, map._tileHeight);
							q.graphics.drawRect(res.x, res.y, map._tileWidth, map._tileHeight);
							q.graphics.endFill();
						}
					}
					
				}
			}
			shadowMap.draw(s);
			//shadowMap.draw(q);
		}
		
		public function getCorners(tx:int, ty:int): Array 
		{
			var tl:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx, map.y + map._tileHeight * ty);
			var tr:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx + map._tileWidth, map.y + map._tileHeight * ty);
			var bl:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx, map.y + map._tileHeight * ty + map._tileHeight);
			var br:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx + map._tileWidth, map.y + map._tileHeight * ty + map._tileHeight);
			return [tl, tr, bl, br];
		}
		public function poot(): void {
			var p:FlxPoint = new FlxPoint();
			map.ray(player.x +4, player.y + 4, 0, 0, p);
			FlxG.log(p.x + ", " + p.y);
		
		}
	}

}
