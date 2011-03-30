package  
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	/**
	 * ...
	 * @author morgan
	 */
	public class Tree extends FlxSprite
	{
		private const trunkColor:uint = 0xff000000;
		private const maxSize:Number = 200;
		private const maxTrunkSize:Number = 4;
		private const growRate:Number = 4;
		private const growAngleChangeRate:Number = Math.PI / 4;
		
		private var growTrunkWidth:Number = 0;
		private var growAngle:Number = Math.PI / 2; // Up
		private var growTrunkSegment:Shape;
		private var growPosition:Point = new Point(0,0);
		private var currentSize:Number = 0;
		
		private var branches:Array;
		private var branchTimer:Number = 0;
		
		public var growTarget:FlxObject;
		
		public function Tree(x:int, y:int) 
		{
			super(x, y);
			pixels = new BitmapData(300, 300, true, 0x00ffffff);
			offset.x = pixels.width / 2;
			offset.y = pixels.height;
			growTrunkSegment = new Shape();
			growPosition = new Point(pixels.width / 2, pixels.height);
			growTarget = null;
			branches = new Array();
			branchTimer = (2 + Math.random() * 4) / growRate;
		}
		
		override public function update():void 
		{
			if (currentSize < maxSize)
			{
				growTrunk();
				growBranches();
			}
			
			super.update();
		}
		
		// Gets the difference between two angles and makes sure it's always between -pi and pi
		private function angleDifference(a:Number, b:Number):Number
		{
			var diff:Number = b - a;
			while (diff < -Math.PI) { diff += Math.PI * 2; }
			while (diff > Math.PI) { diff -= Math.PI * 2; }
			return diff;
		}
		
		private function growTrunk():void
		{
			// Figure out the new trunk size (it gets smaller as it goes up)
			growTrunkWidth = maxTrunkSize * (1 - (currentSize / maxSize)) + 0.25; // height = 0 : trunk = max, height = top : trunk = 1;
			
			currentSize += growRate * FlxG.elapsed;
			
			// Figure out the direction to the target and update the angle
			if (growTarget != null)
			{
				var toTargetX:Number = growTarget.x - (x + (growPosition.x - offset.x));
				var toTargetY:Number = growTarget.y - (y + (growPosition.y - offset.y));
				var toTargetAngle:Number = Math.atan2(toTargetX, toTargetY);
				var angleDiff:Number = angleDifference(toTargetAngle, growAngle);
				if (angleDiff < 0)
				{
					growAngle += growAngleChangeRate * FlxG.elapsed;
				}
				else
				{
					growAngle -= growAngleChangeRate * FlxG.elapsed;
				}
				
			}
			
			// Offset by the vector it's growing in
			var growX:Number = Math.sin(growAngle) * FlxG.elapsed * growRate;
			var growY:Number = Math.cos(growAngle) * FlxG.elapsed * growRate;
			growPosition = growPosition.add(new Point(growX, growY));			
			
			// Update the trunk circle
			growTrunkSegment.graphics.clear();
			growTrunkSegment.graphics.beginFill( trunkColor );
			growTrunkSegment.graphics.drawCircle( growPosition.x, growPosition.y, growTrunkWidth );
			growTrunkSegment.graphics.endFill();
			
			// Draw this new segment on the tree graphic
			pixels.draw(growTrunkSegment, null, null, null, null, false);				
			
			calcFrame();
		}
		
		private function growBranches():void
		{
			// New branches are born periodically
			branchTimer -= FlxG.elapsed;
			if (branchTimer < 0)
			{
				branchTimer = (2 + Math.random() * 3) / growRate;
				branches.push(new TreeBranch(growPosition.x, growPosition.y, Math.max(growTrunkWidth / 2,0.75), growAngle + Math.random() * 2 - 1, Math.random() * 4 - 2));
			}
			
			for each (var b:TreeBranch in branches)
			{
				b.update(pixels);
			}
		}
	}

}