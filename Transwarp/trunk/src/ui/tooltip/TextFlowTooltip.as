package ui.tooltip
{
	import flash.display.DisplayObjectContainer;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import flash.events.MouseEvent;
	
	public class TextFlowTooltip extends SimpleTooltip
	{
		protected var tFlow:TextFlow;
		protected var controller:ContainerController;
		
		public function get textFlow():TextFlow { return tFlow; }
		public function set textFlow(value:TextFlow):void { tFlow = value; }
		
		public override function get text():String { return ""; }
		public override function set text(value:String):void { 
			
		}
		
		public function TextFlowTooltip(container:DisplayObjectContainer, text:String = "", attachPoint:String = "topright", offsetX:Number = 0, offsetY:Number = 0) {
			super(container, text, attachPoint, offsetX, offsetY);
			
			
		}
		
		protected override function initText(text:String):void {
			importMarkup(text);
			updateTextFlow();
			draw();
		}
		
		protected function importMarkup(text:String, format:String = TextConverter.TEXT_FIELD_HTML_FORMAT):void {
			tFlow = TextConverter.importToFlow(text, format);
		}
		
		protected function updateTextFlow():void {
			controller = new ContainerController(this, 200, 200);
			tFlow.flowComposer.addController(controller);
			tFlow.flowComposer.updateAllControllers();
		}
	}
}