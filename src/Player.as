package  
{
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Thomas Liu
	 */
	public class Player extends FlxSprite
	{
		[Embed (source = "../data/player.png")] private var playerImage:Class;
		
		public var holdObject:FlxObject;
		public var doubleJumped:Boolean;
		
		public function Player(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(playerImage, true, true, 8, 8);
			addAnimation("idle", [0], 0, true);
			addAnimation("run", [1, 2, 3, 4], 10, true);
			addAnimation("jump", [6,5], 2, false);
			acceleration.y = 150;
			maxVelocity.y = 80;
			offset.x = 1;
			offset.y = 0;
			width = 6;
			height = 8;
			holdObject = null;
			doubleJumped = false;
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
				(FlxG.state as GameState).addJumpParticle(x-1, y, false);
			}
			if (FlxG.keys.justPressed("UP") && (!doubleJumped && holdObject == null) && !onFloor && velocity.y > -20) {
				velocity.y = -80;
				doubleJumped = true;
				(FlxG.state as GameState).addJumpParticle(x-1, y, true);
			}
			if (onFloor)
			{
				doubleJumped = false;
			}
			
			
			if (FlxG.keys.RIGHT) {
				velocity.x = 50;
				facing = RIGHT
			}
			else if (FlxG.keys.LEFT) {
				velocity.x = -50;
				facing = LEFT;
			}
			
			// Drop lantern
			if (FlxG.keys.justPressed("DOWN"))
			{
				if (holdObject != null)
				{
					holdObject.velocity.x = velocity.x;
					holdObject.velocity.y = velocity.y;
					holdObject = null;
				}
				else 
				{
					var dx:Number = (FlxG.state as GameState).lantern.x - (x + 3);
					var dy:Number = (FlxG.state as GameState).lantern.y - (y + 4);
					if ((dx * dx + dy * dy) < 64)
					{
						holdObject = (FlxG.state as GameState).lantern;
					}
				}
			}
			
		}
	}

}