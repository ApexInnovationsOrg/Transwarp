package com.apexinnovations.transwarp.events
{
	import com.apexinnovations.transwarp.data.HelpPage;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.Event;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class HelpSelectionEvent extends Event {
		
		public static const HELP_SELECTION_CHANGED:String = "helpSelectionChanged";
		
		public var help:HelpPage;
		
		public function HelpSelectionEvent(help:HelpPage, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.help = help;
			super(HELP_SELECTION_CHANGED, bubbles, cancelable);
		}
	}
}