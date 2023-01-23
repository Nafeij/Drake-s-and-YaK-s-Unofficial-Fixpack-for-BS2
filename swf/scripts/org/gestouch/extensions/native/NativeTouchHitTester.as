package org.gestouch.extensions.native
{
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.geom.Point;
   import org.gestouch.core.ITouchHitTester;
   
   public class NativeTouchHitTester implements ITouchHitTester
   {
       
      
      private var stage:Stage;
      
      public function NativeTouchHitTester(param1:Stage)
      {
         super();
         if(!param1)
         {
            throw ArgumentError("Missing stage argument.");
         }
         this.stage = param1;
      }
      
      public function hitTest(param1:Point, param2:Object = null) : Object
      {
         if(Boolean(param2) && param2 is DisplayObject)
         {
            return param2;
         }
         return DisplayObjectUtils.getTopTarget(this.stage,param1);
      }
   }
}
