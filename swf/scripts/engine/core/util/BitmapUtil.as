package engine.core.util
{
   import flash.display.BitmapData;
   
   public class BitmapUtil
   {
       
      
      public function BitmapUtil()
      {
         super();
      }
      
      public static function drawWithQuality(param1:BitmapData, ... rest) : void
      {
         if("drawWithQuality" in param1)
         {
            param1.drawWithQuality.apply(null,rest);
         }
         else
         {
            param1.draw.apply(null,rest.slice(0,-1));
         }
      }
   }
}
