package com.apexinnovations.transwarp.webservices {

	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.events.IdleEvent;
	import com.apexinnovations.transwarp.events.PageSelectionEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="idle", type="com.apexinnovations.transwarp.events.IdleEvent")]
	public class VisitListener extends EventDispatcher {
		
		protected var _minDuration:Number;
		protected var _timeout:Number;
		protected var _updateInterval:Number;
		protected var _idle:Boolean = false;
		
		
		protected var idleTimer:Timer;
		protected var visitTimer:Timer;
		
		protected var visitID:uint = 0;
		protected var visit:VisitService = new VisitService();
		
		public function VisitListener(minDuration:Number, updateInterval:Number, timeout:Number) {
			_minDuration = minDuration;
			_timeout = timeout;
			_updateInterval = updateInterval;
			
			Courseware.instance.addEventListener(PageSelectionEvent.PAGE_SELECTION_CHANGED, pageChanged);
			
			idleTimer = new Timer(timeout);
			idleTimer.start();
			
			visitTimer = new Timer(minDuration);
			visitTimer.start();
			
			visitTimer.addEventListener(TimerEvent.TIMER, visitTimerHandler);
			idleTimer.addEventListener(TimerEvent.TIMER, idleTimeout);
			
			visit.addEventListener(ApexWebServiceEvent.VISIT_COMPLETE, visitSuccess);
			visit.addEventListener(ApexWebServiceEvent.VISIT_FAILURE, visitFailure);
		}
		
		public function get minDuration():Number { return _minDuration; }
		public function get timeout():Number { return _timeout; }
		public function get updateIntervale():Number { return _updateInterval; }
		public function get idle():Boolean { return _idle; }
		
		protected function pageChanged(event:Event = null):void {
			if(visitID != 0)
				visit.dispatch(visitID);
			
			visitID = 0;
			
			visitTimer.reset();
			visitTimer.delay = _minDuration;
			visitTimer.start();
		}
		
		protected function visitTimerHandler(event:Event = null):void {
			visitTimer.reset();
			visitTimer.delay = _updateInterval;
			visitTimer.start();

			visit.dispatch(visitID);
		}
		
		protected function visitSuccess(event:ApexWebServiceEvent):void {
			visitID = event.data.insertID;
		}
		
		protected function visitFailure(event:Event):void {
			// TODO How are we handling this?
		}
		
		public function resetTimeout(event:Event = null):void {
			if(_idle) {
				visitTimerHandler(); //start new visit session
				_idle = false;
			}
			
			idleTimer.reset();
			idleTimer.start();		
		}
		
		protected function idleTimeout(event:Event):void {
			idleTimer.stop();
			visitTimer.stop();
			
			_idle = true;
			
			if(visitID != 0)
				visit.dispatch(visitID);
			
			visitID = 0;
			
			dispatchEvent(new IdleEvent(_timeout));
		}
		
	}
}