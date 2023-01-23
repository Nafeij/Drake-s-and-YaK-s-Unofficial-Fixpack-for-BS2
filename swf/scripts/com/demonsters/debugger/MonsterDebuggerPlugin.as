package com.demonsters.debugger
{
   public class MonsterDebuggerPlugin
   {
       
      
      private var _id:String;
      
      public function MonsterDebuggerPlugin(param1:String)
      {
         super();
         this._id = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      protected function send(param1:Object) : void
      {
         MonsterDebugger.send(this._id,param1);
      }
      
      public function handle(param1:MonsterDebuggerData) : void
      {
      }
   }
}
