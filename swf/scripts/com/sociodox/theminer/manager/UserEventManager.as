package com.sociodox.theminer.manager
{
   import com.sociodox.theminer.data.UserEventEntry;
   
   public class UserEventManager
   {
       
      
      private var mUserEvents:Vector.<UserEventEntry>;
      
      public function UserEventManager()
      {
         super();
         this.mUserEvents = new Vector.<UserEventEntry>();
      }
      
      public function GetUserEvents() : Vector.<UserEventEntry>
      {
         return this.mUserEvents;
      }
      
      public function OnSharedEvent(param1:*) : void
      {
         var _loc2_:UserEventEntry = new UserEventEntry();
         if(param1.hasOwnProperty("Name"))
         {
            _loc2_.Name = param1["Name"];
         }
         else
         {
            _loc2_.Name = "-";
         }
         if(param1.hasOwnProperty("Info"))
         {
            _loc2_.Info = param1["Info"];
         }
         else
         {
            _loc2_.Info = "-";
         }
         if(param1.hasOwnProperty("Value1"))
         {
            _loc2_.Value1 = param1["Value1"];
         }
         else
         {
            _loc2_.Value1 = "-";
         }
         if(param1.hasOwnProperty("Value2"))
         {
            _loc2_.Value2 = param1["Value2"];
         }
         else
         {
            _loc2_.Value2 = "-";
         }
         if(param1.hasOwnProperty("StatusLabel"))
         {
            _loc2_.StatusLabel = param1["StatusLabel"];
         }
         else
         {
            _loc2_.StatusLabel = "-";
         }
         if(param1.hasOwnProperty("StatusProgress"))
         {
            _loc2_.StatusProgress = param1["StatusProgress"];
         }
         else
         {
            _loc2_.StatusProgress = -1;
         }
         if(param1.hasOwnProperty("StatusColor"))
         {
            _loc2_.StatusColor = param1["StatusColor"];
         }
         else
         {
            _loc2_.StatusColor = 0;
         }
         if(param1.hasOwnProperty("Priority"))
         {
            _loc2_.Priority = param1["Priority"];
         }
         else
         {
            _loc2_.Priority = 0;
         }
         if(param1.hasOwnProperty("Visible"))
         {
            _loc2_.Visible = param1["Visible"];
         }
         else
         {
            _loc2_.Visible = true;
         }
         if(param1.hasOwnProperty("IsError"))
         {
            _loc2_.IsError = param1["IsError"];
         }
         else
         {
            _loc2_.IsError = false;
         }
         this.mUserEvents.push(_loc2_);
         param1.stopPropagation();
         param1.stopImmediatePropagation();
      }
      
      public function AddCustomUserEvent(param1:String = null, param2:String = null, param3:String = null, param4:String = null, param5:String = null, param6:Number = -1, param7:uint = 4278190080, param8:int = 0, param9:Boolean = true, param10:Boolean = false) : UserEventEntry
      {
         var _loc11_:UserEventEntry = new UserEventEntry();
         if(param1)
         {
            _loc11_.Name = param1;
         }
         else
         {
            _loc11_.Name = null;
         }
         if(param2)
         {
            _loc11_.Info = param2;
         }
         else
         {
            _loc11_.Info = null;
         }
         _loc11_.StatusColor = param7;
         if(param5)
         {
            _loc11_.StatusLabel = param5;
         }
         else
         {
            _loc11_.StatusLabel = null;
         }
         _loc11_.StatusProgress = param6;
         if(param3)
         {
            _loc11_.Value1 = param3;
         }
         else
         {
            _loc11_.Value1 = null;
         }
         if(param4)
         {
            _loc11_.Value2 = param4;
         }
         else
         {
            _loc11_.Value2 = null;
         }
         _loc11_.Priority = param8;
         _loc11_.Visible = param9;
         _loc11_.IsError = param10;
         if(param1 || param2 || param6 != -1 || param3 || Boolean(param4))
         {
            this.mUserEvents.push(_loc11_);
            return _loc11_;
         }
         return null;
      }
   }
}
