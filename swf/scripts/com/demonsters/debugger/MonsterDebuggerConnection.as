package com.demonsters.debugger
{
   internal class MonsterDebuggerConnection
   {
      
      private static var connector:IMonsterDebuggerConnection;
       
      
      public function MonsterDebuggerConnection()
      {
         super();
      }
      
      internal static function initialize() : void
      {
         connector = new MonsterDebuggerConnectionDefault();
      }
      
      internal static function set address(param1:String) : void
      {
         connector.address = param1;
      }
      
      internal static function set onConnect(param1:Function) : void
      {
         connector.onConnect = param1;
      }
      
      internal static function get connected() : Boolean
      {
         return connector.connected;
      }
      
      internal static function processQueue() : void
      {
         connector.processQueue();
      }
      
      internal static function send(param1:String, param2:Object, param3:Boolean = false) : void
      {
         connector.send(param1,param2,param3);
      }
      
      internal static function connect() : void
      {
         connector.connect();
      }
   }
}
