package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   import engine.path.PathGraph;
   import engine.path.PathRegionsMapping;
   import engine.tile.Tile;
   
   public class BattleBoardPathGraph extends PathGraph
   {
      
      public static const REGION_WALKABLE:int = 0;
      
      public static const REGION_UNWALKABLE:int = 1;
       
      
      public var tiles:BattleBoardTiles;
      
      public var regionsMapping:PathRegionsMapping;
      
      public function BattleBoardPathGraph(param1:BattleBoardTiles, param2:ILogger)
      {
         var _loc3_:Tile = null;
         var _loc4_:int = 0;
         this.regionsMapping = new PathRegionsMapping();
         this.regionsMapping.addLink(REGION_UNWALKABLE,REGION_WALKABLE);
         super(heuristicDistance,coherenceFunction,param2,this.regionsMapping);
         this.tiles = param1;
         for each(_loc3_ in param1.tiles)
         {
            _loc4_ = 0;
            addNode(_loc3_,0,_loc4_);
         }
         for each(_loc3_ in param1.tiles)
         {
            this.linkTile(_loc3_,1,0);
            this.linkTile(_loc3_,-1,0);
            this.linkTile(_loc3_,0,1);
            this.linkTile(_loc3_,0,-1);
         }
         finishGraphGeneration(1,null);
      }
      
      private static function coherenceFunction(param1:Tile, param2:Tile, param3:Tile) : Number
      {
         return 1;
      }
      
      private static function heuristicDistance(param1:Tile, param2:Tile) : Number
      {
         var _loc3_:int = param1.x - param2.x;
         var _loc4_:int = param1.y - param2.y;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_;
      }
      
      private function linkTile(param1:Tile, param2:int, param3:int) : void
      {
         var _loc4_:Tile = this.tiles.getTile(param1.x + param2,param1.y + param3);
         if(_loc4_)
         {
            addLink(param1,_loc4_,0);
         }
      }
   }
}
