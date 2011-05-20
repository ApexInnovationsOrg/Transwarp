package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.skins.IconButtonSkin;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import spark.components.Button;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class IconButton extends Button {
		
		public function IconButton() {
			super();
			
			buttonMode = true;
			setStyle("skinClass", IconButtonSkin);
		}
	}
}