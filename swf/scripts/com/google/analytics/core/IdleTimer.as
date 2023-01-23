package com.google.analytics.core
{
   import com.google.analytics.debug.DebugConfiguration;
   import com.google.analytics.debug.VisualDebugMode;
   import com.google.analytics.v4.Configuration;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class IdleTimer
   {
       
      
      private var _loop:Timer;
      
      private var _session:Timer;
      
      private var _debug:DebugConfiguration;
      
      private var _stage:Stage;
      
      private var _buffer:Buffer;
      
      private var _lastMove:int;
      
      private var _inactivity:Number;
      
      public function IdleTimer(param1:Configuration, param2:DebugConfiguration, param3:DisplayObject, param4:Buffer)
      {
         super();
         var _loc5_:Number = param1.idleLoop;
         var _loc6_:Number = param1.idleTimeout;
         var _loc7_:Number = param1.sessionTimeout;
         this._loop = new Timer(_loc5_ * 1000);
         this._session = new Timer(_loc7_ * 1000,1);
         this._debug = param2;
         this._stage = param3.stage;
         this._buffer = param4;
         this._lastMove = getTimer();
         this._inactivity = _loc6_ * 1000;
         this._debug.info("delay: " + _loc5_ + "sec , inactivity: " + _loc6_ + "sec, sessionTimeout: " + _loc7_,VisualDebugMode.geek);
         this._loop.start();
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         this._lastMove = getTimer();
         if(this._session.running)
         {
            this._debug.info("session timer reset",VisualDebugMode.geek);
            this._session.reset();
         }
      }
      
      public function checkForIdle(param1:TimerEvent) : void
      {
         var _loc2_:int = getTimer();
         if(_loc2_ - this._lastMove >= this._inactivity)
         {
            if(!this._session.running)
            {
               this._debug.info("session timer start",VisualDebugMode.geek);
               this._session.start();
            }
         }
      }
      
      public function endSession(param1:TimerEvent) : void
      {
         this._session.removeEventListener(TimerEvent.TIMER_COMPLETE,this.endSession);
         this._debug.info("session timer end session",VisualDebugMode.geek);
         this._session.reset();
         this._buffer.resetCurrentSession();
         this._debug.info(this._buffer.utmb.toString(),VisualDebugMode.geek);
         this._debug.info(this._buffer.utmc.toString(),VisualDebugMode.geek);
         this._session.addEventListener(TimerEvent.TIMER_COMPLETE,this.endSession);
      }
   }
}
