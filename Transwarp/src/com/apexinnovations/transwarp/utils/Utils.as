package com.apexinnovations.transwarp.utils {
	
	TranswarpVersion.revision = "$Rev$";
	
	public class Utils {
		
		public function Utils() {}
		
		// Hash function written by Bob Jenkins
		// http://www.burtleburtle.net/bob/hash/doobs.html
		public static function jenkinsHash(str:String):uint {
			var hash:uint = 0;
			for(var i :uint=0; i < str.length; ++i) {
				hash += str.charCodeAt(i);
				hash += (hash << 10);
				hash ^= (hash >> 6);
			}
			hash += (hash << 3);
			hash ^= (hash >> 11);
			hash += (hash << 15);
			return hash;
		}
		
		public static function zeroPad(number:int, width:int):String {
			var s:String = String(number);
			while(s.length < width) s = '0' + s;
			return s;
		}
	}
}