package com.apexinnovations.transwarp.application.assets {
	import flash.display.Bitmap;

	public class IconAsset extends Bitmap{
		protected var _url:String;
		protected var _id:String;
		protected var _name:String;
		protected var _highlightIntensity:Number;
		
		public function IconAsset(url:String, id:String, name:String = "", highlightIntensity:Number = 0.3) {
			_url  = url;
			_id   = id;
			_name = name;
			_highlightIntensity = highlightIntensity;
		}
		
		public function get url():String  { return _url; }
		public function get id():String   { return _id;  }
		public function get localizedName():String { return _name;}
		public function get highlightIntensity():Number { return _highlightIntensity;}
	}
}