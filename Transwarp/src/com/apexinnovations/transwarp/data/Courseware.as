package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.data.Product;
	import com.apexinnovations.transwarp.data.User;
	import com.apexinnovations.transwarp.webservices.*;
	
	import flash.errors.*;
	import flash.utils.*;
	
	// This represents the user taking the class and the product being taken
	public class Courseware {
		private static var _instance:Courseware;	// Make this class a singleton
		private var _copyright:String = '';			// Copyright information about this engine
		private var _currentCourse:Course = null;	// Current course the user is viewing
		private var _currentPage:Page = null;		// Current page the user is viewing
		private var _debug:Boolean = false;			// Are we in debug mode?
		private var _owner:String = '';				// The owner of this engine - Apex Innovations, e.g.
		private var _rootFolder:String = '';		// The folder from which all page content is accessed
		private var _timeout:int = 0;				// The timeout value of inactivity, in seconds
		private var _website:String = '';			// The base URL of the website this engine is being run from

		private var _product:Product = null;		// The product that we're working with
		private var _user:User = null;				// The user that's accessing the courseware

		public static function get instance():Courseware {
			if(!_instance)
				new Courseware(<courseware/>);
			return _instance;
		}		

		public function Courseware(xml:XML) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;
			
			try {
				_copyright = xml.@copyright;
				_debug = xml.@debug;
				_owner = xml.@owner;
				_rootFolder = xml.@rootFolder;
				_timeout = xml.@timeout;
				_website = xml.@website;

				_product = new Product(xml.product[0]);
				_user = new User(xml.user[0]);
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get copyright():String { return _copyright; }
		public function get currentCourse():Course { return _currentCourse; }
		public function get currentPage():Page { return _currentPage; }
		public function get debug():Boolean { return _debug; }
		public function get owner():String { return _owner; }
		public function get rootFolder():String { return '/Classroom/engine/' + _rootFolder; }
		public function get timeout():int { return _timeout; }
		public function get website():String { return _website; }

		public function get product():Product { return _product; }
		public function get user():User { return _user; }
		
		public function set currentCourse(course:Course):void { _currentCourse = course; }
		public function set currentPage(page:Page):void { _currentPage = page; }

		// Logs whatever the user wants to log
		public function log(logEvent:String):void {
			var log:LogService = new LogService();
			
			this.initAWS();
			
			log.dispatch(logEvent);
		}
		
		// Searches the product for pages with the keywords, returns an ordered list of pages, by weight
		public function search(keywords:String):Vector.<Page> {
			var pages:Vector.<Page> = new Vector.<Page>();

			// LMS users aren't allowed to search
			if (this.user.lms) return pages;
			
trace('Searching all pages for keywords: "' + keywords + '"');
			// NEEDS WORK - not truly recursive
			for each (var course:Course in this.product.courses) {
				// Allow search even within courses that this user is restricted from
				for each (var item:* in course.contents) {
					if (item is Page) {
						if (item.search(keywords)) {
							pages[pages.length] = item;
						}
					} else {
						for each (var subitem:* in item.contents) {
							if (subitem is Page) {
								if (subitem.search(keywords)) {
									pages[pages.length] = subitem;
								}
							} else {
								for each (var subsubitem:* in subitem.contents) {
									// Ad nauseum
								}
							}
						}
					}
				}
			}
			// Log the search
			var srch:SearchService = new SearchService();
			
			this.initAWS();
			
			srch.dispatch(keywords);
			
			// Sort and return the results
			return pages.sort(this.pageWeightCompare);
		}

	
		// Makes sure the ApexWebService is initialized
		private function initAWS():void {
			if (this.user)			ApexWebService.userID = this.user.id;
			if (this.currentCourse)	ApexWebService.courseID = this.currentCourse.id;
			if (this.currentPage)	ApexWebService.pageID = this.currentPage.id;
		}
		
		// Comparison function to sort pages by weight
		private function pageWeightCompare(x:Page, y:Page):Number {
			return y.weight - x.weight;
		}
	}
}