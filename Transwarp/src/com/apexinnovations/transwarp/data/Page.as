package com.apexinnovations.transwarp.data {
	import com.apexinnovations.transwarp.utils.Utils;
	import com.apexinnovations.transwarp.webservices.BookmarkService;
	import com.apexinnovations.transwarp.webservices.CommentService;
	
	import flash.utils.getQualifiedClassName;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.formatters.DateFormatter;
	import mx.resources.ResourceManager;

	public class Page extends CoursewareObject {
		
		protected var _config:String = '';										// URL of XML file to be loaded by SWF as configuration
		protected var _configType:String = '';
		protected var _created:Date;											// XML format: YYYY-MM-DDTHH:MM:SS
		protected var _description:TextFlow = null;								// A brief description of this page, used in search results
		protected var _lastUpdate:Date = null;									// When was the last update to this page?
		protected var _instructions:TextFlow = null;							// Instruction text, as a TextFlow
		protected var _keywords:String = '';									// Space separated list of keywords for this page
		protected var _links:Vector.<Link> = new Vector.<Link>();				// Vector (array) of related Links
		protected var _questions:Vector.<Question> = new Vector.<Question>();	// Vector (array) of related Questions
		protected var _supportText:TextFlow = null;								// Any supporting text, as a TextFlow
		protected var _swf:String = '';											// URL of SWF file to load
		protected var _timeline:Boolean = false;								// Does this page have a timeline across the bottom to show progress?
		protected var _updates:Vector.<Update> = new Vector.<Update>();			// Vector (array) of related Updates
		protected var _weight:uint = 0;											// The 'weight' of the page in a search ranking
		protected var _searchFields:Vector.<String> = new Vector.<String>();	// These are the fields that will be searched - composited and converted to strings
		
		
		public function Page(xml:XML, parent:CoursewareObjectContainer, depth:int) {
			super(xml, parent, depth);
			
			try {
				_config = xml.@config;
				_configType = xml.@configType;
				_created = DateFormatter.parseDateString(xml.@created);
				_demo = xml.@demo == 'true';
				_description = Utils.importTextFlow(xml.description.children()[0]);
				_instructions = Utils.importTextFlow(xml.instructions.children()[0]);
				_keywords = xml.keywords;
				_supportText = Utils.importTextFlow(xml.supportText.children()[0]);
				_swf = xml.@swf;
				_timeline = xml.@timeline == 'true';
							
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName((this) + ': Bad Initialization XML:  [' + e.message + ']'));
			}
		
			var fileName:String = "PAGE_" + Utils.zeroPad(_id, 6);
			
			if(!_swf || _swf == '') {
				_swf = fileName + "/" + fileName + ".swf";
			}	
			
			for each (var l:XML in xml.links.link) {
				_links.push(new Link(l, this));
			}
			for each (var q:XML in xml.questions.question) {
				_questions.push(new Question(q, this));
			}
			var tmp:Update;
			for each (var u:XML in xml.updates.update) {
				tmp = new Update(u, this);
				if (Utils.trim(Utils.textFlowToString(tmp.textFlow)) != "") {
					_updates.push(tmp);
					if (tmp.time > _lastUpdate) _lastUpdate = tmp.time;
				}
			}
			
			// Initialize text search fields for faster searching later
			_searchFields[0] = qualifiedName;
			_searchFields[1] = _keywords;
			_searchFields[2] = Utils.textFlowToString(_description);
			_searchFields[3] = Utils.textFlowToString(_supportText);
			_searchFields[4] = Utils.textFlowToString(_instructions);
			_searchFields[5] = '';
			for each (var lnk:Link in _links) {
				if (lnk.textFlow)	_searchFields[5] += Utils.textFlowToString(lnk.textFlow);
			}
			_searchFields[6] = '';
			_searchFields[7] = '';
			for each (var qstn:Question in _questions) {
				if (qstn.qTextFlow)	_searchFields[6] += Utils.textFlowToString(qstn.qTextFlow);
				if (qstn.aTextFlow)	_searchFields[7] += Utils.textFlowToString(qstn.aTextFlow);
			}
			_searchFields[8] = '';
			for each (var upd:Update in _updates) {
				if (upd.textFlow && (Courseware.instance.debug || !upd.hidden)) _searchFields[8] += Utils.textFlowToString(upd.textFlow);
			}
			
			var demoUser:Boolean = _parentCourseware.user.demo
			
			if(_restricted || (demoUser && !_demo)) {
				_audio = '';
				_description = null;
				_supportText = null;
				_instructions = null;
				_timeline = false;
				
				if(demoUser) {
					_visited = !_demo;
					_swf = "PAGE_000000/PAGE_000000.swf";
				} else if(_restricted) {
					_swf = "PAGE_000001/PAGE_000001.swf";
				}
			}				
					 			
		}
		
		public function get config():String { return _config; }
		public function get configType():String { return _configType; }
		public function get created():Date { return _created; }
		public function get description():TextFlow { return _description; }
		[Bindable("pageDataChanged")] public function get instructions():TextFlow { return _instructions; }
		public function get keywords():String { return _keywords; }
		public function get links():Vector.<Link> { return _links; }
		public function get questions():Vector.<Question> { return _questions; }
		[Bindable("pageDataChanged")] public function get supportText():TextFlow { return _supportText; }
		[Bindable("pageDataChanged")] public function get swf():String { return _swf; }
		[Bindable("pageDataChanged")] public function get timeline():Boolean { return _timeline; }
		public function get updates():Vector.<Update> { return _updates; }
		public function get weight():uint { return _weight; }
		
		[Bindable("pageDataChanged")] public function get hasQuestions():Boolean { return _questions.length > 0; }
		[Bindable("pageDataChanged")] public function get hasSupportText():Boolean { return _supportText !== null; }
		[Bindable("pageDataChanged")] public function get hasLinks():Boolean { return _links.length > 0; }
		[Bindable("pageDataChanged")] public function get hasUpdates():Boolean { return _lastUpdate > Courseware.instance.user.lastAccess; }
		
		// Does everything associated with commenting on this page 
		public function comment(s:String):void {
			var comment:CommentService = new CommentService();
			comment.dispatch(s);
		}
		
		// Searches the page for keywords, stores and returns a weight
		public function search(terms:Array, exclude:Array, require:Array):uint {			
			var i:int, j:int;
			var found:Boolean = false;
			var needle:RegExp;
			
			// Initialized on each search
			_weight = 0;
			
			// First, see if we have all required terms
			for (i = 0; i < require.length; i++) {
				found = false;
				for (j = 0; j < 9; j++) {
					if (find(matchWildcards(require[i]), _searchFields[j])) {
						found = true;
						break;
					}
				}
				if (!found) break;
			}
			if (require.length && !found) return 0;
			
			// Next make sure we don't have any excluded terms
			for (i = 0; i < exclude.length; i++) {
				found = false;
				for (j = 0; j < 9; j++) {
					if (find(matchWildcards(exclude[i]), _searchFields[j])) {
						found = true;
						break;
					}
				}
				if (found) break;
			}
			if (exclude.length) {
				if (found) {
					return 0;
				} else {
					_weight += 1;	// Just in case all we have is an exclude list
				}
			}
			
			// Now weight the page
			for each (var term:String in terms) {
				if(Courseware.instance.debug && _id == uint(term))
					_weight += 100;
				needle = matchWildcards(term);
				_weight += find(needle, _searchFields[0]) * 5;	// qualifiedName
				_weight += find(needle, _searchFields[1]) * 3;	// keywords
				_weight += find(needle, _searchFields[2]) * 4;	// description
				_weight += find(needle, _searchFields[3]) * 2;	// support text
				_weight += find(needle, _searchFields[4]) * 1;	// instructions
				_weight += find(needle, _searchFields[5]) * 2;	// links
				_weight += find(needle, _searchFields[6]) * 1;	// questions
				_weight += find(needle, _searchFields[7]) * 2;	// answers
				_weight += find(needle, _searchFields[8]) * 1;	// updates
			}
			
			for each (term in require) {
				needle = matchWildcards(term);
				_weight += find(needle, _searchFields[0]) * 5;	// qualifiedName
				_weight += find(needle, _searchFields[1]) * 3;	// keywords
				_weight += find(needle, _searchFields[2]) * 4;	// description
				_weight += find(needle, _searchFields[3]) * 2;	// support text
				_weight += find(needle, _searchFields[4]) * 1;	// instructions
				_weight += find(needle, _searchFields[5]) * 2;	// links
				_weight += find(needle, _searchFields[6]) * 1;	// questions
				_weight += find(needle, _searchFields[7]) * 2;	// answers
				_weight += find(needle, _searchFields[8]) * 1;	// updates
			}
			
			return _weight;
		}		
		
		// Counts the number of occurrences of needle in haystack
		protected function find(needle:RegExp, haystack:String, caseInsensitive:Boolean = true):uint {
			var count:uint = 0;
			var match:Object;
			while((match = needle.exec(haystack)) != null) {
				count++;				
			}
			return count;
		}
		
		// Create a regular expression for matching wildcards
		protected function matchWildcards(term:String):RegExp {
			// First, remove RegExp special characters, then replace ? and * with .? and .*
			return new RegExp(term.replace('/([{}\(\)\^$&.\/\+\|\[\\\\]|\]|\-)/g', '').replace(/([\?\*])/g, '.$1'), 'ig');
		}
	}
}