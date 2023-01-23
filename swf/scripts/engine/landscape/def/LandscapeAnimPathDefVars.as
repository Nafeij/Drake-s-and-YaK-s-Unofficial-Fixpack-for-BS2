package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class LandscapeAnimPathDefVars extends LandscapeAnimPathDef
   {
      
      public static const schema:Object = {
         "name":"LandscapeAnimPathDefVars",
         "type":"object",
         "properties":{
            "nodes":{
               "type":"array",
               "skip":true
            },
            "looping":{
               "type":"boolean",
               "optional":true
            },
            "autostart":{
               "type":"boolean",
               "optional":true
            },
            "start_segment":{
               "type":"number",
               "optional":true
            },
            "start_t":{
               "type":"number",
               "optional":true
            },
            "start_visible":{
               "type":"boolean",
               "optional":true
            },
            "manage_visibility":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function LandscapeAnimPathDefVars(param1:LandscapeSpriteDef, param2:Object, param3:ILogger)
      {
         var _loc4_:Object = null;
         var _loc5_:AnimPathType = null;
         var _loc6_:AnimPathNodeDef = null;
         super(param1);
         EngineJsonDef.validateThrow(param2,schema,param3);
         manage_visibility = BooleanVars.parse(param2.manage_visibility,manage_visibility);
         start_segment = param2.start_segment;
         if(param2.start_t != undefined)
         {
            start_t = param2.start_t;
         }
         for each(_loc4_ in param2.nodes)
         {
            _loc5_ = Enum.parse(AnimPathType,_loc4_.type) as AnimPathType;
            _loc6_ = null;
            _loc6_ = null;
            switch(_loc5_)
            {
               case AnimPathType.HIDE:
                  _loc6_ = AnimPathNodeHideDefVars.constructNode(_loc4_,param3);
                  break;
               case AnimPathType.SCALE:
                  _loc6_ = AnimPathNodeScaleDefVars.constructNode(_loc4_,param3);
                  break;
               case AnimPathType.MOVE:
                  _loc6_ = AnimPathNodeMoveDefVars.constructNode(_loc4_,param3);
                  break;
               case AnimPathType.FLOAT:
                  _loc6_ = new AnimPathNodeFloatDef().fromJson(_loc4_,param3);
                  break;
               case AnimPathType.ROTATE:
                  _loc6_ = new AnimPathNodeRotateDef().fromJson(_loc4_,param3);
                  break;
               case AnimPathType.WAIT:
                  _loc6_ = AnimPathNodeWaitDefVars.constructNode(_loc4_,param3);
                  break;
               case AnimPathType.PLAYING:
                  _loc6_ = AnimPathNodePlayingDefVars.constructNode(_loc4_,param3);
                  break;
               case AnimPathType.ALPHA:
                  _loc6_ = AnimPathNodeAlphaDefVars.constructNode(_loc4_,param3);
                  break;
               case AnimPathType.SOUND:
                  _loc6_ = new AnimPathNodeSoundDef().fromJson(_loc4_,param3);
                  break;
               case AnimPathType.WOBBLE:
                  _loc6_ = new AnimPathNodeWobbleDef().fromJson(_loc4_,param3);
            }
            if(!_loc6_)
            {
               throw new ArgumentError("Failed to create an anim node from: " + _loc4_);
            }
            nodes.push(_loc6_);
         }
         looping = BooleanVars.parse(param2.looping,looping);
         autostart = BooleanVars.parse(param2.autostart,autostart);
         start_visible = BooleanVars.parse(param2.start_visible,start_visible);
      }
      
      public static function save(param1:LandscapeAnimPathDef) : Object
      {
         var _loc3_:AnimPathNodeDef = null;
         var _loc2_:Object = {"nodes":[]};
         for each(_loc3_ in param1.nodes)
         {
            if(_loc3_ is AnimPathNodeAlphaDef)
            {
               _loc2_.nodes.push(AnimPathNodeAlphaDefVars.save(_loc3_ as AnimPathNodeAlphaDef));
            }
            else if(_loc3_ is AnimPathNodeHideDef)
            {
               _loc2_.nodes.push(AnimPathNodeHideDefVars.save(_loc3_ as AnimPathNodeHideDef));
            }
            else if(_loc3_ is AnimPathNodeMoveDef)
            {
               _loc2_.nodes.push(AnimPathNodeMoveDefVars.save(_loc3_ as AnimPathNodeMoveDef));
            }
            else if(_loc3_ is AnimPathNodePlayingDef)
            {
               _loc2_.nodes.push(AnimPathNodePlayingDefVars.save(_loc3_ as AnimPathNodePlayingDef));
            }
            else if(_loc3_ is AnimPathNodeScaleDef)
            {
               _loc2_.nodes.push(AnimPathNodeScaleDefVars.save(_loc3_ as AnimPathNodeScaleDef));
            }
            else if(_loc3_ is AnimPathNodeWaitDef)
            {
               _loc2_.nodes.push(AnimPathNodeWaitDefVars.save(_loc3_ as AnimPathNodeWaitDef));
            }
            else if(_loc3_ is AnimPathNodeFloatDef)
            {
               _loc2_.nodes.push((_loc3_ as AnimPathNodeFloatDef).save());
            }
            else if(_loc3_ is AnimPathNodeRotateDef)
            {
               _loc2_.nodes.push((_loc3_ as AnimPathNodeRotateDef).save());
            }
            else if(_loc3_ is AnimPathNodeSoundDef)
            {
               _loc2_.nodes.push((_loc3_ as AnimPathNodeSoundDef).save());
            }
            else if(_loc3_ is AnimPathNodeWobbleDef)
            {
               _loc2_.nodes.push((_loc3_ as AnimPathNodeWobbleDef).save());
            }
         }
         if(!param1.looping)
         {
            _loc2_.looping = false;
         }
         if(!param1.autostart)
         {
            _loc2_.autostart = false;
         }
         if(!param1.manage_visibility)
         {
            _loc2_.manage_visibility = false;
         }
         if(param1.start_visible)
         {
            _loc2_.start_visible = param1.start_visible;
         }
         if(param1.start_segment)
         {
            _loc2_.start_segment = param1.start_segment;
         }
         if(param1.start_t)
         {
            _loc2_.start_t = param1.start_t;
         }
         return _loc2_;
      }
   }
}
