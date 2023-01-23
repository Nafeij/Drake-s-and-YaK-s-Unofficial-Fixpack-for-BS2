package org.gestouch.gestures
{
   [Event(name="gestureCancelled",type="org.gestouch.events.GestureEvent")]
   [Event(name="gestureEnded",type="org.gestouch.events.GestureEvent")]
   [Event(name="gestureChanged",type="org.gestouch.events.GestureEvent")]
   [Event(name="gestureBegan",type="org.gestouch.events.GestureEvent")]
   public class AbstractContinuousGesture extends Gesture
   {
       
      
      public function AbstractContinuousGesture(param1:Object = null)
      {
         super(param1);
      }
   }
}
