package com.apexinnovations.transwarp.ui {
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;

	public class TranswarpLayout extends BasicLayout {
		
		public function TranswarpLayout() {
			super();
		}
		
		override public function updateDisplayList(width:Number, height:Number):void {
			if(height / width < 0.7)
				width = height / 0.7;
			else
				height = width * 0.7;
			
			super.updateDisplayList(width, height);
		}
	}
}