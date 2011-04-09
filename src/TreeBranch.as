package  
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import org.flixel.*;
	/**
	 * ...
	 * @author morgan
	 */
	public class TreeBranch 
	{
		private const branchColor:uint = 0xff0e4a2a;		
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var angle:Number;
		public var angularVelocity:Number;
		public var branchSegment:Shape;
		public var growRate:Number;
		public function TreeBranch(x:Number,y:Number,width:Number,angle:Number,angularVelocity:Number) 
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.angle = angle;
			this.angularVelocity = angularVelocity;
			this.growRate = Math.random() * 6 + 2;
			branchSegment = new Shape();
		}
		
		public function update(pixels:BitmapData) : void
		{
			// Hacky update function ):
			if (width > 0.3)
			{
				width *= 0.985;
			}
			else
			{
				return;
			}
			angle += angularVelocity * FlxG.elapsed;
			var growX:Number = Math.sin(angle) * FlxG.elapsed * growRate;
			var growY:Number = Math.cos(angle) * FlxG.elapsed * growRate;
			x += growX;
			y += growY;
			
			branchSegment.graphics.clear();
			branchSegment.graphics.beginFill( branchColor );
			branchSegment.graphics.drawCircle( x, y, width );
			branchSegment.graphics.endFill();
			
			// Draw this new segment on the tree graphic
			pixels.draw(branchSegment, null, null, null, null, false);			
		}
		
	}

}