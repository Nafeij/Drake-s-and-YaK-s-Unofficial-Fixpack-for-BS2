package engine.heraldry
{
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.def.EngineJsonDef;
   import flash.display.BlendMode;
   
   public class HeraldryDefVars extends HeraldryDef
   {
      
      public static const schema:Object = {
         "name":"HeraldryDefVars",
         "type":"object",
         "properties":{
            "name":{"type":"string"},
            "crest":{"type":"string"},
            "banner":{"type":"string"},
            "color":{"type":"string"},
            "color_crown":{
               "type":"string",
               "optional":true
            },
            "blend":{
               "type":"string",
               "optional":true
            },
            "tags":{
               "type":"string",
               "optional":true
            },
            "prereq":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function HeraldryDefVars()
      {
         super();
      }
      
      public static function toJson(param1:HeraldryDef, param2:HeraldrySystem) : Object
      {
         var _loc3_:String = param1._crestId;
         if(!_loc3_ && Boolean(param1.crestDef))
         {
            _loc3_ = param1.crestDef.id;
         }
         if(!_loc3_)
         {
            _loc3_ = "";
         }
         var _loc4_:Object = {
            "name":param1.name,
            "crest":_loc3_,
            "banner":param1.bannerId,
            "color":ColorUtil.colorStr(param1.crestColor,"0x",true)
         };
         if(Boolean(param1.blendMode) && param1.blendMode != BlendMode.NORMAL)
         {
            _loc4_.blend = param1.blendMode;
         }
         if(param1.prereq)
         {
            _loc4_.prereq = param1.prereq;
         }
         if(param1.tags)
         {
            _loc4_.tags = param2.makeTagsArray(param1.tags).join(",");
         }
         return _loc4_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : HeraldryDefVars
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.name = param1.name;
         this.prereq = param1.prereq;
         this._crestId = param1.crest;
         this.bannerId = param1.banner;
         this.crestColor = param1.color;
         if(param1.color_crown != undefined)
         {
            this.crownColor = param1.color_crown;
         }
         if(param1.blend != undefined)
         {
            blendMode = param1.blend;
         }
         if(param1.tags)
         {
            this.tagsArray = param1.tags.split(/[,\s]/);
         }
         else
         {
            this.tagsArray = [];
         }
         createHashId();
         return this;
      }
   }
}
