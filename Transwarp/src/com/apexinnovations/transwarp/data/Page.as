package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.webservices.*;
	
	import flash.errors.*;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.formatters.DateFormatter;
	
	// This represents a page in the course
	public class Page {
		private var _allow:String = '';										// Space separated list of types of user allowed to view this page (e.g. 'LMS Doctor Beta'). '' means all
		private var _bookmarked:Boolean = false;							// Has this page been bookmarked by the user?
		private var _configuration:String = '';								// URL of XML file to be loaded by SWF as configuration
		private var _created:Date;											// XML format: YYYY-MM-DDTHH:MM:SS
		private var _demo:Boolean = false;									// Is this page viewable on the demo?
		private var _deny:String = '';										// Space separated list of types of user prevented from viewing this page (e.g. 'LMS Doctor Beta'). '' means none
		private var _id:uint = 0;											// Unique PageID from repository/database
		private var _instructions:TextFlow = null;							// Instruction text, as a TextFlow
		private var _keywords:String = '';									// Space separated list of keywords for this page
		private var _links:Vector.<Link> = new Vector.<Link>();				// Vector (array) of related Links
		private var _name:String = '';										// Display name of this page
		private var _parent:Object = null;									// A link back to the parent (folder or course)
		private var _questions:Vector.<Question> = new Vector.<Question>();	// Vector (array) of related Questions
		private var _supportText:TextFlow = null;							// Any supporting text, as a TextFlow
		private var _swf:String = '';										// URL of SWF file to load
		private var _timeline:Boolean = false;								// Does this page have a timeline across the bottom to show progress?
		private var _updates:Vector.<Update> = new Vector.<Update>();		// Vector (array) of related Updates
		private var _visited:Boolean = false;								// Has this page been visited by the user?
		private var _weight:uint = 0;										// The 'weight' of the page in a search ranking

		public function Page(xml:XML, parent:Object) {
			try {
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
				_timeline = xml.@timeline;
				_visited = xml.@visited == 'true';
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}

			for each (var l:XML in xml.links.link) {
				_links[_links.length] = new Link(l, this);
			}
			for each (var q:XML in xml.questions.question) {
				_questions[_questions.length] = new Question(q, this);
			}
			for each (var u:XML in xml.updates.update) {
				_updates[_updates.length] = new Update(u, this);
			}
		}
		
		public function get allowBeta():Boolean { return ((_allow == '' || _allow.indexOf('Beta') != -1) && !(_deny.indexOf('Beta') != -1)); }
		public function get allowDoctor():Boolean { return ((_allow == '' || _allow.indexOf('Doctor') != -1) && !(_deny.indexOf('Doctor') != -1)); }
		public function get allowEMT():Boolean { return ((_allow == '' || _allow.indexOf('EMT') != -1) && !(_deny.indexOf('EMT') != -1)); }
		public function get allowLMS():Boolean { return ((_allow == '' || _allow.indexOf('LMS') != -1) && !(_deny.indexOf('LMS') != -1)); }
		public function get allowNurse():Boolean { return ((_allow == '' || _allow.indexOf('Nurse') != -1) && !(_deny.indexOf('Nurse') != -1)); }
		public function get bookmarked():Boolean { return _bookmarked; }
		public function get configuration():String { return _configuration; }
		public function get created():Date { return _created; }
		public function get demo():Boolean { return _demo; }
		public function get id():uint { return _id; }
		public function get instructions():TextFlow { return _instructions; }
		public function get keywords():String { return _keywords; }
		public function get links():Vector.<Link> { return _links; }
		public function get name():String { return _name; }
		public function get parent():Object { return _parent; }
		public function get qualifiedName():String {
			var p:* = this, qName:String = _name;
			while (!((p = p.parent) is Course)) { qName = p.name + ' : ' + qName; }
			return qName;
		}
		public function get questions():Vector.<Question> { return _questions; }
		public function get supportText():TextFlow { return _supportText; }
		public function get swf():String { return _swf; }
		public function get timeline():Boolean { return _timeline; }
		public function get visited():Boolean { return _visited; }
		public function set visited(val:Boolean):void { _visited = val; }
		public function get updates():Vector.<Update> { return _updates; }
		public function get weight():uint { return _weight; }

		// Does everything associated with bookmarking this page 
		public function bookmark():void {
			this._bookmarked = true;
			
			var bookmark:BookmarkService = new BookmarkService();
			
			this.initAWS();
			
			bookmark.dispatch();
		}
		
		// Does everything associated with commenting on this page 
		public function comment(s:String):void {
			var comment:CommentService = new CommentService();
			
			this.initAWS();

			comment.dispatch(s);
		}
		
		// Searches the page for keywords, stores and returns a weight
		public function search(s:String):uint {
			var keywords:Array = s.split(' ');
			_weight = 0;	// Initialized on each search
			for each (var word:String in keywords) {
				_weight += this.find(word, _name) * 5;
				_weight += this.find(word, _keywords) * 2;
							
				if (_supportText)	_weight += this.find(word, this.TFtoStr(_supportText)) * 3;
				if (_instructions)	_weight += this.find(word, this.TFtoStr(_instructions)) * 1;

				for each (var l:Link in _links) {
					if (l.textFlow)		_weight += this.find(word, this.TFtoStr(l.textFlow)) * 2;
				}
				for each (var q:Question in _questions) {
					if (q.qTextFlow)	_weight += this.find(word, this.TFtoStr(q.qTextFlow)) * 1;
					if (q.aTextFlow)	_weight += this.find(word, this.TFtoStr(q.aTextFlow)) * 2;
				}
				for each (var u:Update in _updates) {
					if (u.textFlow)	_weight += this.find(word, this.TFtoStr(u.textFlow)) * 1;
				}
			}
			//trace('   Page: ' + _id + ' (' + _name  + '): search weight = ' + _weight);
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
		
		// Makes sure the ApexWebService is initialized
		private function initAWS():void {
			var cw:Courseware = Courseware.instance;
			
			ApexWebService.userID = cw.user.id;
			ApexWebService.courseID = cw.currentCourse.id;
			ApexWebService.pageID = this._id;
		}
		
		// Converts a TextFlow into a String
		private function TFtoStr(tf:TextFlow):String {
			if (tf == null) return '';
			var tfx:XML = XML(TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE));
			var s:String = '';
			for each (var x:XML in tfx..*.text()) {
				s += x + ' ';
			}
			return s.substr(0, s.length - 1).replace(/  /g, ' '); // remove double spaces and trailing space
		}
		
	}
}