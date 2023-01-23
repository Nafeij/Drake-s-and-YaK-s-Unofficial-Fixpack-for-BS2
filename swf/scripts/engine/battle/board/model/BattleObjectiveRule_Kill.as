package engine.battle.board.model
{
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.core.logging.ILogger;
   
   public class BattleObjectiveRule_Kill extends BattleObjectiveRule
   {
       
      
      public var subdef:Def_Kill;
      
      public function BattleObjectiveRule_Kill(param1:BattleObjective, param2:BattleObjectiveRuleDef)
      {
         super(param1,param2,_secret);
         this.subdef = param2.subdef as Def_Kill;
         board.addEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.killingEffectHandler);
      }
      
      public static function fromJson(param1:Object, param2:ILogger) : Object
      {
         return new Def_Kill().fromJson(param1,param2);
      }
      
      override protected function handleComplete() : void
      {
         board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.killingEffectHandler);
      }
      
      override public function cleanup() : void
      {
         board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.killingEffectHandler);
         super.cleanup();
      }
      
      private function killingEffectHandler(param1:BattleBoardEvent) : void
      {
         var _loc2_:IBattleEntity = param1.entity;
         var _loc3_:IEffect = !!_loc2_ ? _loc2_.killingEffect : null;
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:BattleAbility = _loc3_.ability as BattleAbility;
         if(_loc4_.fake || manager.faking)
         {
            return;
         }
         if(!this.subdef.matchesAbility(_loc3_.ability.def.id))
         {
            return;
         }
         if(this.subdef.casterRequirements)
         {
            if(!this.subdef.casterRequirements.checkExecutionConditions(_loc3_.ability.caster,logger,true))
            {
               return;
            }
         }
         if(this.subdef.targetRequirements)
         {
            if(!this.subdef.targetRequirements.checkExecutionConditions(_loc3_.target,logger,true))
            {
               return;
            }
         }
         complete = true;
      }
   }
}

import engine.battle.ability.def.AbilityExecutionEntityConditions;
import engine.core.logging.ILogger;
import engine.def.EngineJsonDef;
import flash.utils.Dictionary;

class Def_Kill
{
   
   public static const schema:Object = {
      "name":"BattleObjective_Kill",
      "type":"object",
      "properties":{
         "ability":{
            "type":"string",
            "optional":true
         },
         "casterRequirements":{
            "type":AbilityExecutionEntityConditions.schema,
            "optional":true
         },
         "targetRequirements":{
            "type":AbilityExecutionEntityConditions.schema,
            "optional":true
         }
      }
   };
    
   
   public var hasAbilities:Boolean = false;
   
   public var abilities:Dictionary;
   
   public var casterRequirements:AbilityExecutionEntityConditions;
   
   public var targetRequirements:AbilityExecutionEntityConditions;
   
   public function Def_Kill()
   {
      this.abilities = new Dictionary();
      super();
   }
   
   public function matchesAbility(param1:String) : Boolean
   {
      return !this.hasAbilities || Boolean(this.abilities[param1]);
   }
   
   public function fromJson(param1:Object, param2:ILogger) : Object
   {
      var _loc3_:Array = null;
      var _loc4_:String = null;
      EngineJsonDef.validateThrow(param1,schema,param2);
      if(param1.ability)
      {
         _loc3_ = param1.ability.split(",");
         for each(_loc4_ in _loc3_)
         {
            this.hasAbilities = true;
            this.abilities[_loc4_] = true;
         }
      }
      if(param1.casterRequirements)
      {
         this.casterRequirements = new AbilityExecutionEntityConditions().fromJson(param1.casterRequirements,param2);
      }
      if(param1.targetRequirements)
      {
         this.targetRequirements = new AbilityExecutionEntityConditions().fromJson(param1.targetRequirements,param2);
      }
      return this;
   }
}
