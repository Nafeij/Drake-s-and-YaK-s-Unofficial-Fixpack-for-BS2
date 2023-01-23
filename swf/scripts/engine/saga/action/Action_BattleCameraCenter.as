package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.saga.Saga;
   
   public class Action_BattleCameraCenter extends Action
   {
       
      
      public function Action_BattleCameraCenter(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:IBattleEntity = null;
         var _loc1_:BattleBoardView = BattleBoardView.instance;
         var _loc2_:BattleBoard = saga.getBattleBoard();
         if(!_loc1_ || !_loc2_)
         {
            end();
            return;
         }
         if(!def.id)
         {
            _loc1_.cameraFollowEntity(null,false);
            end();
            return;
         }
         var _loc3_:String = def.param;
         var _loc4_:Array = !!_loc3_ ? _loc3_.split(" ") : [];
         for each(_loc10_ in _loc4_)
         {
            if(_loc10_ == "follow")
            {
               _loc5_ = true;
            }
            else if(_loc10_ == "instant")
            {
               _loc6_ = true;
            }
            else if(_loc10_ == "allowDead")
            {
               _loc7_ = true;
            }
            else if(_loc10_.indexOf("cameraX=") == 0)
            {
               _loc8_ = int(_loc10_.substr("cameraX".length));
            }
            else if(_loc10_.indexOf("cameraY=") == 0)
            {
               _loc9_ = int(_loc10_.substr("cameraY=".length));
            }
         }
         _loc11_ = super.findBattleEntityFromList(def.id,_loc7_);
         if(_loc11_)
         {
            if(_loc5_)
            {
               _loc1_.cameraFollowEntity(_loc11_,_loc6_);
            }
            else
            {
               _loc1_.cameraCenterOnEntity(_loc11_,_loc6_,_loc8_,_loc9_);
            }
         }
         else
         {
            logger.info("Unable to find any suitable entity in [" + def.id + "]");
         }
         _loc1_.board.scene.disableStartPan();
         end();
      }
   }
}
