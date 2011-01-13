package ui.tooltip
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.compose.StandardFlowComposer;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	public class TextFlowTooltip extends TooltipBase
	{
		protected var _textFlow:TextFlow;
		protected var controller:ContainerController;
		
		public function get textFlow():TextFlow { return _textFlow; }
		public function set textFlow(value:TextFlow):void { 
			removeOldFlow(); 
			_textFlow = value;
			updateTextFlow();
		}
		
		public function get html():XML { return XML(TextConverter.export(_textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.XML_TYPE));}
		public function set html(value:XML):void {
			removeOldFlow();
			importMarkup(value, TextConverter.TEXT_FIELD_HTML_FORMAT);
			updateTextFlow();
		}
		
		public function get textFlowXML():XML { return XML(TextConverter.export(_textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE));}
		public function set textFlowXML(value:XML):void {
			removeOldFlow();
			importMarkup(value, TextConverter.TEXT_LAYOUT_FORMAT);
			updateTextFlow();
		}


		public function TextFlowTooltip(container:DisplayObjectContainer, text:XML = null, attachPoint:String = "topright", offsetX:Number = 0, offsetY:Number = 0) {
			super(container, attachPoint, offsetX, offsetY);

			if (text) {
				importMarkup(text, inferMarkupType(text));
				updateTextFlow();
			}
		}

		public function setCompositionSize(w:Number, h:Number):Boolean {
			if(controller) {
				controller.setCompositionSize(w, h);
				return true;
			} else
				return false;			
		}
		
		public function get compositionWidth():Number { return controller ? controller.compositionWidth : 0; }
		public function get compositionHeight():Number { return controller ? controller.compositionHeight : 0; }
		
		protected function inferMarkupType(xml:XML):String {
			if (xml.localName() == "TextFlow")
				return TextConverter.TEXT_LAYOUT_FORMAT;
			else
				return TextConverter.TEXT_FIELD_HTML_FORMAT;
		}

		protected function importMarkup(text:XML, format:String):void {
			_textFlow = TextConverter.importToFlow(text, format);
			_textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, needsRedraw);
			_textFlow.addEventListener(UpdateCompleteEvent.UPDATE_COMPLETE, needsRedraw);
		}

		protected function removeOldFlow():void {
			if (!_textFlow)
				return;
			_textFlow.flowComposer.removeAllControllers();
		}

		public override function update(forceRedraw:Boolean = false):void {
			if(_textFlow)
				_textFlow.flowComposer.updateAllControllers();
			super.update(forceRedraw);
		}
		
		protected function updateTextFlow():void {
			if (!_textFlow)
				return;
			
			controller = new ContainerController(this, 200, NaN);
			_textFlow.flowComposer.addController(controller);
			_textFlow.flowComposer.updateAllControllers();
			
		}
	}
}