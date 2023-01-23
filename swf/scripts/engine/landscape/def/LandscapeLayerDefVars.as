package engine.landscape.def
{
   import engine.anim.def.AnimLibrary;
   import engine.core.BoxInt;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   
   public class LandscapeLayerDefVars extends LandscapeLayerDef
   {
      
      public static const schema:Object = {
         "name":"LandscapeLayerDefVars",
         "type":"object",
         "properties":{
            "nameId":{"type":"string"},
            "offset":{
               "type":PointVars.schema,
               "optional":true
            },
            "speed":{"type":"number"},
            "view_index":{
               "type":"number",
               "optional":true
            },
            "randomGroup":{
               "type":"string",
               "optional":true
            },
            "always":{
               "type":"boolean",
               "optional":true
            },
            "clickBlocker":{
               "type":"boolean",
               "optional":true
            },
            "ifCondition":{
               "type":"string",
               "optional":true
            },
            "notCondition":{
               "type":"string",
               "optional":true
            },
            "layerSprites":{
               "type":"array",
               "items":LandscapeSpriteDefVars.schema,
               "optional":true
            },
            "splines":{
               "type":"array",
               "items":LandscapeSplineDefVars.schema,
               "optional":true
            },
            "occludes":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "requireLayer":{
               "type":"string",
               "optional":true
            },
            "includeLayer":{
               "type":"string",
               "optional":true
            },
            "disableBoundaryAdjust":{
               "type":"boolean",
               "optional":true
            },
            "blockInvertLayer":{
               "type":"string",
               "optional":true
            },
            "blockInvertPrefix":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function LandscapeLayerDefVars(param1:LandscapeDef)
      {
         super(param1);
      }
      
      public static function save(param1:LandscapeLayerDef) : Object
      {
         var _loc3_:LandscapeSpriteDef = null;
         var _loc4_:LandscapeSplineDef = null;
         var _loc2_:Object = {};
         _loc2_.nameId = param1.nameId;
         _loc2_.offset = PointVars.save(param1.offset);
         _loc2_.speed = param1.speed;
         if(param1.ifCondition)
         {
            _loc2_.ifCondition = param1.ifCondition;
         }
         if(param1.notCondition)
         {
            _loc2_.notCondition = param1.notCondition;
         }
         if(Boolean(param1.randomGroup) && !StringUtil.isWhitespace(param1.randomGroup))
         {
            _loc2_.randomGroup = param1.randomGroup;
         }
         if(Boolean(param1.layerSprites) && param1.layerSprites.length > 0)
         {
            _loc2_.layerSprites = [];
            for each(_loc3_ in param1.layerSprites)
            {
               _loc2_.layerSprites.push(LandscapeSpriteDefVars.save(_loc3_));
            }
         }
         if(Boolean(param1.splines) && param1.splines.length > 0)
         {
            _loc2_.splines = [];
            for each(_loc4_ in param1.splines)
            {
               _loc2_.splines.push(LandscapeSplineDefVars.save(_loc4_));
            }
         }
         if(param1.requireLayer)
         {
            _loc2_.requireLayer = param1.requireLayer;
         }
         if(param1.includeLayer)
         {
            _loc2_.includeLayer = param1.includeLayer;
         }
         if(Boolean(param1.occludes) && param1.occludes.length > 0)
         {
            _loc2_.occludes = param1.occludes;
         }
         if(param1.always)
         {
            _loc2_.always = param1.always;
         }
         if(param1.viewIndex >= 0)
         {
            _loc2_.view_index = param1.viewIndex;
         }
         if(param1.clickBlocker)
         {
            _loc2_.clickBlocker = param1.clickBlocker;
         }
         if(param1.disableBoundaryAdjust)
         {
            _loc2_.disableBoundaryAdjust = param1.disableBoundaryAdjust;
         }
         if(param1.blockInvertLayerId)
         {
            _loc2_.blockInvertLayer = param1.blockInvertLayerId;
         }
         if(param1.blockInvertPrefix)
         {
            _loc2_.blockInvertPrefix = param1.blockInvertPrefix;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:String, param2:Object, param3:ILogger, param4:AnimLibrary) : LandscapeLayerDefVars
      {
         EngineJsonDef.validateThrow(param2,schema,param3);
         nameId = param2.nameId;
         clickBlocker = param2.clickBlocker;
         disableBoundaryAdjust = param2.disableBoundaryAdjust;
         if(param2.offset != undefined)
         {
            offset = PointVars.parse(param2.offset,param3,offset);
         }
         speed = Number(param2.speed);
         randomGroup = param2.randomGroup;
         ifCondition = param2.ifCondition;
         notCondition = param2.notCondition;
         blockInvertLayerId = param2.blockInvertLayer;
         blockInvertPrefix = param2.blockInvertPrefix;
         always = BooleanVars.parse(param2.always,always);
         occludes = param2.occludes;
         requireLayer = param2.requireLayer;
         includeLayer = param2.includeLayer;
         if(param2.view_index != undefined)
         {
            viewIndex = param2.view_index;
         }
         var _loc5_:int = 0;
         var _loc6_:BoxInt = new BoxInt();
         _loc5_ += this._fromJsonLayerSprites(param2,param3,param4,param1,_loc6_);
         this._performSpriteLinkages(_loc6_.value,param3);
         this._fromJsonSplines(param2,param3);
         if(nameId == LAYER_ID_ACTORS_BACK || nameId == LAYER_ID_ACTORS_FACING)
         {
            always = true;
         }
         if(_loc5_)
         {
            throw new ArgumentError("LandscapeLayerDefVars errors loading.");
         }
         return this;
      }
      
      private function _fromJsonSplines(param1:Object, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         var _loc4_:LandscapeSplineDef = null;
         if(!param1.splines)
         {
            return;
         }
         splines = new Vector.<LandscapeSplineDef>();
         for each(_loc3_ in param1.splines)
         {
            _loc4_ = new LandscapeSplineDefVars().fromJson(_loc3_,param2);
            _loc4_.layer = this;
            splines.push(_loc4_);
         }
      }
      
      private function _fromJsonLayerSprites(param1:Object, param2:ILogger, param3:AnimLibrary, param4:String, param5:BoxInt) : int
      {
         var errors:int;
         var spriteNumber:int = 0;
         var spriteVar:Object = null;
         var sprite:LandscapeSpriteDef = null;
         var vars:Object = param1;
         var logger:ILogger = param2;
         var anims:AnimLibrary = param3;
         var sceneName:String = param4;
         var hasLinks:BoxInt = param5;
         if(!vars.layerSprites)
         {
            return 0;
         }
         spriteNumber = 0;
         errors = 0;
         var _loc7_:int = 0;
         var _loc8_:* = vars.layerSprites;
         for(; §§hasnext(_loc8_,_loc7_); spriteNumber++)
         {
            spriteVar = §§nextvalue(_loc7_,_loc8_);
            try
            {
               sprite = new LandscapeSpriteDefVars(this,sceneName,spriteVar,logger,anims);
               sprite.layer = this;
               layerSprites.push(sprite);
               if(sprite.linkedId)
               {
                  ++hasLinks.value;
               }
               if(sprite.tooltip)
               {
                  hasTooltips = true;
               }
            }
            catch(e:Error)
            {
               logger.error("LandscapeLayerDefVars failed to load sprite " + spriteNumber + ":" + e);
               errors++;
               continue;
            }
         }
         return errors;
      }
      
      private function _performSpriteLinkages(param1:int, param2:ILogger) : void
      {
         var _loc3_:LandscapeSpriteDef = null;
         var _loc4_:LandscapeSpriteDef = null;
         while(param1)
         {
            for each(_loc3_ in layerSprites)
            {
               if(_loc3_.linkedId)
               {
                  param1--;
                  for each(_loc4_ in layerSprites)
                  {
                     if(_loc4_.nameId == _loc3_.linkedId)
                     {
                        _loc3_.createLinkTo(_loc4_);
                        break;
                     }
                  }
                  if(!_loc3_.linked)
                  {
                     param2.error("Unable to find link for sprite " + _loc3_ + " on layer " + this);
                  }
               }
            }
         }
      }
   }
}
