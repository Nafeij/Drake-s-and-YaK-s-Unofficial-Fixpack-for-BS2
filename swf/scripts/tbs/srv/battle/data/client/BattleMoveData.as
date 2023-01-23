package tbs.srv.battle.data.client
{
   import engine.core.logging.ILogger;
   import engine.tile.TileLocationVars;
   import engine.tile.def.TileLocation;
   
   public class BattleMoveData extends BaseBattleTurnData
   {
       
      
      public var tiles:Vector.<TileLocation>;
      
      public function BattleMoveData()
      {
         this.tiles = new Vector.<TileLocation>();
         super();
      }
      
      override public function toString() : String
      {
         return super.toString() + ", [tiles=" + this.tiles + "]";
      }
      
      override public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         super.parseJson(param1,param2);
         for each(_loc3_ in param1.tiles)
         {
            this.tiles.push(TileLocationVars.parse(_loc3_,param2));
         }
      }
   }
}
