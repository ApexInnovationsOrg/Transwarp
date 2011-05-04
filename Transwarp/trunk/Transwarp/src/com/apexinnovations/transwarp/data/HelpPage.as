package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Courseware;
	import flash.utils.*;
	import flash.errors.*;
	
	// This represents a help page to display
	public class HelpPage {
		private var _icon:String = '';	// The URL to an icon to load for this help page
		private var _name:String = '';	// The name of this help page
		private var _url:String = '';	// The URL to the SWF to load for this help page
		
		public function HelpPage(xml:XML) {
			try {
				_icon = xml.@icon;
				_name = xml.@name;
				_url = xml.@url;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get icon():String { return _icon; }
		public function get name():String { return _name; }
		public function get url():String { return _url; }
	}
}