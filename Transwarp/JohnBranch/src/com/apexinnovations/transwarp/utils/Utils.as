package com.apexinnovations.transwarp.utils {
	
	TranswarpVersion.revision = "$Rev$";
	
	public class Utils {
		import flashx.textLayout.conversion.ConversionType;
		import flashx.textLayout.conversion.TextConverter;
		import flashx.textLayout.elements.TextFlow;
		
		public function Utils() {}
		
		// Escapes characters being stored in JSON value, e.g {"var" : "value"}
		public static function encodeJSONValue(s:String):String {
			return s.replace(/\n/g, '\\n').replace(/\t/g, '\\t').replace(/\r/g, '\\r').replace(/\f/g, '\\f').replace(/\b/g, '').replace(/\\/g, '\\').replace(/"/g, '\"').replace(/\\/g, '\\');
		}

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
		
		public static function textFlowToString(tf:TextFlow):String {
			if (tf == null) return '';
			
			var tfx:XML = XML(TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE));
			var s:String = '';
			for each (var x:XML in XMLList(tfx..*).text()) {
				s += x + ' ';
			}
			
			return s.substr(0, s.length - 1).replace(/\\[nrt]/g, ' ').replace(/  /g, ' '); // remove double spaces and trailing space
		}
		
		public static function trim(s:String):String {
			return s.replace(/^\s+|\s+$/gs, '');
		}
		
		public static function zeroPad(number:int, width:int):String {
			var s:String = String(number);
			while(s.length < width) s = '0' + s;
			return s;
		}
		
		public static function importTextFlow(markup:XML):TextFlow {
			if(!markup)
				return null;
			
			var s:String = '';
			for each (var x:XML in XMLList(markup..*).text()) {
				s += x;
			}
			
			if(s.replace(/\s/g, '').length == 0)
				return null;
			
			return TextConverter.importToFlow(markup, TextConverter.TEXT_LAYOUT_FORMAT);
		}
	}
}