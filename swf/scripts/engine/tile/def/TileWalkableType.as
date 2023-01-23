package engine.tile.def
{
   import engine.core.util.Enum;
   
   public class TileWalkableType extends Enum
   {
      
      public static const WALKABLE:TileWalkableType = new TileWalkableType("WALKABLE",enumCtorKey);
      
      public static const NOT_WALKABLE:TileWalkableType = new TileWalkableType("NOT_WALKABLE",enumCtorKey);
      
      public static const GHOST_WALKABLE:TileWalkableType = new TileWalkableType("GHOST_WALKABLE",enumCtorKey);
       
      
      public function TileWalkableType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
