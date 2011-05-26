package com.apexinnovations.transwarp.ui.tooltip {
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	import flash.errors.IllegalOperationError;
	
	import mx.managers.IToolTipManager2;
	import mx.managers.ToolTipManagerImpl;
	import mx.resources.ResourceManager;
	import mx.resources.IResourceManager;
	import mx.styles.IStyleClient;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import spark.primitives.Rect;
	import mx.resources.IResourceBundle;
	import mx.core.UIComponent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class TranswarpTooltipManager extends ToolTipManagerImpl implements IToolTipManager2 {
		
		private static var _instance:TranswarpTooltipManager;
		public static function getInstance():IToolTipManager2 {
			if(!_instance)
				_instance = new TranswarpTooltipManager();
			return _instance;
		}
		
		public function TranswarpTooltipManager() {
			super();
			if(_instance)
				throw new IllegalOperationError("TranswarpTooltipManager is a singleton: use TranswarpTooltipManager.getInstance() to get an instance.");
			
			toolTipClass = TranswarpTooltip;	
		}
		
		override mx_internal function initializeTip():void {
			assignResources();				
		}
		
		protected function assignResources():void {
			var manager:IResourceManager = ResourceManager.getInstance();
			var text:String = manager.getString("Tooltips", currentText);
			currentToolTip.text = text? text : currentText;
		}
		
		override mx_internal function positionTip():void {
			
			var placement:String = "topRight";
			var padX:Number = -10;
			var padY:Number = 0;
			
			if(currentTarget is IStyleClient) {
				var client:IStyleClient = IStyleClient(currentTarget);
				placement = getStyleWithDefault(client,"toolTipPlacement", placement);
				padX = getStyleWithDefault(client,"toolTipPaddingX", padX);
				padY = getStyleWithDefault(client,"toolTipPaddingY", padY);
			}		
			
			IStyleClient(currentToolTip).setStyle("toolTipPlacement", placement);
			sizeTip(currentToolTip);
			
			var screen:Rectangle = currentToolTip.screen;
			var target:Rectangle = getGlobalBounds(currentTarget, currentToolTip.parent); // currentToolTip.parent may need to be .root instead
			
			var p:Point = calculatePlacement(placement, target, padX, padY);
			
			var leftRight:int = 2;
			var topBottom:int = 2;
						
			// Don't look too hard at what follows.  It's ugly and incomplete.  
			
			// Attempt to move tooltips if they don't fit on the screen.
			//		tooltips on the corners can only move to the other corners, and
			//		tooltis on the sides can only move to the other side.
			
			var hOverflow:Number = p.x + currentToolTip.width - screen.width;
			var hUnderflow:Number = -1 * p.x;
				
			var vOverflow:Number = p.y + currentToolTip.height - screen.height;
			var vUnderflow:Number = -1 * p.y;
			
			
			if(hOverflow > 0 && (placement == "topRight" || placement == "bottomRight" || placement == "right")
				&& hUnderflow + target.width + currentToolTip.width <= 0)
				leftRight = -1;
			else if(hUnderflow > 0 && (placement == "topLeft" || placement == "bottomLeft" || placement == "left")
				&& hOverflow + target.width + currentToolTip.width <= 0)
				leftRight = 1;
			
			if(vOverflow > 0 && (placement == "bottomRight" || placement == "bottomLeft" || placement == "bottom")
				&& vUnderflow + target.height + currentToolTip.height <= 0)
				topBottom = -1;
			else if(vUnderflow > 0 && (placement == "topRight" || placement == "top" || placement == "topLeft")
				&& vOverflow + target.height + currentToolTip.height <= 0)
				topBottom = 1;
			
			
			var newPlacement:String = "";
			
			if(topBottom != 2 || leftRight != 2) {
				if(topBottom == 1 || (topBottom == 2 && (placement == "bottomRight" || placement == "bottomLeft" || placement == "bottom")))
					newPlacement = "bottom";
				else if(topBottom == -1 || (topBottom == 2 && (placement == "topRight" || placement == "topLeft" || placement == "top")))
					newPlacement = "top";
				
				if(leftRight == -1 || (leftRight == 2 && (placement == "topLeft" || placement == "left" || placement == "bottomLeft")))
					newPlacement += newPlacement == "" ? "left" : "Left";
				else if(leftRight == 1 || (leftRight == 2 && (placement == "topRight" || placement == "right" || placement == "bottomRight")))
					newPlacement += newPlacement == "" ? "right" : "Right";
				
			
				IStyleClient(currentToolTip).setStyle("toolTipPlacement", newPlacement);
				sizeTip(currentToolTip);
				p = calculatePlacement(newPlacement, target, padX, padY);
			}  
			currentToolTip.move(p.x, p.y);	
		}
		
		protected function calculatePlacement(placement:String, target:Rectangle, padX:Number, padY:Number):Point {
			var x:Number;
			var y:Number;
			
			switch (placement) {
				case "topLeft":
				case "left":
				case "bottomLeft":
					x = target.x - currentToolTip.width - padX;
					break;
				
				case "topRight":
				case "right":
				case "bottomRight":
					x = target.x + target.width + padX;
					break;
				
				case "top":
				case "bottom":
					x = target.x + (target.width - currentToolTip.width) / 2;
					break;
			}
			
			switch (placement) {
				case "top":
				case "topLeft":
				case "topRight":
					y = target.y - currentToolTip.height - padY;
					break;
				
				case "bottom":
				case "bottomLeft":
				case "bottomRight":
					y = target.y + target.height + padY;
					break;
				
				case "left":
				case "right":
					y = target.y + (target.height - currentToolTip.height) / 2;
					break;
			}
			
			return new Point(x,y);
		}
		
		
		private function getStyleWithDefault(client:IStyleClient, key:String, defaultValue:*):* {
			var value:* = client.getStyle(key);
			if(value === undefined)
				return defaultValue;
			else
				return value;
		}
		
		private function getGlobalBounds(obj:DisplayObject, parent:DisplayObject):Rectangle {
			var upperLeft:Point = new Point(0,0);
			upperLeft = obj.localToGlobal(upperLeft);
			upperLeft = parent.globalToLocal(upperLeft);
			return new Rectangle(upperLeft.x, upperLeft.y, obj.width, obj.height);
		}
		
		
	}
}