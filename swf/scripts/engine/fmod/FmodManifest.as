package engine.fmod
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class FmodManifest
   {
      
      public static const schema:Object = {
         "name":"FmodManifest",
         "type":"object",
         "properties":{"events":{
            "type":"array",
            "items":FmodManifestEvent.schema
         }}
      };
       
      
      private var _events:Dictionary;
      
      public function FmodManifest()
      {
         this._events = new Dictionary();
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : FmodManifest
      {
         var _loc3_:Object = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         for each(_loc3_ in param1.events)
         {
            this.addEvent(new FmodManifestEvent().fromJson(_loc3_,param2));
         }
         return this;
      }
      
      public function addManifest(param1:FmodManifest) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1._events)
         {
            this.addEvent(param1._events[_loc2_]);
         }
      }
      
      private function addEvent(param1:FmodManifestEvent) : void
      {
         this._events[param1.name] = param1;
      }
      
      public function getEvent(param1:String) : FmodManifestEvent
      {
         return this._events[param1];
      }
      
      public function hasEvent(param1:String) : Boolean
      {
         return param1 in this._events;
      }
      
      public function debugDump(param1:ILogger) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:FmodManifestEvent = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         param1.debug("fmod manifest dump:" + _loc3_ + " " + _loc5_);
         for(_loc2_ in this._events)
         {
            _loc3_ = _loc2_ as String;
            _loc4_ = this._events[_loc3_];
            _loc5_ = "banks:";
            for each(_loc6_ in _loc4_.banks)
            {
               _loc5_ = _loc5_ + " " + _loc6_;
            }
            param1.debug("  manifest " + _loc3_ + " " + _loc5_);
         }
      }
   }
}
