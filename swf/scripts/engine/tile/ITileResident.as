package engine.tile
{
   import engine.battle.ability.effect.model.EffectTag;
   import engine.tile.def.TileRect;
   
   public interface ITileResident
   {
       
      
      function get mobile() : Boolean;
      
      function get attackable() : Boolean;
      
      function set attackable(param1:Boolean) : void;
      
      function get battleHudIndicatorVisible() : Boolean;
      
      function set battleHudIndicatorVisible(param1:Boolean) : void;
      
      function get collidable() : Boolean;
      
      function get enabled() : Boolean;
      
      function set enabled(param1:Boolean) : void;
      
      function get active() : Boolean;
      
      function set active(param1:Boolean) : void;
      
      function get x() : Number;
      
      function get y() : Number;
      
      function get localWidth() : Number;
      
      function get localLength() : Number;
      
      function get boardWidth() : Number;
      
      function get boardLength() : Number;
      
      function isLocalRect(param1:int, param2:int) : Boolean;
      
      function get diameter() : Number;
      
      function get tiles() : Tiles;
      
      function get centerX() : Number;
      
      function get centerY() : Number;
      
      function get rect() : TileRect;
      
      function get tile() : Tile;
      
      function canPass(param1:ITileResident) : Boolean;
      
      function awareOf(param1:ITileResident) : Boolean;
      
      function get visible() : Boolean;
      
      function get visibleToPlayer() : Boolean;
      
      function get interactable() : Boolean;
      
      function get nonexistant() : Boolean;
      
      function get usable() : Boolean;
      
      function set usable(param1:Boolean) : void;
      
      function get isSquare() : Boolean;
      
      function hasTag(param1:EffectTag) : Boolean;
   }
}
