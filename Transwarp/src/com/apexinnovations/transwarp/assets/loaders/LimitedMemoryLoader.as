package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class LimitedMemoryLoader extends EventDispatcher {
		
		protected var loadQueue:Array = [];
		protected var inMemory:Array = [];
		
		protected var _bytesLoaded:uint = 0;
		protected var needsRecount:Boolean = false;
		
		protected var memoryCap:uint;
		protected var maxConnections:int = 2;
		protected var loaders:Dictionary = new Dictionary();
		
		protected var activeLoaders:Dictionary = new Dictionary();
		protected var activeCount:int = 0;
		
		public function LimitedMemoryLoader(memoryCap:uint) {
			super();
			this.memoryCap = memoryCap;			
		}
		
		protected function addLoader(loader:LoaderCore):void {
			if(loader in loaders)
				return;
			
			loaders[loader] = loader;
			loader.addEventListener(LoaderEvent.OPEN, childOpen);
			loader.addEventListener(LoaderEvent.CANCEL, processQueue);
			loader.addEventListener(LoaderEvent.COMPLETE, processQueue);
			loader.addEventListener(LoaderEvent.PROGRESS, childProgress);
			
			var status:int = loader.status;
			if(status == LoaderStatus.COMPLETED || status == LoaderStatus.LOADING) {
				if(status == LoaderStatus.LOADING)
					setActive(loader, true);
				inMemory.unshift(loader);
			}
		}
				
		protected function removeLoader(loader:LoaderCore):void {
			if(loader in loaders) {
				delete loaders[loader];
				loader.removeEventListener(LoaderEvent.OPEN, childOpen);
				loader.removeEventListener(LoaderEvent.CANCEL, processQueue);
				loader.removeEventListener(LoaderEvent.COMPLETE, processQueue);
				loader.removeEventListener(LoaderEvent.PROGRESS, childProgress);
			}
		}
		
		public function requestLoad(loader:LoaderCore):void {
			addLoader(loader);
			var status:int = loader.status;
			if(status == LoaderStatus.READY) {
				var index:int = loadQueue.indexOf(loader);
				if(index != -1)
					loadQueue.splice(index, 1);
				loadQueue.unshift(loader);
				
				if(activeCount < maxConnections)
					processQueue();
				
			} else if (status == LoaderStatus.COMPLETED || status == LoaderStatus.LOADING){
				index = inMemory.indexOf(loader);
				if(index != 0) {
					inMemory.splice(index, 1);
					inMemory.unshift(loader);
				} else if (index == -1)
					trace("Loaded item _not_ in inMemory list!");					
			}
		}
		
		public function prioritizeLoaders(loaders:Array):void {
			for each(var loader:LoaderCore in loaders) {
				addLoader(loader);
				if(loader.status == LoaderStatus.READY)
					loadQueue.push(loader);
			}
			
			if(activeCount < maxConnections)
				processQueue();
		}
		
		protected function processQueue(event:Event = null):void {
			if(event)
				setActive(event.target, false);
			
			while(loadQueue.length && activeCount < maxConnections) {
				var next:LoaderCore = loadQueue.shift();
				if(next.status == LoaderStatus.READY) {
					makeRoom(next.auditedSize ? next.bytesTotal - next.bytesLoaded : 0);
					next.load();
				}
			}
		}
		
		protected function makeRoom(headroom:int = 0):void {
			while(bytesLoaded + headroom > memoryCap && inMemory.length) {
				var loader:LoaderCore = inMemory.pop();
				var before:uint = loader.bytesLoaded;
				//trace("unload", loader);
				loader.unload();
				_bytesLoaded -= before - loader.bytesLoaded;
			}
				
			if(bytesLoaded > memoryCap)
				trace("UNABLE TO GET UNDER MEMORY CAP.  THIS IS BAD, BATMAN.  REAL BAD.");
		}
		
		protected function get bytesLoaded():uint {
			if(needsRecount)
				calculateBytesLoaded();
			return _bytesLoaded;
		}
		
		protected function calculateBytesLoaded():void {
			_bytesLoaded = 0;
			for each (var loader:LoaderCore in loaders) {
				_bytesLoaded += loader.bytesLoaded;
			}
			needsRecount = false;
		}
		
		protected function setActive(loader:*, value:Boolean):void {
			if(value && !(loader in activeLoaders)) {
				activeCount++;
				activeLoaders[loader] = true;
			} else if(!value && loader in activeLoaders) {
				activeCount--;
				delete activeLoaders[loader];
			}
		}
		
		protected function childProgress(event:Event):void {
			needsRecount = true;
		}
		
		protected function childOpen(event:Event):void {
			setActive(event.target, true);
			var index:int = inMemory.indexOf(event.target);
			if(index != -1)
				inMemory.splice(index, 1);
			inMemory.unshift(event.target);
			//trace("open", event.target);
		}
		
	}
}