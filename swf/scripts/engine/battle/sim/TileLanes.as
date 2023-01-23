package engine.battle.sim
{
   import engine.math.MathUtil;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class TileLanes
   {
       
      
      public var hugs:Vector.<TileLocation>;
      
      public var toward:TileRect;
      
      public var around:TileRect;
      
      public var minDist:int;
      
      public var maxDist:int;
      
      private var maxMove:int;
      
      private var tiles:Tiles;
      
      public function TileLanes(param1:Tiles, param2:TileRect, param3:int, param4:int, param5:TileRect, param6:int)
      {
         this.hugs = new Vector.<TileLocation>();
         super();
         if(param4 < 0)
         {
            throw new ArgumentError("can\'t use maxDist < 0");
         }
         this.tiles = param1;
         this.toward = param5;
         this.minDist = Math.max(1,param3);
         this.maxDist = param4;
         this.around = param2;
         this.maxMove = param6;
         this.makeLeftLanes();
         this.makeRightLanes();
         this.makeFrontLanes();
         this.makeBackLanes();
         this.hugs.sort(this.compare);
      }
      
      private function hugIfCanMoveTo(param1:int, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc3_:TileLocation = TileLocation.fetch(param1,param2);
         if(!this.tiles.getTileByLocation(_loc3_))
         {
            return;
         }
         if(this.maxMove >= 0)
         {
            _loc4_ = MathUtil.manhattanDistance(_loc3_.x,_loc3_.y,this.toward.loc.x,this.toward.loc.y);
            if(_loc4_ > this.maxMove)
            {
               return;
            }
         }
         this.hugs.push(_loc3_);
      }
      
      private function makeFrontLanes() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = this.around.left;
         while(_loc1_ < this.around.right)
         {
            _loc2_ = this.minDist;
            while(_loc2_ <= this.maxDist)
            {
               _loc3_ = this.around.front - _loc2_ - this.toward.length + 1;
               this.hugIfCanMoveTo(_loc1_,_loc3_);
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      private function makeBackLanes() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = this.around.left;
         while(_loc1_ < this.around.right)
         {
            _loc2_ = this.minDist;
            while(_loc2_ <= this.maxDist)
            {
               _loc3_ = this.around.back + _loc2_ - 1;
               this.hugIfCanMoveTo(_loc1_,_loc3_);
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      private function makeLeftLanes() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = this.around.front;
         while(_loc1_ < this.around.back)
         {
            _loc2_ = this.minDist;
            while(_loc2_ <= this.maxDist)
            {
               _loc3_ = this.around.left - _loc2_ - this.toward.width + 1;
               this.hugIfCanMoveTo(_loc3_,_loc1_);
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      private function makeRightLanes() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = this.around.front;
         while(_loc1_ < this.around.back)
         {
            _loc2_ = this.minDist;
            while(_loc2_ <= this.maxDist)
            {
               _loc3_ = this.around.right + _loc2_ - 1;
               this.hugIfCanMoveTo(_loc3_,_loc1_);
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      private function compare(param1:TileLocation, param2:TileLocation) : int
      {
         var _loc3_:int = param1.manhattanDistanceTo(this.toward.loc);
         var _loc4_:int = param2.manhattanDistanceTo(this.toward.loc);
         return _loc3_ - _loc4_;
      }
   }
}
