package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleFsm;
   import engine.saga.Saga;
   
   public class Action_BattleSpawn extends Action_BattleUnitMove
   {
       
      
      public function Action_BattleSpawn(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:BattleBoardView = null;
         var _loc5_:BattleFsm = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         if(!def.id)
         {
            throw new ArgumentError("no id");
         }
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(!_loc1_)
         {
            throw new ArgumentError("no battle");
         }
         var _loc2_:String = def.id;
         var _loc3_:IBattleEntity = _loc1_._spawn.spawnSpawnerById(_loc2_,true,false,null);
         if(!_loc3_)
         {
            throw new ArgumentError("unable to spawn spawner id [" + _loc2_ + "]");
         }
         saga.applyUnitDifficultyBonuses(_loc3_);
         if(_loc3_)
         {
            if(def.varname)
            {
               logger.info("Assigning VAR [ " + def.varname + "] from spawnend [" + _loc3_.id + "]");
               saga.setVar(def.varname,_loc3_.id);
            }
            _loc4_ = BattleBoardView.instance;
            if(Boolean(_loc3_.active) && Boolean(_loc3_.enabled) && Boolean(_loc3_.mobile) && Boolean(_loc3_.attackable))
            {
               if(_loc3_.party.team != "prop")
               {
                  _loc5_ = _loc1_.fsm as BattleFsm;
                  if(_loc5_ && _loc5_.order && _loc5_.order.initialized)
                  {
                     _loc5_.order.addEntity(_loc3_);
                     _loc5_.participants.push(_loc3_);
                  }
               }
            }
            if(def.anchor)
            {
               _loc6_ = Boolean(def.param) && def.param.indexOf("camera") >= 0;
               _loc7_ = Boolean(def.param) && def.param.indexOf("follow") >= 0;
               _loc8_ = Boolean(def.param) && def.param.indexOf("pathfind") >= 0;
               performMovement(_loc3_.id,def.anchor,_loc6_,_loc7_,true,_loc8_);
               return;
            }
         }
         end();
      }
   }
}
