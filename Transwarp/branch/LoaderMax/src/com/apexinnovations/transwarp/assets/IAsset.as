package com.apexinnovations.transwarp.assets {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.IEventDispatcher;
	
	TranswarpVersion.revision = "$Rev$";
	
	public interface IAsset extends IEventDispatcher {
		
		function get type():String;
		function get url():String;
		function get id():String;
		function get status():String;
		function get isLoaded():Boolean;
		
	}
}