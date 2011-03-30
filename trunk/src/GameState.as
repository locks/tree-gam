package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	import flash.display.Shape;
	import flash.display.StageQuality;
	/**
	* ...
	* @author Thomas Liu
	*/
	public class GameState extends FlxState
	{
		[Embed (source = "../data/tiles.png")] private var tilesImage:Class;
		[Embed (source = "../data/jump_particle.png")] private var jumpParticleImage:Class;
		[Embed (source = "../data/overlay.png")] private var overlayImage:Class;
		public var player:Player;
		public var map:FlxTilemap;
		public var shadowMap:BitmapData; 
		public var overlay:FlxSprite;
		
		public var particles:FlxGroup;
		public function GameState() 
		{
			super();
			overlay = new FlxSprite();
			overlay.loadGraphic(overlayImage, false, false, 300, 300);
			
			shadowMap = new BitmapData(FlxG.width, FlxG.height, true, 0x55000000);
			player = new Player(50, 50);
			add(player);
			//add(overlay);
			bgColor = 0xffd1dfe7;
			map = new FlxTilemap();
			var tilemap:String = ( <![CDATA[
			1,1,1,1,1,1,6,1,1,1,1,1
			1,0,0,0,0,0,5,0,0,0,0,1
			1,0,0,0,3,0,4,0,0,0,0,1
			1,0,0,0,0,0,0,0,0,3,0,1
			1,6,6,1,0,0,0,0,0,0,0,1
			1,1,1,0,0,0,0,0,0,8,0,1
			1,2,0,0,0,6,0,0,0,3,0,1
			2,0,0,0,0,4,0,0,0,0,0,1
			1,0,0,0,0,0,0,0,0,0,0,1
			1,0,0,0,0,7,8,9,0,0,0,1
			2,0,6,0,0,1,0,1,2,0,0,1
			1,0,5,0,0,2,0,2,1,0,0,1
			1,0,5,0,0,1,0,1,2,0,0,1
			1,0,4,0,0,0,0,0,0,0,0,1
			1,0,0,0,0,0,0,8,0,0,7,1
			1,2,1,2,2,3,1,1,1,1,1,1

			]]> ).toString();
			map.loadMap(tilemap, tilesImage, 8, 8);
			add(map);
			
			particles = new FlxGroup();
			add(particles);
			// Populate with empty particles so we never have to create them on the fly
			for (var i:int = 0; i < 2; i++) { particles.add( new Particle() ); }
			
		}
		
		override public function create():void 
		{
			FlxG.stage.quality = StageQuality.LOW;	// Removes anti-aliasing on the shadows. Not sure if it's better or worse. 
			super.create();
		}
		
		public function addJumpParticle(x:int, y:int) : void
		{
			addParticle(x, y, jumpParticleImage, 8, 2, 0.2);
		}
		
		override public function update():void 
		{
			super.update();
			shadowMap.fillRect(new Rectangle(0, 0, FlxG.width, FlxG.height), 0xffffffff);
			FlxU.collide(player, map);
			
		}
		override public function render():void 
		{
			drawShadows();
			FlxG.buffer.draw(shadowMap, null,null, "multiply");
			 //new ColorTransform(1,1,1,1,0,0,0,-128)
			
			super.render();
			FlxG.buffer.draw(overlay.pixels, new Matrix(1, 0, 0, 1, player.x - overlay.width / 2 + 4, player.y - overlay.height / 2 + 4), null, "multiply");
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
						
						

						//s.graphics.beginFill(0x4d3781, 1);
						s.graphics.beginFill(0x000000, 1);
						s.graphics.lineStyle(1, 0xff000000, 0);
						
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
			/*
			var q:Shape = new Shape();
			for (r = 0; r < map.widthInTiles; r++) {
				for (c = 0; c < map.heightInTiles; c++) {
					if (map.getTile(r, c) != 0) {
						var res:FlxPoint = new FlxPoint(-1, -1);
						map.ray(px, py, r * map._tileWidth + map._tileWidth / 2, c * map._tileHeight + map._tileHeight / 2, res);
						if (res.x > -1 && res.y > -1) {
							
							//q.graphics.beginFill(0xffff0000);
							//q.graphics.drawRect(res.x * map._tileHeight, res.y * map._tileWidth, map._tileWidth, map._tileHeight);
							//q.graphics.drawRect(res.x, res.y, map._tileWidth, map._tileHeight);
							//q.graphics.endFill();
						}
					}
					
				}
			}
			*/
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
		
		private function addParticle(x:int, y:int, graphic:Class, width:int, numFrames:int, lifetime:Number):void
		{
			var p:Particle = (Particle)(particles.getFirstAvail());
			if (p == null)
			{
				p = (Particle)(particles.getRandom());
			}
			p.spawn(x, y, graphic, width, numFrames, lifetime);
		}		
	}

}
