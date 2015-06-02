package com.apexinnovations.transwarp.assets.loaders {	
	
	public interface ISharedLoader {
		
		function addReference(referrer:*):void;
		function releaseReference(referrer:*):void;
		
		function get referenceCount():int;
		
		function get pendingFlush():Boolean;
		function set pendingFlush(value:Boolean):void;
	}
}