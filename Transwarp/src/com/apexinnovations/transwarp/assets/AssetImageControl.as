package com.apexinnovations.transwarp.assets {
	import br.com.stimuli.loading.BulkLoader;
	
	import spark.components.Image;
	import flash.events.Event;

	public class AssetImageControl extends Image {
		
		protected var _assetID:String;
		protected var _asset:BitmapAsset;
				
		public function AssetImageControl(src:Object = null) {
			super();
			if(src)
				source = src;
		}

		
		public function set assetID(value:String):void {
			_assetID = value;
			_asset = AssetLoader.instance.getBitmapAsset(value);
			
			if(_asset.status == BulkLoader.COMPLETE)
				source = _asset.bitmapData.clone();
			else
				_asset.addEventListener(BulkLoader.COMPLETE, loadComplete);	
		}
		
			
		public function get assetID():String { return _assetID; }
		
		protected function loadComplete(event:Event):void {
			if(_asset.bitmapData)
				source = _asset.bitmapData.clone();
		}
		
		
	}
	
}