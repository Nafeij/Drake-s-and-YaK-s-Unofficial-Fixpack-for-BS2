package com.sociodox.theminer.data
{
   import flash.events.Event;
   
   public class UserEventEntry extends Event
   {
      
      public static const USER_EVENT:String = "TheMinerUserEvent";
      
      private static var GLOBAL_ID:int = 0;
       
      
      public var Name:String = "";
      
      public var Info:String = "";
      
      public var StatusColor:uint = 4287137928;
      
      public var StatusLabel:String = "";
      
      public var StatusProgress:Number = -1;
      
      public var Value1:String;
      
      public var Value2:String;
      
      public var Id:int = 0;
      
      public var Priority:int = 0;
      
      public var Visible:Boolean = true;
      
      public var IsError:Boolean = false;
      
      public function UserEventEntry()
      {
         super(USER_EVENT,false,true);
         this.Id = GLOBAL_ID++;
      }
      
      public function Set(param1:String = null, param2:String = null, param3:String = null, param4:String = null, param5:String = null, param6:Number = -1, param7:uint = 4287137928, param8:int = 0, param9:Boolean = true) : void
      {
         if(param1)
         {
            this.Name = param1;
         }
         else
         {
            this.Name = "-";
         }
         if(param2)
         {
            this.Info = param2;
         }
         else
         {
            this.Info = "-";
         }
         this.StatusColor = param7;
         if(param5)
         {
            this.StatusLabel = param5;
         }
         else
         {
            this.StatusLabel = "-";
         }
         this.StatusProgress = param6;
         if(param3)
         {
            this.Value1 = param3;
         }
         else
         {
            this.Value1 = "-";
         }
         if(param4)
         {
            this.Value2 = param4;
         }
         else
         {
            this.Value2 = "-";
         }
         this.Priority = param8;
         this.Visible = param9;
      }
   }
}
