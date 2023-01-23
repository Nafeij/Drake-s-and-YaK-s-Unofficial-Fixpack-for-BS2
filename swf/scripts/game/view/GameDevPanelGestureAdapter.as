package game.view
{
   import com.stoicstudio.platform.PlatformFlash;
   import flash.display.Stage;
   import flash.geom.Rectangle;
   import org.gestouch.events.GestureEvent;
   import org.gestouch.gestures.TapGesture;
   
   public class GameDevPanelGestureAdapter
   {
       
      
      private var wrapper:GameWrapper;
      
      private var singleTap:TapGesture;
      
      private var hitbox:Rectangle;
      
      public function GameDevPanelGestureAdapter(param1:GameWrapper)
      {
         this.hitbox = new Rectangle();
         super();
         this.wrapper = param1;
         this.checkGestureAdapter();
      }
      
      public function checkGestureAdapter() : void
      {
         var _loc1_:Stage = PlatformFlash.stage;
         if(this.singleTap)
         {
            this.singleTap.removeEventListener(GestureEvent.GESTURE_RECOGNIZED,this.tapRecognized);
            this.singleTap.dispose();
            this.singleTap = null;
         }
         if(_loc1_)
         {
            this.singleTap = new TapGesture(_loc1_);
            this.singleTap.numTapsRequired = 3;
            this.singleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED,this.tapRecognized);
         }
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         this.hitbox.setTo(param1 - 100,param2 - 100,100,100);
      }
      
      private function tapRecognized(param1:GestureEvent) : void
      {
         if(this.hitbox.containsPoint(this.singleTap.location))
         {
            this.wrapper.toggleDevPanel();
         }
      }
   }
}
