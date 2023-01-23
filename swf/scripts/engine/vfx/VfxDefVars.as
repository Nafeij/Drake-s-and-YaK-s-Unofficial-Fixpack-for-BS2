package engine.vfx
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.NumberVars;
   
   public class VfxDefVars extends VfxDef
   {
      
      public static const schema:Object = {
         "name":"VfxDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "clip":{
               "type":"string",
               "optional":true
            },
            "clips":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "flip":{
               "type":"boolean",
               "optional":true
            },
            "localize":{
               "type":"boolean",
               "optional":true
            },
            "scale":{
               "type":"number",
               "optional":true
            },
            "depth":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function VfxDefVars(param1:Object, param2:ILogger, param3:VfxLibrary)
      {
         var _loc4_:String = null;
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         _name = param1.name;
         _localize = BooleanVars.parse(param1.localize,_localize);
         if(param1.clip)
         {
            if(param1.clips != undefined)
            {
               throw new ArgumentError("Only clip or clips");
            }
            _clipUrls.push(param1.clip);
         }
         else
         {
            if(param1.clips == undefined)
            {
               throw new ArgumentError("Need clip or clips");
            }
            for each(_loc4_ in param1.clips)
            {
               _clipUrls.push(_loc4_);
            }
         }
         if(param1.flip != undefined)
         {
            _flip = Boolean(param1.flip) && (param1.flip is Boolean || param1.flip == "true");
         }
         this.scale = NumberVars.parse(param1.scale,this.scale);
         this.depth = param1.depth;
      }
      
      public static function save(param1:VfxDef) : Object
      {
         var _loc4_:String = null;
         var _loc2_:Object = {
            "name":param1.name,
            "clips":[],
            "flip":param1.flip
         };
         var _loc3_:int = 0;
         while(_loc3_ < param1.numClipUrls)
         {
            _loc4_ = param1.getClipUrl(_loc3_);
            _loc2_.clips.push(_loc4_);
            _loc3_++;
         }
         if(param1.depth)
         {
            _loc2_.depth = param1.depth;
         }
         if(param1.scale != 1)
         {
            _loc2_.scale = param1.scale;
         }
         return _loc2_;
      }
   }
}
