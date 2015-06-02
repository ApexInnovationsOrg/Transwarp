package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.loading.XMLLoader;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class SharedXMLLoader extends XMLLoader implements ISharedLoader {
		
		include "ISharedLoaderImpl.as"
		
		public function SharedXMLLoader(urlOrRequest:*, vars:Object=null) {
			super(urlOrRequest, vars);
		}
		
		override public function unload():void {
			if(referenceCount == 0 || pendingFlush)
				super.unload();
		}
	}
}