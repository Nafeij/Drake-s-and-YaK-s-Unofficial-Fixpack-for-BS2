package engine.tile.def
{
   public class TileDef
   {
       
      
      public var _location:TileLocation;
      
      public var _walkableType:TileWalkableType;
      
      public var _rect:TileRect;
      
      public function TileDef(param1:int, param2:int, param3:TileWalkableType)
      {
         this._walkableType = TileWalkableType.WALKABLE;
         super();
         this.location = TileLocation.fetch(param1,param2);
         this._rect = new TileRect(this.location,1,1);
         this._walkableType = param3;
      }
      
      public function get id() : String
      {
         return this.x + "_" + this.y;
      }
      
      public function toString() : String
      {
         return this._location.toString();
      }
      
      public function get rect() : TileRect
      {
         return this._rect;
      }
      
      public function get y() : int
      {
         return this.location.y;
      }
      
      public function get x() : int
      {
         return this.location.x;
      }
      
      public function get centerX() : Number
      {
         return this.location.x + 0.5;
      }
      
      public function get centerY() : Number
      {
         return this.location.y + 0.5;
      }
      
      public function get location() : TileLocation
      {
         return this._location;
      }
      
      public function set location(param1:TileLocation) : void
      {
         this._location = param1;
      }
   }
}
