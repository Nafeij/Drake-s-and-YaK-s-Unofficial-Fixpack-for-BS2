package engine.anim.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   import engine.resource.AnimClipResource;
   import engine.resource.ResourceManager;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class AnimLibraryVars extends AnimLibrary
   {
      
      public static const schema:Object = {
         "name":"AnimLibraryVars",
         "type":"object",
         "properties":{
            "remap":{
               "optional":true,
               "type":{
                  "type":"object",
                  "properties":{
                     "src":{"type":"string"},
                     "replace":{"type":"string"},
                     "replacement":{"type":"string"}
                  }
               }
            },
            "mixes":{
               "type":"array",
               "items":AnimMixDefVars.schema
            },
            "layers":{
               "optional":true,
               "type":"array",
               "items":{
                  "type":"object",
                  "properties":{
                     "layerId":{"type":"string"},
                     "sourceLayerId":{
                        "type":"string",
                        "optional":true
                     },
                     "replace":{
                        "type":"string",
                        "optional":true
                     },
                     "replacement":{
                        "type":"string",
                        "optional":true
                     },
                     "anims":{
                        "type":"array",
                        "items":AnimDefVars.schema
                     },
                     "omitAnims":{
                        "type":"array",
                        "items":"string"
                     },
                     "omitOrients":{
                        "type":"array",
                        "items":"string"
                     }
                  }
               }
            },
            "anims":{
               "type":"array",
               "items":AnimDefVars.schema
            },
            "orients":{
               "type":"array",
               "items":OrientedAnimsDefVars.schema
            },
            "locos":{
               "type":"array",
               "items":AnimLocoVars.schema,
               "optional":true
            },
            "offsets":{
               "optional":true,
               "type":{"properties":{
                  "NE":{
                     "type":"string",
                     "optional":true
                  },
                  "NW":{
                     "type":"string",
                     "optional":true
                  },
                  "SW":{
                     "type":"string",
                     "optional":true
                  },
                  "SE":{
                     "type":"string",
                     "optional":true
                  }
               }}
            },
            "animsScale":{
               "type":"number",
               "optional":true
            },
            "animsAlpha":{
               "type":"number",
               "optional":true
            },
            "animsColor":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public function AnimLibraryVars(param1:String, param2:Object, param3:Class, param4:ILogger, param5:String, param6:String)
      {
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc11_:IAnimFacing = null;
         var _loc12_:String = null;
         var _loc13_:Point = null;
         var _loc14_:AnimDefVars = null;
         var _loc15_:Object = null;
         var _loc16_:String = null;
         var _loc17_:String = null;
         var _loc18_:Vector.<IAnimDef> = null;
         var _loc19_:String = null;
         var _loc20_:String = null;
         var _loc21_:AnimDefLayer = null;
         var _loc22_:AnimDef = null;
         var _loc23_:AnimDef = null;
         var _loc24_:OrientedAnimsDefVars = null;
         var _loc25_:AnimMixDefVars = null;
         var _loc26_:Object = null;
         var _loc27_:AnimLocoVars = null;
         var _loc28_:AnimLoco = null;
         super(param1,param4);
         EngineJsonDef.validateThrow(param2,schema,param4);
         if(param2.animsScale != undefined)
         {
            _animsScale = param2.animsScale;
         }
         if(param2.animsAlpha != undefined)
         {
            _animsAlpha = param2.animsAlpha;
         }
         if(param2.animsColor != undefined)
         {
            _animsColor = param2.animsColor;
         }
         if(param2.offsets)
         {
            _offsetsByFacing = new Dictionary();
            for(_loc10_ in param2.offsets)
            {
               _loc11_ = Enum.parse(param3,_loc10_) as IAnimFacing;
               _loc12_ = String(param2.offsets[_loc10_]);
               _loc13_ = PointVars.parseString(_loc12_,null);
               _offsetsByFacing[_loc11_] = _loc13_;
            }
         }
         addAnimLayer("",null,null,null);
         for each(_loc7_ in param2.anims)
         {
            _loc14_ = new AnimDefVars(_loc7_,param4,this,param5,param6);
            addAnimDef("",_loc14_,true);
         }
         if(param2.layers)
         {
            for each(_loc15_ in param2.layers)
            {
               _loc16_ = String(_loc15_.layerId);
               if(_loc15_.sourceLayerId != undefined)
               {
                  _loc17_ = String(_loc15_.sourceLayerId);
                  _loc18_ = getAllAnimDefs(_loc17_);
                  _loc19_ = String(_loc15_.replace);
                  _loc20_ = String(_loc15_.replacement);
                  _loc21_ = addAnimLayer(_loc16_,_loc17_,_loc15_.omitAnims,_loc15_.omitOrients);
                  for each(_loc22_ in _loc18_)
                  {
                     if(!_loc21_.isOmittedAnim(_loc22_.name))
                     {
                        _loc23_ = _loc22_.clone();
                        if(_loc19_)
                        {
                           _loc23_.clipUrl = _loc23_.clipUrl.replace(_loc19_,_loc20_);
                        }
                        addAnimDef(_loc16_,_loc23_,false);
                     }
                  }
               }
               for each(_loc7_ in _loc15_.anims)
               {
                  _loc14_ = new AnimDefVars(_loc7_,param4,this,param5,param6);
                  addAnimDef(_loc16_,_loc14_,true);
               }
            }
         }
         for each(_loc8_ in param2.orients)
         {
            _loc24_ = new OrientedAnimsDefVars(_loc8_,param3,param4);
            addOrientedAnims(_loc24_);
         }
         for each(_loc9_ in param2.mixes)
         {
            _loc25_ = new AnimMixDefVars(_loc9_,param4);
            addAnimMixDef(_loc25_);
         }
         if(param2.locos)
         {
            for each(_loc26_ in param2.locos)
            {
               _loc27_ = new AnimLocoVars(_loc26_,param4);
               addAnimLoco(_loc27_);
            }
         }
         if(!getLoco(null))
         {
            _loc28_ = new AnimLoco();
            _loc28_.id = "";
            _loc28_.stop = "walkstop";
            _loc28_.loop = "walk";
            _loc28_.start = "walkstart";
            addAnimLoco(_loc28_);
         }
      }
      
      public static function save(param1:AnimLibrary) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc6_:OrientedAnimsDef = null;
         var _loc7_:AnimMixDef = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:IAnimFacing = null;
         var _loc11_:Point = null;
         var _loc12_:String = null;
         var _loc13_:Vector.<IAnimDef> = null;
         var _loc14_:AnimDef = null;
         var _loc15_:String = null;
         var _loc16_:Array = null;
         var _loc17_:Array = null;
         var _loc18_:Object = null;
         var _loc19_:Object = null;
         var _loc20_:Object = null;
         var _loc2_:Object = {
            "mixes":[],
            "anims":[],
            "orients":[]
         };
         if(param1.animsScale != 1)
         {
            _loc2_.animsScale = param1.animsScale;
         }
         if(param1.animsAlpha != 1)
         {
            _loc2_.animsAlpha = param1.animsAlpha;
         }
         if(param1.animsColor != 4294967295)
         {
            _loc2_.animsColor = param1.animsColor;
         }
         if(param1.offsetsByFacing)
         {
            _loc8_ = {};
            _loc2_.offsets = _loc8_;
            for each(_loc9_ in param1.offsetsByFacing)
            {
               _loc10_ = _loc9_ as IAnimFacing;
               _loc11_ = param1.offsetsByFacing[_loc10_];
               if(Boolean(_loc11_) && (_loc11_.x != 0 || _loc11_.y != 0))
               {
                  _loc2_[_loc10_.name] = _loc11_;
               }
            }
         }
         var _loc5_:int = 0;
         while(_loc5_ < param1.layerCount)
         {
            _loc12_ = param1.getLayerId(_loc5_);
            _loc13_ = param1.getExplicitAnimDefs(_loc12_);
            if(!_loc12_)
            {
               _loc4_ = _loc2_.anims;
            }
            else
            {
               if(!_loc2_.layers)
               {
                  _loc2_.layers = {};
               }
               _loc3_ = _loc2_.layers[_loc12_] = {"anims":[]};
               _loc15_ = param1.getAnimLayerSourceLayerId(_loc12_);
               _loc16_ = param1.getAnimLayerOmitAnims(_loc12_);
               _loc17_ = param1.getAnimLayerOmitOrients(_loc12_);
               if(_loc15_)
               {
                  _loc3_.sourceLayerId = _loc15_;
               }
               if(_loc16_)
               {
                  _loc3_.omitAnims = _loc16_;
               }
               if(_loc17_)
               {
                  _loc3_.omitOrients = _loc17_;
               }
               _loc4_ = _loc3_.anims;
            }
            for each(_loc14_ in _loc13_)
            {
               _loc18_ = AnimDefVars.save(_loc14_);
               _loc4_.push(_loc18_);
            }
            _loc5_++;
         }
         for each(_loc6_ in param1.orientedAnims)
         {
            _loc19_ = OrientedAnimsDefVars.save(_loc6_);
            _loc2_.orients.push(_loc19_);
         }
         for each(_loc7_ in param1.mixes)
         {
            _loc20_ = AnimMixDefVars.save(_loc7_);
            _loc2_.mixes.push(_loc20_);
         }
         return _loc2_;
      }
      
      override public function resolve(param1:ResourceManager) : void
      {
         var _loc3_:String = null;
         var _loc4_:Vector.<IAnimDef> = null;
         var _loc5_:IAnimDef = null;
         super.resolve(param1);
         var _loc2_:int = 0;
         while(_loc2_ < layerCount)
         {
            _loc3_ = getLayerId(_loc2_);
            _loc4_ = getAllAnimDefs(_loc3_);
            for each(_loc5_ in _loc4_)
            {
               param1.getResource(_loc5_.clipUrl,AnimClipResource,resourceGroup);
            }
            _loc2_++;
         }
         resourceGroup.addResourceGroupListener(this.resourceGroupCompleteHandler);
      }
      
      private function resourceGroupCompleteHandler(param1:Event) : void
      {
         var _loc4_:String = null;
         var _loc5_:Vector.<IAnimDef> = null;
         var _loc6_:IAnimDef = null;
         var _loc7_:AnimClipResource = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < layerCount)
         {
            _loc4_ = getLayerId(_loc3_);
            _loc5_ = getAllAnimDefs(_loc4_);
            for each(_loc6_ in _loc5_)
            {
               _loc7_ = resourceGroup.getResource(_loc6_.clipUrl) as AnimClipResource;
               if(_loc7_.ok)
               {
                  _loc6_.clip = _loc7_.clipDef;
               }
               else
               {
                  _loc2_++;
               }
            }
            _loc3_++;
         }
         if(_loc2_)
         {
            logger.error("AnimLibrary [" + url + "] had " + _loc2_ + " errors, failed to load.");
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}
