package engine.saga.action
{
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.saga.Saga;
   
   public class Action_BattleWaitMove extends Action
   {
       
      
      private var bb:BattleBoard;
      
      private var entity:IBattleEntity;
      
      public var moving:Boolean;
      
      public function Action_BattleWaitMove(param1:ActionDef, param2:Saga, param3:Boolean)
      {
         super(param1,param2);
         this.moving = param3;
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
                  this.bb.addEventListener(BattleBoardEvent.BOARD_ENTITY_MOVING,this.boardEntityMovingHandler);
                  return;
               }
               throw ArgumentError("No such entity [" + def.id + "]");
            }
         }
         end();
      }
      
      private function boardEntityMovingHandler(param1:BattleBoardEvent) : void
      {
         if(param1.entity == this.entity)
         {
            if(param1.entity.mobility.moving == this.moving)
            {
               this.bb.removeEventListener(BattleBoardEvent.BOARD_ENTITY_MOVING,this.boardEntityMovingHandler);
               end();
            }
         }
      }
   }
}
