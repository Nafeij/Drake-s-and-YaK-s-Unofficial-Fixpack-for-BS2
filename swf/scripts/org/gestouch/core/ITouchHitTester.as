package org.gestouch.core
{
   import flash.geom.Point;
   
   public interface ITouchHitTester
   {
       
      
      function hitTest(param1:Point, param2:Object = null) : Object;
   }
}
