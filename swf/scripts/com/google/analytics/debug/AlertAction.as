package com.google.analytics.debug
{
   public class AlertAction
   {
       
      
      private var _callback;
      
      public var activator:String;
      
      public var container:Alert;
      
      public var name:String;
      
      public function AlertAction(param1:String, param2:String, param3:*)
      {
         super();
         this.name = param1;
         this.activator = param2;
         this._callback = param3;
      }
      
      public function execute() : void
      {
         if(this._callback)
         {
            if(this._callback is Function)
            {
               (this._callback as Function)();
            }
            else if(this._callback is String)
            {
               this.container[this._callback]();
            }
         }
      }
   }
}
