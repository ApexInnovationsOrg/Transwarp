package com.apexinnovations.transwarp.application.assets {
	import spark.components.Image;

	public class AssetImageControl extends Image {
		
		protected var _assetID:String;
		
		
		public function AssetImageControl(src:Object = null) {
			super();
			if(src)
				source = src;
		}

		
		public function set assetID(value:String):void {
			_assetID = value;
			var asset:BitmapAsset = AssetLoader.instance.getBitmapAsset(value);
			source = asset ? asset.bitmapData.clone() : null;
		}
		
		public function get assetID():String { return _assetID; }
	}
}