package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.entity.model.BattleEntityEvent;
   
   public class Op_WaitForEntityEvent extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForEntityEvent",
         "properties":{
            "ability":{"type":"string"},
            "abilityLevel":{
               "type":"number",
               "optional":true
            },
            "event":{"type":"string"},
            "execChild":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      private var ablDef:BattleAbilityDef;
      
      private var eventType:String;
      
      private var execChild:Boolean;
      
      private var abilityLevel:int;
      
      public function Op_WaitForEntityEvent(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         this.eventType = param1.params.event;
         if(param1.params.abilityLevel)
         {
            this.abilityLevel = int(param1.params.abilityLevel);
         }
         this.abilityLevel = Math.min(this.ablDef.maxLevel,Math.max(1,this.abilityLevel));
         var _loc3_:Class = BattleEntityEvent;
         var _loc4_:* = _loc3_[this.eventType];
         if(!_loc4_)
         {
            throw ArgumentError("invalid event type [" + this.eventType + "]");
         }
         this.eventType = _loc4_;
      }
      
      override public function apply() : void
      {
         target.addEventListener(this.eventType,this.eventHandler);
      }
      
      override public function remove() : void
      {
         target.removeEventListener(this.eventType,this.eventHandler);
      }
      
      private function eventHandler(param1:BattleEntityEvent) : void
      {
         if(!caster)
         {
            return;
         }
         var _loc2_:BattleAbility = new BattleAbility(target,this.ablDef.getBattleAbilityDefLevel(this.abilityLevel),manager);
         _loc2_.targetSet.addTarget(target);
         if(this.execChild)
         {
            ability.addChildAbility(_loc2_);
         }
         else
         {
            _loc2_.execute(null);
         }
      }
   }
}
