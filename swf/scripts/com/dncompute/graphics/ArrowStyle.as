package com.dncompute.graphics
{
   public class ArrowStyle
   {
       
      
      public var headWidth:Number = -1;
      
      public var headLength:Number = 10;
      
      public var shaftThickness:Number = 2;
      
      public var shaftPosition:Number = 0;
      
      public var shaftControlPosition:Number = 0.5;
      
      public var shaftControlSize:Number = 0.5;
      
      public var edgeControlPosition:Number = 0.5;
      
      public var edgeControlSize:Number = 0.5;
      
      public function ArrowStyle(param1:Object = null)
      {
         var _loc2_:String = null;
         super();
         if(param1 != null)
         {
            for(_loc2_ in param1)
            {
               this[_loc2_] = param1[_loc2_];
            }
         }
      }
   }
}
