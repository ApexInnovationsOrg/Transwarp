package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.loading.DataLoader;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class SharedDataLoader extends DataLoader implements ISharedLoader {
		
		include "ISharedLoaderImpl.as"
		
		public function SharedDataLoader(urlOrRequest:*, vars:Object=null) {
			super(urlOrRequest, vars);
		}
		
		override public function unload():void {
			if(referenceCount == 0 || pendingFlush)
				super.unload();
		}
	}
}