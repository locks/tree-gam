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
			addAnimation("run", [1, 2, 3, 4], 15, true);
			addAnimation("jump", [6,5], 2, false);
			acceleration.y = 150;
			maxVelocity.y = 80;
			offset.x = 1;
			offset.y = 0;
			width = 6;
			height = 8;
		}
		
		override public function update():void 
		{			
			updatePlayerInput();
			updatePlayerAnim();
			super.update();
		}
		
		private function updatePlayerAnim():void
		{
			if (onFloor)
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
			else
			{
				play("jump");
			}
		}
		
		private function updatePlayerInput():void
		{
			velocity.x = 0;
			if (FlxG.keys.justPressed("UP") && onFloor) {
				velocity.y = -60;
				(FlxG.state as GameState).addJumpParticle(x-1, y);
			}
			if (FlxG.keys.RIGHT) {
				velocity.x = 50;
				facing = RIGHT
			}
			else if (FlxG.keys.LEFT) {
				velocity.x = -50;
				facing = LEFT;
			}
		}
	}

}