package  
{
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import SfxrSynth;
	import SfxrParams;	
	/**
	 * ...
	 * @author Thomas Liu
	 */
	public class Player extends FlxSprite
	{
		[Embed (source = "../data/player.png")] private var playerImage:Class;
		
		public const jumpForce:Number = 75;
		public const doubleJumpForce:Number = 65;
		public const holdJumpAccel:Number = 40;
		public const walkSpeed:Number = 50;
		
		public var timeInAir:Number = 0;
		public var holdObject:FlxObject;
		public var doubleJumped:Boolean;
		
		public var stepSynth:SfxrSynth = new SfxrSynth();
		public var jumpSynth:SfxrSynth = new SfxrSynth();
		public var doubleJumpSynth:SfxrSynth = new SfxrSynth();
		public var landSynth:SfxrSynth = new SfxrSynth();
		public var takeSynth:SfxrSynth = new SfxrSynth();
		public var throwSynth:SfxrSynth = new SfxrSynth();
		public var dropSynth:SfxrSynth = new SfxrSynth();
		
		private var footstepTimer:Number = 0;
		
		public function Player(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(playerImage, true, true, 8, 8);
			addAnimation("idle", [0], 0, true);
			addAnimation("run", [1, 2, 3, 4], 10, true);
			addAnimation("jump", [6, 5], 2, false);
			
			acceleration.y = 150;
			maxVelocity.y = 85;
			offset.x = 1;
			offset.y = 0;
			width = 6;
			height = 8;
			holdObject = null;
			doubleJumped = false;
			stepSynth.params.setSettingsString("2,,0.1,,0.18,0.34,,-0.52,,,,,,,,,-0.72,,1,,,0.19,,0.45");
			jumpSynth.params.setSettingsString("3,,0.091,,0.11,0.21,,-0.4,,,,,,,,,-0.28,,1,,,0.19,,0.33");
			doubleJumpSynth.params.setSettingsString("3,,0.091,,0.11,0.31,,-0.4,,,,,,,,,-0.28,,1,,,0.19,,0.33");
			landSynth.params.setSettingsString("2,,0.24,,0.27,0.3,,-0.4,,,,,,,,,-0.72,,1,,,0.19,,0.55");
			takeSynth.params.setSettingsString("3,,0.091,,0.14,0.38,,0.9199,,,,,,,,,0.1,,1,,,0.19,,0.33");
			throwSynth.params.setSettingsString("1,0.04,0.12,,0.5,0.31,,-0.18,-0.02,,,0.56,0.7,0.61,,,0.3,,0.39,-0.3199,,0.19,,0.33");
			dropSynth.params.setSettingsString("1,0.04,0.12,,0.25,0.36,,-0.28,-0.02,,,0.56,0.71,0.61,,,0.3,,0.39,-0.3199,,0.19,,0.31");
		}
		
		override public function update():void 
		{			
			if ((FlxG.state as GameState).ending)
			{
				velocity.x = 0;
			}
			else
			{
				updatePlayerInput();
			}
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
					footstepTimer += FlxG.elapsed;
					if (footstepTimer > 0.19)
					{
						footstepTimer = 0;
						stepSynth.playMutated(0.1, 8);
					}
				}
				else
				{
					play("idle");
				}				
			}
			else if (timeInAir > 0.1)
			{				
				play("jump");
			}
		}
		
		private function updatePlayerInput():void
		{
			velocity.x = 0;
			
			if (!onFloor)
			{
				timeInAir += FlxG.elapsed;
			}
			else
			{
				timeInAir = 0;
			}
			
			// First jump (on the floor)
			if ( (FlxG.keys.justPressed("UP") || FlxG.keys.justPressed("X")) && onFloor) {
				velocity.y = -jumpForce;
				(FlxG.state as GameState).addJumpParticle(x - 1, y, false);
				jumpSynth.play();
			}
			
			if ( (FlxG.keys.UP || FlxG.keys.X) && !onFloor)
			{
				velocity.y -= holdJumpAccel * FlxG.elapsed;
			}
			
			// Double jump (if you're not holding the lantern)
			if ( (FlxG.keys.justPressed("UP") || FlxG.keys.justPressed("X")) && (!doubleJumped && holdObject == null) && !onFloor && velocity.y > -20) {
				velocity.y = -doubleJumpForce;
				doubleJumped = true;
				(FlxG.state as GameState).addJumpParticle(x - 1, y, true);
				doubleJumpSynth.play();
			}
			if (onFloor) // Reset double jump
			{
				doubleJumped = false;
			}
			
			// Horizontal movement
			if (FlxG.keys.RIGHT) {
				velocity.x = walkSpeed;
				facing = RIGHT
			}
			else if (FlxG.keys.LEFT) {
				velocity.x = -walkSpeed;
				facing = LEFT;
			}
			
			// Drop/pick up lantern if you press down
			if ( (FlxG.keys.justPressed("DOWN") || FlxG.keys.justPressed("C")) )
			{
				if (holdObject != null)
				{
					if (velocity.x == 0 && velocity.y == 0)
					{
						holdObject.velocity.x = 0;
						holdObject.velocity.y = 10;
						dropSynth.play();
					}
					else
					{
						holdObject.velocity.x = velocity.x * 1.3;
						holdObject.velocity.y = velocity.y * 0.8 - 20;
						throwSynth.play();
					}
					holdObject = null;
				}
				else // If you're within 8 pixel radius of a grabbable you can grab it
				{
					var l:Array = (FlxG.state as GameState).carryables.members;
					for (var i:int = 0; i < l.length; i++ )
					{
						var o:FlxObject = l[i];
						var dx:Number = o.x - (x + 3);
						var dy:Number = o.y - (y + 4);
						if ((dx * dx + dy * dy) < 64)
						{
							holdObject = o;
							takeSynth.play();
							break;
						}
					}
				}
			}
			
		}
		
		override public function hitBottom(Contact:FlxObject, Velocity:Number):void 
		{
			if (velocity.y > jumpForce / 2)
			{
				landSynth.play();
			}
			super.hitBottom(Contact, Velocity);
		}
	}

}