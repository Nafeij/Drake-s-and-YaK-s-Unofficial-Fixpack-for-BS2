package engine.battle.ability.phantasm.def
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.EffectPhase;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class ChainPhantasmsDefVars extends ChainPhantasmsDef
   {
      
      public static const schema:Object = {
         "name":"ChainPhantasmsDef",
         "description":"ChainPhantasmsDef Definition",
         "properties":{
            "waitEffectPhase":{
               "type":{"properties":{
                  "effect":{"type":"string"},
                  "phase":{"type":"string"}
               }},
               "optional":true
            },
            "startDelay":{
               "type":"number",
               "optional":true
            },
            "endTime":{"type":"number"},
            "applyTime":{"type":"number"},
            "applyTimeVariance":{
               "type":"number",
               "optional":true
            },
            "results":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "rotation":{
               "type":"boolean",
               "optional":true
            },
            "reverseRotation":{
               "type":"boolean",
               "optional":true
            },
            "sprites":{
               "type":"array",
               "items":PhantasmDefSprite.schema,
               "optional":true
            },
            "flyTexts":{
               "type":"array",
               "items":PhantasmDefFlyText.schema,
               "optional":true
            },
            "anims":{
               "type":"array",
               "items":PhantasmDefAnim.schema,
               "optional":true
            },
            "sounds":{
               "type":"array",
               "items":PhantasmDefSound.schema,
               "optional":true
            },
            "endTriggers":{
               "type":"array",
               "items":PhantasmAnimTriggerDefVars.schema,
               "optional":true
            },
            "applyTriggers":{
               "type":"array",
               "items":PhantasmAnimTriggerDefVars.schema,
               "optional":true
            },
            "colors":{
               "type":"array",
               "items":PhantasmDefColorPulsator.schema,
               "optional":true
            }
         }
      };
       
      
      public function ChainPhantasmsDefVars(param1:Object, param2:BattleAbilityDef, param3:ILogger)
      {
         var _loc4_:Object = null;
         var _loc5_:PhantasmDef = null;
         var _loc6_:PhantasmDefSprite = null;
         var _loc7_:PhantasmDefColorPulsator = null;
         var _loc8_:PhantasmDefFlyText = null;
         var _loc9_:PhantasmDefAnim = null;
         var _loc10_:PhantasmDefSound = null;
         var _loc11_:String = null;
         var _loc12_:EffectResult = null;
         var _loc13_:String = null;
         var _loc14_:Vector.<PhantasmDef> = null;
         var _loc15_:String = null;
         var _loc16_:Object = null;
         var _loc17_:PhantasmAnimTriggerDef = null;
         var _loc18_:Object = null;
         var _loc19_:PhantasmAnimTriggerDef = null;
         EngineJsonDef.validateThrow(param1,schema,param3);
         super();
         if(param1.sprites)
         {
            for each(_loc4_ in param1.sprites)
            {
               _loc6_ = new PhantasmDefSprite(_loc4_,param3);
               entries.push(_loc6_);
            }
         }
         if(param1.colors)
         {
            for each(_loc4_ in param1.colors)
            {
               _loc7_ = new PhantasmDefColorPulsator(_loc4_,param3);
               entries.push(_loc7_);
            }
         }
         if(param1.flyTexts)
         {
            for each(_loc4_ in param1.flyTexts)
            {
               _loc8_ = new PhantasmDefFlyText(_loc4_,param3);
               entries.push(_loc8_);
            }
         }
         if(param1.anims)
         {
            for each(_loc4_ in param1.anims)
            {
               _loc9_ = new PhantasmDefAnim(_loc4_,param3);
               entries.push(_loc9_);
            }
         }
         if(param1.sounds)
         {
            for each(_loc4_ in param1.sounds)
            {
               _loc10_ = new PhantasmDefSound(_loc4_,param3);
               entries.push(_loc10_);
            }
         }
         if(param1.results)
         {
            this.results_vars = param1.results;
            for each(_loc11_ in param1.results)
            {
               _loc12_ = Enum.parse(EffectResult,_loc11_) as EffectResult;
               addResult(_loc12_);
            }
         }
         if(param1.rotation != undefined)
         {
            rotation = param1.rotation;
         }
         reverseRotation = param1.reverseRotation;
         for each(_loc5_ in entries)
         {
            if(_loc5_.animTrigger)
            {
               _loc13_ = _loc5_.animTrigger.key;
               _loc14_ = animTriggerEntriesMap[_loc13_];
               if(!_loc14_)
               {
                  _loc14_ = new Vector.<PhantasmDef>();
                  animTriggerEntriesMap[_loc13_] = _loc14_;
               }
               _loc14_.push(_loc5_);
            }
            else if(_loc5_.time >= 0)
            {
               timedEntries.push(_loc5_);
            }
         }
         timedEntries.sort(this.compareTime);
         endTime = param1.endTime;
         applyTime = param1.applyTime;
         applyTimeVariance = param1.applyTimeVariance;
         startDelay = param1.startDelay;
         if(applyTime > endTime)
         {
            throw new ArgumentError("ChainPhantasmDef cannot end prior to apply");
         }
         if(param1.waitEffectPhase)
         {
            _loc15_ = param1.waitEffectPhase.effect;
            waitEffectPhase = Enum.parse(EffectPhase,param1.waitEffectPhase.phase) as EffectPhase;
            waitEffect = param2.getEffectDefByName(_loc15_);
            if(!waitEffect)
            {
               throw new ArgumentError("ChainPhantasmDef waitEffectPhase.effect invalid: " + _loc15_);
            }
         }
         else
         {
            waitEffectPhase = Enum.parse(EffectPhase,"INVALID") as EffectPhase;
         }
         if(param1.applyTriggers)
         {
            for each(_loc16_ in param1.applyTriggers)
            {
               _loc17_ = new PhantasmAnimTriggerDefVars(_loc16_,param3);
               applyTriggers.push(_loc17_);
            }
         }
         if(param1.endTriggers)
         {
            for each(_loc18_ in param1.endTriggers)
            {
               _loc19_ = new PhantasmAnimTriggerDefVars(_loc18_,param3);
               endTriggers.push(_loc19_);
            }
         }
      }
      
      public static function save(param1:ChainPhantasmsDef) : Object
      {
         var _loc8_:PhantasmDef = null;
         var _loc9_:PhantasmAnimTriggerDef = null;
         var _loc10_:EffectResult = null;
         var _loc11_:Object = null;
         var _loc2_:Object = {
            "endTime":param1.endTime,
            "applyTime":param1.applyTime
         };
         if(param1.startDelay)
         {
            _loc2_.startDelay = param1.startDelay;
         }
         if(param1.applyTimeVariance)
         {
            _loc2_.applyTimeVariance = param1.applyTimeVariance;
         }
         if(Boolean(param1.waitEffectPhase) && Boolean(param1.waitEffect))
         {
            _loc2_.waitEffectPhase = {
               "effect":param1.waitEffect.name,
               "phase":param1.waitEffectPhase.name
            };
         }
         if(param1.results_vars)
         {
            _loc2_.results = param1.results_vars;
         }
         else if(param1.results)
         {
            _loc2_.results = [];
            for each(_loc10_ in param1.results)
            {
               _loc2_.results.push(_loc10_.name);
            }
         }
         if(!param1.rotation)
         {
            _loc2_.rotation = param1.rotation;
         }
         if(param1.reverseRotation)
         {
            _loc2_.reverseRotation = param1.reverseRotation;
         }
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         for each(_loc8_ in param1.entries)
         {
            _loc11_ = _loc8_.toJson();
            if(_loc8_ as PhantasmDefSprite)
            {
               _loc3_.push(_loc11_);
            }
            if(_loc8_ as PhantasmDefColorPulsator)
            {
               _loc7_.push(_loc11_);
            }
            else if(_loc8_ as PhantasmDefFlyText)
            {
               _loc4_.push(_loc11_);
            }
            else if(_loc8_ as PhantasmDefAnim)
            {
               _loc5_.push(_loc11_);
            }
            else if(_loc8_ as PhantasmDefSound)
            {
               _loc6_.push(_loc11_);
            }
         }
         if(_loc3_.length)
         {
            _loc2_.sprites = _loc3_;
         }
         if(_loc4_.length)
         {
            _loc2_.flyTexts = _loc4_;
         }
         if(_loc5_.length)
         {
            _loc2_.anims = _loc5_;
         }
         if(_loc6_.length)
         {
            _loc2_.sounds = _loc6_;
         }
         if(_loc7_.length)
         {
            _loc2_.colors = _loc7_;
         }
         if(Boolean(param1.endTriggers) && Boolean(param1.endTriggers.length))
         {
            _loc2_.endTriggers = [];
            for each(_loc9_ in param1.endTriggers)
            {
               _loc2_.endTriggers.push(PhantasmAnimTriggerDefVars.save(_loc9_));
            }
         }
         if(Boolean(param1.applyTriggers) && Boolean(param1.applyTriggers.length))
         {
            _loc2_.applyTriggers = [];
            for each(_loc9_ in param1.applyTriggers)
            {
               _loc2_.applyTriggers.push(PhantasmAnimTriggerDefVars.save(_loc9_));
            }
         }
         return _loc2_;
      }
      
      private function compareTime(param1:PhantasmDef, param2:PhantasmDef) : int
      {
         return param1.time - param2.time;
      }
   }
}
