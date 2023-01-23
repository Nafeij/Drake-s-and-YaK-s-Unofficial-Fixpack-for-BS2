package org.gestouch.core
{
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public final class GestureState
   {
      
      public static const POSSIBLE:GestureState = new GestureState("POSSIBLE");
      
      public static const RECOGNIZED:GestureState = new GestureState("RECOGNIZED",true);
      
      public static const BEGAN:GestureState = new GestureState("BEGAN");
      
      public static const CHANGED:GestureState = new GestureState("CHANGED");
      
      public static const ENDED:GestureState = new GestureState("ENDED",true);
      
      public static const CANCELLED:GestureState = new GestureState("CANCELLED",true);
      
      public static const FAILED:GestureState = new GestureState("FAILED",true);
      
      private static var allStatesInitialized:Boolean;
      
      {
         _initClass();
      }
      
      private var name:String;
      
      private var eventType:String;
      
      private var validTransitionStateMap:Dictionary;
      
      private var _isEndState:Boolean = false;
      
      public function GestureState(param1:String, param2:Boolean = false)
      {
         this.validTransitionStateMap = new Dictionary();
         super();
         if(allStatesInitialized)
         {
            throw new IllegalOperationError("You cannot create gesture states." + "Use predefined constats like GestureState.RECOGNIZED");
         }
         this.name = "GestureState." + param1;
         this.eventType = "gesture" + param1.charAt(0).toUpperCase() + param1.substr(1).toLowerCase();
         this._isEndState = param2;
      }
      
      private static function _initClass() : void
      {
         POSSIBLE.setValidNextStates(RECOGNIZED,BEGAN,FAILED);
         RECOGNIZED.setValidNextStates(POSSIBLE);
         BEGAN.setValidNextStates(CHANGED,ENDED,CANCELLED);
         CHANGED.setValidNextStates(CHANGED,ENDED,CANCELLED);
         ENDED.setValidNextStates(POSSIBLE);
         FAILED.setValidNextStates(POSSIBLE);
         CANCELLED.setValidNextStates(POSSIBLE);
         allStatesInitialized = true;
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      private function setValidNextStates(... rest) : void
      {
         var _loc2_:GestureState = null;
         for each(_loc2_ in rest)
         {
            this.validTransitionStateMap[_loc2_] = true;
         }
      }
      
      gestouch_internal function toEventType() : String
      {
         return this.eventType;
      }
      
      gestouch_internal function canTransitionTo(param1:GestureState) : Boolean
      {
         return param1 in this.validTransitionStateMap;
      }
      
      gestouch_internal function get isEndState() : Boolean
      {
         return this._isEndState;
      }
   }
}
