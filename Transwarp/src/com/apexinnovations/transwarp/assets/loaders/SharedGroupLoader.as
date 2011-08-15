package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.core.LoaderCore;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class SharedGroupLoader extends LoaderMax {
		
		protected static var loaderFactory:SharedLoaderFactory = new SharedLoaderFactory();
		
		public function SharedGroupLoader(vars:Object=null) {
			super(vars);
		}
		
		override public function get status():int {
			//Because of the way we share loaders among several LoaderMax "parent loaders", they sometimes incorrectly think their status is
			//READY when it should be LOADING or COMPLETE because another loader has already loaded (or is loading) a child of this loader.
			//The status getter always rechecks the status of child loaders when the current status is COMPLETED, so by assigning that to
			//_status here, we force a recalc when the current status is READY.
			if(_status == LoaderStatus.READY)  
				_status = LoaderStatus.COMPLETED;
			return super.status;
		}
		
		
		protected function holdLoaders():void {
			for each(var loader:LoaderCore in _loaders) {
				if(loader is ISharedLoader)
					ISharedLoader(loader).addReference(this);
			}
		}
		
		protected function releaseLoaders():void {
			for each(var loader:LoaderCore in _loaders) {
				if(loader is ISharedLoader)
					ISharedLoader(loader).releaseReference(this);
			}
		}
		
		protected function setFlush(value:Boolean):void {
			for each(var loader:LoaderCore in _loaders) {
				if(loader is ISharedLoader)
					ISharedLoader(loader).pendingFlush = value;
			}
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		// Overrides of LoaderMax functions to add and release references on shared loaders
		///////////////////////////////////////////////////////////////////////////////////
		
		override public function insert(loader:LoaderCore, index:uint=999999999):LoaderCore {
			var s:int = status;
			// A loader status of anything but READY or DISPOSED indicates that it is at least trying to load
			if(loader is ISharedLoader && s != LoaderStatus.READY && s != LoaderStatus.DISPOSED)
				ISharedLoader(loader).addReference(this);
			return super.insert(loader, index);
		}
		
		override public function load(flushContent:Boolean=false):void {
			if(flushContent) 
				setFlush(true);
			else			
				holdLoaders();
			
			super.load(flushContent);
			
			if(flushContent)
				setFlush(false);
		}
		
		override public function unload():void {
			releaseLoaders();
			super.unload();
		}
		
		override public function empty(disposeChildren:Boolean=true, unloadAllContent:Boolean=false):void {
			releaseLoaders();
			super.empty(disposeChildren, unloadAllContent);
		}
		
		override public function remove(loader:LoaderCore):void {
			if(loader is ISharedLoader)
				ISharedLoader(loader).releaseReference(this);
			super.remove(loader);
		}

	}
}