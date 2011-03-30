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
			loadGraphic(playerImage, true, true, 8, 8);
			addAnimation("idle", [0], 0, true);
			addAnimation("run", [1, 2, 3, 4], 10, true);
			addAnimation("jump", [6,5], 2, false);
			acceleration.y = 150;
			maxVelocity.y = 80;
		}
		
		override public function update():void 
		{
			
			velocity.x = 0;
			//velocity.y = 0;
			if (FlxG.keys.justPressed("UP")) {
				velocity.y = -60;
			} if (FlxG.keys.RIGHT) {
				velocity.x = 50;
				facing = RIGHT
			} else if (FlxG.keys.LEFT) {
				velocity.x = -50;
				facing = LEFT;
			}
			if (!onFloor)
			{
				play("jump");
			}
			else
			{
				if (velocity.x != 0)
				{
					play("run");
				}
				else
				{
					play("idle");
				}
			}
			
			
			if (FlxG.keys.justReleased("C")) {
				(FlxG.state as GameState).poot();
			}
			
			super.update();
		}
	}

}