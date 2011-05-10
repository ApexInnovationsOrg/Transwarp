package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.events.PageSelectionEvent;
	import com.apexinnovations.transwarp.ui.tree.CourseList;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.webservices.*;
	
	import flash.errors.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	TranswarpVersion.revision = "$Rev$";
	
	
	[Event(name="pageSelectionChanged", type="com.apexinnovations.transwarp.events.PageSelectionEvent")]
	
	// This represents the user taking the class and the product being taken
	public class Courseware extends EventDispatcher {
		private static var _instance:Courseware;	// Make this class a singleton
		
		private var _color:uint = 0xFFFFFF;			// The background color to use for this product in the engine's UI
		private var _copyright:String = '';			// Copyright information about this engine
		private var _currentCourse:Course = null;	// Current course the user is viewing
		private var _currentPage:Page = null;		// Current page the user is viewing
		private var _currentCourseList:CourseList;
		private var _debug:Boolean = false;			// Are we in debug mode?
		private var _owner:String = '';				// The owner of this engine - Apex Innovations, e.g.
		private var _product:Product = null;		// The product that we're working with
		private var _rootFolder:String = '';		// The folder from which all page content is accessed
		private var _timeout:int = 0;				// The timeout value of inactivity, in seconds
		private var _user:User = null;				// The user that's accessing the courseware
		private var _website:String = '';			// The base URL of the website this engine is being run from
		private var _contentLoader:ContentLoader;
		
		
		// Return the singleton instance of this class
		public static function get instance():Courseware {
			return _instance;
		}		

		// Logs whatever the user wants to log
		public static function log(event:String, obj:Object = null):void {
			var log:LogService = new LogService();
					
			log.dispatch((obj ? _instance.getClassName(obj) + ': ' : '') + event);
		}
		
		// Searches the product for pages with the keywords, returns an ordered list of pages, by weight
		public static function search(keywords:String):Vector.<Page> {
			var pages:Vector.<Page> = new Vector.<Page>();
			
			// LMS users aren't allowed to search
			if (_instance.user.lms) return pages;
			
			for each (var course:Course in _instance.product.courses) {
				for each (var item:Page in course.pages) {
					if (item.search(keywords)) {
						pages.push(item);
					}
				}
			}
			// Log the search
			var srch:SearchService = new SearchService();
			
			srch.dispatch(keywords);
			
			// Sort and return the results
			return pages.sort(_instance.pageWeightCompare);
		}
		
			
		public function Courseware(xml:XML) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;
			
			try {
				_color = uint("0x" + String(xml.@color).substr(1,6));	// @color like '#FF00FF'
				_copyright = xml.@copyright;
				_debug = xml.@debug == 'true';
				_owner = xml.@owner;
				_rootFolder = xml.@rootFolder;
				_timeout = xml.@timeout;
				_website = xml.@website;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}
			
			_product = new Product(xml.product[0], this);
			_user = new User(xml.user[0], this);
			
			_currentCourseList = new CourseList();
			currentCourse = _product.getCourseByID(_user.startCourseID);
			currentPage = _currentCourse.pages[0];
			
			_contentLoader = new ContentLoader(_product);
		}
		
		
		[Bindable] public function get color():uint { return _color; }
		public function set color(value:uint):void { _color = value; }
		
		public function get copyright():String { return _copyright; }
		
		[Bindable] public function get currentCourse():Course { return _currentCourse; }
		public function set currentCourse(course:Course):void { 
			_currentCourse = course;
			_currentCourseList.course = course;
			dispatchEvent(new Event("courseChanged"));		
		}
		
		[Bindable("courseChanged")] public function get currentCourseList():CourseList {
			return _currentCourseList;	
		}		
		
		[Bindable] public function get currentPage():Page { return _currentPage; }
		public function set currentPage(page:Page):void {
			if(_currentPage == page || page == null)
				return;
			_currentPage = page;
			page.visited = true;
			
			dispatchEvent(new PageSelectionEvent(page));		
		}
		
		public function get debug():Boolean { return _debug; }
		public function get owner():String { return _owner; }
		public function get product():Product { return _product; }
		public function get rootFolder():String { return _rootFolder; }
		public function get timeout():int { return _timeout; }
		public function get user():User { return _user; }
		public function get website():String { return _website; }
		
		public function get contentLoader():ContentLoader { return _contentLoader; }
		
		public function getCourseByID(courseID:uint):Course {
			for each(var c:Course in product.courses)
				if(c.id == courseID)
					return c;
			return null;
		}
		

		// Gets the minimal class name for an object
		private function getClassName(o:Object):String {
			var fullClassName:String = getQualifiedClassName(o);
			return fullClassName.slice(fullClassName.lastIndexOf("::") + 2);
		}
		
		// Comparison function to sort pages by weight
		private function pageWeightCompare(x:Page, y:Page):Number {
			return y.weight - x.weight;
		}
		
		
		public function nextPage():void {
			moveSelection(pageToIndex(_currentPage) + 1, false);
		}
		
		public function prevPage():void {
			moveSelection(pageToIndex(_currentPage) - 1, true);
		}
		
		protected function pageToIndex(page:Page):int {
			var index:int = _currentCourseList.getItemIndex(_currentPage);
			if(index < 0 && _currentCourse.pages.indexOf(page) > 0) {
				var parent:* = page.parent;
				while(parent is Folder) {
					Folder(parent).open = true;
					parent = Folder(parent).parent; 
				}
				return _currentCourseList.getItemIndex(page);
			}

			return index;			
		}
		
		protected function moveSelection(newIndex:int, up:Boolean):void {
			var list:CourseList = _currentCourseList;
			
			if(newIndex < 0 || newIndex >= list.length)
				return;
			
			var newPage:* = list.getItemAt(newIndex);
			if(newPage is Page) {
				var page:Page = newPage as Page;
				Courseware.instance.currentPage = page;
				if(page.parent is Folder && !Folder(page.parent).open)
					(page.parent as Folder).open = true;
				
			}
			else { //newPage is Folder
				var folder:Folder = newPage as Folder;
				if(up) {
					if(folder.open) {
						moveSelection(newIndex - 1, up);
					} else {
						folder.open = true
						moveSelection(folder.contents.length + newIndex, up);
					}
				} else {
					folder.open = true;
					moveSelection(newIndex + 1, up);
				}						
				
			}
		}		
	}	
}