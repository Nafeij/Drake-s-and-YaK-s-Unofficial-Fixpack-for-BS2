package engine.battle.board.def
{
   import engine.ability.def.StringIntPair;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import flash.utils.Dictionary;
   
   public class BattleDeploymentAreas
   {
       
      
      public var area:TileLocationArea;
      
      public var deployments:Vector.<BattleDeploymentArea>;
      
      public var locationToDeployment:Dictionary;
      
      public function BattleDeploymentAreas()
      {
         this.area = new TileLocationArea();
         this.deployments = new Vector.<BattleDeploymentArea>();
         this.locationToDeployment = new Dictionary();
         super();
      }
      
      public function clear() : void
      {
         this.area.clear();
         this.deployments.splice(0,this.deployments.length);
         this.locationToDeployment = new Dictionary();
      }
      
      public function get numDeployments() : int
      {
         return !!this.deployments ? this.deployments.length : 0;
      }
      
      public function get numTiles() : int
      {
         return !!this.area ? this.area.numTiles : 0;
      }
      
      public function getLocationFacing(param1:TileLocation) : BattleFacing
      {
         var _loc2_:BattleDeploymentArea = this.locationToDeployment[param1];
         return !!_loc2_ ? _loc2_.facing : null;
      }
      
      public function getExecAbilityId(param1:TileLocation) : StringIntPair
      {
         var _loc2_:BattleDeploymentArea = this.locationToDeployment[param1];
         return !!_loc2_ ? _loc2_.execAbilityId : null;
      }
      
      public function addDeployment(param1:BattleDeploymentArea) : void
      {
         var _loc2_:TileLocation = null;
         this.deployments.push(param1);
         this.area.addArea(param1.area);
         for each(_loc2_ in this.area.locations)
         {
            if(param1.area.hasTile(_loc2_))
            {
               this.locationToDeployment[_loc2_] = param1;
            }
         }
      }
   }
}
