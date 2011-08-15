package com.apexinnovations.transwarp.assets {
	import com.apexinnovations.transwarp.assets.loaders.LimitedMemoryLoader;
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.data.Product;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.utils.Dictionary;

	TranswarpVersion.revision = "$Rev$";
	
	public class ContentLoader {
		
		protected var mainLoader:LimitedMemoryLoader;
		protected var loaders:Dictionary = new Dictionary();
		
		protected var courses:Array = [];
		
		public function ContentLoader(product:Product, mainLoader:LimitedMemoryLoader) {
			this.mainLoader = mainLoader;
			
			for each(var c:Course in product.courses) {
				var pageList:Array = [];
				for each(var page:Page in c.pages) {
					var idx:int = pageList.push(page);
					var loader:PageLoader = new PageLoader(page); 
					loaders[page] = loader;			
				}
				courses[c.id] = pageList;
			}
		}
		
		public function getPageLoader(page:Page, prioritizeBefore:int = 1, prioritizeAfter:int = 7):PageLoader {
			var loader:PageLoader = loaders[page];
			mainLoader.requestLoad(loader);
			
			var pages:Array = courses[page.course.id]
			var index:int = pages.indexOf(page);
			
			var before:Array
			var after:Array;
			
			if(prioritizeBefore > 0 && index > 0) { 
				before = pages.slice(Math.max(0,index - prioritizeBefore), Math.max(0, index-1));
				before.filter(filter);
				mainLoader.prioritizeLoaders(before);
			}
			
			var last:int = pages.length - 1;
			
			if(prioritizeAfter > 0 && index < last) {
				after = pages.slice(Math.min(last, index+1), Math.min(last, index + prioritizeAfter));
				after.filter(filter);
				mainLoader.prioritizeLoaders(after);
			}		
			
			return loader;			
		}
		
		protected function filter(item:*, index:int, array:Array):void {
			array[index] = loaders[item];
		}
	}
}