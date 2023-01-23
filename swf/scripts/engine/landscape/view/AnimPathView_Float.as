package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeFloatDef;
   import flash.geom.Matrix;
   
   public class AnimPathView_Float extends AnimPathViewNode
   {
       
      
      private var _floatDef:AnimPathNodeFloatDef;
      
      private var _period_y_ms:int;
      
      private var _period_x_ms:int;
      
      public function AnimPathView_Float(param1:AnimPathNodeFloatDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._floatDef = param1;
         this.refreshParams();
      }
      
      private static function computeOffset(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = Math.sin(param1 * Math.PI / param2);
         return _loc4_ * param3;
      }
      
      override public function cleanup() : void
      {
         this._floatDef = null;
         super.cleanup();
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         this.refreshParams();
         if(param1 < _startTime_ms)
         {
            return null;
         }
         nodeMatrix.identity();
         var _loc2_:Number = 0;
         if(Boolean(this._floatDef.y_amplitude) && Boolean(this._floatDef.y_period))
         {
            _loc2_ = computeOffset(param1 - _startTime_ms,this._period_y_ms,this._floatDef.y_amplitude);
            nodeMatrix.translate(0,_loc2_);
         }
         if(Boolean(this._floatDef.x_amplitude) && Boolean(this._floatDef.x_period))
         {
            _loc2_ = computeOffset(param1 - _startTime_ms,this._period_x_ms,this._floatDef.x_amplitude);
            nodeMatrix.translate(_loc2_,0);
         }
         return nodeMatrix;
      }
      
      override protected function refreshParams() : void
      {
         super.refreshParams();
         this._period_y_ms = this._floatDef.y_period * 1000;
         this._period_x_ms = this._floatDef.x_period * 1000;
      }
   }
}
