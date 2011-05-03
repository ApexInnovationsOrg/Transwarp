package com.apexinnovations.transwarp.assets {
	import br.com.stimuli.loading.BulkLoader;
	
	import com.apexinnovations.transwarp.events.AssetAddedEvent;
	
	import flash.events.Event;
	
	import spark.components.Image;

	public class AssetImageControl extends Image {
		
		protected var _asset:BitmapAsset;
		protected var _assetID:String;
		
		public function AssetImageControl(src:Object = null) {
			super();
			if(src)
				source = src;
		}

		
		public function set assetID(value:String):void {
			_assetID = value;
			
			if(value == null)
				asset = null;
			else {
				var a:BitmapAsset = AssetLoader.instance.getBitmapAsset(value);
				if(a)	
					asset = a;
				else
					AssetLoader.instance.addEventListener(AssetAddedEvent.ASSET_ADDED, assetAdded);				
			}
				
		}
				
		public function get assetID():String { return _assetID; }
		
		public function get asset():BitmapAsset { return _asset; }
		
		public function set asset(value:BitmapAsset):void {
			if(_asset)
				_asset.removeEventListener(BulkLoader.COMPLETE, loadComplete);
			
			_asset = value;
			_assetID = _asset ? _asset.id : null;
			
			if(!_asset)
				source = null;
			else if(!_asset.isLoaded)
				_asset.addEventListener(BulkLoader.COMPLETE, loadComplete);
			else
				source = _asset.bitmapData.clone();
		}
		
		
		protected function loadComplete(event:Event):void {
			if(_asset.bitmapData)
				source = _asset.bitmapData.clone();
		}
		
		protected function assetAdded(event:AssetAddedEvent):void {
			if(event.asset.id == _assetID) {
				asset = event.asset as BitmapAsset;
				AssetLoader.instance.removeEventListener(AssetAddedEvent.ASSET_ADDED, assetAdded);
			}
		}		
		
	}	
}