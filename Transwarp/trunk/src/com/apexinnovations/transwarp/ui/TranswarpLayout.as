package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.application.TranswarpFlex;
	
	import flash.display.DisplayObject;
	
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;

	public class TranswarpLayout extends BasicLayout {
		
		public var heightOffset:Number = 0;
		public var widthOffset:Number = 0;
		
		public function TranswarpLayout() {
			super();
		}
		
		override public function updateDisplayList(width:Number, height:Number):void {
			var newWidth:Number, newHeight:Number;
			if((height-heightOffset) / (width-widthOffset) < 0.7) {
				newWidth = (height-heightOffset) / 0.7 + widthOffset;
				newHeight = height;
				target.setLayoutBoundsPosition((width - newWidth) / 2, 0); 		// center horizontally
			} else {
				newWidth = width;
				newHeight = (width-heightOffset) * 0.7 + heightOffset;
				target.setLayoutBoundsPosition(0,  (height - newHeight) / 2);	// center vertically
			}
			
			super.updateDisplayList(newWidth, newHeight);
		}
	}
}