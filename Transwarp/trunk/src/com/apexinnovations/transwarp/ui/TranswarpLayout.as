package com.apexinnovations.transwarp.ui {
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;

	public class TranswarpLayout extends BasicLayout {
		
		public function TranswarpLayout() {
			super();
		}
		
		override public function updateDisplayList(width:Number, height:Number):void {
			var newWidth:Number, newHeight:Number;
			
			if(height / width < 0.7) {
				newWidth = height / 0.7;
				newHeight = height;
				target.setLayoutBoundsPosition((width - newWidth) / 2, 0); 		// center horizontally
			} else {
				newWidth = width;
				newHeight = width * 0.7;
				target.setLayoutBoundsPosition(0,  (height - newHeight) / 2);	// center vertically
			}
			
			super.updateDisplayList(newWidth, newHeight);
		}
	}
}