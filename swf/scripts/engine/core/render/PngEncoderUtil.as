package engine.core.render
{
   import flash.display.BitmapData;
   import flash.display.PNGEncoderOptions;
   import flash.utils.ByteArray;
   
   public class PngEncoderUtil
   {
       
      
      public function PngEncoderUtil()
      {
         super();
      }
      
      public static function pngEncode(param1:BitmapData, param2:Boolean) : ByteArray
      {
         var _loc3_:PNGEncoderOptions = new PNGEncoderOptions(param2);
         return param1.encode(param1.rect,_loc3_,new ByteArray());
      }
   }
}
