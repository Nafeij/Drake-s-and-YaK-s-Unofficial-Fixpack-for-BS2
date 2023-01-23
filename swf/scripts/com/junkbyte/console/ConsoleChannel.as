package com.junkbyte.console
{
   import flash.display.DisplayObjectContainer;
   
   public class ConsoleChannel
   {
      
      public static const GLOBAL_CHANNEL:String = " * ";
      
      public static const DEFAULT_CHANNEL:String = "-";
      
      public static const CONSOLE_CHANNEL:String = "C";
      
      public static const FILTER_CHANNEL:String = "~";
       
      
      private var _c;
      
      private var _name:String;
      
      public var enabled:Boolean = true;
      
      public function ConsoleChannel(param1:*, param2:Console = null)
      {
         super();
         this._name = Console.MakeChannelName(param1);
         if(this._name == ConsoleChannel.GLOBAL_CHANNEL)
         {
            this._name = ConsoleChannel.DEFAULT_CHANNEL;
         }
         this._c = !!param2 ? param2 : Cc;
      }
      
      public function add(param1:*, param2:Number = 2, param3:Boolean = false) : void
      {
         if(this.enabled)
         {
            this._c.ch(this._name,param1,param2,param3);
         }
      }
      
      public function log(... rest) : void
      {
         this.multiadd(this._c.logch,rest);
      }
      
      public function info(... rest) : void
      {
         this.multiadd(this._c.infoch,rest);
      }
      
      public function debug(... rest) : void
      {
         this.multiadd(this._c.debugch,rest);
      }
      
      public function warn(... rest) : void
      {
         this.multiadd(this._c.warnch,rest);
      }
      
      public function error(... rest) : void
      {
         this.multiadd(this._c.errorch,rest);
      }
      
      public function fatal(... rest) : void
      {
         this.multiadd(this._c.fatalch,rest);
      }
      
      private function multiadd(param1:Function, param2:Array) : void
      {
         if(this.enabled)
         {
            param1.apply(null,new Array(this._name).concat(param2));
         }
      }
      
      public function stack(param1:*, param2:int = -1, param3:Number = 5) : void
      {
         if(this.enabled)
         {
            this._c.stackch(this.name,param1,param2,param3);
         }
      }
      
      public function explode(param1:Object, param2:int = 3) : void
      {
         this._c.explodech(this.name,param1,param2);
      }
      
      public function map(param1:DisplayObjectContainer, param2:uint = 0) : void
      {
         this._c.mapch(this.name,param1,param2);
      }
      
      public function inspect(param1:Object, param2:Boolean = true) : void
      {
         this._c.inspectch(this.name,param1,param2);
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function clear() : void
      {
         this._c.clear(this._name);
      }
      
      public function toString() : String
      {
         return "[ConsoleChannel " + this.name + "]";
      }
   }
}
