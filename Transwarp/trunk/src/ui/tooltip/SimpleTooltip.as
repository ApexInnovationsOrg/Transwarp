package ui.tooltip {
	import flash.display.DisplayObjectContainer;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class SimpleTooltip extends TooltipBase {
		
		protected var tf:TextField;
		
		public function get text():String {return tf.text;}
		public function set text(value:String):void {tf.text=value;	invalidate();}
		
		public function get textFormat():TextFormat { return tf.defaultTextFormat; }
		public function set textFormat(value:TextFormat):void { tf.defaultTextFormat = value; invalidate();}
		
		public function SimpleTooltip(container:DisplayObjectContainer=null, text:String = "", attachPoint:String = "topright", offsetX:Number = 0, offsetY:Number = 0) {
			super(container, attachPoint, offsetX, offsetY);
			
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = text;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.defaultTextFormat = new TextFormat("Arial", 11);
			addChild(tf);
		}
	}
}