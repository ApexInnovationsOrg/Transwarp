package com.apexinnovations.transwarp.data {
	import com.apexinnovations.transwarp.config.ConfigData;
	import com.apexinnovations.transwarp.events.FolderOpenEvent;
	import com.apexinnovations.transwarp.events.PageSelectionEvent;
	import com.apexinnovations.transwarp.utils.*;
	import com.apexinnovations.transwarp.webservices.*;
	
	import flash.errors.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.*;
	import flash.utils.*;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="pageSelectionChanged", type="com.apexinnovations.transwarp.events.PageSelectionEvent")]
	
	// This represents the user taking the class and the product being taken
	public class Courseware extends EventDispatcher {
		private static var _instance:Courseware;	// Make this class a singleton
		
		private var _buttonBGColor:uint = 0x333333;	// The background color to use for buttons
		private var _buttonFGColor:uint = 0xCCCCCC;	// The foreground color to use for buttons
		private var _color:uint = 0xFFFFFF;			// The background color to use for this product in the engine's UI
		private var _copyright:String = '';			// Copyright information about this engine
		private var _currentCourse:Course = null;	// Current course the user is viewing
		private var _currentPage:CoursewareObject	// Current page the user is viewing
		private var _currentCourseList:CourseList;
		private var _debug:Boolean = false;			// Are we in debug mode?
		private var _highlightColor:uint = 0x000000;// The highlight color to use for this product in the engine's UI
		private var _owner:String = '';				// The owner of this engine - Apex Innovations, e.g.
		private var _product:Product = null;		// The product that we're working with
		private var _rootFolder:String = '';		// The folder from which all page content is accessed
		private var _timeout:int = 0;				// The timeout value of inactivity, in seconds
		private var _user:User = null;				// The user that's accessing the courseware
		private var _website:String = '';			// The base URL of the website this engine is being run from
		
		private var _obeyAllowDeny:Boolean = true;
		
		private var _successfulInit:Boolean = true;
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
			keywords = Utils.trim(keywords);
			
			if (!keywords) return null;
			
			var pages:Vector.<Page> = new Vector.<Page>();
									
			// Get list of excluded terms
			var i:int;
			var tmp:String = keywords;
			var exclude:Array = tmp.match(/-("[^"]*"|\S+)/g);
			tmp = tmp.replace(/-("[^"]*"|\S+)/g, '');		// ... and remove them from original keywords
			for (i = 0; i < exclude.length; i ++) {
				exclude[i] = exclude[i].replace(/[\-"]/g, '');		// remove + and " chars
			}
			exclude = removeDuplicates(exclude);
			
			// Get list of required terms
			var require:Array = tmp.match(/\+("[^"]*"|\S+)/g);
			tmp = tmp.replace(/\+("[^"]*"|\S+)/g, '');	// ... and remove them from original keywords
			for (i = 0; i < require.length; i ++) {
				require[i] = require[i].replace(/[\+"]/g, '');		// remove - and " chars
			}
			require = removeDuplicates(require);

			// Get list of remaining search terms
			var terms:Array = tmp.match(/("[^"]*"|\S+)/g);
			for (i = 0; i < terms.length; i ++) {
				terms[i] = terms[i].replace(/"/g, '');		// remove " chars
			}
			
			terms = removeDuplicates(terms);
			
			for each (var course:Course in _instance.product.courses) {
				for each (var item:Page in course.pages) {
					if (item.search(terms, exclude, require)) {
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
		
		private static function removeDuplicates(array:Array):Array {
			array.sort();
			
			for (var i:int = array.length-1; i>0; --i) {
				if (array[i]===array[i-1])
					array.splice(i,1);
			}
			return array;
		}
			
		public function Courseware(xml:XML, obeyAllowDeny:Boolean = true) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;
			
			try {
				buttonBGColor = uint("0x" + String(xml.@buttonBGColor).substr(1,6));	// @color like '#FF00FF'
				buttonFGColor = uint("0x" + String(xml.@buttonFGColor).substr(1,6));	// @color like '#FF00FF'
				color = uint("0x" + String(xml.@color).substr(1,6));	// @color like '#FF00FF'
				_copyright = xml.@copyright;
				_debug = xml.@debug == 'true';
				highlightColor = uint("0x" + String(xml.@highlightColor).substr(1,6));	// @color like '#FF00FF'
				_owner = xml.@owner;
				_rootFolder = xml.@rootFolder;
				_timeout = xml.@timeout;
				volume = uint(xml.@volume);
				_website = xml.@website;
				
				if(CONFIG::DEBUG) {
					_debug = true;
					obeyAllowDeny = false;
				}
				
				_obeyAllowDeny = obeyAllowDeny;
				
				
				_user = new User(xml.user[0], this);
				_product = new Product(xml.product[0], this);
				
			} catch ( e:Error ) {
				_successfulInit = false;
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}
			
			ConfigData.buttonBGColor = buttonBGColor;
			ConfigData.buttonFGColor = buttonFGColor;
			ConfigData.color = color;
			ConfigData.website = _website;
			
			var sortToken:uint = 0;
			for each(var c:Course in _product) {
				for each(var item:CoursewareObject in c.flatList)
					item.sortToken = sortToken++;
			}
			
			ConfigData.userID = _user.id;
			
			_currentCourseList = new CourseList();
			_currentCourseList.addEventListener(FolderOpenEvent.FOLDER_OPEN, folderOpenHandler);
			currentCourse = _product.getCourseByID(_user.startCourseID);
			currentPage = _currentCourse.pages[0];			
		}
		

		[Bindable("colorChanged")] public function get buttonBGColor():uint { return _buttonBGColor; }
		public function set buttonBGColor(value:uint):void { 
			_buttonBGColor = value;
			dispatchEvent(new Event("colorChanged"));
		}
		
		[Bindable("colorChanged")] public function get buttonFGColor():uint { return _buttonFGColor; }
		public function set buttonFGColor(value:uint):void { 
			_buttonFGColor = value;
			dispatchEvent(new Event("colorChanged"));
		}
		
		[Bindable("colorChanged")] public function get color():uint { return _color; }
		public function set color(value:uint):void { 
			_color = value;
			dispatchEvent(new Event("colorChanged"));
		}
		
		[Bindable("colorChanged")] public function get highlightColor():uint { return _highlightColor; }
		public function set highlightColor(value:uint):void { 
			_highlightColor = value;
			dispatchEvent(new Event("colorChanged"));
		}
		
		public function get copyright():String { return _copyright; }
		
		[Bindable] public function get currentCourse():Course { return _currentCourse; }
		public function set currentCourse(course:Course):void { 
			if(_currentCourse == course || course == null)
				return;
			_currentCourse = course;
			_currentCourseList.course = course;
			dispatchEvent(new Event("courseChanged"));		
		}
		
		[Bindable("courseChanged")] public function get currentCourseList():CourseList {
			return _currentCourseList;	
		}		
		
		[Bindable("pageSelectionChanged")] public function get currentPage():CoursewareObject { return _currentPage; }
		public function set currentPage(page:CoursewareObject):void {
			if(_currentPage == page || page == null)
				return;
			if(currentCourse != page.parentCourse) currentCourse = page.parentCourse;			// Might be sent to a page via search - need to change courses
			_currentPage = page;
			
			var p:CoursewareObject = page;
			while((p = p.parent) is Folder) 
				Folder(p).open = true;
			
			if(!_user.demo)
				page.visited = true;
			
			
			dispatchEvent(new PageSelectionEvent(page));		
		}
		
		[Bindable("courseChanged")] public function get debug():Boolean { return _debug; }
		public function get owner():String { return _owner; }
		public function get product():Product { return _product; }
		public function get rootFolder():String { return _rootFolder; }
		public function get timeout():int { return _timeout; }
		[Bindable("colorChanged")] public function get user():User { return _user; }
		
		public function get obeyAllowDeny():Boolean { return _obeyAllowDeny; }
		
		[Bindable] public function get volume():uint { return 100 * SoundMixer.soundTransform.volume; }
		public function set volume(val:uint):void {
			SoundMixer.soundTransform = new SoundTransform(val/100);
		}
		
		public function get website():String { return _website; }
		
		
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
			moveSelection(1);
		}
		
		public function prevPage():void {
		 	moveSelection(-1);	
		}
				
		protected function moveSelection(offset:int):void {
			if(!_currentPage || ! _currentPage.parentCourse)
				return;
			var contents:Vector.<CoursewareObject> = _currentPage.parentCourse.flatList;
			var index:int = contents.indexOf(_currentPage) + offset;
			if(index < contents.length && index >= 0)
				currentPage = contents[index];
		}
		
		protected function folderOpenHandler(event:FolderOpenEvent):void {
			if(!_user.autoCloseMenu)
				return;
			closeUnrelatedFolder(_currentCourse.contents, event.folder);			
		}
		
		//Used for auto-closing folders when opening another.
		protected function closeUnrelatedFolder(contents:Vector.<CoursewareObject>, target:Folder):void {
			for each (var content:Object in contents) {
				var folder:Folder = content as Folder;
				if(folder && folder !== target) {
					folder.open = folder.contents.indexOf(target) != -1;
					closeUnrelatedFolder(folder.contents, target);
				}
			}
		}

		public function get successfulInit():Boolean {
			return _successfulInit;
		}

	}	
}