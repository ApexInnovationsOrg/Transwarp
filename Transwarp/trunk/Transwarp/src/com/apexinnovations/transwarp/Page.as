package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import flash.utils.*;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import mx.formatters.DateFormatter;
	
	// This represents a page in the course
	public class Page {
		private var _allow:String = '';				// Space separated list of types of user allowed to view this page (e.g. 'LMS Doctor Beta'). '' means all
		private var _bookmarked:Boolean = false;	// Has this page been bookmarked by the user?
		private var _configuration:String = '';		// URL of XML file to be loaded by SWF as configuration
		private var _created:Date;					// XML format: YYYY-MM-DDTHH:MM:SS
		private var _demo:Boolean = false;			// Is this page viewable on the demo?
		private var _deny:String = '';				// Space separated list of types of user prevented from viewing this page (e.g. 'LMS Doctor Beta'). '' means none
		private var _id:uint = 0;					// Unique PageID from repository/database
		private var _instructions:TextFlow = null;	// Instruction text, as a TextFlow
		private var _keywords:String = '';			// Space separated list of keywords for this page
		private var _name:String = '';				// Display name of this page
		private var _supportText:TextFlow = null;	// Any supporting text, as a TextFlow
		private var _swf:String = '';				// URL of SWF file to load
		private var _timeline:Boolean = false;		// Does this page have a timeline across the bottom to show progress?
		private var _visited:Boolean = false;		// Has this page been visited by the user?

		private var _links:Vector.<Link> = new Vector.<Link>();				// Vector (array) of related Links
		private var _questions:Vector.<Question> = new Vector.<Question>();	// Vector (array) of related Questions
		private var _updates:Vector.<Update> = new Vector.<Update>();		// Vector (array) of related Updates

		public function Page(xml:XML) {
			try {
				_allow = xml.@allow;
				_bookmarked = xml.@bookmarked;
				_configuration = xml.@configuration;
				_created = DateFormatter.parseDateString(xml.@created);
				_deny = xml.@deny;
				_allow = xml.@allow;
				_id = xml.@id;
				_instructions = TextConverter.importToFlow(xml.instructions[0], TextConverter.TEXT_LAYOUT_FORMAT);
				_keywords = xml.@keywords;
				_name = xml.@name;
				_supportText = TextConverter.importToFlow(xml.supportText[0], TextConverter.TEXT_LAYOUT_FORMAT);
				_swf = xml.@swf;
				_timeline = xml.@timeline;
				_visited = xml.@visited;

				for each (var l:XML in xml.links.link) {
					_links[_links.length] = new Link(l);
				}
				for each (var q:XML in xml.questions.question) {
					_questions[_questions.length] = new Question(q);
				}
				for each (var u:XML in xml.updates.update) {
					_updates[_updates.length] = new Update(u);
				}
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get allowBeta():Boolean { return ((_allow == '' || _allow.indexOf('Beta') > 0) && !(_deny.indexOf('Beta') > 0)); }
		public function get allowDoctor():Boolean { return ((_allow == '' || _allow.indexOf('Doctor') > 0) && !(_deny.indexOf('Doctor') > 0)); }
		public function get allowEMT():Boolean { return ((_allow == '' || _allow.indexOf('EMT') > 0) && !(_deny.indexOf('EMT') > 0)); }
		public function get allowLMS():Boolean { return ((_allow == '' || _allow.indexOf('LMS') > 0) && !(_deny.indexOf('LMS') > 0)); }
		public function get allowNurse():Boolean { return ((_allow == '' || _allow.indexOf('Nurse') > 0) && !(_deny.indexOf('Nurse') > 0)); }
		public function get bookmarked():Boolean { return _bookmarked; }
		public function get configuration():String { return _configuration; }
		public function get created():Date { return _created; }
		public function get demo():Boolean { return _demo; }
		public function get id():uint { return _id; }
		public function get instructions():TextFlow { return _instructions; }
		public function get keywords():String { return _keywords; }
		public function get name():String { return _name; }
		public function get supportText():TextFlow { return _supportText; }
		public function get swf():String { return _swf; }
		public function get timeline():Boolean { return _timeline; }
		public function get visited():Boolean { return _visited; }

		public function get links():Vector.<Link> { return _links; }
		public function get questions():Vector.<Question> { return _questions; }
		public function get updates():Vector.<Update> { return _updates; }
		
		// Does everything associated with bookmarking this page 
		public function bookmark():void {
			this._bookmarked = true;
			
			// NEEDS WORK - log the bookmark, highlight the menu item
		}
		
		// Does everything associated with commenting on this page 
		public function comment(s:String):void {
			// NEEDS WORK - log the comment
		}
		
		// Searches the page for keywords, returns a weight
		public function search(s:String):uint {
			// NEEDS WORK - needs to search other fields, return a weight
			var keywords:Array = s.split(' ');
			for each (var word:String in keywords) {
				if (_keywords.indexOf(word) > 0) {
					return 1;	
				} else if (false) {
					// Need processing here for finding keywords in updates, links, questions, supportText, instructions
				}
			}
			return 0;
		}
		
		// Does everything associated with visiting this page
		public function visit():void {
			this._visited = true;
			
			Courseware.instance.currentPage = this;
			
			// NEEDS WORK - log the page visit, load the SWF, unbold the menu item, etc.
		}
	}
}