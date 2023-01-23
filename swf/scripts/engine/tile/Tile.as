package engine.tile
{
   import engine.battle.ability.effect.model.EffectTag;
   import engine.tile.def.TileDef;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileWalkableType;
   import flash.utils.Dictionary;
   
   public class Tile
   {
       
      
      public var def:TileDef;
      
      public var tiles:Tiles;
      
      private var _residents:Dictionary;
      
      public var _numResidents:int;
      
      private var _walkableType:TileWalkableType;
      
      public function Tile(param1:TileDef, param2:Tiles)
      {
         this._residents = new Dictionary();
         super();
         this.def = param1;
         this.tiles = param2;
         this._walkableType = param1._walkableType;
      }
      
      public function cleanup() : void
      {
         this.def = this.def;
         this.tiles = null;
         this._residents = null;
         this._numResidents = 0;
      }
      
      public function equals(param1:Tile) : Boolean
      {
         return this.def._location.equals(param1.def._location);
      }
      
      public function get id() : String
      {
         return "tile_" + this.def.id;
      }
      
      public function get name() : String
      {
         return "Tile";
      }
      
      public function toString() : String
      {
         return this.def.toString();
      }
      
      public function addResident(param1:ITileResident) : void
      {
         if(this._residents[param1] == null)
         {
            if(param1.collidable && param1.enabled)
            {
               ++this._numResidents;
               this._residents[param1] = param1;
            }
         }
      }
      
      public function removeResident(param1:ITileResident) : void
      {
         if(this._residents[param1] != null)
         {
            --this._numResidents;
            delete this._residents[param1];
         }
      }
      
      public function hasResident(param1:ITileResident) : Boolean
      {
         return this._residents[param1] != null;
      }
      
      public function findResident(param1:ITileResident) : ITileResident
      {
         var _loc2_:ITileResident = null;
         for each(_loc2_ in this._residents)
         {
            if(_loc2_ != param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function get numResidents() : int
      {
         return this._numResidents;
      }
      
      public function get location() : TileLocation
      {
         return this.def._location;
      }
      
      public function get rect() : TileRect
      {
         return this.def._rect;
      }
      
      public function get y() : int
      {
         return this.def._location._y;
      }
      
      public function get x() : int
      {
         return this.def._location._x;
      }
      
      public function get centerX() : Number
      {
         return this.def._location._x + 0.5;
      }
      
      public function get centerY() : Number
      {
         return this.def._location._y + 0.5;
      }
      
      public function get residents() : Dictionary
      {
         return this._residents;
      }
      
      public function get anyResident() : ITileResident
      {
         var _loc1_:ITileResident = null;
         if(!this._residents)
         {
            return null;
         }
         for each(_loc1_ in this._residents)
         {
            if(_loc1_.collidable && _loc1_.enabled)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      public function getWalkableFor(param1:ITileResident = null) : Boolean
      {
         if(param1)
         {
            switch(this._walkableType)
            {
               case TileWalkableType.WALKABLE:
                  return true;
               case TileWalkableType.NOT_WALKABLE:
                  return false;
               case TileWalkableType.GHOST_WALKABLE:
                  return param1.hasTag(EffectTag.GHOSTED);
            }
         }
         return this._walkableType == TileWalkableType.WALKABLE;
      }
      
      public function setWalkableType(param1:TileWalkableType) : void
      {
         if(param1)
         {
            this._walkableType = param1;
         }
      }
   }
}
