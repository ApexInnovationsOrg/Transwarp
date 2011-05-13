package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.utils.*;
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.webservices.*;
	
	import flash.errors.*;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.formatters.DateFormatter;
	
	TranswarpVersion.revision = "$Rev$";
	
	// This represents a page in the course
	public class Page extends EventDispatcher {
		private var _allow:String = '';										// Space separated list of types of user allowed to view this page (e.g. 'LMS Doctor Beta'). '' means all
		private var _bookmarked:Boolean = false;							// Has this page been bookmarked by the user?
		private var _configuration:String = '';								// URL of XML file to be loaded by SWF as configuration
		private var _course:Course = null;									// Which course is this page a part of?
		private var _created:Date;											// XML format: YYYY-MM-DDTHH:MM:SS
		private var _demo:Boolean = false;									// Is this page viewable on the demo?
		private var _deny:String = '';										// Space separated list of types of user prevented from viewing this page (e.g. 'LMS Doctor Beta'). '' means none
		private var _id:uint = 0;											// Unique PageID from repository/database
		private var _instructions:TextFlow = null;							// Instruction text, as a TextFlow
		private var _keywords:String = '';									// Space separated list of keywords for this page
		private var _links:Vector.<Link> = new Vector.<Link>();				// Vector (array) of related Links
		private var _name:String = '';										// Display name of this page
		private var _parent:Object = null;									// A link back to the parent (folder or course)
		private var _parentFolders:String = '';								// A listing of the parent folders of this page (e.g. "Folder 1 » Folder 2 » Folder 3 »" 
		private var _questions:Vector.<Question> = new Vector.<Question>();	// Vector (array) of related Questions
		private var _searchSnippet:String = '';								// A snippet of text describing that last search's results
		private var _supportText:TextFlow = null;							// Any supporting text, as a TextFlow
		private var _swf:String = '';										// URL of SWF file to load
		private var _timeline:Boolean = false;								// Does this page have a timeline across the bottom to show progress?
		private var _updates:Vector.<Update> = new Vector.<Update>();		// Vector (array) of related Updates
		private var _visited:Boolean = false;								// Has this page been visited by the user?
		private var _weight:uint = 0;										// The 'weight' of the page in a search ranking
		private var _depth:int;
		
		public function Page(xml:XML, parent:Object, depth:int) {
			try {
				_depth = depth;
				_allow = xml.@allow;
				_bookmarked = xml.@bookmarked == 'true';
				_configuration = xml.@configuration;
				_created = DateFormatter.parseDateString(xml.@created);
				_deny = xml.@deny;
				_id = xml.@id;
				_instructions = (xml.instructions == undefined ? null : TextConverter.importToFlow(xml.instructions.children()[0], TextConverter.TEXT_LAYOUT_FORMAT));
				_keywords = xml.@keywords;
				_name = xml.@name;
				_parent = parent;
				_supportText = (xml.supportText == undefined ? null : TextConverter.importToFlow(xml.supportText.children()[0], TextConverter.TEXT_LAYOUT_FORMAT));
				_swf = xml.@swf;
				if(!_swf || _swf == '')
					_swf = 'PAGE_' + Utils.zeroPad(_id, 6) + '.swf';
				
				
				_timeline = xml.@timeline;
				_visited = xml.@visited == 'true';
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}
			var p:* = this;
			while (!((p = p.parent) is Course)) {
				if (p is Folder) _parentFolders = p.name + ' » ' + _parentFolders;
			}
			_course = (p as Course);

			for each (var l:XML in xml.links.link) {
				_links.push(new Link(l, this));
			}
			for each (var q:XML in xml.questions.question) {
				_questions.push(new Question(q, this));
			}
			for each (var u:XML in xml.updates.update) {
				_updates.push(new Update(u, this));
			}
		}
		
		public function get allowBeta():Boolean { return ((_allow == '' || _allow.indexOf('Beta') != -1) && !(_deny.indexOf('Beta') != -1)); }
		public function get allowDoctor():Boolean { return ((_allow == '' || _allow.indexOf('Doctor') != -1) && !(_deny.indexOf('Doctor') != -1)); }
		public function get allowEMT():Boolean { return ((_allow == '' || _allow.indexOf('EMT') != -1) && !(_deny.indexOf('EMT') != -1)); }
		public function get allowLMS():Boolean { return ((_allow == '' || _allow.indexOf('LMS') != -1) && !(_deny.indexOf('LMS') != -1)); }
		public function get allowNurse():Boolean { return ((_allow == '' || _allow.indexOf('Nurse') != -1) && !(_deny.indexOf('Nurse') != -1)); }
		public function get bookmarked():Boolean { return _bookmarked; }
		public function get configuration():String { return _configuration; }
		public function get course():Course { return _course; }
		public function get created():Date { return _created; }
		public function get demo():Boolean { return _demo; }
		public function get depth():int { return _depth; }
		public function set depth(value:int):void { _depth = value;	}
		public function get id():uint { return _id; }
		public function get instructions():TextFlow { return _instructions; }
		public function get keywords():String { return _keywords; }
		public function get links():Vector.<Link> { return _links; }
		public function get name():String { return _name; }
		public function get parent():Object { return _parent; }
		public function get parentFolders():String { return _parentFolders; }
		public function get qualifiedName():String { return parentFolders + _name; }
		public function get questions():Vector.<Question> { return _questions; }
		public function get searchSnippet():String { return _searchSnippet; }
		public function get supportText():TextFlow { return _supportText; }
		public function get swf():String { return _swf; }
		public function get timeline():Boolean { return _timeline; }
		[Bindable] public function get visited():Boolean { return _visited; }
		public function set visited(val:Boolean):void {
			_visited = val;
			
			var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			event.source = this;
			event.kind = PropertyChangeEventKind.UPDATE;
			dispatchEvent(event);
			
			if (_visited && _parent is Folder) _parent.updateVisited();
		}
		public function get updates():Vector.<Update> { return _updates; }
		public function get weight():uint { return _weight; }

		[Bindable("pageDataChanged")] public function get hasQuestions():Boolean { return _questions.length > 0; }
		[Bindable("pageDataChanged")] public function get hasSupportText():Boolean { return _supportText !== null; }
		[Bindable("pageDataChanged")] public function get hasLinks():Boolean { return _links.length > 0; }
		[Bindable("pageDataChanged")] public function get hasUpdates():Boolean { return _updates.length > 0; }
				
		// Does everything associated with bookmarking this page 
		public function bookmark():void {
			this._bookmarked = true;
			
			var bookmark:BookmarkService = new BookmarkService();
			
			bookmark.dispatch();
		}
		
		// Does everything associated with commenting on this page 
		public function comment(s:String):void {
			var comment:CommentService = new CommentService();
			comment.dispatch(s);
		}
		
		// Searches the page for keywords, stores and returns a weight
		public function search(s:String):uint {
			var keywords:Array = s.split(' ');
			
			// Initialized on each search
			_searchSnippet = qualifiedName + ' ' + _keywords + ' ' + (_supportText ? Utils.textFlowToString(_supportText) : '');
			_searchSnippet = '...' + _searchSnippet.substring(25, 225) + '...';
			_weight = 0;
			
			for each (var word:String in keywords) {
				_weight += find(word, qualifiedName) * 5;
				_weight += find(word, _keywords) * 2;
							
				if (_supportText)	_weight += find(word, Utils.textFlowToString(_supportText)) * 3;
				if (_instructions)	_weight += find(word, Utils.textFlowToString(_instructions)) * 1;

				for each (var l:Link in _links) {
					if (l.textFlow)		_weight += find(word, Utils.textFlowToString(l.textFlow)) * 2;
				}
				for each (var q:Question in _questions) {
					if (q.qTextFlow)	_weight += find(word, Utils.textFlowToString(q.qTextFlow)) * 1;
					if (q.aTextFlow)	_weight += find(word, Utils.textFlowToString(q.aTextFlow)) * 2;
				}
				for each (var u:Update in _updates) {
					if (u.textFlow)	_weight += find(word, Utils.textFlowToString(u.textFlow)) * 1;
				}
			}

			return _weight;
		}
		
		
		// Counts the number of occurrences of needle in haystack
		private function find(needle:String, haystack:String, caseInsensitive:Boolean = true):uint {
			var i:int = -1, c:uint = 0;
			if ( caseInsensitive ) {
				needle = needle.toLowerCase();
				haystack = haystack.toLowerCase();
			}
			do {
				i = haystack.indexOf(needle, i + 1);
				if (i != -1) c++;
			} while(i != -1);
			return c;
		}
	}
}