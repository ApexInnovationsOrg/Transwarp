package ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	public class TopBar extends Sprite
	{
		public const HEIGHT:Number = 46;
		
		public function TopBar(container:DisplayObjectContainer) {
			container.addChild(this);
			
			draw();		
		}
		
		private function draw():void {
			var w:Number = stage.stageWidth;
			
			var m:Matrix = new Matrix();
			m.createGradientBox(w * 2.5, HEIGHT * 3, Math.PI/2, -w/6, -HEIGHT/1.25);
			graphics.beginGradientFill(GradientType.RADIAL, [0x000068, 0x0000cc], [1, 1], [0, 255], m);			
			graphics.lineStyle(1);
			graphics.drawRect(0, 0, w, HEIGHT);
			graphics.endFill();
			
			var f:Array = new Array();
			f.push(new GlowFilter(0, 0.5, 0, 3, 2, 1, true));
			f.push(new GlowFilter(0, 0.8, 0, 7));
			filters = f;			
		}
	}
}