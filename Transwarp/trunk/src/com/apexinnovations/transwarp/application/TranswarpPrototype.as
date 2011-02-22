package com.apexinnovations.transwarp.application
{	
	import com.apexinnovations.transwarp.ui.tooltip.TooltipBase;
	
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Application;
	
	[Frame(factoryClass="com.apexinnovations.transwarp.application.CustomSystemManager")]
	public class TranswarpPrototype extends Application {
		
		public function TranswarpPrototype() {
			super();
			addEventListener(FlexEvent.PREINITIALIZE, preinit);
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		protected function preinit(e:Event):void {
			TooltipBase.defaultContainer = SystemManager(this.systemManager);
		}
		
		protected function onAdded(event:Event):void {
			//stage.scaleMode = StageScaleMode.SHOW_ALL; //Scale whole window instead of flowing to fill the space
		}		
	}	
}