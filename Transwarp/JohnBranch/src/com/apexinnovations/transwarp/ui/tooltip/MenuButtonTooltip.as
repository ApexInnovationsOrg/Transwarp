package com.apexinnovations.transwarp.ui.tooltip {
	import mx.core.IToolTip;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class MenuButtonTooltip extends SkinnableComponent implements IToolTip {
		
		public function MenuButtonTooltip() {
			super();
		}
		
		public function get text():String {
			return null;
		}
		
		public function set text(value:String):void {
			
		}
	}
}