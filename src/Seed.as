package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author ...
	 */
	public class Seed extends FlxSprite
	{
		[Embed (source = "../data/seed.png")] private var seedImage:Class;
		
		public const firstDirtTile:int = 10;
		public const lastDirtTile:int = 12;
		public function Seed(x:int, y:int) 
		{
			super(x, y, seedImage);
			width = 2;
			height = 4;
			offset.x = 3;
			offset.y = 4;
			acceleration.y = 50;
		}
		
		override public function update():void 
		{
			var gs:GameState = (FlxG.state as GameState);
			var underTile:uint = (FlxG.state as GameState).map.getTile(x / 8, y / 8 + 1);
			if ( underTile >= firstDirtTile && underTile <= lastDirtTile && gs.player.holdObject != this)
			{
				kill();
				var newTree:Tree = new Tree(x, int(y / 8 + 1) * 8 );
				newTree.growTarget = gs.lantern;
				gs.currentTree = newTree;
				gs.treeGroup.add(newTree);
				gs.add(newTree.warningSprite);
			}
			super.update();
		}
		
	}

}