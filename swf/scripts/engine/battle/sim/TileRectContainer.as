package engine.battle.sim
{
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class TileRectContainer
   {
       
      
      public var hugs:Vector.<TileLocation>;
      
      public var from:TileRect;
      
      public var rect:TileRect;
      
      public function TileRectContainer(param1:TileRect, param2:TileRect)
      {
         this.hugs = new Vector.<TileLocation>();
         super();
         this.from = param1;
         this.rect = param2;
         param2.visitEnclosedTileLocations(this._visitEnclosed,0);
         this.hugs.sort(this.compare);
      }
      
      private function _visitEnclosed(param1:int, param2:int, param3:*) : void
      {
         this.hugs.push(TileLocation.fetch(param1,param2));
      }
      
      private function compare(param1:TileLocation, param2:TileLocation) : int
      {
         var _loc3_:int = param1.manhattanDistanceTo(this.from.loc);
         var _loc4_:int = param2.manhattanDistanceTo(this.from.loc);
         return _loc3_ - _loc4_;
      }
   }
}
