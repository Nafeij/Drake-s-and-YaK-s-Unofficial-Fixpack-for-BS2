package engine.heraldry
{
   import engine.core.util.BitmapUtil;
   import flash.display.BitmapData;
   import flash.display.StageQuality;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class Heraldry
   {
      
      public static const SIZE_SMALL:int = 64;
      
      public static const SIZE_MEDIUM:int = 128;
      
      public static const SIZE_LARGE:int = 256;
       
      
      public var def:HeraldryDef;
      
      public var largeCompositeBmpd:BitmapData;
      
      public var mediumCompositeBmpd:BitmapData;
      
      public var smallCompositeBmpd:BitmapData;
      
      public var smallCrestBmpd:BitmapData;
      
      public function Heraldry(param1:HeraldryDef, param2:BitmapData, param3:BitmapData)
      {
         var _loc7_:Point = null;
         var _loc8_:Number = NaN;
         super();
         this.def = param1;
         var _loc4_:Matrix = new Matrix();
         var _loc5_:Number = SIZE_SMALL / SIZE_LARGE;
         var _loc6_:Number = SIZE_MEDIUM / SIZE_LARGE;
         if(param2)
         {
            this.smallCrestBmpd = new BitmapData(SIZE_SMALL,SIZE_SMALL,true,0);
            _loc4_.scale(_loc5_,_loc5_);
            BitmapUtil.drawWithQuality(this.smallCrestBmpd,param2,_loc4_,null,null,null,true,StageQuality.BEST);
            this.smallCrestBmpd = applyColor(this.smallCrestBmpd,param1.crownColor);
            param2 = applyColor(param2,param1.crestColor);
         }
         else
         {
            param2 = param2;
         }
         if(!param3)
         {
            if(param2)
            {
               param2.dispose();
            }
            return;
         }
         this.largeCompositeBmpd = param3.clone();
         if(param2)
         {
            _loc8_ = 50;
            _loc7_ = new Point((this.largeCompositeBmpd.width - param2.width) / 2,50);
            _loc4_.identity();
            _loc4_.translate(_loc7_.x,_loc7_.y);
            BitmapUtil.drawWithQuality(this.largeCompositeBmpd,param2,_loc4_,null,param1.blendMode,null,true,StageQuality.BEST);
         }
         _loc4_.identity();
         _loc4_.scale(_loc6_,_loc6_);
         this.mediumCompositeBmpd = new BitmapData(param3.width * _loc6_,param3.height * _loc6_,true,0);
         BitmapUtil.drawWithQuality(this.mediumCompositeBmpd,param3,_loc4_,null,null,null,true,StageQuality.BEST);
         if(param2)
         {
            _loc4_.identity();
            _loc4_.translate(_loc7_.x,_loc7_.y);
            _loc4_.scale(_loc6_,_loc6_);
            BitmapUtil.drawWithQuality(this.mediumCompositeBmpd,param2,_loc4_,null,param1.blendMode,null,true,StageQuality.BEST);
         }
         _loc4_.identity();
         _loc4_.scale(_loc5_,_loc5_);
         this.smallCompositeBmpd = new BitmapData(param3.width * _loc5_,param3.height * _loc5_,true,0);
         BitmapUtil.drawWithQuality(this.smallCompositeBmpd,param3,_loc4_,null,null,null,true,StageQuality.BEST);
         if(param2)
         {
            _loc4_.identity();
            _loc4_.translate(_loc7_.x,_loc7_.y);
            _loc4_.scale(_loc5_,_loc5_);
            BitmapUtil.drawWithQuality(this.smallCompositeBmpd,param2,_loc4_,null,param1.blendMode,null,true,StageQuality.BEST);
         }
         if(param2)
         {
            param2.dispose();
         }
      }
      
      private static function applyColor(param1:BitmapData, param2:uint) : BitmapData
      {
         var _loc3_:BitmapData = new BitmapData(param1.width,param1.height,true,0);
         var _loc4_:* = param2 >> 16 & 255;
         var _loc5_:* = param2 >> 8 & 255;
         var _loc6_:* = param2 >> 0 & 255;
         var _loc7_:ColorMatrixFilter = new ColorMatrixFilter([0,0,0,0,_loc4_,0,0,0,0,_loc5_,0,0,0,0,_loc6_,-1,0,0,0,255]);
         _loc3_.applyFilter(param1,param1.rect,new Point(0,0),_loc7_);
         return _loc3_;
      }
      
      public function clone() : Heraldry
      {
         var _loc1_:Heraldry = new Heraldry(this.def,null,null);
         _loc1_.largeCompositeBmpd = !!this.largeCompositeBmpd ? this.largeCompositeBmpd.clone() : null;
         _loc1_.mediumCompositeBmpd = !!this.mediumCompositeBmpd ? this.mediumCompositeBmpd.clone() : null;
         _loc1_.smallCompositeBmpd = !!this.smallCompositeBmpd ? this.smallCompositeBmpd.clone() : null;
         _loc1_.smallCrestBmpd = !!this.smallCrestBmpd ? this.smallCrestBmpd.clone() : null;
         return _loc1_;
      }
      
      public function cleanup() : void
      {
         if(this.largeCompositeBmpd)
         {
            this.largeCompositeBmpd.dispose();
            this.largeCompositeBmpd = null;
         }
         if(this.mediumCompositeBmpd)
         {
            this.mediumCompositeBmpd.dispose();
            this.mediumCompositeBmpd = null;
         }
         if(this.smallCompositeBmpd)
         {
            this.smallCompositeBmpd.dispose();
            this.smallCompositeBmpd = null;
         }
         if(this.smallCrestBmpd)
         {
            this.smallCrestBmpd.dispose();
            this.smallCrestBmpd = null;
         }
      }
   }
}
