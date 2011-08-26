package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.errors.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	TranswarpVersion.revision = "$Rev$";
	
	// This represents a help page to display
	public class HelpPage extends EventDispatcher {
		private var _icon:String = '';		// The URL to an icon to load for this help page
		private var _name:String = '';		// The name of this help page
		private var _parent:Product = null;	// A link back to the product
		private var _url:String = '';		// The URL to the SWF to load for this help page
		
		private var whitelist:Boolean = false;
		private var courseWhitelist:Dictionary;
		private var pageWhitelist:Dictionary;
		
		public function HelpPage(xml:XML, parent:Product) {
			try {
				_icon = xml.@icon;
				_name = xml.@name;
				_parent = parent;
				_url = xml.@url;
				
				courseWhitelist = parseWhiteList(xml.@courses);
				pageWhitelist = parseWhiteList(xml.@pages);
				whitelist = courseWhitelist || pageWhitelist;				
				
			} catch ( e:Error ) {
				// No need to throw an error, just log it
				Courseware.log('Bad Initialization XML:  [' + e.message + ']', this);
			}
		}
		
		protected function parseWhiteList(list:String):Dictionary {

			if(list && list != "") {
				var dict:Dictionary = new Dictionary();
				for each(var e:String in list.split(" "))
					dict[uint(e)] = true;
				return dict;
			} else
				return null;
		}
		
		public function visibleOnPage(page:CoursewareObject):Boolean {
			if(whitelist)
				return (pageWhitelist ? pageWhitelist[page.id] : false) || (courseWhitelist ? courseWhitelist[page.parentCourse.id] : false);
			else
				return true;
		}
		
		public function get icon():String { return _icon; }
		[Bindable("helpPageChanged")] public function get name():String { return _name; }
		public function get parent():Product { return _parent; }
		[Bindable("helpPageChanged")] public function get url():String { return _url; }
	}
}