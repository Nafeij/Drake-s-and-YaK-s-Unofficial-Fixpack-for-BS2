package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeScaleDef;
   import flash.geom.Matrix;
   
   public class AnimPathView_Scale extends AnimPathViewNode
   {
       
      
      private var _scaleDef:AnimPathNodeScaleDef;
      
      public function AnimPathView_Scale(param1:AnimPathNodeScaleDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._scaleDef = param1;
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         this.refreshParams();
         if(param1 < _startTime_ms)
         {
            return null;
         }
         nodeMatrix.identity();
         nodeMatrix.scale(this._scaleDef.scaleX,this._scaleDef.scaleY);
         return nodeMatrix;
      }
   }
}
