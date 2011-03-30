package  
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Thomas Liu
	 */
	public class Player extends FlxSprite
	{
		[Embed (source = "../data/player.png")] private var playerImage:Class;
		public function Player(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(playerImage, false, false, 8, 8);
		}
		
		override public function update():void 
		{
			super.update();
			velocity.x = 0;
			velocity.y = 0;
			if (FlxG.keys.UP) {
				velocity.y = -50;
			} else if (FlxG.keys.DOWN) {
				velocity.y = 50;
			} else if (FlxG.keys.RIGHT) {
				velocity.x = 50;
			} else if (FlxG.keys.LEFT) {
				velocity.x = -50;
			}
			if (FlxG.keys.justReleased("C")) {
				(FlxG.state as GameState).poot();
			}
		}
	}

}