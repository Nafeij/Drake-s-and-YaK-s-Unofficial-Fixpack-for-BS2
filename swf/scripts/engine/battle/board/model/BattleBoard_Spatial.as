package engine.battle.board.model
{
   import engine.tile.def.TileRect;
   
   public class BattleBoard_Spatial
   {
       
      
      public var board:IBattleBoard;
      
      public function BattleBoard_Spatial(param1:IBattleBoard)
      {
         super();
         this.board = param1;
      }
      
      public function findAllRectIntersectionEntities(param1:TileRect, param2:IBattleEntity, param3:Vector.<IBattleEntity>) : Boolean
      {
         var _loc4_:IBattleEntity = null;
         var _loc5_:Boolean = false;
         for each(_loc4_ in this.board.entities)
         {
            if(_loc4_ != param2)
            {
               if(!(!_loc4_.enabled || !_loc4_.alive))
               {
                  _loc5_ = param1.testIntersectsRect(_loc4_.rect);
                  if(_loc5_)
                  {
                     if(!param3)
                     {
                        return true;
                     }
                     param3.push(_loc4_);
                  }
               }
            }
         }
         return Boolean(param3) && param3.length > 0;
      }
      
      private function internalAddEntityToList(param1:IBattleEntity, param2:int, param3:int, param4:Vector.<IBattleEntity>, param5:Boolean) : Vector.<IBattleEntity>
      {
         var _loc6_:IBattleEntity = this._findEntityOnTile(param2,param3,true,null,false);
         if(Boolean(_loc6_) && (!param4 || param4.indexOf(_loc6_) < 0))
         {
            if(param5 && !param1.awareOf(_loc6_))
            {
               return param4;
            }
            if(!param4)
            {
               param4 = new Vector.<IBattleEntity>();
            }
            param4.push(_loc6_);
         }
         return param4;
      }
      
      public function findAllAdjacentEntities(param1:IBattleEntity, param2:TileRect, param3:Vector.<IBattleEntity>, param4:Boolean) : Vector.<IBattleEntity>
      {
         var _loc5_:int = param2.loc.x;
         var _loc6_:int = param2.loc.y;
         if(param2.width == 1)
         {
            param3 = this.internalAddEntityToList(param1,_loc5_ + 0,_loc6_ - 1,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ + 0,_loc6_ + 1,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ - 1,_loc6_ + 0,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ + 1,_loc6_ + 0,param3,param4);
         }
         else if(param2.width == 2)
         {
            param3 = this.internalAddEntityToList(param1,_loc5_ + 0,_loc6_ - 1,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ + 0,_loc6_ + 2,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ + 1,_loc6_ - 1,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ + 1,_loc6_ + 2,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ - 1,_loc6_ + 0,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ + 2,_loc6_ + 0,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ - 1,_loc6_ + 1,param3,param4);
            param3 = this.internalAddEntityToList(param1,_loc5_ + 2,_loc6_ + 1,param3,param4);
         }
         return param3;
      }
      
      public function _findEntityOnTile(param1:Number, param2:Number, param3:Boolean, param4:*, param5:Boolean) : IBattleEntity
      {
         var _loc6_:IBattleEntity = null;
         var _loc7_:TileRect = null;
         for each(_loc6_ in this.board.entities)
         {
            if(_loc6_ != param4)
            {
               if(!(param3 && !_loc6_.alive))
               {
                  if(!_loc6_.isSubmerged)
                  {
                     _loc7_ = _loc6_.rect;
                     if(_loc7_)
                     {
                        if(_loc7_.testContainsPoint(param1 + 0.5,param2 + 0.5,param5))
                        {
                           return _loc6_;
                        }
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public function find2RectIntersections(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : uint
      {
         if(param1 >= param5 + param7 || param1 + param3 <= param5 || param2 >= param6 + param8 || param2 + param4 <= param6)
         {
            return 0;
         }
         return 1;
      }
   }
}
