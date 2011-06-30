package com.apexinnovations.transwarp.ui.tooltip {
	import com.apexinnovations.transwarp.skins.TranswarpTooltipSkin;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.core.IToolTip;
	import mx.managers.ToolTipManager;
	import mx.managers.ToolTipManagerImpl;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.utils.TextFlowUtil;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class TranswarpTooltip extends SkinnableComponent implements IToolTip {
		
		public function TranswarpTooltip() {
			super();
			mouseChildren = false;
			maxWidth = 300;
			setStyle("skinClass", TranswarpTooltipSkin);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Skin parts 
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="true", type="spark.components.RichText")]
		public var textDisplay:RichText;
		
		override protected function partAdded(partName:String, instance:Object):void {
			invalidateProperties();
		}		
		
		//--------------------------------------------------------------------------
		//
		//  Properties 
		//
		//--------------------------------------------------------------------------
		
		protected var _text:String;
		
		[Bindable]
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			textFlow = TextFlowUtil.importFromString(value);
		}
				
		protected var _textFlow:TextFlow;
		
		[Bindable]
		public function get textFlow():TextFlow { return _textFlow; }
		public function set textFlow(value:TextFlow):void {
			_textFlow = value;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(textDisplay)
				textDisplay.textFlow = _textFlow;			
		}
	}
}