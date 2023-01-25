package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_BattleWaitUnitInteracted extends Action
   {
       
      
      private var waitForIt:IBattleEntity;
      
      public function Action_BattleWaitUnitInteracted(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = null;
         var _loc2_:IEntityDef = null;
         var _loc3_:BattleBoard = null;
         if(def.id)
         {
            _loc1_ = def.id;
            _loc2_ = saga.getCastMember(_loc1_);
            if(_loc2_)
            {
               _loc1_ = String(_loc2_.id);
            }
            _loc3_ = saga.getBattleBoard();
            if(Boolean(_loc3_) && Boolean(_loc3_.fsm))
            {
               this.waitForIt = _loc3_.getEntityByIdOrByDefId(_loc1_,null,false);
               if(this.waitForIt)
               {
                  _loc3_.fsm.addEventListener(BattleFsmEvent.INTERACT,this.battleFsmInteractHandler);
                  return;
               }
               throw new ArgumentError("Invalid id [" + _loc1_ + "] from [" + def.id + "]");
            }
         }
         end();
      }
      
      private function battleFsmInteractHandler(param1:BattleFsmEvent) : void
      {
         var _loc2_:BattleBoard = saga.getBattleBoard();
         var _loc3_:BattleFsm = !!_loc2_ ? _loc2_.fsm as BattleFsm : null;
         if(_loc3_)
         {
            if(!_loc3_.turn || !_loc3_.turn.entity || _loc3_.interact != this.waitForIt)
            {
               return;
            }
         }
         param1.target.removeEventListener(BattleFsmEvent.INTERACT,this.battleFsmInteractHandler);
         end();
      }
   }
}
