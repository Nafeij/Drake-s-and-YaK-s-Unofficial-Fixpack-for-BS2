package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class EntityAppearanceDefVars extends EntityAppearanceDef
   {
      
      public static const schema:Object = {
         "name":"EntityAppearanceDefVars",
         "type":"object",
         "properties":{
            "portrait":{"type":"string"},
            "backPortrait":{
               "type":"string",
               "optional":true
            },
            "backPortraitOffset":{
               "type":"number",
               "optional":true
            },
            "versusPortrait":{"type":"string"},
            "promotePortrait":{"type":"string"},
            "portraitFoley":{
               "type":"string",
               "optional":true
            },
            "icon":{"type":"string"},
            "sounds":{"type":"string"},
            "anims":{"type":"string"},
            "vfx":{"type":"string"},
            "unlock_id":{
               "type":"string",
               "optional":true
            },
            "acquire_id":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function EntityAppearanceDefVars(param1:IEntityClassDef, param2:IEntityDef)
      {
         super(param1,param2);
      }
      
      public static function save(param1:EntityAppearanceDef) : Object
      {
         var _loc2_:Object = {
            "portrait":param1.portraitUrl,
            "versusPortrait":param1.versusPortraitUrl,
            "promotePortrait":param1.promotePortraitUrl,
            "icon":param1.baseIconUrl,
            "sounds":param1.soundsUrl,
            "anims":param1.animsUrl,
            "vfx":param1.vfxUrl
         };
         if(param1.unlock_id)
         {
            _loc2_.unlock_id = param1.unlock_id;
         }
         if(param1.acquire_id)
         {
            _loc2_.acquire_id = param1.acquire_id;
         }
         if(param1.backPortraitOffset)
         {
            _loc2_.backPortraitOffset = param1.backPortraitOffset;
         }
         if(param1.portraitFoley)
         {
            _loc2_.portraitFoley = param1.portraitFoley;
         }
         _loc2_.backPortrait = !!param1.backPortraitUrl ? param1.backPortraitUrl : "";
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : EntityAppearanceDefVars
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         _portraitUrl = param1.portrait;
         _backPortraitUrl = param1.backPortrait;
         _versusPortraitUrl = param1.versusPortrait;
         _promotePortraitUrl = param1.promotePortrait;
         setupIcons(param1.icon);
         _soundsUrl = param1.sounds;
         _animsUrl = param1.anims;
         _vfxUrl = param1.vfx;
         _unlock_id = param1.unlock_id;
         _acquire_id = param1.acquire_id;
         _portraitFoley = param1.portraitFoley;
         if(param1.backPortraitOffset != undefined)
         {
            backPortraitOffset = param1.backPortraitOffset;
         }
         var _loc3_:Boolean = false;
         if(_portraitUrl)
         {
            if(_loc3_)
            {
               _portraitUrl = _portraitUrl.replace("/portrait.clip",".swf/portrait");
            }
            else
            {
               _portraitUrl = _portraitUrl.replace(".swf/portrait","/portrait.clip");
            }
         }
         return this;
      }
   }
}
