package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.IPartyDef;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   
   public class Action_GuiSurvivalSetup extends Action
   {
       
      
      public function Action_GuiSurvivalSetup(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:IEntityDef = null;
         saga.setVar(SagaVar.VAR_SURVIVAL_PROGRESS,0);
         saga.setVar(SagaVar.VAR_SURVIVAL_SETUP,0);
         saga.setVar(SagaVar.VAR_SURVIVAL_SETTING_UP,1);
         var _loc1_:IEntityListDef = saga.caravan._legend.roster;
         var _loc2_:IPartyDef = saga.caravan._legend.party;
         _loc2_.clear();
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.numCombatants)
         {
            _loc4_ = _loc1_.getCombatantAt(_loc3_);
            if(_loc4_)
            {
               _loc4_.isSurvivalRecruited = false;
            }
            _loc3_++;
         }
         saga.performAssembleHeroes();
      }
      
      override public function triggerAssembleHeroesComplete() : void
      {
         var _loc4_:IEntityDef = null;
         saga.setVar(SagaVar.VAR_SURVIVAL_SETUP,1);
         saga.setVar(SagaVar.VAR_SURVIVAL_SETTING_UP,0);
         var _loc1_:IEntityListDef = saga.caravan._legend.roster;
         var _loc2_:IPartyDef = saga.caravan._legend.party;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.numCombatants)
         {
            _loc4_ = _loc1_.getCombatantAt(_loc3_);
            if(_loc4_)
            {
               _loc4_.isSurvivalRecruited = _loc2_.hasMemberId(_loc4_.id);
            }
            _loc3_++;
         }
         _loc1_.sortEntities();
         end();
      }
   }
}
