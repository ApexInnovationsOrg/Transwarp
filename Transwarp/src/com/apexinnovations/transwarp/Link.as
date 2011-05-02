package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents and outside link related to a page
	public class Link {
		private var _url:String = '';
		private var _textFlow:TextFlow = null;
		
		public function Link(xml:XML) {
			try {
				_url = xml.@url;
				_textFlow = xml[0];
			} catch ( e:Error ) {
				throw new ArgumentError("Invalid Initialization XML");
			}
		}
		
		public function get url():String { return _url; }
		public function get textFlow():TextFlow { return _textFlow; }
	}
}