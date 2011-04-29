package com.apexinnovations.transwarp.assets {
	import flash.events.IEventDispatcher;
	
	public interface IAsset extends IEventDispatcher {
		
		function get type():String;
		function get url():String;
		function get id():String;
		function get status():String;
		function get isLoaded():Boolean;
		
	}
}