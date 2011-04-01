package  
{
	import flash.display.BitmapData;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author morgan
	 */
	public class EditMode extends FlxObject
	{
		[Embed (source = "../data/editor_cursor.png")] private var cursorImage:Class;		
		[Embed (source = "../data/editor_tileSelector.png")] private var selectorImage:Class;		
		[Embed (source = "../data/tiles.png")] private var tilesImage:Class;
		public var enabled:Boolean;
		public var selector:FlxSprite;
		public var paintTile:uint;
		public var tileSprite:FlxSprite;
		
		public function EditMode() 
		{
			selector = new FlxSprite(0, 0, selectorImage);
			selector.visible = false;			
			tileSprite = new FlxSprite(0, 0);
			tileSprite.loadGraphic(tilesImage, true, false, 8, 8);
			tileSprite.alpha = 1;
			tileSprite.visible = false;
			enabled = false;
			paintTile = 1;
		}
		
		public function initialize() : void
		{
			(FlxG.state as GameState).add(tileSprite);			
			(FlxG.state as GameState).add(selector);
		}
		
		public function toggle() : void
		{
			enabled = !enabled;
			selector.visible = enabled;
			tileSprite.visible = enabled;
			if (enabled)
			{
				FlxG.mouse.show(cursorImage);
			}
			else
			{
				FlxG.mouse.hide();
			}
		}
	
		public override function update() : void
		{
			selector.x = Math.floor(FlxG.mouse.x / 8) * 8
			selector.y = Math.floor(FlxG.mouse.y / 8) * 8
			tileSprite.x = selector.x;
			tileSprite.y = selector.y;
			tileSprite.frame = paintTile;
			if (FlxG.mouse.pressed())
			{
				(FlxG.state as GameState).map.setTile(selector.x / 8, selector.y / 8, paintTile);
			}
			if (FlxG.keys.justPressed("COMMA"))
			{
				paintTile = Math.max(paintTile - 1, 0);
			}
			if (FlxG.keys.justPressed("PERIOD"))
			{
				paintTile++;
			}
			if (FlxG.keys.justPressed("S"))
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
				trace(allData);
			}
		}
		
	}

}