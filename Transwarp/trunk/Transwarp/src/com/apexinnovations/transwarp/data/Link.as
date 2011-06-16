package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.EventDispatcher;
	import flash.errors.*;
	import flash.utils.*;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	TranswarpVersion.revision = "$Rev$";
	
	// This represents and outside link related to a page
	public class Link extends EventDispatcher {
		private var _parent:Page = null;		// A link back to the page
		private var _textFlow:TextFlow = null;	// The text description of this link, as a TextFlow
		private var _url:String = '';			// The URL of this link
		
		public function Link(xml:XML, parent:Page) {
			try {
				_parent = parent;
				_textFlow = TextConverter.importToFlow(xml.children()[0], TextConverter.TEXT_LAYOUT_FORMAT);
				_url = xml.@url;
			} catch ( e:Error ) {
				// No need to throw an error, just log it
				Courseware.log('Bad Initialization XML:  [' + e.message + ']', this);
			}
		}
		
		public function get parent():Page { return _parent; }
		[Bindable("pageSelectionChanged")] public function get textFlow():TextFlow { return _textFlow; }
		public function get url():String { return _url; }
	}
}