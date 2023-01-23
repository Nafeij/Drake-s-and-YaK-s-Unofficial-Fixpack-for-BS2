package com.google.analytics.core
{
   import flash.net.URLRequest;
   import flash.utils.getTimer;
   
   public class RequestObject
   {
       
      
      public var start:int;
      
      public var end:int;
      
      public var request:URLRequest;
      
      public function RequestObject(param1:URLRequest)
      {
         super();
         this.start = getTimer();
         this.request = param1;
      }
      
      public function get duration() : int
      {
         if(!this.hasCompleted())
         {
            return 0;
         }
         return this.end - this.start;
      }
      
      public function complete() : void
      {
         this.end = getTimer();
      }
      
      public function hasCompleted() : Boolean
      {
         return this.end > 0;
      }
      
      public function toString() : String
      {
         var _loc1_:Array = [];
         _loc1_.push("duration: " + this.duration + "ms");
         _loc1_.push("url: " + this.request.url);
         return "{ " + _loc1_.join(", ") + " }";
      }
   }
}
