package ui.tooltip
{
	import flash.display.DisplayObjectContainer;

	public class TextFlowTooltip extends SimpleTooltip
	{
		public function TextFlowTooltip(container:DisplayObjectContainer, text:String = "", attachPoint:String = "topright", offsetX:Number = 0, offsetY:Number = 0) {
			super(container, text, attachPoint, offsetX, offsetY);
			
		}
		
		protected override function initText(text:String):void {
			
		}
	}
}