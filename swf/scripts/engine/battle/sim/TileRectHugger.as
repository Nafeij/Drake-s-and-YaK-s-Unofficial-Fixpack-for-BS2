package engine.battle.sim
{
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class TileRectHugger
   {
       
      
      public var hugs:Vector.<TileLocation>;
      
      public var from:TileRect;
      
      public var rect:TileRect;
      
      private var bloat:TileRect;
      
      public function TileRectHugger(param1:TileRect, param2:TileRect)
      {
         this.hugs = new Vector.<TileLocation>();
         super();
         this.from = param1;
         this.rect = param2;
         this.bloat = new TileRect(TileLocation.fetch(param2.left - param1.width,param2.front - param1.length),param2.width + param1.width,param2.length + param1.length);
         var _loc3_:int = this.bloat.left + 1;
         while(_loc3_ < this.bloat.right)
         {
            this.hugs.push(TileLocation.fetch(_loc3_,this.bloat.front));
            this.hugs.push(TileLocation.fetch(_loc3_,this.bloat.back));
            _loc3_++;
         }
         var _loc4_:int = this.bloat.front + 1;
         while(_loc4_ < this.bloat.back)
         {
            this.hugs.push(TileLocation.fetch(this.bloat.left,_loc4_));
            this.hugs.push(TileLocation.fetch(this.bloat.right,_loc4_));
            _loc4_++;
         }
         this.hugs.sort(this.compare);
      }
      
      private function compare(param1:TileLocation, param2:TileLocation) : int
      {
         var _loc3_:int = param1.manhattanDistanceTo(this.from.loc);
         var _loc4_:int = param2.manhattanDistanceTo(this.from.loc);
         var _loc5_:Boolean = param1.y > this.bloat.front && param1.y < this.bloat.back || param1.x > this.bloat.left && param1.x < this.bloat.right;
         var _loc6_:Boolean = param2.y > this.bloat.front && param2.y < this.bloat.back || param2.x > this.bloat.left && param2.x < this.bloat.right;
         var _loc7_:int = this.bloat.width * this.bloat.length;
         var _loc8_:int = !_loc5_ ? _loc7_ : 0;
         var _loc9_:int = !_loc6_ ? _loc7_ : 0;
         return _loc3_ + _loc8_ - (_loc4_ + _loc9_);
      }
   }
}
