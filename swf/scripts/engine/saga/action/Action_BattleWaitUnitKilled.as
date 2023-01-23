package engine.saga.action
{
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.saga.Saga;
   
   public class Action_BattleWaitUnitKilled extends Action
   {
       
      
      private var bb:BattleBoard;
      
      private var entity:IBattleEntity;
      
      public function Action_BattleWaitUnitKilled(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(def.id)
         {
            this.bb = saga.getBattleBoard();
            if(this.bb)
            {
               this.entity = this.bb.getEntityByIdOrByDefId(def.id,null,false);
               if(this.entity)
               {
                  this.bb.addEventListener(BattleBoardEvent.BOARD_ENTITY_ALIVE,this.boardEntityAliveHandler);
                  return;
               }
               throw ArgumentError("No such entity [" + def.id + "]");
            }
         }
         end();
      }
      
      private function boardEntityAliveHandler(param1:BattleBoardEvent) : void
      {
         if(param1.entity == this.entity)
         {
            if(!param1.entity.alive)
            {
               this.bb.removeEventListener(BattleBoardEvent.BOARD_ENTITY_MOVING,this.boardEntityAliveHandler);
               end();
            }
         }
      }
   }
}
