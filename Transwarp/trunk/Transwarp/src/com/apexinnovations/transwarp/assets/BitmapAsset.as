package com.apexinnovations.transwarp.assets {
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import flash.display.Bitmap;

	public class BitmapAsset extends Bitmap implements IAsset{
		protected var _name:String;
		protected var _highlightIntensity:Number;
		protected var _item:LoadingItem;
		
		public function BitmapAsset(item:LoadingItem, name:String = "", highlightIntensity:Number = 0.3) {
			_item = item;
			_name = name;
			_highlightIntensity = highlightIntensity;
		}
		
		public function get type():String { return AssetType.BITMAP; }
		
		public function get status():String { return _item.status;  }
		public function get url():String	{ return _item.url.url; }
		public function get id():String		{ return _item.id;      }
		public function get isLoaded():Boolean { return _item.isLoaded; }
		
		
		public function get localizedName():String { return _name; }
		public function get highlightIntensity():Number { return _highlightIntensity; }
	}
}