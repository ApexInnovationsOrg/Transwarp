package com.apexinnovations.transwarp.application.assets {
	import flash.events.IEventDispatcher;
	
	public interface IAsset extends IEventDispatcher {
		
		function get type():String;
		function get url():String;
		function get id():String;
		function get status():String;
		
	}
}