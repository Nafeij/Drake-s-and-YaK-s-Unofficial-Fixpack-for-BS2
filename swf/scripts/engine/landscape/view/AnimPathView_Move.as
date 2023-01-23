package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeMoveDef;
   import flash.geom.Matrix;
   
   public class AnimPathView_Move extends AnimPathViewNode
   {
       
      
      private var _moveDef:AnimPathNodeMoveDef;
      
      private var _moveT:Number = 0;
      
      public function AnimPathView_Move(param1:AnimPathNodeMoveDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._moveDef = param1;
      }
      
      override public function cleanup() : void
      {
         this._moveDef = null;
         super.cleanup();
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         refreshParams();
         if(param1 < _startTime_ms || param1 > _startTime_ms + _duration_ms)
         {
            return null;
         }
         var _loc2_:Function = this._moveDef.getEaseFunction();
         var _loc3_:Number = _loc2_(param1 - _startTime_ms,0,1,_duration_ms);
         this.moveT = _loc3_;
         return null;
      }
      
      public function get moveT() : Number
      {
         return this._moveT;
      }
      
      public function set moveT(param1:Number) : void
      {
         this._moveT = param1;
         var _loc2_:Number = this._moveDef.computeSplineT(param1);
         var _loc3_:Number = this._moveDef.start.x + (this._moveDef.target.x - this._moveDef.start.x) * _loc2_;
         var _loc4_:Number = this._moveDef.start.y + (this._moveDef.target.y - this._moveDef.start.y) * _loc2_;
         view.updateAnchor(_loc3_,_loc4_);
      }
   }
}
