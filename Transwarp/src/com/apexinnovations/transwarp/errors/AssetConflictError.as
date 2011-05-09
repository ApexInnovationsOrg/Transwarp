package com.apexinnovations.transwarp.errors {
	
	import com.apexinnovations.transwarp.assets.IAsset;
	import com.apexinnovations.transwarp.utils.Utils;
	
	Utils.revision = "$Rev$";
	
	public class AssetConflictError extends Error {
		public var assetID:String;
		public var originalAsset:IAsset;		
		public var url:String;
		
		public function AssetConflictError(assetID:String, url:String, originalAsset:IAsset) {
			this.originalAsset = originalAsset;
			this.assetID = assetID;
			this.url = url;
			
			super("Asset ID conflict on id: '" + assetID + "'");
		}
	}
}