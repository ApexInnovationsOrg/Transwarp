package main {
	import flashx.textLayout.container.TextContainerManager;
	
	import mx.managers.SystemManager;
	
	public class CustomManager extends SystemManager {
		public function CustomManager()	{
			var c:Class = TextContainerManager;
			super();
		}
	}
}