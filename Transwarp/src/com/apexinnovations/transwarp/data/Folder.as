package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Page;
	
	import flash.errors.*;
	import flash.utils.*;
	
	// This represents a folder of pages and subfolders (of pages)
	public class Folder {
		private var _contents:Array = [];	// An ordered collection of the contents of this folder (pages and other folders)
		private var _name:String = '';		// The name of this folder
		private var _open:Boolean = false;	// Is this folder open (contents are visible in the menu)?
		private var _parent:Object = null;	// A link back to the parent (folder or course)
				
		public function Folder(xml:XML, parent:Object) {
			try {
				_name = xml.@name;
				_parent = parent;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}

			for each (var child:XML in xml.children()) {
				if (child.@visited != undefined) {
					_contents[_contents.length] = new Page(child, this);
				} else {
					_contents[_contents.length] = new Folder(child, this);
				}
			}
		}
		
		public function get contents():Array { return _contents; }
		public function get name():String { return _name; }
		public function get open():Boolean { return _open; }
		public function set open(val:Boolean):void { _open = val; }
		public function get parent():Object { return _parent; }
		
		// Returns a Vector (array) of Pages in this Folder
		public function pages(recurse:Boolean = true):Vector.<Page> {
			var _pages:Vector.<Page> = new Vector.<Page>();
			
			for each (var item:* in _contents) {
				if (item is Page) {
					_pages[_pages.length] = item as Page;
				} else if (recurse) {
					for each (var x:Page in (item as Folder).pages(recurse)) {
						_pages.push(x);
					}
				}
			}
			return _pages;
		}
		
		// Returns an array of viewable (folder open) pages and folders within this page
		public function viewableContents():Array {
			var _viewable:Array = [];
			
			for each (var item:* in _contents) {
				_viewable[_viewable.length] = item;
				if ((item is Folder) && item.open) {
					for each (var x:* in item.viewableContents()) {
						_viewable.push(x);
					}
//					_viewable.concat(item.viewableContents());
				}
			}
			return _viewable;
		}
	}
}