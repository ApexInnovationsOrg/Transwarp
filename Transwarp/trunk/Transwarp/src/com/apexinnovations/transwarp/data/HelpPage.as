package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.errors.*;
	import flash.utils.*;
	
	TranswarpVersion.revision = "$Rev$";
	
	// This represents a help page to display
	public class HelpPage {
		private var _icon:String = '';		// The URL to an icon to load for this help page
		private var _name:String = '';		// The name of this help page
		private var _parent:Product = null;	// A link back to the product
		private var _url:String = '';		// The URL to the SWF to load for this help page
		
		public function HelpPage(xml:XML, parent:Product) {
			try {
				_icon = xml.@icon;
				_name = xml.@name;
				_parent = parent;
				_url = xml.@url;
			} catch ( e:Error ) {
				// No need to throw an error, just log it
				Courseware.log('Bad Initialization XML:  [' + e.message + ']', this);
			}
		}
		
		public function get icon():String { return _icon; }
		public function get name():String { return _name; }
		public function get parent():Product { return _parent; }
		public function get url():String { return _url; }
	}
}