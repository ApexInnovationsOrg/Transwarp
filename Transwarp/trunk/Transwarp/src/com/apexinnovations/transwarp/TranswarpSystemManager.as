package com.apexinnovations.transwarp {
	
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.events.SuspendFrameEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.utils.Utils;
	import com.apexinnovations.transwarp.webservices.LogService;
	
	import flash.events.Event;

	import mx.core.mx_internal;
	import mx.managers.SystemManager;

	
	use namespace mx_internal;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="frameSuspended", type="com.apexinnovations.transwarp.events.SuspendFrameEvent")]
	public class TranswarpSystemManager extends SystemManager {
		protected var _resumable:Boolean = false;
		
		protected var _xml:XML;
				
		public function TranswarpSystemManager()	{
			super();
		}
		
		override mx_internal function initialize():void {
			super.initialize();
		}
		
		override mx_internal function docFrameHandler(event:Event=null):void {
			if(_resumable)
				kickOff();
		}
		
		override mx_internal function preloader_completeHandler(event:Event):void {
			preloader.removeEventListener(Event.COMPLETE, preloader_completeHandler);
			preloader.dispatchEvent(new SuspendFrameEvent(this));
		}		
		
		public function resumeNextFrame():void {
			if(currentFrame >= 2) {
				_resumable = true;
				kickOff();
			}
		}
		
		public function get xml():XML { return _xml;}
		public function set xml(value:XML):void {
			_xml = value;
		}
		
		protected function assetsLoaded(e:Event):void {
			resumeNextFrame();		
		}
	}
}

// Force loading of special classes into frame 1:

import flashx.textLayout.container.TextContainerManager;
TextContainerManager;