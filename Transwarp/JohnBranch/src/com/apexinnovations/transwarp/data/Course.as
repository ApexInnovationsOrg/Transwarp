package com.apexinnovations.transwarp.data {
	import flash.utils.getQualifiedClassName;

	public class Course extends CoursewareObjectContainer {
		
		protected var _level:uint;
		protected var _flatList:Vector.<CoursewareObject>;
		
		public function Course(xml:XML, parent:CoursewareObjectContainer) {
			super(xml, parent, 0);
			
			try {
				_level = xml.@level;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}
			
			_flatList = new Vector.<CoursewareObject>();
			buildFlatList(this, _flatList);
			
		}
		
		[Bindable("courseChanged")] public function get level():uint {return _level;}
		[Bindable("courseChanged")] public function get levelRoman():String { return roman(_level); }
		public function get flatList():Vector.<CoursewareObject> { return _flatList; }
		
		protected function buildFlatList(node:CoursewareObjectContainer, list:Vector.<CoursewareObject>):void {
			for each(var child:CoursewareObject in node.contents) {
				list.push(child);
				if(child is CoursewareObjectContainer)
					buildFlatList(child as CoursewareObjectContainer, list);
			}
		}
		
		override protected function createChild(node:XML):CoursewareObject {
			var kind:String = node.localName();
			
			if(!kind)
				return null;
			
			kind = kind.toLowerCase();
			
			var obj:CoursewareObject;
			
			if(kind == "page") {
				return new Page(node, this, _depth+1);
			} else if(kind == "folder") {
				return new Folder(node, this, _depth+1);
			}
			
			return null;
		}
		
		private function roman(n:int):String {
			if( n >= 4000 || n < 1)
				return "N/A";
			
			var x:String = "";
			
			var i:int = 0;
			
			var romanValues:Array = [1000,900,500,400,100,90,50,40,10,9,5,4,1];
			var romanSymbols:Array = ['M','CM','D','CD','C','XC','L','XL','X','IX','V','IV','I']; 			
			
			while(n > 0) {
				var symbol:String = romanSymbols[i];
				var value:int = romanValues[i];
				
				while(n >= value) {
					x += symbol;
					n -= value;
				}
				i++;				
			}
			
			return x;
		}
	}
}