package air.fmodstudio.ane
{
   import flash.desktop.NativeApplication;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.external.ExtensionContext;
   import flash.utils.ByteArray;
   
   public class FmodStudio implements IEventDispatcher
   {
      
      public static const CONTEXT_ID:String = "air.fmodstudio.ane.FmodStudioAneContext";
       
      
      private var context:ExtensionContext;
      
      private var _disposed:Boolean = false;
      
      public function FmodStudio()
      {
         super();
         var _loc1_:String = "";
         if(NativeApplication.nativeApplication != null)
         {
            _loc1_ = String(NativeApplication.nativeApplication.applicationID);
            if(_loc1_.indexOf("air.") != 0)
            {
               _loc1_ = "air." + _loc1_ + "/" + _loc1_;
            }
         }
         this.context = ExtensionContext.createExtensionContext(CONTEXT_ID,_loc1_);
      }
      
      private static function getEventIdBytes(param1:FmodEventId) : ByteArray
      {
         return param1 != null ? param1.bytes : null;
      }
      
      public function hasContext() : Boolean
      {
         return this.context != null;
      }
      
      public function initFMOD(param1:Boolean, param2:int) : Boolean
      {
         if(param2 < 0)
         {
            return false;
         }
         return this.context.call("initFMOD",param1,param2);
      }
      
      public function pause() : Boolean
      {
         return this.context.call("pause");
      }
      
      public function unpause() : Boolean
      {
         return this.context.call("unpause");
      }
      
      public function systemUpdate() : Boolean
      {
         return this.context.call("systemUpdate");
      }
      
      public function loadBank(param1:String, param2:ByteArray) : Boolean
      {
         return this.context.call("loadBank",param1,param2);
      }
      
      public function unloadBank(param1:String) : Boolean
      {
         return this.context.call("unloadBank",param1);
      }
      
      public function playEvent(param1:String) : FmodEventId
      {
         var _loc2_:ByteArray = new ByteArray();
         var _loc3_:Boolean = Boolean(this.context.call("playEvent",param1,_loc2_));
         return _loc3_ ? new FmodEventId(_loc2_) : null;
      }
      
      public function stopEvent(param1:FmodEventId, param2:Boolean) : Boolean
      {
         return this.context.call("stopEvent",getEventIdBytes(param1),param2);
      }
      
      public function getNumEventInsts(param1:String) : int
      {
         return this.context.call("getNumEventInsts",param1) as int;
      }
      
      public function getEventInst(param1:String, param2:int) : FmodEventId
      {
         var _loc3_:ByteArray = new ByteArray();
         var _loc4_:Boolean = Boolean(this.context.call("getEventInst",param1,param2,_loc3_));
         return _loc4_ ? new FmodEventId(_loc3_) : null;
      }
      
      public function isLooping(param1:FmodEventId) : Boolean
      {
         return this.context.call("isLooping",getEventIdBytes(param1));
      }
      
      public function isPlaying(param1:FmodEventId) : Boolean
      {
         return this.context.call("isPlaying",getEventIdBytes(param1));
      }
      
      public function getEventName(param1:FmodEventId) : String
      {
         var _loc2_:Object = this.context.call("getEventName",getEventIdBytes(param1));
         return _loc2_ != null ? _loc2_ as String : null;
      }
      
      public function startSnapshot(param1:String) : Boolean
      {
         return this.context.call("startSnapshot",param1);
      }
      
      public function stopSnapshot(param1:String) : Boolean
      {
         return this.context.call("stopSnapshot",param1);
      }
      
      public function stopAllSnapshots() : Boolean
      {
         return this.context.call("stopAllSnapshots");
      }
      
      public function getEventTimelinePosition(param1:FmodEventId) : int
      {
         return this.context.call("getEventTimelinePosition",getEventIdBytes(param1)) as int;
      }
      
      public function hasEventDefParameter(param1:String, param2:String) : Boolean
      {
         return this.context.call("hasEventDefParameter",param1,param2) as Boolean;
      }
      
      public function getNumEventParameters(param1:FmodEventId) : int
      {
         return this.context.call("getNumEventParameters",getEventIdBytes(param1)) as int;
      }
      
      public function getEventParameterName(param1:FmodEventId, param2:int) : String
      {
         return this.context.call("getEventParameterName",getEventIdBytes(param1),param2) as String;
      }
      
      public function getEventParameterValue(param1:FmodEventId, param2:int) : Number
      {
         return this.context.call("getEventParameterValue",getEventIdBytes(param1),param2) as Number;
      }
      
      public function getEventParameterValueByName(param1:FmodEventId, param2:String) : Number
      {
         return this.context.call("getEventParameterValueByName",getEventIdBytes(param1),param2) as Number;
      }
      
      public function setEventParameterValue(param1:FmodEventId, param2:int, param3:Number) : Boolean
      {
         return this.context.call("setEventParameterValue",getEventIdBytes(param1),param2,param3) as Boolean;
      }
      
      public function setEventParameterValueByName(param1:FmodEventId, param2:String, param3:Number) : Boolean
      {
         if(!param2)
         {
            throw new ArgumentError("setEventParameterValueByName invalid name");
         }
         return this.context.call("setEventParameterValueByName",getEventIdBytes(param1),param2,param3) as Boolean;
      }
      
      public function get3dNumListeners() : Number
      {
         return this.context.call("get3dNumListeners") as Number;
      }
      
      public function set3dNumListeners(param1:int) : Boolean
      {
         return this.context.call("set3dNumListeners",param1) as Boolean;
      }
      
      public function set3dListenerPosition(param1:int, param2:Number, param3:Number, param4:Number) : Boolean
      {
         return this.context.call("set3dListenerPosition",param1,param2,param3,param4) as Boolean;
      }
      
      public function set3dEventPosition(param1:FmodEventId, param2:Number, param3:Number, param4:Number) : Boolean
      {
         return this.context.call("set3dEventPosition",getEventIdBytes(param1),param2,param3,param4) as Boolean;
      }
      
      public function getNumBusChildren(param1:String) : int
      {
         return this.context.call("getNumBusChildren",param1) as int;
      }
      
      public function getBusChildName(param1:String, param2:int) : String
      {
         return this.context.call("getBusChildName",param1,param2) as String;
      }
      
      public function getBusMute(param1:String) : Boolean
      {
         return this.context.call("getBusMute",param1) as Boolean;
      }
      
      public function getBusVolume(param1:String) : Number
      {
         return this.context.call("getBusVolume",param1) as Number;
      }
      
      public function setBusMute(param1:String, param2:Boolean) : Boolean
      {
         return this.context.call("setBusMute",param1,param2) as Boolean;
      }
      
      public function setBusVolume(param1:String, param2:Number) : Boolean
      {
         return this.context.call("setBusVolume",param1,param2) as Boolean;
      }
      
      public function getEventVolume(param1:FmodEventId) : Number
      {
         return this.context.call("getEventVolume",getEventIdBytes(param1)) as Number;
      }
      
      public function setEventVolume(param1:FmodEventId, param2:Number) : Boolean
      {
         return this.context.call("setEventVolume",getEventIdBytes(param1),param2) as Boolean;
      }
      
      public function setEventPitchMultiplier(param1:FmodEventId, param2:Number) : Boolean
      {
         return this.context.call("setEventPitchMultiplier",getEventIdBytes(param1),param2) as Boolean;
      }
      
      public function setEventTimelinePos(param1:FmodEventId, param2:int) : Boolean
      {
         return this.context.call("setEventTimelinePos",getEventIdBytes(param1),param2) as Boolean;
      }
      
      public function get disposed() : Boolean
      {
         return this._disposed;
      }
      
      public function dispose() : void
      {
         this._disposed = true;
         this.context.dispose();
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.context.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.context.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.context.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.context.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.context.willTrigger(param1);
      }
   }
}
