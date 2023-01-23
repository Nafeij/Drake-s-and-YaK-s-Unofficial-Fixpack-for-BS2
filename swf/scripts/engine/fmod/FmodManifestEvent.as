package engine.fmod
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class FmodManifestEvent
   {
      
      public static const schema:Object = {
         "name":"FmodManifestEvent",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "banks":{
               "type":"array",
               "items":"string"
            },
            "completeMarkerPos":{
               "type":"array",
               "items":"number",
               "optional":true
            },
            "oldSustPt":{
               "type":{
                  "type":"object",
                  "properties":{
                     "param":{"type":"string"},
                     "rangeMin":{"type":"number"},
                     "scale":{"type":"number"}
                  }
               },
               "optional":true
            }
         }
      };
       
      
      public var name:String;
      
      public var banks:Array;
      
      public var completeMarkerPos:Vector.<Number>;
      
      public var oldSustPtParam:String = null;
      
      public var oldSustPtRangeMin:Number = -1;
      
      public var oldSustPtScale:Number = -1;
      
      public function FmodManifestEvent()
      {
         this.banks = [];
         this.completeMarkerPos = new Vector.<Number>();
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : FmodManifestEvent
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.name = param1.name;
         for each(_loc3_ in param1.banks)
         {
            this.banks.push(_loc3_ as String);
         }
         if(param1.completeMarkerPos != undefined)
         {
            for each(_loc4_ in param1.completeMarkerPos)
            {
               this.completeMarkerPos.push(_loc4_ as Number);
            }
         }
         if(param1.oldSustPt != undefined)
         {
            this.oldSustPtParam = param1.oldSustPt.param;
            this.oldSustPtRangeMin = param1.oldSustPt.rangeMin;
            this.oldSustPtScale = param1.oldSustPt.scale;
         }
         return this;
      }
      
      public function isOldSustPt() : Boolean
      {
         return this.oldSustPtParam != null;
      }
      
      public function hasCompleteMarkers() : Boolean
      {
         return this.completeMarkerPos.length > 0;
      }
   }
}
