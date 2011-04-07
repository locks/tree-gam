package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxTileblock;
	import org.flixel.FlxTilemap;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author morgan
	 */
	public class EditMode extends FlxObject
	{
		[Embed (source = "../data/editor_cursor.png")] private var cursorImage:Class;		
		[Embed (source = "../data/editor_tileSelector.png")] private var selectorImage:Class;		
		[Embed (source = "../data/editor_tileSelector_red.png")] private var selectorRedImage:Class;		
		[Embed (source = "../data/tiles.png")] private var tilesImage:Class;
		[Embed (source = "../data/tilebg.png")] private var tilebgImage:Class;
		public var enabled:Boolean;
		public var selector:FlxSprite;
		public var selectorRed:FlxSprite;
		public var paintTile:uint;
		public var tileSprite:FlxSprite;
		public var tiles:FlxTilemap;
		public var currTileIndex:int = 1;
		public var tilebg:FlxSprite;
		
		public function EditMode() 
		{
			selector = new FlxSprite(0, 0, selectorImage);
			selector.visible = false;			
			selectorRed = new FlxSprite(0, 0, selectorRedImage);
			selectorRed.visible = false;			
			tileSprite = new FlxSprite(0, 0);
			tilebg = new FlxSprite(0, 0);
			tilebg.loadGraphic(tilebgImage, false, false, 96, 24);
			tileSprite.loadGraphic(tilesImage, true, false, 8, 8);
			
			tileSprite.alpha = 0.8;
			tileSprite.visible = false;
			enabled = false;
			paintTile = 1;
			var s:String = "";
			for (var i:int = 0; i < 48; i++) {
				s += "" + i + ",";
				if (i % 12 == 11) s += "\n";
			}
			tilebg.visible = false;
			tiles = new FlxTilemap();
			tiles.loadMap(s, tilesImage, 8, 8);
			tiles.scrollFactor.x = 0;
			tiles.scrollFactor.y = 0;
			tilebg.scrollFactor.x = 0;
			tilebg.scrollFactor.y = 0;
			tiles.visible = false;
			selectorRed.scrollFactor.x = 0;
			selectorRed.scrollFactor.y = 0;
		}
		
		public function initialize() : void
		{
			(FlxG.state as GameState).add(tileSprite);			
			(FlxG.state as GameState).add(selector);
			
			(FlxG.state as GameState).add(tilebg);
			(FlxG.state as GameState).add(tiles);
			(FlxG.state as GameState).add(selectorRed);
			var b:BitmapData = new BitmapData(8 * ((FlxG.state as GameState).totaltiles + (FlxG.state as GameState).mapEntities.length), 8, true, 0xffff0000);
			var b2:BitmapData = FlxG.addBitmap(tilesImage);
			b.draw(b2);
			for (var i:int = 0; i < (FlxG.state as GameState).mapEntities.length; i++) {
				var c:Class = getDefinitionByName(getQualifiedClassName((FlxG.state as GameState).mapEntities[i])) as Class;
				var o:FlxSprite = (new c(0, 0) as FlxSprite);
				b.draw(o.pixels, new Matrix(1, 0, 0, 1, 8 * (FlxG.state as GameState).totaltiles + 8 * i, 0));
				//b.copyPixels(o.pixels, new Rectangle(0, 0, 8, 8), new Point(8 * (FlxG.state as GameState).totaltiles + 8 * i, 0));
			}
			tiles._pixels = b;
			(FlxG.state as GameState).map._pixels = b;
		}
		
		
		public function toggle() : void
		{
			enabled = !enabled;
			selector.visible = enabled;
			selectorRed.visible = enabled;
			tileSprite.visible = enabled;
			tiles.visible = enabled;
			tilebg.visible = enabled;
			if (enabled)
			{
				FlxG.mouse.show(cursorImage);
				(FlxG.state as GameState).map.loadMap((FlxG.state as GameState).currentMapString, tilesImage, 8, 8);
				initialize();
				(FlxG.state as GameState).entities.members = new Array();
				
			}
			else
			{
				
				FlxG.mouse.hide();
				(FlxG.state as GameState).currentMapString = getMapString();
				(FlxG.state as GameState).replaceEntityTiles();
			}
		}
	
		public override function update() : void
		{
			if (enabled) {
				selector.x = Math.floor(FlxG.mouse.x / 8) * 8
				selector.y = Math.floor(FlxG.mouse.y / 8) * 8
				tileSprite.x = selector.x;
				tileSprite.y = selector.y;
				tileSprite.frame = paintTile;
				if (FlxG.mouse.pressed())
				{
					var sx:Number = FlxG.mouse.cursor.getScreenXY().x;
					var sy:Number = FlxG.mouse.cursor.getScreenXY().y;
					if (sy > 24) {
						(FlxG.state as GameState).map.setTile(selector.x / 8, selector.y / 8, paintTile);
					} else {
						selectorRed.x = int(sx / 8) * 8;
						selectorRed.y = int(sy / 8) * 8;
						FlxG.log(selectorRed.y);
						paintTile = currTileIndex * (selectorRed.x / 8 + 12 * ((selectorRed.y / 8)));
					}
				}
				if (FlxG.keys.justPressed("PERIOD"))
				{
					for (var i:int = 0; i < 48; i++) {
						tiles.setTileByIndex(i, tiles.getTileByIndex(i) + 48, true);
						currTileIndex++;
					}
				}
				if (FlxG.keys.justPressed("COMMA"))
				{
					for (i = 0; i < 48; i++) {
						tiles.setTileByIndex(i, tiles.getTileByIndex(i) - 48, true);
						currTileIndex--;
					}
				}
				if (FlxG.keys.justPressed("S"))
				{
					//trace(getMapString());
					var f:FileReference = new FileReference();
					f.save(getMapString());
				}
			}
		}
		
		public function getMapString() : String
		{
			var data:Array = (FlxG.state as GameState).map._data;
			var allData:String = "";
			var cols:int = (FlxG.state as GameState).map.widthInTiles;
			for (var i:int = 0; i < data.length / cols; i++)
			{
				for (var j:int = 0; j < cols; j++)
				{
					if (j < cols-1)
					{
						allData += data[i * cols + j] + ",";
					}
					else
					{
						allData += data[i * cols + j];
					}
				}
				if ( i < data.length / cols - 1 )
				{
					allData += "\n";
				}
			}
			return allData;
		}
		
	}

}