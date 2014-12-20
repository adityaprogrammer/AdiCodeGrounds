package HUD
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.sampler.StackFrame;
	import flash.system.Security;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	public class ASHUDController
	{
		private var scrubber:MovieClip;
		private var scrubberValue:Number;
		private var scrubInterval:uint;
		private var playPause:MovieClip;
		private var videoInterval:uint;
		private var _vduration:Number;
		private var _vtitle:String;
		private var stream:NetStream
		private var hud:HUDContainer;
		public function ASHUDController(_stream:NetStream,_hud:HUDContainer,title:String,duration:Number)
		{
			
			stream=_stream;
			hud=_hud;
			_vduration=duration;
			videoInterval= setInterval(videoStatus, 100);
			scrubber=hud.Scrubber;
			hud.Title.text=title;
			playPause=hud.playPauseBtn;
			playPause.buttonMode=true;
			playPause.enabled=true;
			playPause.addEventListener(MouseEvent.CLICK,onBtnClick);
			scrubber.btn.buttonMode = true;
			scrubberValue=0;
			scrubber.btn.addEventListener(MouseEvent.MOUSE_DOWN,sliderPress);
			
		}
		
		private function videoStatus():void
		{
			var amountLoaded:Number = stream.bytesLoaded / stream.bytesTotal;
			//videoTrackDownload.width = amountLoaded * 340;
			scrubber.btn.x =scrubber.bar.x+ (stream.time / _vduration) * 100;
			displayTime(stream.time, _vduration);
		}
		private function sliderPress(e:Event):void
		{
			scrubber.btn.startDrag(false,new Rectangle(scrubber.bar.x,scrubber.bar.y,scrubber.bar.width,0));
			scrubber.stage.addEventListener(MouseEvent.MOUSE_UP,sliderRelease);
			clearInterval(videoInterval);
			scrubInterval = setInterval(scrubTimeline, 10);
		}
		private function scrubTimeline():void
		{
			displayTime(stream.time, _vduration);
			var num:Number= 100*(scrubber.btn.x-scrubber.bar.x)/scrubber.bar.width;
			scrubberValue=Number(num.toPrecision(2));
			
			var seekVal:Number=Math.floor((scrubberValue*_vduration)/100);
			stream.seek(seekVal);  //  seeks the video to the frame 
		}
		private function displayTime(duration:Number,currentTime:Number):void
		{
			
			hud.dateTimeHolder.Duration.text=HMSConverter(duration)+"/";
			hud.dateTimeHolder.Time.text="/"+HMSConverter(currentTime);
		}
		// move to hud class
		private function HMSConverter(time:Number):String 
		{
			var ns_seconds:Number = time;
			var minutes:Number = Math.floor(ns_seconds/60);
			var seconds:Number = Math.floor(ns_seconds%60);
			var hours:Number=Math.floor(minutes/60);
			var seconds_txt:String;
			var minutes_txt:String;
			var hours_txt:String;
			
			if (seconds<10) {
				seconds_txt = "0"+seconds;
			}
			else
			{
				seconds_txt=String(seconds);
			}
			if (minutes<10) {
				minutes_txt = "0"+minutes;
			}else
			{
				minutes_txt = String(minutes);
			}
			if (hours<10) {
				hours_txt = "0"+hours;
			}else
			{
				hours_txt=String(hours);
			}
			return (hours_txt+":"+minutes_txt+":"+seconds_txt);
		}
		private function sliderRelease( e:MouseEvent):void
		{
			scrubber.stage.removeEventListener(MouseEvent.MOUSE_UP,sliderRelease);
			scrubber.btn.stopDrag();
			var num:Number= 100*(scrubber.btn.x-scrubber.bar.x)/scrubber.bar.width;
			scrubberValue=Number(num.toPrecision(2));
			clearInterval(scrubInterval);
			var seekVal:Number=Math.floor((scrubberValue*_vduration)/100);
			//trace("slider value is  " +seekVal);
			stream.seek(seekVal);
			videoInterval= setInterval(videoStatus, 100);
		}
		private function onBtnClick(e:Event):void
		{
			switch(e.currentTarget.name)
			{
				case "playPauseBtn":
					if(playPause.currentLabel=="play")
					{
						playPause.gotoAndStop("pause");
						callPlay();
					}else
					{
						playPause.gotoAndStop("play");
						callPause();
					}
					break;
			}
		}
		private function callPause():void
		{
			stream.pause();
		}
		private function callPlay():void
		{
			stream.resume();
		}
	}
}