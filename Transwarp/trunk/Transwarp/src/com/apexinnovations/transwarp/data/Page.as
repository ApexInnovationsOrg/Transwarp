package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.utils.*;
	import com.apexinnovations.transwarp.webservices.*;
	
	import flash.errors.*;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.formatters.DateFormatter;
	import mx.resources.ResourceManager;
	
	TranswarpVersion.revision = "$Rev$";
	
	// This represents a page in the course
	public class Page extends EventDispatcher {
		private var _allow:String = '';										// Space separated list of types of user allowed to view this page (e.g. 'LMS Doctor Beta'). '' means all
		private var _audio:String = '';										// name of audio file to load with page, if not the default of 'PAGE_{id}.mp3', or 'false' if no audio
		private var _bookmarked:Boolean = false;							// Has this page been bookmarked by the user?
		private var _config:String = '';								// URL of XML file to be loaded by SWF as configuration
		private var _configType:String = '';
		private var _course:Course = null;									// Which course is this page a part of?
		private var _created:Date;											// XML format: YYYY-MM-DDTHH:MM:SS
		private var _demoMode:Boolean = false;								// Are we in demo mode?
		private var _demo:Boolean = false;									// Is this page viewable on the demo?
		private var _deny:String = '';										// Space separated list of types of user prevented from viewing this page (e.g. 'LMS Doctor Beta'). '' means none
		private var _description:TextFlow = null;							// A brief description of this page, used in search results
		private var _lastUpdate:Date = null;								// When was the last update to this page?
		private var _id:uint = 0;											// Unique PageID from repository/database
		private var _instructions:TextFlow = null;							// Instruction text, as a TextFlow
		private var _keywords:String = '';									// Space separated list of keywords for this page
		private var _links:Vector.<Link> = new Vector.<Link>();				// Vector (array) of related Links
		private var _name:String = '';										// Display name of this page
		private var _parent:Object = null;									// A link back to the parent (folder or course)
		private var _parentFolders:String = '';								// A listing of the parent folders of this page (e.g. "Folder 1 » Folder 2 » Folder 3 »" 
		private var _questions:Vector.<Question> = new Vector.<Question>();	// Vector (array) of related Questions
		private var _sortToken:uint = 0;									// This allows for quick sorting of pages relative to their order in the courseware
		private var _supportText:TextFlow = null;							// Any supporting text, as a TextFlow
		private var _swf:String = '';										// URL of SWF file to load
		private var _timeline:Boolean = false;								// Does this page have a timeline across the bottom to show progress?
		private var _updates:Vector.<Update> = new Vector.<Update>();		// Vector (array) of related Updates
		private var _visited:Boolean = false;								// Has this page been visited by the user?
		private var _weight:uint = 0;										// The 'weight' of the page in a search ranking
		private var _depth:int;												// The depth of this page in the course/folder/page hierarch
		private var _searchFields:Vector.<String> = new Vector.<String>();	// These are the fields that will be searched - composited and converted to strings
		
		public function Page(xml:XML, parent:Object, depth:int, isDemo:Boolean) {
			try {
				_depth = depth;
				_allow = xml.@allow;
				_bookmarked = xml.@bookmarked == 'true';
				_config = xml.@config;
				_configType = xml.@configType;
				_created = DateFormatter.parseDateString(xml.@created);
				_demo = xml.@demo == 'true';
				_deny = xml.@deny;
				_description = (xml.description == undefined ? null : TextConverter.importToFlow(xml.description.children()[0], TextConverter.TEXT_LAYOUT_FORMAT));
				_id = xml.@id;
				_instructions = (xml.instructions == undefined ? null : TextConverter.importToFlow(xml.instructions.children()[0], TextConverter.TEXT_LAYOUT_FORMAT));
				_keywords = xml.keywords;
				_name = xml.@name;
				_parent = parent;
				_supportText = (xml.supportText == undefined ? null : TextConverter.importToFlow(xml.supportText.children()[0], TextConverter.TEXT_LAYOUT_FORMAT));
				_swf = xml.@swf;
				_timeline = xml.@timeline == 'true';
				_visited = xml.@visited == 'true';
				
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}
			
			if(_instructions && Utils.trim(Utils.textFlowToString(_instructions)) == "") {
				_instructions = null;
			}
			
			var fileName:String = 'PAGE_' + Utils.zeroPad(_id, 6);
			
			if(!_swf || _swf == '')
				_swf = fileName + '/' + fileName + '.swf';
			_audio = xml.@audio;
			if(_audio.toLowerCase() == 'false' || _audio.toLowerCase() == "none" || _audio.toLowerCase() == "streamed") {
				_audio = '';
			} else if(!_audio) {
				_audio = fileName + '/' + fileName + '.mp3';
			}
			
			var separator:String = ' ' + ResourceManager.getInstance().getString("Chrome", "FOLDER_SEPARATOR") + ' '; 
			
			var p:* = this;
			while (!((p = p.parent) is Course)) {
				if (p is Folder) _parentFolders = p.name + separator + _parentFolders;
			}
			_course = (p as Course);

			_demoMode = isDemo;
			if (!_demoMode) {
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
			} else {
				if (!_demo) {
					_instructions = null;
					_keywords = null;
					_supportText = null;
					_swf = "PAGE_000000/PAGE_000000.swf";
					_audio = '';
					_timeline = false;
				} 
				_visited = !_demo;
			}
		}
		
		public function allowUser(user:User):Boolean {
			var p:Boolean = true;
			
			var classes:Array = user.classes.split(' ');
			
			if(_allow != "")
				p = hasIntersect(classes, _allow.split(' '));
			
			if(_deny != "")
				p = p && hasIntersect(classes, _deny.split(' '));			
			
			return p;
		}
		
		private function hasIntersect(a1:Array, a2:Array):Boolean {
			for each(var e:String in a1)
				if(a2.indexOf(e) != -1)
					return true;
			return false;
		}
		
		public function get allowBeta():Boolean { return ((_allow == '' || _allow.indexOf('Beta') != -1) && !(_deny.indexOf('Beta') != -1)); }
		public function get allowDoctor():Boolean { return ((_allow == '' || _allow.indexOf('Doctor') != -1) && !(_deny.indexOf('Doctor') != -1)); }
		public function get allowEMT():Boolean { return ((_allow == '' || _allow.indexOf('EMT') != -1) && !(_deny.indexOf('EMT') != -1)); }
		public function get allowLMS():Boolean { return ((_allow == '' || _allow.indexOf('LMS') != -1) && !(_deny.indexOf('LMS') != -1)); }
		public function get allowNurse():Boolean { return ((_allow == '' || _allow.indexOf('Nurse') != -1) && !(_deny.indexOf('Nurse') != -1)); }
		[Bindable] public function get bookmarked():Boolean { return _bookmarked; }
		public function set bookmarked(value:Boolean):void {
			_bookmarked = value;
			
			var bookmark:BookmarkService = new BookmarkService();
			
			bookmark.dispatch(!value);
		}
		
		public function get audio():String { return _audio; }
		public function get config():String { return _config; }
		public function get configType():String { return _configType; }
		public function get course():Course { return _course; }
		public function get created():Date { return _created; }
		public function get demo():Boolean { return _demo; }
		public function get depth():int { return _depth; }
		public function set depth(value:int):void { _depth = value;	}
		public function get description():TextFlow { return _description; }
		[Bindable("pageDataChanged")] public function get id():uint { return _id; }
		[Bindable("pageDataChanged")] public function get instructions():TextFlow { return _instructions; }
		public function get keywords():String { return _keywords; }
		public function get links():Vector.<Link> { return _links; }
		public function get name():String { return _name; }
		public function get parent():Object { return _parent; }
		public function get parentFolders():String { return _parentFolders; }
		public function get qualifiedName():String { return parentFolders + _name; }
		public function get questions():Vector.<Question> { return _questions; }
		public function get sortToken():uint { return _sortToken; }
		public function set sortToken(value:uint):void { _sortToken = value;	}
		[Bindable("pageDataChanged")] public function get supportText():TextFlow { return _supportText; }
		[Bindable("pageDataChanged")] public function get swf():String { return _swf; }
		[Bindable("pageDataChanged")] public function get timeline():Boolean { return _timeline; }
		[Bindable] public function get visited():Boolean { return _visited; }
		public function set visited(val:Boolean):void {
			if (!_demoMode) {
				_visited = val;
				
				var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
				event.source = this;
				event.kind = PropertyChangeEventKind.UPDATE;
				dispatchEvent(event);
				
				if (_visited && _parent is Folder) _parent.updateVisited();
			}			
		}
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
		private function find(needle:RegExp, haystack:String, caseInsensitive:Boolean = true):uint {
			var count:uint = 0;
			var match:Object;
			while((match = needle.exec(haystack)) != null) {
				count++;				
			}
			return count;
		}
		
		// Create a regular expression for matching wildcards
		private function matchWildcards(term:String):RegExp {
			// First, remove RegExp special characters, then replace ? and * with .? and .*
			return new RegExp(term.replace('/([{}\(\)\^$&.\/\+\|\[\\\\]|\]|\-)/g', '').replace(/([\?\*])/g, '.$1'), 'ig');
		}
	}
}