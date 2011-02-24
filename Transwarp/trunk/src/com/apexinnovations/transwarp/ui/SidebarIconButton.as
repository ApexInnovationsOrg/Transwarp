package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.application.assets.AssetLoader;
	import com.apexinnovations.transwarp.application.assets.IconAsset;
	
	import flash.display.DisplayObject;

	public class SidebarIconButton extends IconButton {
		
		protected var _artID:String;
		protected var _asset:IconAsset;
				
		override public function set art(value:DisplayObject):void {
			super.art = value;
			_art.width = _art.height = 32;			
		}
		
		public function set artID(value:String):void {
			_artID = value;
			_asset = AssetLoader.instance.getIconAsset(_artID);
			highlightIntensity = _asset.highlightIntensity;
			art = _asset;
		}
		
		public function get artID():String { return _artID; }
		
		public function get localizedName():String { return _asset.localizedName; }
		
		public function SidebarIconButton(art:Object = null) {
			super();
			if(art is String) 
				artID = String(art);
			else if(art is DisplayObject)
				this.art = DisplayObject(art);
		}		
	}
}