package engine.battle.ability.effect.def
{
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.model.IEffect;
   import engine.core.logging.ILogger;
   import engine.core.util.StableJson;
   
   public class EffectDefConditions
   {
       
      
      public var other:String;
      
      public var results:Vector.<EffectResult>;
      
      public var tag:EffectTagReqs;
      
      public var minLevel:int;
      
      public var target:AbilityExecutionEntityConditions;
      
      public function EffectDefConditions()
      {
         this.results = new Vector.<EffectResult>();
         super();
      }
      
      public function toString() : String
      {
         return StableJson.stringifyObject(EffectDefConditionsVars.save(this),"").replace(/\n/g,"");
      }
      
      private function isResultSatisfactory(param1:EffectResult) : Boolean
      {
         var _loc2_:EffectResult = null;
         if(this.results.length == 0)
         {
            return true;
         }
         for each(_loc2_ in this.results)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function checkEffectConditions(param1:IEffect, param2:ILogger, param3:AbilityReason) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(!this.isResultSatisfactory(param1.result))
         {
            AbilityReason.setMessage(param3,"wrong_result");
            return false;
         }
         if(this.tag)
         {
            if(!this.tag.checkTags(param1,param2,param3))
            {
               return false;
            }
         }
         if(Boolean(this.target) && Boolean(param1.target))
         {
            if(!this.target.checkExecutionConditions(param1.target,param2,true))
            {
               AbilityReason.setMessage(param3,"eff_target_cond");
               return false;
            }
         }
         return true;
      }
   }
}
