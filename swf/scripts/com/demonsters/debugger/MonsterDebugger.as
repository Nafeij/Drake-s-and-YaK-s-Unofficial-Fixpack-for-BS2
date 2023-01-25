package com.demonsters.debugger
{
   import flash.display.DisplayObject;
   
   public class MonsterDebugger
   {
      
      private static var _enabled:Boolean = true;
      
      private static var _initialized:Boolean = false;
      
      internal static const VERSION:Number = 3.01;
      
      public static var logger:Function;
       
      
      public function MonsterDebugger()
      {
         super();
      }
      
      public static function initialize(param1:Object, param2:String = "127.0.0.1", param3:Function = null) : void
      {
         if(!_initialized)
         {
            _initialized = true;
            MonsterDebuggerCore.base = param1;
            MonsterDebuggerCore.initialize();
            MonsterDebuggerConnection.initialize();
            MonsterDebuggerConnection.address = param2;
            MonsterDebuggerConnection.onConnect = param3;
            MonsterDebuggerConnection.connect();
         }
      }
      
      public static function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public static function set enabled(param1:Boolean) : void
      {
         _enabled = param1;
      }
      
      public static function trace(param1:*, param2:*, param3:String = "", param4:String = "", param5:uint = 0, param6:int = 5) : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.trace(param1,param2,param3,param4,param5,param6);
         }
      }
      
      public static function log(... rest) : void
      {
         var target:String = null;
         var stack:String = null;
         var lines:Array = null;
         var s:String = null;
         var bracketIndex:int = 0;
         var methodIndex:int = 0;
         var args:Array = rest;
         if(_initialized && _enabled)
         {
            if(args.length == 0)
            {
               return;
            }
            target = "Log";
            try
            {
               throw new Error();
            }
            catch(e:Error)
            {
               stack = String(e.getStackTrace());
               if(stack != null && stack != "")
               {
                  stack = stack.split("\t").join("");
                  lines = stack.split("\n");
                  if(lines.length > 2)
                  {
                     lines.shift();
                     lines.shift();
                     s = String(lines[0]);
                     s = s.substring(3,s.length);
                     bracketIndex = s.indexOf("[");
                     methodIndex = s.indexOf("/");
                     if(bracketIndex == -1)
                     {
                        bracketIndex = s.length;
                     }
                     if(methodIndex == -1)
                     {
                        methodIndex = bracketIndex;
                     }
                     target = MonsterDebuggerUtils.parseType(s.substring(0,methodIndex));
                     if(target == "<anonymous>")
                     {
                        target = "";
                     }
                     if(target == "")
                     {
                        target = "Log";
                     }
                  }
               }
               if(args.length == 1)
               {
                  MonsterDebuggerCore.trace(target,args[0],"","",0,5);
               }
               else
               {
                  MonsterDebuggerCore.trace(target,args,"","",0,5);
               }
            }
         }
      }
      
      public static function snapshot(param1:*, param2:DisplayObject, param3:String = "", param4:String = "") : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.snapshot(param1,param2,param3,param4);
         }
      }
      
      public static function breakpoint(param1:*, param2:String = "breakpoint") : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.breakpoint(param1,param2);
         }
      }
      
      public static function inspect(param1:*) : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.inspect(param1);
         }
      }
      
      public static function clear() : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerCore.clear();
         }
      }
      
      public static function hasPlugin(param1:String) : Boolean
      {
         if(_initialized)
         {
            return MonsterDebuggerCore.hasPlugin(param1);
         }
         return false;
      }
      
      public static function registerPlugin(param1:Class) : void
      {
         var _loc2_:MonsterDebuggerPlugin = null;
         if(_initialized)
         {
            _loc2_ = new param1();
            MonsterDebuggerCore.registerPlugin(_loc2_.id,_loc2_);
         }
      }
      
      public static function unregisterPlugin(param1:String) : void
      {
         if(_initialized)
         {
            MonsterDebuggerCore.unregisterPlugin(param1);
         }
      }
      
      internal static function send(param1:String, param2:Object) : void
      {
         if(_initialized && _enabled)
         {
            MonsterDebuggerConnection.send(param1,param2,false);
         }
      }
   }
}
