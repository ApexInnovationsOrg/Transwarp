package com.apexinnovations.transwarp {	
	import com.apexinnovations.transwarp.utils.Utils;
	
	import flashx.textLayout.TextLayoutVersion;
	import flashx.textLayout.container.TextContainerManager;
	import flashx.textLayout.conversion.TextConverter;
	
	import spark.components.Application;
	
	Utils.revision = "$Rev$";
	
	[Frame(factoryClass="com.apexinnovations.transwarp.TranswarpSystemManager")]
	public class TranswarpBase extends Application {
		
		public function TranswarpBase() {
			super();
		}		
	}
}