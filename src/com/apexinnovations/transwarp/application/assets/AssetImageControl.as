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
			if(!value) 
				return;
			var asset:BitmapAsset = AssetLoader.instance.getBitmapAsset(value);
			if(!asset)
				throw new ArgumentError("'"+value+"' is an invalid assetID");
			_assetID = value;
			source = asset.bitmapData.clone();
		}
		
		public function get assetID():String { return _assetID; }
	}
}