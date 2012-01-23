/* SearchService - Processes a search request to the Apex Website
* 
* Copyright (c) 2011 Apex Innovations, LLC. All rights reserved. Any unauthorized reproduction, duplication or transmission by any means, is prohibited.
*/   
package com.apexinnovations.transwarp.webservices
{
	import com.adobe.serialization.json.*;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Dictionary;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class SearchService extends ApexWebService {
		public function SearchService(baseURL:String='') {
			super(baseURL);
		}
		
		// The real class-specific work is done here
		public function dispatch(search:String):void { 
			try{
				var arr:Array = new Array();
				
				var courseware:Courseware = Courseware.instance;
				if(courseware) {
					arr['userID'] = courseware.user.id;
					arr['courseID'] = courseware.currentCourse.id;
					arr['pageID'] = courseware.currentPage.id;
				}
				arr['search'] = search;
				
				// Package up the URLRequest
				var req:URLRequest = super.createRequest('search', super.encrypt(arr));
				
				// Add event listeners for success and failure
				var loader:URLLoader= new URLLoader();
				loader.addEventListener(Event.COMPLETE, jsonLoaded);
				loader.addEventListener(IOErrorEvent.IO_ERROR, jsonError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, jsonError);
				
				// Call the URL
				loader.load(req);
			} catch (e:Error) {
				// Just ignore it
			}
		}
		
		
		// Dispatch the COMPLETE event
		protected function jsonLoaded(e:Event):void {
			var myJSON:Object = JSON.decode(URLLoader(e.target).data);
			
			//trace(this.getClass() + ': JSON data received [success=' + myJSON.success + (myJSON.insertID ? ', insertID=' + myJSON.insertID : '') + (myJSON.debugInfo ? ', debugInfo=(' + myJSON.debugInfo + ')' : '') + ']');
			dispatchEvent(new ApexWebServiceEvent(ApexWebServiceEvent.SEARCH_COMPLETE, myJSON));
		}
		// Dispatch the FAILURE event
		protected function jsonError(e:Event):void {
			trace(this.getClass() + ': JSON ERROR [' + e.toString() + ']');
			dispatchEvent(new ApexWebServiceEvent(ApexWebServiceEvent.SEARCH_FAILURE));
		}
	}
}