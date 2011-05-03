package com.apexinnovations.transwarp.data
{
	import flash.utils.*;
	import flash.errors.*;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents a question and answer related to a page
	public class Question {
		private var _qTextFlow:TextFlow = null;	// The question text, as a TextFlow
		private var _aTextFlow:TextFlow = null;	// The answer text, as a TextFlow
		
		public function Question(xml:XML) {
			try {
				_qTextFlow = TextConverter.importToFlow(xml.query.children()[0], TextConverter.TEXT_LAYOUT_FORMAT);
				_aTextFlow = TextConverter.importToFlow(xml.answer.children()[0], TextConverter.TEXT_LAYOUT_FORMAT);
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get qTextFlow():TextFlow { return _qTextFlow; }
		public function get aTextFlow():TextFlow { return _aTextFlow; }
	}
}