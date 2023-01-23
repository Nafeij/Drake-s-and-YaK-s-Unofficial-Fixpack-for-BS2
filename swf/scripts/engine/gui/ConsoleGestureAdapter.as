package engine.gui
{
   import flash.display.Stage;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import org.gestouch.core.GestureState;
   import org.gestouch.events.GestureEvent;
   import org.gestouch.gestures.LongPressGesture;
   import org.gestouch.gestures.TapGesture;
   
   public class ConsoleGestureAdapter
   {
       
      
      private var console:ConsoleGui;
      
      private var longPress:LongPressGesture;
      
      private var singleTap:TapGesture;
      
      public function ConsoleGestureAdapter(param1:ConsoleGui)
      {
         super();
         this.console = param1;
         this.checkGestureAdapter();
      }
      
      public function checkGestureAdapter() : void
      {
         var _loc1_:Stage = this.console.stage;
         if(this.longPress)
         {
            this.longPress.dispose();
            this.longPress = null;
         }
         if(this.singleTap)
         {
            this.singleTap.removeEventListener(GestureEvent.GESTURE_RECOGNIZED,this.tapRecognized);
            this.singleTap.dispose();
            this.singleTap = null;
         }
         if(_loc1_)
         {
            this.longPress = new LongPressGesture(_loc1_);
            this.longPress.numTouchesRequired = 2;
            this.singleTap = new TapGesture(_loc1_);
            this.singleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED,this.tapRecognized);
         }
      }
      
      private function tapRecognized(param1:GestureEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.longPress.state == GestureState.CHANGED || this.longPress.state == GestureState.BEGAN)
         {
            _loc2_ = Point.distance(this.longPress.location,this.singleTap.location);
            _loc3_ = Capabilities.screenDPI;
            _loc4_ = !!_loc3_ ? _loc2_ / Capabilities.screenDPI : 0;
            if(_loc4_ <= 3)
            {
               this.console.out = !this.console.out;
            }
         }
      }
   }
}
