/* LogService - Processes a page request to the Apex Website
* 
* Copyright (c) 2011 Apex Innovations, LLC. All rights reserved. Any unauthorized reproduction, duplication or transmission by any means, is prohibited.
*/   
package com.apexinnovations.transwarp.crypto
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Dictionary;
	import com.adobe.serialization.json.*;
	
	public class PageService extends ApexWebService {
		public function PageService(baseURL:String='') {
			super(baseURL);
		}
		
		// The real class-specific work is done here
		public function dispatch(userID:uint, courseID:uint, pageID:uint, visitID:uint = 0):void { 
			var arr:Array = new Array();
			arr['userID'] = userID;
			arr['courseID'] = courseID;
			arr['pageID'] = pageID;
			if (visitID != 0) arr['visitID'] = visitID;
			
			// Package up the URLRequest
			var req:URLRequest = super.createRequest('page', super.encrypt(arr));
			
			// Add event listeners for success and failure
			var loader:URLLoader= new URLLoader();
			loader.addEventListener(Event.COMPLETE, jsonLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, jsonError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, jsonError);
			
			// Call the URL
			loader.load(req);
		}
		
		
		// Dispatch the COMPLETE event
		protected function jsonLoaded(e:Event):void {
			var myJSON:Object = JSON.decode(URLLoader(e.target).data);
			
			trace(this.getClass() + ': JSON data received [success=' + myJSON.success + (myJSON.insertID ? ', insertID=' + myJSON.insertID : '') + (myJSON.debugInfo ? ', debugInfo=(' + myJSON.debugInfo + ')' : '') + ']');
			dispatchEvent(new ApexWebServiceEvent(ApexWebServiceEvent.PAGE_COMPLETE, myJSON));
		}
		// Dispatch the FAILURE event
		protected function jsonError(e:Event):void {
			trace(this.getClass() + ': JSON ERROR [' + e.toString() + ']');
			dispatchEvent(new ApexWebServiceEvent(ApexWebServiceEvent.PAGE_FAILURE));
		}
	}
}