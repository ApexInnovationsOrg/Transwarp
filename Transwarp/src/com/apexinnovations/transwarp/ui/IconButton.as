package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.skins.IconButtonSkin;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import spark.components.Button;
	
	TranswarpVersion.revision = "$Rev$";
	
	
	[SkinState("overhighlight")]
	[SkinState("uphighlight")]
	[SkinState("downhighlight")]
	public class IconButton extends Button {
		
		protected var _highlight:Boolean;
		
		
		public function IconButton() {
			super();
			
			buttonMode = true;
			setStyle("skinClass", IconButtonSkin);
		}

		override protected function getCurrentSkinState():String {
			var state:String = super.getCurrentSkinState();
			if(_highlight && state != "disabled")
				state += "highlight";
			
			return state;			
		}
		
		[Bindable]
		public function get highlight():Boolean { return _highlight;}
		public function set highlight(value:Boolean):void {
			_highlight = value;
			invalidateSkinState();
		}

	}
}