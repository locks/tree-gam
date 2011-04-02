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
		private var growAngle:Number = Math.PI; // Up
		private var growTrunkSegment:Shape;
		private var growPosition:Point = new Point(0,0);
		private var currentSize:Number = 0;
		
		private var branches:Array;
		private var branchTimer:Number = 0;
		
		public var growTarget:FlxObject;
		
		public var dying:Boolean = false;
		public var crumbleStack:Array = new Array();
		
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
			if (dying)
			{
				crumble();
			}			
			else if (currentSize < maxSize)
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
		
		private function crumble():void
		{
			var crumbled:int = 0;
			crumbleStack.push(growPosition);
			while (crumbled < 6 && crumbleStack.length > 0)
			{
				var pos:Point = crumbleStack.shift();
				//trace(pixels.getPixel32(pos.x, pos.y));
				if (pixels.getPixel32(pos.x, pos.y) != 0x00000000)
				{
					(FlxG.state as GameState).addTreeParticle((x + (pos.x - offset.x)), (y + (pos.y - offset.y)));
					if (pixels.getPixel32(pos.x, pos.y) > 0x55000000)
					{
						pixels.setPixel32(pos.x, pos.y, 0x55000000);
					}
					else
					{
						pixels.setPixel32(pos.x, pos.y, 0x00000000);
					}
					crumbled++;
					crumbleStack.push(new Point(pos.x + 1, pos.y));					
					crumbleStack.push(new Point(pos.x, pos.y + 1));					
					crumbleStack.push(new Point(pos.x - 1, pos.y));					
					crumbleStack.push(new Point(pos.x, pos.y - 1));					
					crumbleStack.push(new Point(pos.x + Math.floor(Math.random() * 6 - 3), pos.y + Math.floor(Math.random() * 6 - 3)));
					crumbleStack.push(new Point(pos.x + Math.floor(Math.random() * 6 - 3), pos.y + Math.floor(Math.random() * 6 - 3)));
				}
			}
			calcFrame();
		}
		
		private function growTrunk():void
		{
			// Figure out the new trunk size (it gets smaller as it goes up)
			growTrunkWidth = maxTrunkSize * (1 - (currentSize / maxSize)) + 0.25; // height = 0 : trunk = max, height = top : trunk = 1;
			
			currentSize += growRate * FlxG.elapsed;
			
			// Find out if the growth position is in shadow
			var shadow:BitmapData = (FlxG.state as GameState).shadowMap;
			var inShadow:Boolean = shadow.getPixel32(((x + FlxG.scroll.x) + (growPosition.x - offset.x)), ((y - FlxG.scroll.y) + (growPosition.y - offset.y))) != 0xffffffff;
			
			if (growTarget != null)
			{
				// Figure out the direction to the target and update the angle
				var toTargetX:Number = growTarget.x - (x + (growPosition.x - offset.x));
				var toTargetY:Number = growTarget.y - (y + (growPosition.y - offset.y));
				var toTargetAngle:Number = Math.atan2(toTargetX, toTargetY);
				var angleDiff:Number = angleDifference(toTargetAngle, growAngle);
				if (angleDiff < 0)
				{
					growAngle += growAngleChangeRate * FlxG.elapsed * (inShadow ? 0.5 : 1.5);
				}
				else
				{
					growAngle -= growAngleChangeRate * FlxG.elapsed * (inShadow ? 0.5 : 1.5);
				}
				
			}
			
			// Offset by the vector it's growing in
			var growX:Number = Math.sin(growAngle) * FlxG.elapsed * growRate * (inShadow ? 0.5 : 1.5);
			var growY:Number = Math.cos(growAngle) * FlxG.elapsed * growRate * (inShadow ? 0.5 : 1.5);
			var newPosition:Point = growPosition.add(new Point(growX, growY));
			var tilemap:FlxTilemap = (FlxG.state as GameState).map;
			var tileX:int = Math.floor((x + (newPosition.x - offset.x)) / tilemap._tileWidth);
			var tileY:int = Math.floor((y + (newPosition.y - offset.y)) / tilemap._tileHeight);				
			// Don't grow if we're hitting a tile
			if (!tilemap.getTile(tileX, tileY))
			{
				// Destroy!
				//
				growPosition = newPosition
			}
			else
			{
				dying = true;
			}
			
			(FlxG.state as GameState).addTreeParticle((x + (growPosition.x - offset.x + growX)), (y + (growPosition.y - offset.y + growY)));
			

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