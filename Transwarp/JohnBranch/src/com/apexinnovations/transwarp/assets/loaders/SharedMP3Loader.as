package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.loading.MP3Loader;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class SharedMP3Loader extends MP3Loader implements ISharedLoader {
		
		include "ISharedLoaderImpl.as"
		
		public function SharedMP3Loader(urlOrRequest:*, vars:Object=null) {
			super(urlOrRequest, vars);
		}
		
		override public function unload():void {
			if(referenceCount == 0 || pendingFlush)
				super.unload();
		}

	}
}