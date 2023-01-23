package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.fsm.IBattleTurnOrder;
   import engine.battle.sim.BattleParty;
   import engine.entity.def.IEntityDef;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   
   public class Op_ResurrectEntity extends Op
   {
       
      
      public function Op_ResurrectEntity(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         var _loc1_:IEntityDef = target.def;
         var _loc2_:Stats = target.stats;
         _loc2_.setBase(StatType.STRENGTH,Number(_loc1_.stats.getValue(StatType.STRENGTH)) / 2);
         _loc2_.setBase(StatType.WILLPOWER,caster.stats.getValue(StatType.WILLPOWER));
         var _loc3_:BattleEntity = target as BattleEntity;
         _loc3_.active = true;
         _loc3_.alive = true;
         _loc3_.resetKillingEffect();
         var _loc4_:Boolean = true;
         var _loc5_:Number = 1;
         _loc3_.animController.playAnim("die",1,false,false,_loc4_,_loc5_);
         var _loc6_:BattleBoard = board as BattleBoard;
         var _loc7_:BattleParty = caster.party as BattleParty;
         var _loc8_:BattleParty = target.party as BattleParty;
         var _loc9_:IBattleTurnOrder = board.fsm.order;
         if(_loc8_ != _loc7_)
         {
            _loc8_.removeMember(target);
            _loc7_.addMember(target);
         }
         _loc9_.addEntity(target);
         if(board.fsm.participants.indexOf(target) < 0)
         {
            board.fsm.participants.push(target);
         }
         target.centerCameraOnEntity();
      }
   }
}
