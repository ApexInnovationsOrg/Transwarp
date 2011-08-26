package com.apexinnovations.transwarp.utils {
	
	TranswarpVersion.revision = "$Rev$";
	
	public interface ISet {
		function get size():int;
		
		function add(e:*):Boolean;
		function remove(e:*):Boolean;
		
		function clear():void;
		
		function contains(e:*):Boolean;
		function hasIntersect(set:ISet):Boolean;
		
		function intersect(set:ISet):ISet;
		function union(set:ISet):ISet;
		function difference(set:ISet):ISet;
	}
}