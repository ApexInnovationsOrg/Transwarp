package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.skins.ToolButtonSkin;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.MouseEvent;
	
	import spark.components.ToggleButton;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class ToolButton extends ToggleButton {
		
		public function ToolButton() {
			super();
			
			buttonMode = true;
			setStyle("skinClass", ToolButtonSkin);
		}
	}
}