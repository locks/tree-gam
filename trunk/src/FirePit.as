package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author ...
	 */
	public class FirePit extends FlxSprite
	{
		[Embed (source = "../data/firepit.png")] private var firepitImage:Class;
		public function FirePit(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(firepitImage, true, false, 8, 8);
			addAnimation("default", [0, 1], 4, true);
			play("default");
			
		}
		
		override public function update():void 
		{
			super.update();
		}
		
	}

}