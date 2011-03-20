package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.application.assets.AssetLoader;
	import com.apexinnovations.transwarp.application.assets.BitmapAsset;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;

	public class AssetIconButton extends IconButton {
		
		protected var _assetID:String;
		protected var _asset:BitmapAsset;	
		protected var _bmp:Bitmap;
		
		public function set assetID(value:String):void {
			_assetID = value;
			_asset = AssetLoader.instance.getBitmapAsset(_assetID);
			highlightIntensity = _asset ? _asset.highlightIntensity : 0.3;
			_bmp = _asset ? new Bitmap(_asset.bitmapData.clone()) : null;
			art = _bmp;			
		}
		
		public function get assetID():String { return _assetID; }
		
		public function get localizedName():String { return _asset ? _asset.localizedName : ""; }
		
		public function AssetIconButton(art:Object = null) {
			super();
			if(art is String) 
				assetID = String(art);
			else if(art is DisplayObject)
				this.art = DisplayObject(art);
		}
	}
}