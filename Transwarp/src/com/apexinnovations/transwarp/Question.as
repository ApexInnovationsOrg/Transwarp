package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents a question and answer related to a page
	public class Question {
		private var _qTextFlow:TextFlow = null;
		private var _aTextFlow:TextFlow = null;
		
		public function Question(xml:XML) {
			try {
				_qTextFlow = xml.query[0];
				_aTextFlow = xml.answer[0];
			} catch ( e:Error ) {
				throw new ArgumentError("Invalid Initialization XML");
			}
		}
		
		public function get qTextFlow():TextFlow { return _qTextFlow; }
		public function get aTextFlow():TextFlow { return _aTextFlow; }
	}
}