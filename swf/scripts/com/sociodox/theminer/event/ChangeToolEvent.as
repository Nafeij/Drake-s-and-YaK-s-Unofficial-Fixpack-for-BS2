package com.sociodox.theminer.event
{
   import flash.events.Event;
   
   public class ChangeToolEvent extends Event
   {
      
      public static const CHANGE_TOOL_EVENT:String = "ChangeToolEvent";
       
      
      public var mTool:Class;
      
      public function ChangeToolEvent(param1:Class)
      {
         this.mTool = param1;
         super(CHANGE_TOOL_EVENT,true,false);
      }
   }
}
