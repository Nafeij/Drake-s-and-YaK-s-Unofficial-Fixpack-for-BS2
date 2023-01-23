package com.demonsters.debugger
{
   internal interface IMonsterDebuggerConnection
   {
       
      
      function set address(param1:String) : void;
      
      function set onConnect(param1:Function) : void;
      
      function get connected() : Boolean;
      
      function processQueue() : void;
      
      function send(param1:String, param2:Object, param3:Boolean = false) : void;
      
      function connect() : void;
   }
}
