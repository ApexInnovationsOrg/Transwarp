package com.apexinnovations.transwarp.data {
	import flash.display.DisplayObjectContainer;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	public class Folder extends CoursewareObjectContainer {
		
		protected var _open:Boolean = false;
		
		public function Folder(xml:XML, parent:CoursewareObjectContainer, depth:int) {
			super(xml, parent, depth);
		}
		
		override protected function createChild(node:XML):CoursewareObject {
			var kind:String = node.localName();
			
			if(!kind)
				return null;
			
			kind = kind.toLowerCase();
			
			if(kind == "page") {
				return new Page(node, this, _depth+1);
			} else if(kind == "folder") {
				return new Folder(node, this, _depth+1);
			}
			
			return null;
		}
		
		public function get open():Boolean { return _open; }
		public function set open(value:Boolean):void {
			if(_open == value)
				return;
			
			var event:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, true);
			event.source = this;
			event.kind = PropertyChangeEventKind.UPDATE;
			event.property = "open";
			event.oldValue = _open;
			event.newValue = value;
						
			_open = value;
			dispatchEvent(event);
		}
	}
}