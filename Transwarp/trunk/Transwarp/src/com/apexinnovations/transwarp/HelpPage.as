package com.apexinnovations.transwarp
{
	import flash.utils.*;
	import flash.errors.*;
	
	// This represents a help page to display
	public class HelpPage {
		private var _name:String = '';
		private var _url:String = '';
		private var _icon:String = '';
		
		public function HelpPage(xml:XML) {
			try {
				_name = xml.@name;
				_url = xml.@url;
				_icon = xml.@icon;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get name():String { return _name; }
		public function get url():String { return _url; }
		public function get icon():String { return _icon; }
	}
}