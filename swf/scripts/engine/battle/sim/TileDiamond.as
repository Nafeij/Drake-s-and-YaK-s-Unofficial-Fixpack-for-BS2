package engine.battle.sim
{
   import engine.math.MathUtil;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class TileDiamond
   {
       
      
      public var hugs:Vector.<TileLocation>;
      
      public var toward:TileRect;
      
      public var around:TileRect;
      
      public var minDist:int;
      
      public var maxDist:int;
      
      private var tiles:Tiles;
      
      public function TileDiamond(param1:Tiles, param2:TileRect, param3:int, param4:int, param5:TileRect, param6:int)
      {
         var _loc13_:int = 0;
         var _loc14_:TileLocation = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         this.hugs = new Vector.<TileLocation>();
         super();
         if(param4 < 0)
         {
            throw new ArgumentError("can\'t use maxDist < 0");
         }
         this.tiles = param1;
         this.toward = param5;
         this.minDist = param3;
         this.maxDist = param4;
         this.around = param2;
         var _loc7_:int = param2.left - param4;
         var _loc8_:int = param2.right + (param4 - 1);
         var _loc9_:int = param2.front - param4;
         var _loc10_:int = param2.back + (param4 - 1);
         if(Boolean(param5) && !param5.equals(param2))
         {
            _loc7_ -= param5.width - 1;
            _loc9_ -= param5.length - 1;
         }
         var _loc11_:TileRect = !!param5 ? param5.clone() : new TileRect(param2.loc,1,1,param2.facing);
         var _loc12_:int = _loc7_;
         while(_loc12_ <= _loc8_)
         {
            _loc13_ = _loc9_;
            for(; _loc13_ <= _loc10_; _loc13_++)
            {
               _loc14_ = TileLocation.fetch(_loc12_,_loc13_);
               if(param1.getTileByLocation(_loc14_))
               {
                  _loc11_.loc = _loc14_;
                  _loc15_ = TileRectRange.computeRange(_loc11_,param2);
                  if(_loc15_ <= param4 && _loc15_ >= param3)
                  {
                     if(param6 >= 0 && Boolean(param5))
                     {
                        _loc16_ = MathUtil.manhattanDistance(_loc14_.x,_loc14_.y,param5.loc.x,param5.loc.y);
                        if(_loc16_ > param6)
                        {
                           continue;
                        }
                     }
                     this.hugs.push(_loc14_);
                  }
               }
            }
            _loc12_++;
         }
         if(param5)
         {
            this.hugs.sort(this.compare);
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
