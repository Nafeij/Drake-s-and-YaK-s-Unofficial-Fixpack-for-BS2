package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.view.BattleBoardView;
   import engine.saga.Saga;
   import engine.tile.def.TileLocation;
   
   public class Action_BattleTileMarker extends Action
   {
       
      
      public function Action_BattleTileMarker(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(!_loc1_)
         {
            end();
            return;
         }
         var _loc2_:String = def.param;
         var _loc3_:TileLocation = this.extractTileLocation(_loc1_,_loc2_);
         var _loc4_:BattleBoardView = BattleBoardView.instance;
         if(Boolean(_loc4_) && _loc4_.board == _loc1_)
         {
            _loc4_.underlay.marker.tileLocation = _loc3_;
         }
         end();
      }
      
      private function extractTileLocation(param1:BattleBoard, param2:String) : TileLocation
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(Boolean(param2) && param2.charAt(0) == "@")
         {
            param2 = param2.substr(1);
            _loc3_ = param2.split(",");
            _loc4_ = int(_loc3_[0]);
            _loc5_ = int(_loc3_[1]);
            return TileLocation.fetch(_loc4_,_loc5_);
         }
         return null;
      }
   }
}
