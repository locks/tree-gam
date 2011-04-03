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
		[Embed (source = "../data/warning.png")] private var warningImage:Class;
		
		private const trunkColorDark:uint = 0xff0e4a2a;
		private const trunkColorMid:uint = 0xff217a15;
		private const trunkColorLight:uint = 0xff75bf34;
		
		private const maxSize:Number = 200;
		private const maxTrunkSize:Number = 4;
		private const growRate:Number = 12;
		private const growAngleChangeRate:Number = Math.PI;
		private const warningTime:Number = 0.5; // Seconds from impact at which it warns the player
		
		private var growTrunkWidth:Number = 0;
		private var growAngle:Number = Math.PI; // Up
		private var growTrunkSegment:Shape;
		private var lightSegment:Shape;
		private var growPosition:Point = new Point(0, 0);
		private var growVect:Point = new Point(0, 0);
		private var currentSize:Number = 0;
		
		private var branches:Array;
		private var branchTimer:Number = 0;
		
		public var growTarget:FlxObject;
		
		public var dying:Boolean = false;
		public var crumbleStack:Array = new Array();
		
		public var warningSprite:FlxSprite;
		public var hueRotate:Number = 0;
		
		public var allPoints:Array = new Array();
		public var framecount:int = 0;
		
		public function Tree(x:int, y:int) 
		{
			super(x, y);
			pixels = new BitmapData(300, 300, true, 0x00000000);
			offset.x = pixels.width / 2;
			offset.y = pixels.height;
			growTrunkSegment = new Shape();
			growPosition = new Point(pixels.width / 2, pixels.height);
			growTarget = null;
			branches = new Array();
			branchTimer = (2 + Math.random() * 4) / growRate;
			warningSprite = new FlxSprite(0, 0);
			warningSprite.loadGraphic(warningImage, true, false, 32, 32);
			warningSprite.addAnimation("default", [0, 1], 10, true);
			warningSprite.play("default");
			warningSprite.offset.x = warningSprite.width / 2;
			warningSprite.offset.y = warningSprite.height / 2;
			warningSprite.blend = "overlay";
			lightSegment = new Shape();
		}
		
		override public function update():void 
		{
			if (dying)
			{
				warningSprite.kill();
				crumble();
				(FlxG.state as GameState).ending = true;
			}			
			else
			{
				if (framecount % 2 == 0)
				{
					renderTree();
				}	
			}
			if (currentSize < maxSize && !dying)
			{			
				if (framecount % 2 == 0)
				{
					growTrunk();
					growBranches();
				}
			}

			framecount++;
			
			super.update();
		}
		
		private function renderTree() : void
		{
			
			lightSegment.graphics.clear();
			
			var i:int = 0;
			var lightOffsetX:Number = 0 ;
			var lightOffsetY:Number = 0;
			var d:Number = 0;
			var distScale:Number = 1.0;
			lightSegment.graphics.beginFill(trunkColorDark, 1);
			for each (var ptSize:Array in allPoints)
			{
				lightSegment.graphics.drawCircle(ptSize[0].x, ptSize[0].y, ptSize[1]);
			}
			lightSegment.graphics.endFill();
			lightSegment.graphics.beginFill(trunkColorMid, 1);
			for each (ptSize in allPoints)
			{
				i++;
				if (i % 10 == 0)
				{
					lightOffsetX = growTarget.x - (x + (ptSize[0].x - offset.x))
					lightOffsetY = growTarget.y - (y + (ptSize[0].y - offset.y))
					d = Math.sqrt(lightOffsetX * lightOffsetX + lightOffsetY * lightOffsetY);
					lightOffsetX *= 1 / d * ptSize[1] / 3;
					lightOffsetY *= 1 / d * ptSize[1] / 3;
					distScale = Math.max(Math.min(1, 20 / d),0.25);
				}
				if (ptSize[1] * 0.75 * distScale > 0 )
				{
					lightSegment.graphics.drawCircle(ptSize[0].x + lightOffsetX, ptSize[0].y + lightOffsetY, ptSize[1] * 0.75 * distScale);
				}
			}
			lightSegment.graphics.endFill();
			
			lightSegment.graphics.beginFill(trunkColorLight, 1);
			for each (ptSize in allPoints)
			{
				i++;
				if (i % 10 == 0)
				{
					lightOffsetX = growTarget.x - (x + (ptSize[0].x - offset.x))
					lightOffsetY = growTarget.y - (y + (ptSize[0].y - offset.y))
					d = Math.sqrt(lightOffsetX * lightOffsetX + lightOffsetY * lightOffsetY);
					lightOffsetX *= 1 / d * ptSize[1] / 1.5;
					lightOffsetY *= 1 / d * ptSize[1] / 1.5;
					distScale = Math.max(Math.min(2, 50 / d),0.5) - 1;
				}
				if (ptSize[1] * 0.25 * distScale > 0 && d < 50)
				{
					lightSegment.graphics.drawCircle(ptSize[0].x + lightOffsetX, ptSize[0].y + lightOffsetY, ptSize[1] * 0.25 * distScale);
				}
			}
			lightSegment.graphics.endFill();	
			
			pixels.draw(lightSegment);
			calcFrame();
			
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
			while (crumbled < 9 && crumbleStack.length > 0)
			{
				var pos:Point = crumbleStack.shift();
				//trace(pixels.getPixel32(pos.x, pos.y));
				if (pixels.getPixel32(pos.x, pos.y) != 0x00000000)
				{
					/*if (pixels.getPixel32(pos.x, pos.y) > 0x88000000)
					{
						pixels.setPixel32(pos.x, pos.y, 0x550e4a1d);
					}
					else
					{
					*/
						(FlxG.state as GameState).addTreeParticle((x + (pos.x - offset.x)), (y + (pos.y - offset.y)));
						pixels.setPixel32(pos.x, pos.y, 0x00000000);
					//}
					crumbled++;
					crumbleStack.push(new Point(pos.x + 1, pos.y));					
					crumbleStack.push(new Point(pos.x, pos.y + 1));					
					crumbleStack.push(new Point(pos.x - 1, pos.y));					
					crumbleStack.push(new Point(pos.x, pos.y - 1));					
					crumbleStack.push(new Point(pos.x + Math.floor(Math.random() * 6 - 3), pos.y + Math.floor(Math.random() * 6 - 3)));
					crumbleStack.push(new Point(pos.x + Math.floor(Math.random() * 6 - 3), pos.y + Math.floor(Math.random() * 6 - 3)));
				}
			}
			if (crumbleStack.length == 0)
			{
				kill();
				FlxG.fade.start(0xff000000, 0.75, (FlxG.state as GameState).restart, false);
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
			var inShadow:Boolean = shadow.getPixel32(((x + FlxG.scroll.x) + (growPosition.x - offset.x)), ((y + FlxG.scroll.y) + (growPosition.y - offset.y))) != 0xffffffff;
			
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
			growVect = new Point(growX, growY);
			var newPosition:Point = growPosition.add(new Point(growX, growY));
			var tilemap:FlxTilemap = (FlxG.state as GameState).map;
			var tileX:int = Math.floor((x + (newPosition.x - offset.x)) / tilemap._tileWidth);
			var tileY:int = Math.floor((y + (newPosition.y - offset.y)) / tilemap._tileHeight);				
			
			// Don't grow if we're hitting a tile
			if (!tilemap.getTile(tileX, tileY))
			{
				growPosition = newPosition
			}
			else
			{
				dying = true;
			}
			
			// Make warning signals if the tree is approaching a tile soon
			var warningTileX:int = Math.floor((x + (newPosition.x + (Math.sin(growAngle) * warningTime * growRate * (inShadow ? 0.75 : 1.5)) - offset.x)) / tilemap._tileWidth);	
			var warningTileY:int = Math.floor((y + (newPosition.y + (Math.cos(growAngle) * warningTime * growRate * (inShadow ? 0.75 : 1.5)) - offset.y)) / tilemap._tileHeight);	
			if (tilemap.getTile(warningTileX, warningTileY))
			{
				warningSprite.visible = true;
				warningSprite.x = x + growPosition.x - offset.x;
				warningSprite.y = y + growPosition.y - offset.y;
				warningSprite.scale.x = (growTrunkWidth / maxTrunkSize) / 2;
				warningSprite.scale.y = (growTrunkWidth / maxTrunkSize) / 2;
				
			}
			else
			{
				warningSprite.visible = false;
			}
			
			(FlxG.state as GameState).addTreeParticle((x + (growPosition.x - offset.x + growX)), (y + (growPosition.y - offset.y + growY)));
			
			// The tree path is recorded as a list of points.
			if (framecount % 8 == 0)
			{
				allPoints.push( [growPosition, growTrunkWidth] );
			}
		}
		
		private function growBranches():void
		{
			// New branches are born periodically
			branchTimer -= FlxG.elapsed;
			if (branchTimer < 0)
			{
				branchTimer = (2 + Math.random() * 2) / growRate;
				branches.push(new TreeBranch(growPosition.x, growPosition.y, Math.max(growTrunkWidth / 2,0.75), growAngle + Math.random() * 2 - 1, Math.random() * 4 - 2));
			}
			
			for each (var b:TreeBranch in branches)
			{
				b.update(pixels);
			}
		}
	}

}