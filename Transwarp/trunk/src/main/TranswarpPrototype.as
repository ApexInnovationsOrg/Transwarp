package main
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.*;
	import flashx.textLayout.elements.TextFlow;
	
	import ui.IconButton;
	import ui.RightSideBar;
	import ui.TopBar;
	import ui.tooltip.TooltipBase;
	import ui.tooltip.TextFlowTooltip;
	import ui.tooltip.TooltipAttachPoint;
	
	[SWF(width="1020", height="715", frameRate="30")]
	public class TranswarpPrototype extends Sprite
	{
					
		public function TranswarpPrototype() {
			
			var rightSide:RightSideBar = new RightSideBar(this);
			rightSide.x = stage.stageWidth - rightSide.width;
			
			var topBar:TopBar = new TopBar(this);
			
			new URLLoader(new URLRequest("test.xml")).addEventListener(Event.COMPLETE, xmlLoaded);
			
		}
		
		public function xmlLoaded(e:Event):void {
			var s:Sprite = new Sprite();
			addChild(s);
			s.graphics.beginFill(0xffcc00);
			s.graphics.drawRoundRect(0, 0, 50, 50, 10);
			s.graphics.endFill();
			s.x = 500;
			s.y = 400;
			s.buttonMode = true;
			
			XML.ignoreWhitespace = false;
			var xml:XML = new XML(e.target.data);
			xml = xml.transcript[0];
			xml.setLocalName("div");
			
			var t:TextFlowTooltip = new TextFlowTooltip(s, xml, TooltipAttachPoint.TOPLEFT);
			t.anchorObject = s;
			//t.followMouse = true;
			t.paddingX = t.paddingY = 5;
			
			trace(t.textFlowXML);
			
			var points:Array = ["topleft","left","bottomleft","bottom","bottomright","right","topright","top"];
			var c:int = 0;
			s.addEventListener(MouseEvent.CLICK, function():void {t.attachPoint = points[(++c % points.length)]; t.update(true);} );
			
			s.addEventListener(MouseEvent.ROLL_OVER, t.show);
			s.addEventListener(MouseEvent.ROLL_OUT, t.hide);
		}
		
	}
	
}