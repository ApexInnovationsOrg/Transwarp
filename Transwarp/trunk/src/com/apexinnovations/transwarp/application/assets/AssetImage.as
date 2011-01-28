package com.apexinnovations.transwarp.application.assets {
	import spark.components.Image;

	public class AssetImage extends Image {
		
		protected var _assetID:String;
		
		
		public function AssetImage(src:Object = null) {
			super();
			if(src)
				source = src;
		}

		
		public function set assetID(value:String):void {
			if(!value) 
				return;
			var asset:IconAsset = AssetLoader.instance.getIconAsset(value);
			if(!asset)
				throw new ArgumentError("'"+value+"' is an invalid assetID");
			_assetID = value;
			source = asset.bitmapData.clone();
		}
		
		public function get assetID():String { return _assetID; }
	}
}