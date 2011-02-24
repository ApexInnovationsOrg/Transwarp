package com.apexinnovations.transwarp.application.assets
{
	import br.com.stimuli.loading.*;
	
	import com.apexinnovations.transwarp.application.errors.AssetConflictError;
	import com.apexinnovations.transwarp.webservices.ApexWebService;
	import com.apexinnovations.transwarp.webservices.LogService;
	
	import flash.display.Bitmap;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	[Event(name="complete", type="flash.events.Event")]
	public class AssetLoader extends EventDispatcher {
		protected var loader:BulkLoader;
		protected var iconAssets:Dictionary;
		protected static var _instance:AssetLoader;
		
		public static function get instance():AssetLoader {
			if(!_instance)
				new AssetLoader();
			return _instance;
		}		
		
		public function AssetLoader() {
			if(_instance)
				throw new IllegalOperationError("AssetLoader is a singleton");
			
			_instance = this;
			
			loader = new BulkLoader();
			loader.addEventListener(BulkLoader.COMPLETE, onComplete);
			loader.logLevel = BulkLoader.LOG_ERRORS;
			loader.addEventListener(BulkLoader.ERROR, onLoadError);
			loader.addEventListener(BulkLoader.PROGRESS, onProgress);
			
			iconAssets = new Dictionary();
		}
		
		
		
		protected function onComplete(e:Event):void {
			for(var i:* in iconAssets){
				var asset:IconAsset = iconAssets[i];
				asset.bitmapData = loader.getBitmapData(i);
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function addIconAsset(url:String, id:String, name:String="", highlightIntensity:Number = 0.3):void {	
			if(iconAssets[id])
				throw new AssetConflictError(id);
			
			iconAssets[id] = new IconAsset(url, id, name, highlightIntensity);
			loader.add(url, {id:id});
			loader.start();
		}
			
		public function getIconAsset(id:String):IconAsset {
			return IconAsset(iconAssets[id]);
		}
		
		protected function onLoadError(event:Event):void {
			var log:LogService = new LogService();
			var failedItems:Array = loader.getFailedItems();
			for (var i:uint = 0; i < failedItems.length; i++) {
				log.dispatch(ApexWebService.userID, ApexWebService.courseID, ApexWebService.pageID, "Error loading asset: " + failedItems[i].toString());
			}
			loader.removeFailedItems();		// Allows complete event to fire
		}
		
		protected function onProgress(event:BulkProgressEvent):void {
			//TODO: Handle Progress updates
		}		
	}
}