package com.apexinnovations.transwarp.events {
	import com.apexinnovations.transwarp.assets.IAsset;
	import com.apexinnovations.transwarp.utils.Utils;
	
	import flash.events.Event;
	
	Utils.revision = "$Rev$";
	
	public class AssetAddedEvent extends Event {
		
		public static const ASSET_ADDED:String = "assetAdded";
		
		public var asset:IAsset;
		
		public function AssetAddedEvent(asset:IAsset, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(ASSET_ADDED, bubbles, cancelable);
			
			this.asset = asset;
		}
	}
}