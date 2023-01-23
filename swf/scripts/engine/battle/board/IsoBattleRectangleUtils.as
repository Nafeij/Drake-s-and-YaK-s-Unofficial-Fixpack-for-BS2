package engine.battle.board
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class IsoBattleRectangleUtils
   {
       
      
      public function IsoBattleRectangleUtils()
      {
         super();
      }
      
      public static function getIsoRectScreenRect(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Rectangle
      {
         var _loc6_:Pt = IsoMath.isoToScreen(new Pt(param2 * param1,param3 * param1));
         var _loc7_:Pt = IsoMath.isoToScreen(new Pt((param2 + param4) * param1,param3 * param1));
         var _loc8_:Number = (_loc6_.x - _loc7_.x) * 2;
         var _loc9_:Number = (_loc7_.y - _loc6_.y) * 2;
         if(param4 != param5)
         {
            throw new ArgumentError("we currently only support entities with square footprints");
         }
         return new Rectangle(_loc7_.x,_loc6_.y,_loc8_,_loc9_);
      }
      
      public static function getIsoPointScreenPoint(param1:Number, param2:Number, param3:Number) : Point
      {
         var _loc4_:Pt = IsoMath.isoToScreen(new Pt(param2 * param1,param3 * param1));
         return new Point(_loc4_.x,_loc4_.y);
      }
   }
}
