package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	TranswarpVersion.revision = "$Rev$";
	
	public class SharedLoaderFactory {
		
		protected var loaders:Dictionary = new Dictionary();
		
		public function getLoader(key:*, urlOrRequest:*, type:Class, vars:Object = null):* {
			if(!(key in loaders))
				loaders[key] = new type(urlOrRequest, vars);
			var r:* = loaders[key];
			return r;
		}
	}
}