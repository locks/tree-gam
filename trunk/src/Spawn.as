package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	public class Spawn extends FlxSprite
	{
		[Embed (source = "../data/spawn.png")] public var spawnImage:Class;
		
		public var spawned:Boolean = false;
		public function Spawn(x:int, y:int) 
		{
			super(x, y, spawnImage);
			img = spawnImage;
			visible = false;
			solid = false;
		}
		
		override public function update():void 
		{
			if (!spawned)
			{
				var gs:GameState = (FlxG.state as GameState);
				spawned = true;
				gs.player.x = x;
				gs.player.y = y;
				gs.player.holdObject = null;
				gs.lantern.x = x - 8;
				gs.lantern.y = y;
				gs.carryables.add ( new Seed(x + 8, y));
			}
			super.update();
		}
		
	}

}