package engine.core.util
{
   import com.stoicstudio.platform.PlatformInput;
   import flash.system.Capabilities;
   
   public class InputUtil
   {
      
      private static const CLICK_DISTANCE_PIXELS:int = 8;
      
      private static const TOUCH_DISTANCE_INCHES:Number = 0.15;
       
      
      public var clickDistancePixelsSq:Number = 0;
      
      public var clickDistancePixels:Number = 0;
      
      public var isTouch:Boolean;
      
      public function InputUtil()
      {
         super();
         var _loc1_:Number = Capabilities.screenDPI;
         if(PlatformInput.isTouch)
         {
            this.clickDistancePixels = TOUCH_DISTANCE_INCHES * _loc1_;
            this.isTouch = true;
         }
         else
         {
            this.clickDistancePixels = CLICK_DISTANCE_PIXELS;
         }
         this.clickDistancePixelsSq = this.clickDistancePixels * this.clickDistancePixels;
      }
   }
}
