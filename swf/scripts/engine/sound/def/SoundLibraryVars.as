package engine.sound.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SoundLibraryVars extends SoundLibrary
   {
      
      public static const schema:Object = {
         "name":"SoundLibraryVars",
         "type":"object",
         "properties":{
            "sku":{
               "type":"string",
               "optional":true
            },
            "inherits":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "sounds":{
               "type":"array",
               "items":SoundDef.schema
            }
         }
      };
       
      
      public function SoundLibraryVars(param1:String, param2:Object, param3:ILogger)
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:SoundDef = null;
         super(param1,param3);
         if(!param2)
         {
            return;
         }
         EngineJsonDef.validateThrow(param2,schema,param3);
         if(param2.sku)
         {
            this._sku = param2.sku;
         }
         for each(_loc4_ in param2.inherits)
         {
            inheritUrls.push(_loc4_);
         }
         for each(_loc5_ in param2.sounds)
         {
            _loc6_ = new SoundDef().fromJson(sku,_loc5_,param3);
            addSoundDef(_loc6_);
         }
      }
      
      public static function save(param1:SoundLibrary) : Object
      {
         var _loc3_:SoundDef = null;
         var _loc4_:String = null;
         var _loc2_:Object = {"sounds":[]};
         if(param1.sku)
         {
            _loc2_.sku = param1.sku;
         }
         for each(_loc3_ in param1.soundDefs)
         {
            _loc2_.sounds.push(SoundDef.save(_loc3_));
         }
         if(Boolean(param1.inheritUrls) && param1.inheritUrls.length > 0)
         {
            _loc2_.inherits = [];
            for each(_loc4_ in param1.inheritUrls)
            {
               _loc2_.inherits.push(_loc4_);
            }
         }
         return _loc2_;
      }
   }
}
