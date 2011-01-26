package com.apexinnovations.transwarp.application
{	
	import br.com.stimuli.loading.BulkLoader;
	
	import com.apexinnovations.transwarp.ui.tooltip.TooltipBase;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.events.FlexEvent;
	import mx.managers.ISystemManager;
	import mx.managers.SystemManager;
	
	import spark.components.Application;
	
	[Frame(factoryClass="com.apexinnovations.transwarp.application.CustomSystemManager")]
	public class TranswarpPrototype extends Application {
		
		public function TranswarpPrototype() {
			super();
			addEventListener(FlexEvent.PREINITIALIZE, preinit);
		}
		
		protected function preinit(e:Event):void {
			TooltipBase.defaultContainer = SystemManager(this.systemManager);
		}
	}	
}