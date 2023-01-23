package engine.battle.board.model
{
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileDef;
   
   public class BattleTile extends Tile
   {
       
      
      public function BattleTile(param1:TileDef, param2:Tiles)
      {
         super(param1,param2);
      }
      
      override public function cleanup() : void
      {
         var _loc1_:ITileResident = null;
         var _loc2_:BattleEntity = null;
         for each(_loc1_ in residents)
         {
            _loc2_ = _loc1_ as BattleEntity;
            if(_loc2_)
            {
               _loc2_.removeEventListener(BattleEntityEvent.COLLIDABLE,this.collidableHandler);
               _loc2_.removeEventListener(BattleEntityEvent.ENABLED,this.collidableHandler);
            }
         }
         super.cleanup();
      }
      
      override public function addResident(param1:ITileResident) : void
      {
         var _loc2_:BattleEntity = param1 as BattleEntity;
         if(_loc2_)
         {
            _loc2_.addEventListener(BattleEntityEvent.COLLIDABLE,this.collidableHandler);
            _loc2_.addEventListener(BattleEntityEvent.ENABLED,this.collidableHandler);
            super.addResident(param1);
         }
      }
      
      override public function removeResident(param1:ITileResident) : void
      {
         var _loc2_:BattleEntity = param1 as BattleEntity;
         if(_loc2_)
         {
            _loc2_.removeEventListener(BattleEntityEvent.COLLIDABLE,this.collidableHandler);
            _loc2_.removeEventListener(BattleEntityEvent.ENABLED,this.collidableHandler);
            super.removeResident(param1);
         }
      }
      
      protected function collidableHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:BattleEntity = param1.entity as BattleEntity;
         if(_loc2_)
         {
            if(_loc2_.collidable && _loc2_.enabled)
            {
               super.addResident(_loc2_);
            }
            else
            {
               super.removeResident(_loc2_);
            }
         }
      }
   }
}
