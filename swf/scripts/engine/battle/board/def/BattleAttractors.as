package engine.battle.board.def
{
   import engine.battle.board.model.IBattleEntity;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class BattleAttractors
   {
       
      
      public var def:BattleAttractorsDef;
      
      public var attractors:Vector.<BattleAttractor>;
      
      public function BattleAttractors(param1:BattleAttractorsDef)
      {
         var _loc2_:BattleAttractorDef = null;
         var _loc3_:BattleAttractor = null;
         this.attractors = new Vector.<BattleAttractor>();
         super();
         for each(_loc2_ in param1.attractors)
         {
            _loc3_ = new BattleAttractor(_loc2_);
            this.attractors.push(_loc3_);
         }
      }
      
      public function cleanup() : void
      {
         this.attractors = null;
         this.def = null;
      }
      
      public function findClosestValidAttractor(param1:IBattleEntity) : BattleAttractor
      {
         var _loc2_:BattleAttractor = null;
         var _loc5_:BattleAttractor = null;
         var _loc6_:int = 0;
         var _loc3_:int = int.MAX_VALUE;
         var _loc4_:TileRect = param1.rect;
         for each(_loc5_ in this.attractors)
         {
            if(_loc5_.enabled)
            {
               _loc6_ = TileRectRange.computeRange(_loc4_,_loc5_.core);
               if(_loc6_ < _loc3_)
               {
                  _loc3_ = _loc6_;
                  _loc2_ = _loc5_;
               }
            }
         }
         return _loc2_;
      }
      
      public function getAttractorById(param1:String) : IBattleAttractor
      {
         var _loc2_:BattleAttractor = null;
         for each(_loc2_ in this.attractors)
         {
            if(_loc2_._def.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
   }
}
