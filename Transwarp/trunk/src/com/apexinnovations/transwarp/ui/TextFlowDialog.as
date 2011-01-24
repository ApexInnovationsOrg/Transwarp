package com.apexinnovations.transwarp.ui {
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.UpdateCompleteEvent;

	public class TextFlowDialog extends DialogBase {
		protected var title:TextFlowContainer;
		protected var body:TextFlowContainer;
		protected var dirty:Boolean = false;
		
		//protected var _maxWidth:Number = 400;
		//protected var _maxHeight:Number = NaN;
		
		public function get maxWidth():Number { return _maxWidth; }
		public function get maxHeight():Number { return _maxHeight; }
		
		public function setMaxSize(w:Number, h:Number):void {
			_maxWidth = w;
			_maxHeight = h;
		}
		
		public var closeButton:CloseButton;
		
		public function TextFlowDialog(titleMarkup:XML, bodyMarkup:XML) {
			super();
			closeButton = new CloseButton(this);
			addChild(closeButton);
			
			title = new TextFlowContainer(titleMarkup);
			body = new TextFlowContainer(bodyMarkup);
			
			addChild(title);
			addChild(body);
			
			title.addEventListener(TextFlowContainer.TEXT_FLOW_CONTAINER_UPDATE, invalidate);
			body.addEventListener(TextFlowContainer.TEXT_FLOW_CONTAINER_UPDATE, invalidate);
		}
		
			
		public function positionPieces():void {  //NEEDS RENAME
			body.y = Math.max(title.height, closeButton.height) + 2;
			title.x = Math.max(0, (body.width - title.width)/2);
			title.y = Math.max(0, (closeButton.height - title.height)/2);
			closeButton.x = Math.max(title.width, body.width) - closeButton.width - 2;
		}
		
		public override function draw():void {
			positionPieces();			
			var bounds:Rectangle = getBounds(this);							
			graphics.clear();
			graphics.lineStyle(1,0,1,true);
			graphics.beginFill(0xffffff, .9);
			graphics.drawRoundRect(bounds.x - 5, bounds.y - 5, bounds.width + 10, bounds.height + 10, 20);
			graphics.endFill();
			super.draw();
		}
	
	}
}