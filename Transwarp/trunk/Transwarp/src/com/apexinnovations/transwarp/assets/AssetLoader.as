package com.apexinnovations.transwarp.assets
{
	import br.com.stimuli.loading.*;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.apexinnovations.transwarp.errors.AssetConflictError;
	import com.apexinnovations.transwarp.events.AssetAddedEvent;
	import com.apexinnovations.transwarp.webservices.ApexWebService;
	import com.apexinnovations.transwarp.webservices.LogService;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="assetAdded", type="com.apexinnovations.transwarp.events.AssetAddedEvent")]
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
				throw new IllegalOperationError("AssetLoader is a singleton: use AssetLoader.instance to get an instance.");
			
			_instance = this;
			
			loader = new BulkLoader();
			loader.addEventListener(BulkLoader.COMPLETE, onAllComplete);
			loader.logLevel = BulkLoader.LOG_ERRORS;
			loader.addEventListener(BulkLoader.ERROR, onLoadError);
			loader.addEventListener(BulkLoader.PROGRESS, onProgress);
			
			iconAssets = new Dictionary();
		}
		
		
		protected function bitmapLoadComplete(event:Event):void {
			var item:LoadingItem = event.target as LoadingItem;
			var asset:BitmapAsset = BitmapAsset(iconAssets[item.id]);
			asset.bitmapData = loader.getBitmapData(item.id);
			asset.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onAllComplete(e:Event):void {		
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function addBitmapAsset(url:String, id:String, name:String="", highlightIntensity:Number = 0.3):BitmapAsset {	
			if(iconAssets[id])
				throw new AssetConflictError(url, id, iconAssets[id]);
			
			var item:LoadingItem = loader.add(url, {id:id});
			loader.start();
			item.addEventListener(Event.COMPLETE, bitmapLoadComplete)
			var asset:BitmapAsset = new BitmapAsset(item, name, highlightIntensity);
			iconAssets[id] = asset			
			
			dispatchEvent(new AssetAddedEvent(asset));
				
			return asset;
		}
			
		public function getBitmapAsset(id:String):BitmapAsset {		
			return iconAssets[id] as BitmapAsset;			
		}
		
		protected function onLoadError(event:Event):void {
			var log:LogService = new LogService();
			var failedItems:Array = loader.getFailedItems();
			for (var i:uint = 0; i < failedItems.length; i++) {
				log.dispatch("Error loading asset: " + failedItems[i].toString());
			}
			loader.removeFailedItems();		// Allows complete event to fire
		}
		
		protected function onProgress(event:BulkProgressEvent):void {
			//TODO: Handle Progress updates
		}		
	}
}