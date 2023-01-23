package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeRotateDef;
   import engine.math.MathUtil;
   import flash.geom.Matrix;
   
   public class AnimPathView_Rotate extends AnimPathViewNode
   {
       
      
      private var _rotationDef:AnimPathNodeRotateDef;
      
      private var _radians_start:Number = 0;
      
      private var _radians_end:Number = 0;
      
      public function AnimPathView_Rotate(param1:AnimPathNodeRotateDef, param2:AnimPathView)
      {
         super(param1,param2);
         nodeMatrix = new Matrix();
         this._rotationDef = param1;
         this.refreshParams();
      }
      
      override public function cleanup() : void
      {
         this._rotationDef = null;
         super.cleanup();
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         this.refreshParams();
         if(param1 < _startTime_ms)
         {
            return null;
         }
         if(this._rotationDef.continuous)
         {
            param1 %= _duration_ms;
         }
         else if(param1 >= _startTime_ms + _duration_ms)
         {
            param1 = _duration_ms;
         }
         nodeMatrix.identity();
         var _loc2_:Number = (param1 - _startTime_ms) / _duration_ms;
         var _loc3_:Number = MathUtil.lerp(this._radians_start,this._radians_end,_loc2_);
         nodeMatrix.translate(-this._rotationDef.pivot.x,-this._rotationDef.pivot.y);
         nodeMatrix.rotate(_loc3_);
         nodeMatrix.translate(this._rotationDef.pivot.x,this._rotationDef.pivot.y);
         return nodeMatrix;
      }
      
      override protected function refreshParams() : void
      {
         super.refreshParams();
         this._radians_start = this._rotationDef.degrees_start * MathUtil.PI_OVER_180;
         this._radians_end = this._rotationDef.degrees_end * MathUtil.PI_OVER_180;
      }
   }
}
