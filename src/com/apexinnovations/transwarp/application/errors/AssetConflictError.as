package com.apexinnovations.transwarp.application.errors {

	public class AssetConflictError extends Error {
		
		public function AssetConflictError(assetID:String) {
			super("Asset ID conflict on id: '" + assetID + "'");
		}
	}
}