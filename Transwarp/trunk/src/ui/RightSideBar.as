package ui
{
	import br.com.stimuli.loading.BulkLoader;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import ui.tooltip.SimpleTooltip;
	import ui.tooltip.TooltipAttachPoint;
	
	public class RightSideBar extends Sprite
	{
		public const WIDTH:Number = 40;
		
		private var loader:BulkLoader;
		
		private var buttonInfo:Array = [
			{art : "../artwork/gear.png", text : "Options"},
			{art: "../artwork/information.png", text : "Instructions"},
			{art: "../artwork/question2.png", text : "Critical Question", highlightAlpha : 0.2},
			{art : "../artwork/comment.png", text : "Comment on This Page"},
			{art : "../artwork/globe.png", text : "Related Links"},
			{art : "../artwork/star.png", text : "Favorites"},
			{art : "../artwork/sound.png", text : "Transcript"},
			{art : "../artwork/hammer.png", text : "Tools"},
		];
		
		private var buttons:Vector.<IconButton>;
		private var tooltip:SimpleTooltip;
		private var map:Dictionary = new Dictionary();
		
		public function RightSideBar(container:DisplayObjectContainer) {
			container.addChild(this);
			
			buttons = new Vector.<IconButton>();
			
			loader = new BulkLoader();
			loader.addEventListener(BulkLoader.COMPLETE, loadingComplete);
			
			for each (var info:Object in buttonInfo) {
				loader.add(info.art);				
			}
			
			loader.start();
			
			tooltip = new SimpleTooltip(this);
			tooltip.attachPoint = TooltipAttachPoint.LEFT; 
			
			draw();
		}
		
		private function draw():void {
			graphics.beginFill(0xdddddd, 1);
			graphics.lineStyle(1);
			graphics.drawRect(0, 0, WIDTH, stage.stageHeight);
			graphics.endFill();
		}


		private function loadingComplete(e:Event):void {
			for each (var info:Object in buttonInfo) {
				var bmp:Bitmap = loader.getBitmap(info.art);
				var b:IconButton = new IconButton(this, bmp);
				
				if (info.highlightAlpha) {
					b.highlightAlpha = info.highlightAlpha;
				}
				
				b.addEventListener(MouseEvent.ROLL_OVER, rollOver);
				b.addEventListener(MouseEvent.ROLL_OUT, rollOut);
				
				buttons.push(b);
				map[b] = info;
			}
			update();
		}

		private function rollOver(e:MouseEvent):void {
			tooltip.text = map[e.target].text;
			tooltip.anchorObject = DisplayObject(e.target);			
			tooltip.delayedShow(0.5);
		}

		private function rollOut(e:MouseEvent):void {
			tooltip.hide();
		}

		private function update():void {
			for (var i:int = 0; i < buttons.length; ++i) {
				var button:IconButton = buttons[i];
				button.x = WIDTH / 2 - 16;
				button.y = stage.stageHeight - (i + 1) * (42);
			}
		}

	}
	
}