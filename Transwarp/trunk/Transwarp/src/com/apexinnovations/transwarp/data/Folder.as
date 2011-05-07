package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Page;
	
	import flash.errors.*;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	// This represents a folder of pages and subfolders (of pages)
	public class Folder extends EventDispatcher {
		private var _contents:Array = [];						// An ordered collection of the contents of this folder (pages and other folders)
		private var _depth:int;									// The depth at which this folder resides in the course hierarchy
		private var _name:String = '';							// The name of this folder
		private var _open:Boolean = false;						// Is this folder open (contents are visible in the menu)?
		private var _pages:Vector.<Page> = new Vector.<Page>();	// An ordered collection of pages of this course
		private var _parent:Object = null;						// A link back to the parent (folder or course)
		private var _visited:Boolean = false;					// Is everything in this folder visited
		
		
		public function Folder(xml:XML, parent:Object, depth:int) {
			try {
				_depth = depth;
				_name = xml.@name;
				_parent = parent;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}

			for each (var child:XML in xml.children()) {
				if (child.localName() == "page") {
					var p:Page = new Page(child, this, _depth + 1);
					_contents.push(p);
					_pages.push(p);
				} else {
					var f:Folder = new Folder(child, this, _depth + 1);
					_contents.push(f);
					_pages = _pages.concat(f.pages);
				}
			}
		}
		
		public function get contents():Array { return _contents; }
		public function get depth():int { return _depth; }
		public function set depth(value:int):void { _depth = value;	}
		public function get name():String { return _name; }

		public function get open():Boolean { return _open; }
		public function set open(value:Boolean):void {
			if(_open == value)
				return;
			
			var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			event.source = this;
			event.kind = PropertyChangeEventKind.UPDATE;
			event.property = "open";
			event.oldValue = _open;
			event.newValue = value;
			_open = value;
			
			dispatchEvent(event);
		}
		
		public function get pages():Vector.<Page> { return _pages; }
		public function get parent():Object { return _parent; }
		
		public function get viewableContents():Array {
			var _viewable:Array = [];
			
			for each (var item:* in _contents) {
				_viewable.push(item);
				if ((item is Folder) && item.open) {
					_viewable = _viewable.concat(item.viewableContents);
				}
			}
			return _viewable;
		}
		
		[Bindable] public function get visited():Boolean { return _visited; }
		public function set visited(val:Boolean):void { 
			_visited = val;
			
			var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			event.source = this;
			event.kind = PropertyChangeEventKind.UPDATE;
			dispatchEvent(event);
			
			if (_visited && _parent is Folder) _parent.updateVisited();
		}
		
		public function updateVisited():void {
			if (_visited) return;
			
			for each (var item:* in _contents) {
				if (!item.visited) return;
			}
			this.visited = true;
			if (_parent is Folder) parent.updateVisited();
		}
	}
}