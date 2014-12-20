package
{
	import HUD.ASHUDController;	
	import XML.ASXMLLoader;	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.utils.Timer;
	
	
	[SWF(width='400',height='350',backgroundColor='#ffffff',frameRate='30',align='centre')]
	public class ASVPlayer extends MovieClip
	{
		private var videoURL:String = "http://static.smdg.ca/videoPlayer/big_buck_bunny.mp4";
		private var targXML:String="http://static.smdg.ca/videoPlayer/videotest/test1.xml"
		private var connection:NetConnection;
		private var stream:NetStream;
		private var video:Video;		
		private var _xmlLoader:ASXMLLoader;
		private var ASHud:HUDContainer;
		private var _VideoContainer:MovieClip;		
		private var xmlTimer:Timer;
		private var HudCtrlObj:ASHUDController;
		private var _vduration:Number;
		
		
		public function ASVPlayer()
		{
			addEventListener(Event.ADDED_TO_STAGE,init);
			addEventListener(Event.REMOVED_FROM_STAGE,exit);
			this.loaderInfo.addEventListener(Event.UNLOAD, onUnloadedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			exit();
		}
		private function onUnloadedFromStage(event:Event):void
		{
			exit();
		}
		private function init(event:Event):void
		{
			try
			{
				/* This is to handle any unhandeled exceptions in run time to gracefully exit*/
				addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleGlobalErrors);
				//ExternalInterface.call("console.log", "Tada");
				initXML();
			}catch(e:Error)
			{
				ExternalInterface.call("console.log", "Init Error ",e,e.message);
			}
		}
		private function initXML():void
		{
			_xmlLoader=new ASXMLLoader(targXML);
			xmlTimer=new Timer(200);
			xmlTimer.addEventListener(TimerEvent.TIMER,onXMLTimer);
			xmlTimer.start();
		}
		private function onXMLTimer(Event:TimerEvent):void
		{
			if(_xmlLoader.Flag==1)
			{
				xmlTimer.removeEventListener(TimerEvent.TIMER,onXMLTimer);
				xmlTimer.stop();
				initVariables();
			}
		}
		private function initVariables():void
		{	
			ASHud=new HUDContainer();
			addChild(ASHud);
			_VideoContainer=MovieClip(ASHud.VC);
			video= new Video(_VideoContainer.width,_VideoContainer.height);
			// on the NetConnection 
			initConnection();
			// on the NetStream
			initStream();
			loadVideo();		
			
		}
		private function traceChildren():void
		{
			for (var i:uint = 0; i < ASHud.numChildren; i++){
				trace ('\t|\t ' +i+'.\t name:' + ASHud.getChildAt(i).name + '\t type:' + typeof (ASHud.getChildAt(i))+ '\t' + ASHud.getChildAt(i));
			}
		}
		private function initConnection():void
		{
			connection = new NetConnection();
			connection.connect(null); // not to streaming server
			connection.addEventListener(NetStatusEvent.NET_STATUS, doNetStatus);
			connection.addEventListener(IOErrorEvent.IO_ERROR, doIOError);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, doSecurityError);	
		}
		private function initStream():void
		{
			stream = new NetStream(connection);			
			stream.client = this;
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, doAsyncError);
			stream.addEventListener(NetStatusEvent.NET_STATUS, doNetStatus);
			stream.addEventListener(IOErrorEvent.IO_ERROR, doIOError);
		}
		private function loadVideo():void
		{
			// add video to the container.
			
			_VideoContainer.addChild(video);
			
			// attach the NetStream to the video object
			video.attachNetStream(stream);
			
			// default buffer time  1 second
			stream.bufferTime = 1;
			
			// tell the stream to receive the audio
			stream.receiveAudio(true);
			
			// tell the stream to receive the video
			stream.receiveVideo(true);
			
			// play a video file on a HTTP servser
			stream.play(videoURL);
		}
		private function loadControls():void
		{
			HudCtrlObj=new ASHUDController(stream,ASHud,_xmlLoader._title,_vduration);
		}
		private function handleGlobalErrors(e:UncaughtErrorEvent):void
		{
			//ExternalInterface.call("console.log", "UncaughtErrorEvent===:::",e);
		}
		private function doSecurityError(evt:SecurityErrorEvent):void
		{
			//trace("AbstractStream.securityError:"+evt.text);
			// when this happens, you don't have security rights on the server containing the video file
			// a crossdomain.xml file would fix the problem easily
		}
		
		private function doIOError(evt:IOErrorEvent):void
		{
			//trace("AbstractScreem.ioError:"+evt.text);
			// there was a connection drop, a loss of internet connection, or something else wrong. 404 error too.
		}
		
		private function doAsyncError(evt:AsyncErrorEvent):void
		{
			//trace("AsyncError:"+evt.text);
		}
		public function onPlayStatus(info:Object):void  
		{  
			switch(info.code) {  
				case "NetStream.Play.Complete":  
					// code to handle steream end  
					break;  
			}  
		}  
		private function doNetStatus(evt:NetStatusEvent):void
		{
			switch (evt.info.code)
			{
				case "NetConnection.Connect.Success" :
					break;
				case "NetStream.Play.StreamNotFound" :
					//trace(("Stream not found: " + videoURL));
					break;
				case "NetStream.Play.PublishNotify":
					break;
				case "NetStream.Buffer.Full" :
					break;
				case "NetStream.Buffer.Empty" :
					
					break;
				case "NetStream.Play.Start" :
					
					break;
				case "NetStream.Play.Stop" :
					
					//stream.resume();
					
					break;
			}
		}
		public function onMetaData(infoObject:Object):void
		{
			if(infoObject.duration != null)
			{
				// initialize the HUD controls after the meta data is got
				_vduration=infoObject.duration;
				loadControls();
			}
			
		}
		private function exit():void
		{	
			// cleanup procedures... remove all events
			// null all objects
			removeEventListener(Event.ADDED_TO_STAGE,init);
			removeEventListener(Event.REMOVED_FROM_STAGE,exit);
		}
		
	}
}