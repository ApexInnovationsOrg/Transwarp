package com.apexinnovations.transwarp.utils {
	public class Utils {
		
		public function Utils() {}
		
		
		static protected var _revision:uint;
		
		public static function set revision(value:String):void {
			var r:uint = uint(value.substring(6, value.length-1));
			if(r > _revision)
				_revision = r;
		}
		
		[Bindable] public static function get revision():String {
			return _revision.toString();
		}
		
	}
}