package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	public class Lantern extends FlxSprite
	{
		[Embed (source = "../data/lantern.png")] private var lanternImage:Class;
		
		public var lightEmission:FlxSprite;
		public var particleTimer:Number = 0;
		public function Lantern(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(lanternImage, true, false, 8, 8);
			addAnimation("default", [0, 1], 5, true);
			play("default");
			width = 2;
			height = 4;
			offset.x = 3;
			offset.y = 4;
			lightEmission = null;
			acceleration.y = 50;
			
		}
		
		override public function update():void 
		{
			particleTimer += FlxG.elapsed;
			if (particleTimer > 0.1)
			{
				(FlxG.state as GameState).addLightParticle(x + 1, y + 2);
				particleTimer = 0;
			}
			velocity.x *= 0.99;
			if (lightEmission != null)
			{
				lightEmission.x = x - lightEmission.width / 2 + 2;
				lightEmission.y = y - lightEmission.height / 2 + 2;
			}
			super.update();
		}
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void 
		{
			if (velocity.y > 15)
			{
				velocity.y = -velocity.y * 0.5;
			}
			else
			{
				super.hitBottom(Contact, Velocity);
			}
			velocity.x *= 0.95;
			
		}
		
		override public function hitLeft(Contact:FlxObject, Velocity:Number):void 
		{
			velocity.x = -velocity.x * 0.5;
		}
		
		override public function hitRight(Contact:FlxObject, Velocity:Number):void 
		{
			velocity.x = -velocity.x * 0.5;
		}
		
	}

}