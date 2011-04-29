package com.apexinnovations.transwarp {	
	import flashx.textLayout.container.TextContainerManager;
	
	import spark.components.Application;
	
	[Frame(factoryClass="com.apexinnovations.transwarp.TranswarpSystemManager")]
	public class TranswarpBase extends Application {
		
		public function TranswarpBase() {
			super();
		}
		
		protected var romanValues:Array = [1000,900,500,400,100,90,50,40,10,9,5,4,1]
		protected var romanSymbols:Array = ['M','CM','D','CD','C','XC','L','XL','X','IX','V','IV','I']; 			
		
		public function roman(n:int):String {
			if( n >= 4000 || n < 1)
				return "N/A";
			
			var x:String = "";
			
			var i:int = 0;
			
			while(n > 0) {
				var symbol:String = romanSymbols[i];
				var value:int = romanValues[i];
				
				while(n >= value) {
					x += symbol;
					n -= value;
				}
				i++;				
			}
			
			return x;
			
		}
		
	}
}