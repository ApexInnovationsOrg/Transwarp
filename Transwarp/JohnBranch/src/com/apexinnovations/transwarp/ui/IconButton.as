package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.skins.IconButtonSkin;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import com.apexinnovations.transwarp.ui.ext.Button;
	
	TranswarpVersion.revision = "$Rev$";
	
	
	[SkinState("overhighlight")]
	[SkinState("uphighlight")]
	[SkinState("downhighlight")]
	[SkinState("upfaded")]
	[SkinState("overfaded")]
	[SkinState("downfaded")]
	public class IconButton extends Button {
		
		protected var _highlight:Boolean = false;
		protected var _faded:Boolean = false;
		
		public function IconButton() {
			super();
			
			buttonMode = true;
			setStyle("skinClass", IconButtonSkin);
		}

		override protected function getCurrentSkinState():String {
			var state:String = super.getCurrentSkinState();
			if(_highlight && state != "disabled")
				state += "highlight";
			else if(_faded && state != "disabled")
				state += "faded";
			return state;			
		}
		
		[Bindable]
		public function get highlight():Boolean { return _highlight;}
		public function set highlight(value:Boolean):void {
			_highlight = value;
			invalidateSkinState();
		}

		[Bindable]
		public function get faded():Boolean { return _faded; }
		public function set faded(value:Boolean):void {
			_faded = value;
			invalidateSkinState();
		}


	}
}