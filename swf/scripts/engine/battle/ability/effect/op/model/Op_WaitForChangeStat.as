package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.core.util.Enum;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   
   public class Op_WaitForChangeStat extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForChangeStat",
         "properties":{
            "ability":{"type":"string"},
            "stat":{"type":"string"},
            "delta":{"type":"number"},
            "threshold":{
               "type":"number",
               "optional":true
            },
            "targetOriginalCaster":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var oldWatchValue:int;
      
      private var ablDef:BattleAbilityDef;
      
      public var stat_target_watch:Stat;
      
      private var delta:int;
      
      private var threshold:int = 0;
      
      private var useThreshold:Boolean;
      
      private var targetOriginalCaster:Boolean = false;
      
      private var statType:StatType;
      
      public function Op_WaitForChangeStat(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         var _loc3_:String = param1.params.ability;
         this.ablDef = manager.factory.fetchBattleAbilityDef(_loc3_);
         if(!this.ablDef)
         {
            manager.logger.error("Op_WaitForChangeStat " + this + " invalid ability [" + _loc3_ + "]");
         }
         var _loc4_:String = param1.params.stat;
         this.statType = Enum.parse(StatType,_loc4_,false) as StatType;
         if(!this.statType)
         {
            manager.logger.error("Op_WaitForChangeStat " + this + " invalid stat [" + _loc4_ + "]");
         }
         if(param1.params.threshold != undefined)
         {
            this.threshold = param1.params.threshold;
            this.useThreshold = true;
         }
         if(param1.params.targetOriginalCaster != undefined)
         {
            this.targetOriginalCaster = param1.params.targetOriginalCaster;
         }
         this.delta = param1.params.delta;
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(effect.ability.fake || manager.faking)
         {
            return;
         }
         this.stat_target_watch = requireStat(target,this.statType);
         this.oldWatchValue = this.stat_target_watch.value;
         this.stat_target_watch.addEventListener(StatEvent.CHANGE,this.statChangedHandler);
      }
      
      override public function remove() : void
      {
         this.stat_target_watch.removeEventListener(StatEvent.CHANGE,this.statChangedHandler);
      }
      
      private function statChangedHandler(param1:StatEvent) : void
      {
         var _loc2_:int = this.stat_target_watch.value;
         var _loc3_:int = this.oldWatchValue;
         var _loc4_:int = _loc2_ - _loc3_;
         this.oldWatchValue = this.stat_target_watch.value;
         if(!_loc4_)
         {
            return;
         }
         if(this.delta < 0)
         {
            if(_loc4_ > this.delta)
            {
               return;
            }
            if(this.useThreshold)
            {
               if(_loc2_ > this.threshold || _loc3_ <= this.threshold)
               {
                  return;
               }
            }
         }
         if(this.delta > 0)
         {
            if(_loc4_ < this.delta)
            {
               return;
            }
            if(this.useThreshold)
            {
               if(_loc2_ < this.threshold || _loc3_ >= this.threshold)
               {
                  return;
               }
            }
         }
         if(manager.isOpIncomplete(this))
         {
            return;
         }
         logger.info("Op_WaitForChangeStat triggered on " + target + " for " + this.stat_target_watch + " from " + _loc3_ + " -> " + _loc2_ + " via " + this);
         var _loc5_:BattleAbility = new BattleAbility(target,this.ablDef,manager);
         if(this.targetOriginalCaster)
         {
            _loc5_.targetSet.setTarget(caster);
         }
         else
         {
            _loc5_.targetSet.setTarget(target);
         }
         _loc5_.execute(null);
      }
   }
}
