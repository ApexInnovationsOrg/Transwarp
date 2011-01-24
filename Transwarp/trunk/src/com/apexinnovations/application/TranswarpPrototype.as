package com.apexinnovations.application
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.events.FlexEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Application;
	
	import com.apexinnovations.ui.tooltip.TooltipBase;
	
	[Frame(factoryClass="com.apexinnovations.application.CustomManager")]
	public class TranswarpPrototype extends Application {
		
		public function TranswarpPrototype() {
			super();

			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
		}
		
		protected function creationComplete(e:Event):void {
			TooltipBase.defaultContainer = SystemManager(this.systemManager);
		}
	}	
}