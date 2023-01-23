package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   
   public class EntityClassDefListVars extends EntityClassDefList
   {
      
      public static const schema:Object = {
         "name":"EntityClassDefListVars",
         "type":"object",
         "properties":{
            "metadata":{"type":EntitiesMetadataVars.schema},
            "type":{
               "type":"string",
               "optional":true
            },
            "parent":{
               "type":"string",
               "optional":true
            },
            "classes":{
               "type":"array",
               "items":EntityClassDefVars.schema
            }
         }
      };
       
      
      public function EntityClassDefListVars()
      {
         super();
      }
      
      public static function save(param1:EntityClassDefList) : Object
      {
         var _loc3_:EntityClassDef = null;
         var _loc2_:Object = {
            "metadata":EntitiesMetadataVars.save(param1.meta),
            "classes":[],
            "type":(!!param1.type ? param1.type : "")
         };
         for each(_loc3_ in param1.classList)
         {
            _loc2_.classes.push(EntityClassDefVars.save(_loc3_));
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Locale) : EntityClassDefListVars
      {
         var classvars:Object = null;
         var ecd:EntityClassDef = null;
         var vars:Object = param1;
         var logger:ILogger = param2;
         var locale:Locale = param3;
         meta = new EntitiesMetadataVars(vars.metadata,logger,locale);
         for each(classvars in vars.classes)
         {
            try
            {
               ecd = new EntityClassDefVars(classvars,logger,locale);
               register(ecd,logger);
            }
            catch(err:Error)
            {
               ok = false;
               logger.error("Failed to parse class vars id=" + classvars.id + ": " + err.getStackTrace());
            }
         }
         parentUrl = vars.parent;
         type = vars.type;
         init();
         return this;
      }
   }
}
