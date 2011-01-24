package com.apexinnovations.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	public class CloseButton extends IconButton
	{
		[Embed(source="artwork/close.png")] public const CloseIcon:Class;		
		
		public function CloseButton(parent:DialogBase) {
			super(new CloseIcon());
			addEventListener(MouseEvent.CLICK, parent.close);
			
		}
	}
}