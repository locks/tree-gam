package  
{
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author ...
	 */
	public class Lantern extends FlxSprite
	{
		[Embed (source = "../data/lantern.png")] private var lanternImage:Class;
		public function Lantern(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(lanternImage, true, false, 8, 8);
			addAnimation("default", [0, 1], 8, true);
			play("default");
		}
		
	}

}