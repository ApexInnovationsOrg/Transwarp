package main
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import ui.IconButton;
	import ui.RightSideBar;
	import ui.TopBar;
	import ui.tooltip.SimpleTooltip;
	import ui.tooltip.TooltipAttachPoint;
	import ui.tooltip.TextFlowTooltip;
	
	[SWF(width="1020", height="715", frameRate="30")]
	public class TranswarpPrototype extends Sprite
	{
		[Embed(source="artwork/gear.png")] private const Gear:Class;
		
		public function TranswarpPrototype() {
			var rightSide:RightSideBar = new RightSideBar(this);
			rightSide.x = stage.stageWidth - rightSide.width;
			
			var topBar:TopBar = new TopBar(this);
			
			var s:Sprite = new Sprite();
			addChild(s);
			s.graphics.beginFill(0xffcc00);
			s.graphics.drawRoundRect(0, 0, 50, 50, 10);
			s.graphics.endFill();
			s.x = 500;
			s.y = 400;
			s.buttonMode = true;
					
			var t:TextFlowTooltip = new TextFlowTooltip(s, "Test", TooltipAttachPoint.TOPLEFT);
			t.followMouse = true;
			t.paddingX = t.paddingY = 0;
			t.cornerRadis = 0;
			
			
			var points:Array = ["topleft","left","bottomleft","bottom","bottomright","right","topright","top"];
			var c:int = 0;
			s.addEventListener(MouseEvent.CLICK, function():void {t.attachPoint = points[(++c % points.length)]; });
			
			s.addEventListener(MouseEvent.ROLL_OVER, t.show);
			s.addEventListener(MouseEvent.ROLL_OUT, t.hide);
		}
	}
	
}