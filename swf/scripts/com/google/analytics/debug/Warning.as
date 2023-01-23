package com.google.analytics.debug
{
   import flash.events.TextEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class Warning extends Label
   {
       
      
      private var _timer:Timer;
      
      public function Warning(param1:String = "", param2:uint = 3000)
      {
         super(param1,"uiWarning",Style.warningColor,Align.top,false);
         margin.top = 32;
         if(param2 > 0)
         {
            this._timer = new Timer(param2,1);
            this._timer.start();
            this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onComplete,false,0,true);
         }
      }
      
      public function close() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      override public function onLink(param1:TextEvent) : void
      {
         switch(param1.text)
         {
            case "hide":
               this.close();
         }
      }
      
      public function onComplete(param1:TimerEvent) : void
      {
         this.close();
      }
   }
}
