/* ApexWebService - Encrypts params then navigates to a URL and processes returned values
* 
* Copyright (c) 2011 Apex Innovations, LLC. All rights reserved. Any unauthorized reproduction, duplication or transmission by any means, is prohibited.
*/   
package com.apexinnovations.transwarp.webservices
{
	import com.apexinnovations.transwarp.webservices.AES;
	import com.hurlant.util.Hex;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	public class ApexWebService extends EventDispatcher {
		private static const FLASHVAR_INTERNAL_SEPARATOR:String = "|:|";
		private static var crypto:AES = new AES("f30a06c050eba200830a0200300f007ede0007060034000aa00300f007ede00f", AES.MODE_CBC, AES.PADDING_ZEROS);
		
		private static var _baseURL:String = '';	// Base URL for interaction with Web Services
		private static var _userID:uint = 0;		// Current User ID
		private static var _courseID:uint = 0;		// Current Course ID
		private static var _pageID:uint = 0;		// Current Page ID
		
		
		// Class method to get base URL for everything we're doing
		public function ApexWebService(baseURL:String = '') {
			// Set the baseURL
			if (baseURL != '') _baseURL = baseURL;
		}
		
		// Getters and setters
		public static function get baseURL():String { return _baseURL; }
		public static function set baseURL(baseURL:String):void { _baseURL = baseURL; }
		
		// Get the object class name
		public function getClass():String {
			var fullClassName:String = getQualifiedClassName(this);
			return fullClassName.slice(fullClassName.lastIndexOf("::") + 2);
		}
		
		// Encrypts an array 
		protected function encrypt(arr:Array):String {
			// Make a temporary copy so as not to muck with original array
			var tmp:Array = new Array();
			for (var key:Object in arr) {
				// Create new item in temporary array of form "key=value"
				tmp.unshift(key + "=" + arr[key]);
			}
			// Add a timestamp to the temporary array
			tmp.unshift("timestamp=" + Math.round((new Date()).getTime()/1000));
			// Mix up the temporary array
			tmp = shuffle(tmp);
			// Finally, add a random string at the beginning, and serialize the array
			var s:String = randString(5) + "=" + randString(5) + FLASHVAR_INTERNAL_SEPARATOR + tmp.join(FLASHVAR_INTERNAL_SEPARATOR);
			// And encrypt it
			var encrypted:String = Hex.fromArray(crypto.encrypt(s));
			
			return encrypted;
   		}
		// Create a URLRequest object with the encrypted data
		protected function createRequest(urlFragment:String, data:String):URLRequest {
			// Check to make sure our baseURL has been set
			if (baseURL == '') {
				throw new Error(this.getClass() + ': baseURL must be set before calling send()');
			} else {
				var requestVars:URLVariables = new URLVariables();
				requestVars.data = data;
				var req:URLRequest = new URLRequest(_baseURL + "/Classroom/engine/events/" + urlFragment + ".php");
				req.data = requestVars;
				req.method = URLRequestMethod.POST;
				
				return req;
			}
		}
		
	
		// Generate a random character string 'len' characters long
		public static function randString(len:Number, chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String{
			var num_chars:Number = chars.length;
			var randomChars:String = "";
			  
			for (var i:Number = 0; i < len; i++){
				randomChars += chars.charAt(Math.floor(Math.random() * num_chars));
			}
			return randomChars;
		}
		// Shuffle the array (randomly mix it up)
		private static function shuffle(array:Array):Array {
			var _length:Number = array.length, mixed:Array = array.slice(), rn:Number, it:Number, el:Object;
			for (it = 0; it<_length; it++) {
				el = mixed[it];
				mixed[it] = mixed[rn = Math.floor(Math.random() * _length)];
				mixed[rn] = el;
			}
			return mixed;
		}
    }
}