/* AES - Encryption library for Apex Innovatons, LLC. 
* 
* Copyright (c) 2011 Apex Innovations, LLC. All rights reserved. Any unauthorized reproduction, duplication or transmission by any means, is prohibited.
* 
*/   
package com.apexinnovations.transwarp.webservices
{   
	import com.apexinnovations.transwarp.utils.Utils;
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.CBCMode;
	import com.hurlant.crypto.symmetric.ECBMode;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.IVMode;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.util.Hex;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	Utils.revision = "$Rev$";
	
	public class AES {
		private var _key:AESKey;
		private var _mode:ICipher;
		private var _pad:IPad;
		
		public static const MODE_CBC:int = 0;
		public static const MODE_ECB:int = 1;
		public static const PADDING_ZEROS:int = 0;
		public static const PADDING_PKCS5:int = 1;
		public static const PADDING_PKCS7:int = 2;

		
		public function AES(key:String, mode:int = MODE_CBC, padding:int = PADDING_ZEROS, iv:String = "00000000000000000000000000000000") : void {
			var len:Number = key.length;
			if (!key.match(/[[:xdigit:]]/) || !(len == 32 || len == 48 || len == 64)) {
				throw new Error("AES key must be a 32-, 48-, or 64-byte hex number");
				return;
			}
			if (mode != MODE_CBC && mode != MODE_ECB) {
				throw new Error("AES mode must be either AES.MODE_CBC or AES.MODE_ECB");				
				return;
			}
			if (padding != PADDING_ZEROS && padding != PADDING_PKCS5 && padding != PADDING_PKCS7) {
				throw new Error("AES padding must be either AES.PADDING_ZEROS or AES.PADDING_PKCS5 or AES.PADDING_PKCS7");				
				return;
			}
			if (!iv.match(/[[:xdigit:]]/) || !(iv.length == 32)) {
				throw new Error("AES iv must be a 32-byte hex number");
				return;
			}
			_key = new AESKey(Hex.toArray(key));
			_pad = (padding == PADDING_ZEROS ? new NullPad : new PKCS5);
			_mode = (mode == MODE_ECB ? new ECBMode(_key, _pad) : new CBCMode(_key, _pad));
			_pad.setBlockSize(_mode.getBlockSize());
			if (_mode is IVMode) {
				var ivmode:IVMode = _mode as IVMode;
				ivmode.IV = Hex.toArray(iv);
			}
		}
		
		public function encrypt(data:String) : ByteArray {
			var bytes:ByteArray = Hex.toArray(Hex.fromString(data));
			_mode.encrypt(bytes);
			return bytes;
		}
		
		public function decrypt(data:ByteArray) : String {
			_mode.decrypt(data);
			return data.toString();
		}
	}
}