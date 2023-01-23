package engine.core.util
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
   public class ClickableBitmap extends Bitmap
   {
      
      private static const ZERO:Point = new Point(0,0);
       
      
      public var alphaHitThreshold:uint = 34;
      
      public function ClickableBitmap(param1:BitmapData = null, param2:String = "auto", param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override public function hitTestPoint(param1:Number, param2:Number, param3:Boolean = false) : Boolean
      {
         var _loc4_:Point = null;
         if(bitmapData != null && param3 == true)
         {
            _loc4_ = globalToLocal(new Point(param1,param2));
            return bitmapData.hitTest(ZERO,this.alphaHitThreshold,_loc4_);
         }
         return super.hitTestPoint(param1,param2,param3);
      }
   }
}
