package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author morgan
	 */
	 
	public class GameState extends FlxState
	{
		[Embed (source = "../data/tiles.png")] private var tilesImg:Class;	
		
		public function GameState() 
		{
			bgColor = 0xffffffff;
			var testTree:Tree = new Tree(50, 102);
			add(testTree);
			
			FlxG.mouse.show();
			
			testTree.growTarget = FlxG.mouse.cursor;
		}
		
		override public function update():void 
		{
			super.update();
		}
		
	}

}