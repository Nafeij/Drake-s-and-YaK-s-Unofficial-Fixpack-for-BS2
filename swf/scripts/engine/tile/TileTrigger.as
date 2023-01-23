package engine.tile
{
   import engine.tile.def.TileRect;
   
   public class TileTrigger
   {
       
      
      public var _rect:TileRect;
      
      protected var callback:Function;
      
      protected var _visible:Boolean;
      
      public var tiles:Tiles;
      
      public var type:TileTriggerType;
      
      public function TileTrigger(param1:TileRect, param2:Boolean, param3:Function, param4:Tiles)
      {
         this.type = TileTriggerType.NO_TYPE;
         super();
         this._rect = param1.clone();
         this._visible = param2;
         this.callback = param3;
         this.tiles = param4;
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function get rect() : TileRect
      {
         return this._rect;
      }
   }
}
