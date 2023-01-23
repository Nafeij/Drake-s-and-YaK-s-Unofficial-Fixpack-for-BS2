package com.stoicstudio.platform
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import starling.core.Starling;
   
   public class KeyboardMouseBlocker
   {
       
      
      private var dispatchers:Vector.<EventDispatcher>;
      
      private var blockedEvents:Array;
      
      public function KeyboardMouseBlocker()
      {
         this.dispatchers = new Vector.<EventDispatcher>();
         this.blockedEvents = [MouseEvent.CLICK,MouseEvent.MOUSE_DOWN,MouseEvent.MOUSE_UP,MouseEvent.MOUSE_MOVE,MouseEvent.MOUSE_OUT,MouseEvent.MOUSE_OVER,MouseEvent.MOUSE_WHEEL,MouseEvent.ROLL_OUT,MouseEvent.ROLL_OVER,KeyboardEvent.KEY_DOWN,KeyboardEvent.KEY_UP];
         super();
         this.blockAll(PlatformFlash.stage);
         if(Boolean(Starling.current) && Boolean(Starling.current.nativeStage))
         {
            this.blockAll(Starling.current.nativeStage);
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:EventDispatcher = null;
         var _loc2_:String = null;
         for each(_loc1_ in this.dispatchers)
         {
            for each(_loc2_ in this.blockedEvents)
            {
               _loc1_.removeEventListener(_loc2_,this.allEventBlocker);
            }
         }
         this.dispatchers = null;
      }
      
      private function blockAll(param1:EventDispatcher) : void
      {
         var _loc2_:String = null;
         if(!param1)
         {
            return;
         }
         this.dispatchers.push(param1);
         for each(_loc2_ in this.blockedEvents)
         {
            param1.addEventListener(_loc2_,this.allEventBlocker);
         }
      }
      
      private function allEventBlocker(param1:Event) : void
      {
         param1.stopImmediatePropagation();
      }
   }
}
