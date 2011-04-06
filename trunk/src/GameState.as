package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.utils.Dictionary;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	* ...
	* @author Thomas Liu
	*/
	public class GameState extends FlxState
	{
		[Embed (source = "../data/tiles.png")] private var tilesImage:Class;
		[Embed (source = "../data/jump_particle.png")] private var jumpParticleImage:Class;
		[Embed (source = "../data/doublejump_particle.png")] private var doublejumpParticleImage:Class;
		[Embed (source = "../data/background.png")] private var bgImage:Class;
		[Embed (source = "../data/overlay.png")] private var overlayImage:Class;
		[Embed (source = "../data/light.png")] private var lightImage:Class;
		[Embed (source = "../data/light_particle.png")] private var lightParticleImage:Class;
		[Embed (source = "../data/tree_particle.png")] private var treeParticleImage:Class;
		
		[Embed (source = "../data/openmap.txt", mimeType="application/octet-stream")] private var openmapData:Class;
		
		public var player:Player;
		public var lantern:Lantern;
		public var map:FlxTilemap;
		public var shadowMap:BitmapData; 
		public var overlay:FlxSprite;
		public var particles:FlxGroup;
		public var entities:FlxGroup;
		public var editMode:EditMode;
		public var background:FlxSprite;
		public var filledTiles:Array = new Array();
		public var totaltiles:int;
		public var ending:Boolean = false;
		
		public var currentMapString:String;
		public var scrollObject:FlxSprite;
		
		public var currentTree:Tree;
		
		public var mapEntities:Array = [
			FirePit
		]
		
		public function GameState() 
		{
			bgColor = 0xffd1dfe7;
			
			map = new FlxTilemap();		
			currentMapString = generateEmptyMap();
			map.loadMap(currentMapString, tilesImage, 8, 8);
			
			entities = new FlxGroup();
			shadowMap = new BitmapData(FlxG.width, FlxG.height, true, 0x55000000);
			player = new Player(50, map.height - 16);
			lantern = new Lantern(50, 50);
			background = new FlxSprite(0, 8, bgImage);
			background.scrollFactor.x = background.scrollFactor.y = 0.5;
			var tree:Tree = new Tree(30, map.height - 8);			
			currentTree = tree;
			var lightEmission:FlxSprite = new FlxSprite(0, 0, lightImage);
			
			lightEmission.blend = "screen";
			lightEmission.alpha = 0.5;
			lantern.lightEmission = lightEmission;
			
			player.holdObject = lantern;
			tree.growTarget = lantern;

			scrollObject = new FlxSprite(0, 0);
			scrollObject.visible = false;

			particles = new FlxGroup();

			// Populate with empty particles so we never have to create them on the fly
			for (var i:int = 0; i < 150; i++) { particles.add( new Particle() ); }
		
			editMode = new EditMode(); // The editor is a mode in the game
			
			renumberEntities();
			add(background);
			add(tree);
			add(entities);	
			add(map);
			add(lightEmission);
			add(player);		
			add(lantern);		
			add(particles);		
			add(tree.warningSprite);		
			add(editMode);	
			add(scrollObject);
			
		}
		
		override public function create():void 
		{
			editMode.initialize();
			replaceEntityTiles();
			scrollObject.x = player.x;
			scrollObject.y = player.y;			
			FlxG.follow(scrollObject, 3);
			FlxG.followBounds(0, 0, map.width, map.height);
			FlxG.flash.start(0xff000000, 1);
			FlxG.stage.quality = StageQuality.MEDIUM;
		}
		
		override public function update():void 
		{
			if (FlxG.keys.justPressed("Q"))
			{
				editMode.toggle();
			}
			
			// Position the lantern			
			if (player.holdObject != null)
			{
				player.holdObject.x = player.x + ((player.facing == FlxSprite.RIGHT) ? 6 : -3);
				while (map.overlaps(player.holdObject))
				{
					player.holdObject.x += ((player.facing == FlxSprite.RIGHT) ? -1 : 1);
				}
				player.holdObject.y = player.y + 3;
				player.holdObject.velocity.y = 0;
				player.holdObject.velocity.x = 0;
			}

			shadowMap.fillRect(new Rectangle(0, 0, FlxG.width, FlxG.height), 0xffffffff);
			if (editMode.enabled)
			{
				scrollObject.x = player.x;
				scrollObject.y = player.y;
			}	
			else
			{
				if (!ending)
				{
					drawShadows();
					var psx:int = 0;
					var psy:int = 0;

					if ( Math.abs(lantern.x - currentTree.gameGrowPosition.x) > 70
					|| Math.abs(lantern.y - currentTree.gameGrowPosition.y) > 100
					|| currentTree.doneGrowing)
					{
						psx = lantern.x;
						psy = lantern.y;
					}
					else
					{
						psx = (lantern.x + currentTree.gameGrowPosition.x) / 2;
						psy = (lantern.y + currentTree.gameGrowPosition.y) / 2;				
					}

					if ( Math.abs(psx - player.x) > 50 || Math.abs(psy - player.y) > 50 )
					{
						scrollObject.x = player.x;
						scrollObject.y = player.y;
					}		
					else
					{
						scrollObject.x = psx;
						scrollObject.y = psy;
					}
				}
			}			
			
			super.update();

			
			FlxU.collide(player, map);
			FlxU.collide(lantern, map);
			FlxU.collide(player, entities);
			FlxU.collide(lantern, entities);
			
		}
		
		override public function postProcess():void 
		{
			FlxG.buffer.draw(shadowMap, null,new ColorTransform(1,1,1,1,0,0,0,-128), "multiply");
			super.postProcess();
		}
		
		public function getTilesOnScreen():Array
		{
			return map._data;
		}
		
		public function drawShadows2():void 
		{
			
			var px:int = lantern.x + 1;
			var py:int = lantern.y + 1;
			
			var s:Shape = new Shape();
			
			for (var r:int = 0; r < map.widthInTiles; r++) {
				for (var c:int = 0; c < map.heightInTiles; c++) {
					var corners:Array = getCorners(r, c);
					if (map.getTile(r, c) != 0) {
						var rect:Array = new Array();
						var tl:FlxPoint = corners[0]
						var tr:FlxPoint = corners[1]
						var bl:FlxPoint = corners[2]
						var br:FlxPoint = corners[3]
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
						}else { continue; }
						

					
						var corner1:FlxPoint = rect[0] as FlxPoint;
						var corner2:FlxPoint = rect[1] as FlxPoint;
						var corner3:FlxPoint = new FlxPoint((corner1.x - px) * 100 + corner1.x, (corner1.y - py) * 100 + corner1.y);
						var corner4:FlxPoint = new FlxPoint((corner2.x - px) * 100 + corner2.x, (corner2.y - py) * 100 + corner2.y);
						
						s.graphics.beginFill(0xff4d3781, 1);
						s.graphics.lineStyle(1, 0xff4d3781, 0);
						
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
			var screenPt:FlxPoint = getScreenXY(0, 0);
			var mtx:Matrix = new Matrix(1, 0, 0, 1, screenPt.x, screenPt.y);
			shadowMap.draw(s, mtx);
		}	
		
		public function drawShadows():void 
		{
			
			var px:int = lantern.x + 1;
			var py:int = lantern.y + 1;
			
			var s:Shape = new Shape();
			
			for (var i:int = 0; i < filledTiles.length; i++ ) {
				var c:int = filledTiles[i] / map.widthInTiles;
				var r:int = filledTiles[i] % map.widthInTiles;
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
					}else { continue; }
					

				
					var corner1:FlxPoint = rect[0] as FlxPoint;
					var corner2:FlxPoint = rect[1] as FlxPoint;
					var c1dx:Number = (corner1.x - px);
					var c1dy:Number = (corner1.y - py);
					/*var d:Number = Math.sqrt(c1dx * c1dx + c1dy * c1dy);
					c1dx /= d;
					c1dy /= d;
					*/
					var c2dx:Number = (corner2.x - px);
					var c2dy:Number = (corner2.y - py);
					/*d = Math.sqrt(c2dx * c2dx + c2dy * c2dy);
					c2dx /= d;
					c2dy /= d;					
					*/
					var corner3:FlxPoint = new FlxPoint(c1dx * 30 + corner1.x, c1dy * 30 + corner1.y);
					var corner4:FlxPoint = new FlxPoint(c2dx * 30 + corner2.x, c2dy * 30 + corner2.y);
					
					s.graphics.beginFill(0xff4d3781, 1);
					s.graphics.lineStyle(1, 0xff4d3781, 0);
					
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
			var screenPt:FlxPoint = getScreenXY(0, 0);
			var mtx:Matrix = new Matrix(1, 0, 0, 1, screenPt.x, screenPt.y);
			shadowMap.draw(s, mtx);
		}			
		
		public function addJumpParticle(x:int, y:int, double:Boolean) : void
		{
			if (double)
			{
				addParticle(x, y, doublejumpParticleImage, 8, 2, 0.2);
			}
			else
			{
				addParticle(x, y, jumpParticleImage, 8, 2, 0.2);
			}
		}
		
		public function addTreeParticle(x:int, y:int) : void
		{
			var p:Particle = addParticle(x, y, treeParticleImage, 1, 4, 0.5);
			p.velocity.x = Math.random() * 50 - 25;
			p.velocity.y = Math.random() * 50 - 25;
			p.drag.x = 30;
			p.drag.y = 30;
			p.alpha = 0.5;
		}
		
		public function addLightParticle(x:int, y:int) : void
		{
			var p:Particle = addParticle(x, y, lightParticleImage, 1, 3, 0.75);
			p.velocity.x = Math.random() * 30 - 15;
			p.velocity.y = Math.random() * 30 - 15;
		}		
		
		public function restart() : void
		{
			FlxG.timeScale = 1.0;
			FlxG.state = new GameState();
		}
		
		private function getScreenXY(x:int, y:int):FlxPoint
		{
			var Point:FlxPoint = new FlxPoint();
			Point.x = FlxU.floor(x + FlxU.roundingError)+FlxU.floor(FlxG.scroll.x);
			Point.y = FlxU.floor(y + FlxU.roundingError)+FlxU.floor(FlxG.scroll.y);
			return Point;
		}
		
		private function getCorners(tx:int, ty:int): Array 
		{
			var tl:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx, map.y + map._tileHeight * ty);
			var tr:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx + map._tileWidth, map.y + map._tileHeight * ty);
			var bl:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx, map.y + map._tileHeight * ty + map._tileHeight);
			var br:FlxPoint = new FlxPoint(map.x + map._tileWidth * tx + map._tileWidth, map.y + map._tileHeight * ty + map._tileHeight);
			return [tl, tr, bl, br];
		}			
		
		private function addParticle(x:int, y:int, graphic:Class, width:int, numFrames:int, lifetime:Number):Particle
		{
			var p:Particle = (Particle)(particles.getFirstAvail());
			if (p == null)
			{
				p = (Particle)(particles.getRandom());
			}
			p.spawn(x, y, graphic, width, numFrames, lifetime);
			return p;
		}		
		
		public function renumberEntities() : void 
		{
			
			var tilemap:BitmapData = FlxG.addBitmap(tilesImage);
			totaltiles = tilemap.width / 8;
			FlxG.log(totaltiles);
		
		}
		
		// Goes through the tilemap and replaces special entity values with the actual entity object.
		public function replaceEntityTiles() : void
		{
			filledTiles = new Array();
			for (var i:int = 0; i < map.totalTiles; i++)
			{
				if (map.getTileByIndex(i) != 0) { filledTiles.push(i) };

				if (map.getTileByIndex(i) >= totaltiles)
				{
					
					var x:int = i % map.widthInTiles;
					var y:int = i / map.widthInTiles;
					var c:Class = getDefinitionByName(getQualifiedClassName(mapEntities[map.getTileByIndex(i) - totaltiles])) as Class;
					var o:FlxObject = (new c(x * 8, y * 8) as FlxObject);
					o.fixed = true;
					entities.add(o);
					map.setTileByIndex(i, 0);
				}
					
				
			}
		}
		
		private function generateEmptyMap() : String
		{
			var lvl:String = "";
			for (var i:int = 0; i < 60; i++)
			{
				lvl += "1,";
			}			
			lvl += "1\n";
			for (var j:int = 0; j < 81; j++)
			{
				lvl += "1,";
				for (i = 0; i < 59; i++)
				{
					lvl += "0,"
				}
				lvl += "1\n";
			}
			for (i = 0; i < 60; i++)
			{
				lvl += "1,";
			}			
			lvl += "1";
			return lvl;
		}

	}
}
