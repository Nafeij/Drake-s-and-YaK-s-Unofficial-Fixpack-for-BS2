package com.junkbyte.console.vos
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.console_internal;
   import flash.system.System;
   
   public class GraphMemoryGroup extends GraphGroup
   {
      
      public static const NAME:String = "consoleMemoryGraph";
       
      
      private var console:Console;
      
      public function GraphMemoryGroup(param1:Console)
      {
         super(NAME);
         this.console = param1;
         rect.x = 90;
         rect.y = 15;
         alignRight = true;
         var _loc2_:GraphInterest = new GraphInterest("mb");
         _loc2_.col = 6328575;
         _updateArgs.length = 1;
         interests.push(_loc2_);
         freq = 1000;
         menus.push("G");
         onMenu.add(this.onMenuClick);
      }
      
      protected function onMenuClick(param1:String) : void
      {
         if(param1 == "G")
         {
            this.console.gc();
         }
      }
      
      override protected function dispatchUpdates() : void
      {
         _updateArgs[0] = Math.round(System.totalMemory / 10485.76) / 100;
         console_internal::applyUpdateDispather(_updateArgs);
      }
   }
}
