package engine.battle.board.def
{
   import engine.tile.def.TileRect;
   
   public class BattleAttractor implements IBattleAttractor
   {
       
      
      public var _def:BattleAttractorDef;
      
      public var _enabled:Boolean;
      
      public function BattleAttractor(param1:BattleAttractorDef)
      {
         super();
         this._def = param1;
         this._enabled = this._def.enabled;
      }
      
      public function get core() : TileRect
      {
         return this._def.core;
      }
      
      public function get leash() : int
      {
         return this._def.leash;
      }
      
      public function get leashRect() : TileRect
      {
         return this._def.leashRect;
      }
      
      public function get def() : BattleAttractorDef
      {
         return this._def;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
      }
      
      public function toString() : String
      {
         return this.def.toString();
      }
   }
}
