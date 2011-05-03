package com.apexinnovations.transwarp
{
	import flash.utils.*;
	import flash.errors.*;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents and outside link related to a page
	public class Link {
		private var _url:String = '';			// The URL of this link
		private var _textFlow:TextFlow = null;	// The text description of this link, as a TextFlow
		
		public function Link(xml:XML) {
			try {
				_url = xml.@url;
				_textFlow = TextConverter.importToFlow(xml[0], TextConverter.TEXT_LAYOUT_FORMAT);
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get url():String { return _url; }
		public function get textFlow():TextFlow { return _textFlow; }
	}
}