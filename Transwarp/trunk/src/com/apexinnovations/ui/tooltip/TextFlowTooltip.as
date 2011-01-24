package com.apexinnovations.ui.tooltip
{
	import flash.display.DisplayObjectContainer;	
	import com.apexinnovations.ui.TextFlowContainer;
	
	public class TextFlowTooltip extends TooltipBase
	{
		protected var textFlow:TextFlowContainer;		
		
		public function TextFlowTooltip(container:DisplayObjectContainer=null, text:XML = null, attachPoint:String = "topright", offsetX:Number = 0, offsetY:Number = 0) {
			super(container, attachPoint, offsetX, offsetY);
			textFlow = new TextFlowContainer(text);
			addChild(textFlow);
						
			textFlow.addEventListener(TextFlowContainer.TEXT_FLOW_CONTAINER_UPDATE, invalidate);
		}
		
		public function setText(markup:Object):Boolean {
			return textFlow.setText(markup);
		}
		
		public function setMaxSize(w:Number, h:Number):void {
			textFlow.setMaxSize(w, h);
		}
		
		public function get textFlowContainer():TextFlowContainer { return textFlow; }
	}
}