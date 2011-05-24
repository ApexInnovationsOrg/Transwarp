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
			
			sizeTip(currentToolTip);
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
			
			var screen:Rectangle = currentToolTip.screen;
			var target:Rectangle = getGlobalBounds(currentTarget, currentToolTip.parent); // currentToolTip.parent may need to be .root instead
			
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
			IStyleClient(currentToolTip).setStyle("toolTipPlacement", placement);
			currentToolTip.move(x, y);			
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