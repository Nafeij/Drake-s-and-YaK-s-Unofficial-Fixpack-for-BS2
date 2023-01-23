package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeAlphaDef;
   import flash.geom.Matrix;
   
   public class AnimPathView_Alpha extends AnimPathViewNode
   {
       
      
      private var _alphaDef:AnimPathNodeAlphaDef;
      
      private var _alphaT:Number = 0;
      
      public function AnimPathView_Alpha(param1:AnimPathNodeAlphaDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._alphaDef = param1;
      }
      
      public function get alphaT() : Number
      {
         return this._alphaT;
      }
      
      public function set alphaT(param1:Number) : void
      {
         var _loc3_:Number = NaN;
         if(param1 == 0)
         {
            param1 = param1;
         }
         this._alphaT = param1;
         var _loc2_:Number = this._alphaDef.computeSplineT(param1);
         if(sprite)
         {
            _loc3_ = this._alphaDef.start + (this._alphaDef.target - this._alphaDef.start) * _loc2_;
            sprite.alpha = _loc3_;
         }
      }
      
      override public function cleanup() : void
      {
         this._alphaDef = null;
         super.cleanup();
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         var _loc2_:Function = null;
         refreshParams();
         if(param1 < _startTime_ms || param1 > _startTime_ms + _duration_ms)
         {
            return null;
         }
         if(_duration_ms <= 0)
         {
            this.alphaT = 1;
         }
         else
         {
            _loc2_ = this._alphaDef.getEaseFunction();
            this.alphaT = _loc2_(param1 - _startTime_ms,0,1,_duration_ms);
         }
         return null;
      }
   }
}
