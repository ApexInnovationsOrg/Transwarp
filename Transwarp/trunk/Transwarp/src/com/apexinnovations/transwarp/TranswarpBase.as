package com.apexinnovations.transwarp {	
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import spark.components.Application;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Frame(factoryClass="com.apexinnovations.transwarp.TranswarpSystemManager")]
	public class TranswarpBase extends Application {
		
		public function TranswarpBase() {
			super();
		}
	}
}

//Force loading of class into frame 2.
import com.apexinnovations.transwarp.ui.tooltip.TranswarpTooltipManager;

TranswarpTooltipManager;