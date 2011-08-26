package com.apexinnovations.transwarp.utils {
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	TranswarpVersion.revision = "$Rev$";
	
	public class HashSet extends Proxy implements ISet {
		protected var items:Dictionary = new Dictionary();
		protected var iterList:Array; // Temporary array used for iterating over the set
		protected var _size:int = 0;
		
		public function HashSet(source:Object = null) {
			if(source) {
				for each(var e:* in source) {
					add(e);
				}
			}	
		}
		
		public function get size():int { return _size; }
		
		public function clear():void {
			items = new Dictionary();
			_size = 0;
		}
		
		public function add(e:*):Boolean {
			if(e in items) {
				return false;
			} else {
				items[e] = e;
				_size++;
				return true;
			}
		}
		
		public function remove(e:*):Boolean {
			if(e in items) {
				delete items[e];
				_size--;
				return true;
			} else {
				return false;
			}
		}
		
		public function contains(e:*):Boolean {
			return e in items;
		}
		
		public function hasIntersect(set:ISet):Boolean {
			for each(var e:* in set) {
				if(e in items) {
					return true;
				}
			}
			return false;
		}
		
		public function intersect(set:ISet):ISet {
			var intersect:ISet = union(set) as ISet;
			for each(var e:* in intersect) {
				if(!(e in set) || !(e in items))
					intersect.remove(e);
			}
			return intersect;
		}
		
		public function union(set:ISet):ISet {
			var union:HashSet = new HashSet(set);
			for each(var e:* in items) {
				union.add(e);
			}
			return union;
		}
		
		public function difference(set:ISet):ISet {
			var diff:ISet = new HashSet(this);
			for each(var e:* in set) {
				diff.remove(e);
			}
			return diff;
		}
		
		override flash_proxy function hasProperty(name:*):Boolean {
			return contains(name);
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean {
			if(name is QName)
				name = QName(name).localName;
			return remove(name);
		}
		
		override flash_proxy function nextNameIndex(index:int):int {
			if(index == 0) {
				setupIteration();
			}
			
			if(index < iterList.length) {
				return index + 1;
			} else { 
				return 0;
			}
		}
		
		override flash_proxy function nextValue(index:int):* {
			return iterList[index-1];
		}
		
		override flash_proxy function callProperty(name:*, ...parameters):* {
			return undefined;
		}
		
		override flash_proxy function nextName(index:int):String {
			return iterList[index-1] as String;
		}
		
		protected function setupIteration():void {
			iterList = [];
			for each(var e:* in items) {
				iterList.push(e);
			}
		}
		
		public function toString():String {
			var r:String = "[HashSet {";
			for each(var e:* in items) {
				r+= String(e) + ", ";
			}
			r = r.substr(0, r.length-2) +"}]"; 
			return r;
		}
	}
}