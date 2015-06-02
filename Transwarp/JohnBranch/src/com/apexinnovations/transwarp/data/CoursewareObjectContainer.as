package com.apexinnovations.transwarp.data {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class CoursewareObjectContainer extends CoursewareObject {
		
		protected var _contents:Vector.<CoursewareObject>;
		protected var _pages:Vector.<Page>;		
		
		protected var _viewableContents:Array;
		protected var viewableDirty:Boolean = true;
		
		protected var visitedDirty:Boolean = true;
		
		public function CoursewareObjectContainer(xml:XML, parent:CoursewareObjectContainer, depth:int, children:XMLList = null) {
			super(xml, parent, depth);
			
			_contents = new Vector.<CoursewareObject>();
			_pages = new Vector.<Page>();
			
			if(!children)
				children = xml.children();
			
			var user:User = parentCourseware.user;
			
			for each(var child:XML in children) {
				var obj:CoursewareObject = createChild(child);
				
				if(obj && obj.allowUser(user)) {
					_contents.push(obj);
					obj.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChangeHandler);
					
					if(obj is CoursewareObjectContainer) {
						var container:CoursewareObjectContainer = CoursewareObjectContainer(obj);
						//_contents = _contents.concat(container._contents);
						_pages = _pages.concat(container.pages);
					} else if(obj is Page) {
						_pages.push(obj);
					}
				}
			}
			
			calculateVisited();
		}
		
		public function get pages():Vector.<Page> { return _pages; }
		public function get contents():Vector.<CoursewareObject> { return _contents; }
		public function get viewableContents():Array {
			if(viewableDirty)
				calculateViewable();
			return _viewableContents;
		}
		
		public function getPageByID(pageID:uint):Page {
			for each(var p:Page in pages) {
				if(p.id == pageID)
					return p;
			}
			return null;
		}
		
		protected function propertyChangeHandler(event:PropertyChangeEvent):void {
			var evt:PropertyChangeEvent;
			var property:String;
			
			if(event.property == "viewableContents" || event.property == "open") {
				viewableDirty = true;
				property = "viewableContents";
			} else if(event.property == "visited" && calculateVisited()) {
				property = "visited";
			}
			
			if(property) {
				evt = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
				evt.kind = PropertyChangeEventKind.UPDATE;
				evt.source = this;
				evt.property = property;
				dispatchEvent(evt);
			}
				
		}
		
		//Override in subclasses
		protected function createChild(node:XML):CoursewareObject {
			return null;
		}		
		
		protected function calculateViewable():void {
			_viewableContents = [];
			
			for each(var item:CoursewareObject in _contents) {
				_viewableContents.push(item);
				if(item is Folder) {
					if(Folder(item).open) 
						_viewableContents = _viewableContents.concat(Folder(item).viewableContents);
				} else if(item is CoursewareObjectContainer) {
					_viewableContents = _viewableContents.concat(CoursewareObjectContainer(item).viewableContents);
				}
			}
			viewableDirty = false;
		}
		
		protected function calculateVisited():Boolean { //Returns true if the value changed
			var value:Boolean = _visited;
			_visited = true;
			var i:int = 0;
			while(i < _contents.length && _visited) {
				var child:CoursewareObject = _contents[i++];
				_visited = child.visited && _visited;
			}
			
			return value !== visited;
		}		
		
	}
}