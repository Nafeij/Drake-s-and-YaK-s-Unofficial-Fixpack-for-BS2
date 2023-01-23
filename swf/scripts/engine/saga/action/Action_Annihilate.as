package engine.saga.action
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.def.IBattleAbilityDefFactory;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.saga.Saga;
   
   public class Action_Annihilate extends Action
   {
       
      
      public function Action_Annihilate(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         var _loc2_:IBattleEntity = this.findBattleEntity(_loc1_,false);
         if(!_loc2_)
         {
            throw new ArgumentError("No such entity [" + _loc1_ + "]");
         }
         var _loc3_:IBattleBoard = saga.getBattleBoard();
         var _loc4_:IBattleAbilityManager = _loc3_.abilityManager;
         var _loc5_:IBattleAbilityDefFactory = _loc4_.getFactory;
         var _loc6_:IBattleAbilityDef = _loc5_.fetchIBattleAbilityDef("abl_annihilate");
         var _loc7_:BattleAbility = new BattleAbility(_loc2_,_loc6_,_loc4_);
         _loc7_.targetSet.setTarget(_loc2_);
         _loc7_.execute(null);
         end();
      }
   }
}
