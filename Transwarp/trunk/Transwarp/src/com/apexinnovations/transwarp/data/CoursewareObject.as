package com.apexinnovations.transwarp.data {
	import com.apexinnovations.transwarp.utils.HashSet;
	import com.apexinnovations.transwarp.utils.ISet;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.webservices.BookmarkService;
	
	import flash.events.EventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.getQualifiedClassName;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.resources.ResourceManager;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class CoursewareObject extends EventDispatcher {
		
		protected var _id:uint;
		protected var _name:String;
		protected var _parent:CoursewareObjectContainer;
		protected var _parentCourseware:Courseware;
		protected var _parentCourse:Course;
		protected var _depth:int;
		protected var _visited:Boolean;
		protected var _restricted:Boolean;
		protected var _allow:ISet;
		protected var _deny:ISet;
		protected var _demo:Boolean;
		protected var _breadcrumbs:String = '';								// A listing of the parent folders of this page (e.g. "Folder 1 » Folder 2 » Folder 3 »")
		protected var _bookmarked:Boolean;
		protected var _sortToken:uint = 0;									// This allows for quick sorting of pages relative to their order in the courseware
		
		public function CoursewareObject(xml:XML, parent:CoursewareObjectContainer, depth:int) {
			super();
			_parent = parent;
			if(parent) {
				_parentCourseware = parent.parentCourseware;
				_parentCourse = parent.parentCourse;
			}
			
			if(parent is Course)
				_parentCourse = Course(parent);
			
			_depth = depth;
			
			try {
				_id = xml.@id;
				_name = xml.@name;
				_visited = xml.@visited == "true";
				_restricted = (parent ? parent.restricted : false) || xml.@restricted == "true";
				_demo = xml.@demo == "true";
				_allow = (String(xml.@allow) != "") ? new HashSet(String(xml.@allow).toLowerCase().split(' ')) : null;
				_deny = (String(xml.@deny) != "") ? new HashSet(String(xml.@deny).toLowerCase().split(' ')) : null;
				_bookmarked = xml.@bookmarked == "true";
			} catch(e:Error) {
				throw new ArgumentError(getQualifiedClassName(this) + ": Bad Initialization XML: [" + e.message + ']');
			}
			
			var separator:String = ' ' + ResourceManager.getInstance().getString("Chrome", "FOLDER_SEPARATOR") + ' '; 
			
			if(_parent && !(_parent is Course))
				_breadcrumbs = _parent.qualifiedName + separator;
		}
		
		public function get parentCourse():Course { return _parentCourse; }
		public function get parent():CoursewareObjectContainer { return _parent; }
		[Bindable("coursewareObjectChanged")] public function get id():uint { return _id; }
		public function get depth():int { return _depth }
		[Bindable("coursewareObjectChanged")] public function get name():String { return _name; }
		public function get parentCourseware():Courseware { return _parentCourseware; }
		public function get restricted():Boolean { return _restricted; }
		public function get demo():Boolean { return _demo; }
		public function get allow():ISet { return _allow; }
		public function get deny():ISet { return _deny; }
		public function get breadcrumbs():String { return _breadcrumbs; }
		public function get qualifiedName():String { return _breadcrumbs + _name; }
		public function get visited():Boolean { return _visited; }
		
		public function get sortToken():uint { return _sortToken; }
		public function set sortToken(value:uint):void { _sortToken = value; }
		
		public function set visited(value:Boolean):void {
			if(_visited == value)
				return;
			
			var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			event.source = this;
			event.property = "visited";
			event.oldValue = _visited;
			event.newValue = value;
			event.kind = PropertyChangeEventKind.UPDATE;
			
			_visited = value;
			dispatchEvent(event);
		}
		
		[Bindable] public function get bookmarked():Boolean { return _bookmarked; }
		public function set bookmarked(value:Boolean):void {
			_bookmarked = value;
			
			var bookmark:BookmarkService = new BookmarkService();
			
			bookmark.dispatch(_id, !value);
		}
		
		public function allowUser(user:User):Boolean {
			var p:Boolean = true;
			if(_allow && _allow.size > 0)
				p = _allow.hasIntersect(user.classes);
			
			if(_deny && _deny.size > 0 && p)
				p = p && !_deny.hasIntersect(user.classes);
			
			return p;
		}

	}
}