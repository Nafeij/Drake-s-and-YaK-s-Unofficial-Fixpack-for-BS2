package engine.battle.board.model
{
   import engine.battle.board.def.BattleDeploymentArea;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.geom.Point;
   
   public class BattleDeployer_Factions
   {
       
      
      private var board:BattleBoard;
      
      private var logger:ILogger;
      
      public function BattleDeployer_Factions(param1:BattleBoard)
      {
         super();
         this.board = param1;
         this.logger = param1.logger;
      }
      
      public function autoDeployParty(param1:IBattleParty) : void
      {
         var _loc5_:IBattleEntity = null;
         if(!param1)
         {
            return;
         }
         if(param1.numMembers == 0)
         {
            this.logger.error("BattleDeployer_Factions.autoDeployParty " + this.board.toDebugString() + " cannot autodeploy empty party [" + param1 + "]");
            return;
         }
         var _loc2_:BattleDeploymentArea = this.board.def.getDeploymentAreaById(param1.deployment);
         if(!_loc2_)
         {
            this.logger.error("BattleDeployer_Factions.autoDeployParty " + this.board.toDebugString() + " cannot autodeploy non-existent area(s): [" + param1.deployment + "]");
            return;
         }
         var _loc3_:Point = this.board.def.walkableTiles.rect.center;
         _loc2_.area.resetSorted();
         _loc2_.area.sortByRow(TileLocation.fetch(_loc3_.x,_loc3_.y),false);
         var _loc4_:int = 0;
         while(_loc4_ < param1.numMembers)
         {
            _loc5_ = param1.getMember(_loc4_);
            if(!_loc5_.deploymentReady)
            {
               this.autoDeployCharacter(_loc5_,_loc2_);
            }
            _loc4_++;
         }
      }
      
      public function autoDeployCharacter(param1:IBattleEntity, param2:BattleDeploymentArea) : void
      {
         var _loc4_:TileLocation = null;
         var _loc3_:TileRect = param2.area.rect;
         for each(_loc4_ in param2.area.sorted)
         {
            if(this.board.attemptDeploy(param1,param2.facing,param2.area,_loc4_))
            {
               param2.area.removeSortedRectSize(param1.tile.location,param1.boardWidth,param1.boardLength);
               return;
            }
         }
         this.logger.error("Failed to autoDeployCharacter " + param1 + " in deployment: " + param2);
      }
   }
}
