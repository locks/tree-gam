package  
{
	import org.flixel.*;
	/**
	 * ...
	 * @author morgan
	 */
	public class Particle extends FlxSprite
	{
		public var age:Number;
		public var lifetime:Number;
		public function Particle() 
		{
			super(0, 0, null);
			exists = false;
		}
		
		public function spawn(x:int, y:int, graphic:Class, width:int, numFrames:int, lifetime:Number) : void
		{
			loadGraphic(graphic, true, false, width, width);
			var frames:Array = new Array();
			for (var i:int = 0; i < numFrames; i++)
			{
				frames.push(i);
			}
			frames.push(i);
			addAnimation("default", frames, numFrames / lifetime, true);
			this.x = x;
			this.y = y;
			this.age = 0;
			this.lifetime = lifetime;
			this.exists = true;
			play("default", true);
		}
		
		override public function update():void 
		{
			age += FlxG.elapsed;
			if (age >= lifetime) { kill(); }
			super.update();
		}
		
	}

}