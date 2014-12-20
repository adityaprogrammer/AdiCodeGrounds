package XML
{
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.xml.*;
	
	public class ASXMLLoader
	{
		private var AXMLLoader:URLLoader;
		private var AXML:XML;
		public var _title:String;
		public var _src:String;
		public var _duration:Number;
		public var Flag:Number=0;
		
		public function ASXMLLoader(url:String)
		{
			AXMLLoader= new URLLoader();
			AXMLLoader.load(new URLRequest(url));
			AXMLLoader.addEventListener(Event.COMPLETE, processXML);
		}
		private function processXML (e:Event):void{
			
			AXML= new XML(e.target.data);
			_src=AXML.video.@src ;  
			_title=AXML.video.param[0].attribute("value");
			_duration=Number(AXML.video.param[1].attribute("value"));
			Flag=1;
		}
	}
}

