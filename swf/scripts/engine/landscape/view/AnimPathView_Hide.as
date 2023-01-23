package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeHideDef;
   import flash.geom.Matrix;
   
   public class AnimPathView_Hide extends AnimPathViewNode
   {
       
      
      private var _hideDef:AnimPathNodeHideDef;
      
      public function AnimPathView_Hide(param1:AnimPathNodeHideDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._hideDef = param1;
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         this.refreshParams();
         if(param1 < _startTime_ms)
         {
            return null;
         }
         this.view.showing = false;
         return null;
      }
   }
}
