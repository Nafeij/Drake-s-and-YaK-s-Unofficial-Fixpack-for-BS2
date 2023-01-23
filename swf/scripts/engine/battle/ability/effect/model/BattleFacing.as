package engine.battle.ability.effect.model
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import engine.anim.def.IAnimFacing;
   import engine.core.util.Enum;
   import engine.math.MathUtil;
   import engine.tile.def.TileRect;
   
   public class BattleFacing extends Enum implements IAnimFacing
   {
      
      public static const NE:BattleFacing = new BattleFacing("NE",0,-1,enumCtorKey);
      
      public static const SE:BattleFacing = new BattleFacing("SE",1,0,enumCtorKey);
      
      public static const SW:BattleFacing = new BattleFacing("SW",0,1,enumCtorKey);
      
      public static const NW:BattleFacing = new BattleFacing("NW",-1,0,enumCtorKey);
      
      private static var _facings:Vector.<BattleFacing>;
       
      
      public var x:int;
      
      public var y:int;
      
      public var angleRadians:Number;
      
      public var angleDegrees:Number;
      
      public var isoAngleRadians:Number;
      
      public function BattleFacing(param1:String, param2:int, param3:int, param4:Object)
      {
         super(param1,param4);
         this.x = param2;
         this.y = param3;
         this.angleRadians = Math.atan2(param3,param2);
         this.angleDegrees = 180 * this.angleRadians / Math.PI;
         var _loc5_:Pt = IsoMath.isoToScreen(new Pt(param2,param3));
         this.isoAngleRadians = Math.atan2(_loc5_.y,_loc5_.x) + Math.PI / 2;
      }
      
      public static function get facings() : Vector.<BattleFacing>
      {
         if(!_facings)
         {
            _facings = new Vector.<BattleFacing>();
            _facings.push(NE);
            _facings.push(SE);
            _facings.push(SW);
            _facings.push(NW);
         }
         return _facings;
      }
      
      public static function findFacing(param1:Number, param2:Number) : BattleFacing
      {
         if(Math.abs(param1) > Math.abs(param2))
         {
            if(param1 > 0)
            {
               return SE;
            }
            return NW;
         }
         if(param2 > 0)
         {
            return SW;
         }
         return NE;
      }
      
      public static function findFacingAlt(param1:Number, param2:Number) : BattleFacing
      {
         if(Math.abs(param1) >= Math.abs(param2))
         {
            if(param1 >= 0)
            {
               return SE;
            }
            return NW;
         }
         if(param2 >= 0)
         {
            return SW;
         }
         return NE;
      }
      
      public static function findAxialFacingBetweenRects(param1:TileRect, param2:TileRect) : BattleFacing
      {
         var _loc3_:int = param1.right;
         var _loc4_:int = param1.left;
         var _loc5_:int = param1.front;
         var _loc6_:int = param1.back;
         var _loc7_:int = param2.right;
         var _loc8_:int = param2.left;
         var _loc9_:int = param2.front;
         var _loc10_:int = param2.back;
         if(_loc3_ <= _loc8_)
         {
            return SE;
         }
         if(_loc4_ >= _loc7_)
         {
            return NW;
         }
         if(_loc6_ <= _loc9_)
         {
            return SW;
         }
         if(_loc5_ >= _loc10_)
         {
            return NE;
         }
         return null;
      }
      
      public function get flip() : IAnimFacing
      {
         return this.flipBattleFacing;
      }
      
      public function get flipBattleFacing() : BattleFacing
      {
         switch(this)
         {
            case NE:
               return SW;
            case NW:
               return SE;
            case SW:
               return NE;
            case SE:
               return NW;
            default:
               throw new ArgumentError("invalidly flippered");
         }
      }
      
      public function angleRadiansToPoint(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = Math.atan2(param2,param1);
         _loc3_ -= this.angleRadians;
         return MathUtil.mungeRadians(_loc3_);
      }
      
      public function clockwise() : IAnimFacing
      {
         return this.clockwiseBattleFacing();
      }
      
      public function clockwiseBattleFacing() : BattleFacing
      {
         switch(this)
         {
            case NE:
               return NW;
            case NW:
               return SW;
            case SW:
               return SE;
            case SE:
               return NE;
            default:
               return this;
         }
      }
      
      public function getLeft(param1:int, param2:int) : int
      {
         var _loc3_:int = 0;
         if(this.x > 0)
         {
            _loc3_ = Math.abs(param1 - param2);
            return -_loc3_;
         }
         return 0;
      }
      
      public function getRight(param1:int, param2:int) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = Math.min(param1,param2);
         if(this.x < 0)
         {
            _loc4_ = Math.abs(param1 - param2);
            return _loc3_ + _loc4_;
         }
         return _loc3_;
      }
      
      public function getFront(param1:int, param2:int) : int
      {
         var _loc3_:int = 0;
         if(this.y > 0)
         {
            _loc3_ = Math.abs(param1 - param2);
            return -_loc3_;
         }
         return 0;
      }
      
      public function getBack(param1:int, param2:int) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = Math.min(param1,param2);
         if(this.y < 0)
         {
            _loc4_ = Math.abs(param1 - param2);
            return _loc3_ + _loc4_;
         }
         return _loc3_;
      }
      
      public function get deltaX() : int
      {
         return this.x;
      }
      
      public function get deltaY() : int
      {
         return this.y;
      }
   }
}
