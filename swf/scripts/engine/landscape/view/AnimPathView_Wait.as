package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeWaitDef;
   import flash.utils.Timer;
   
   public class AnimPathView_Wait extends AnimPathViewNode
   {
       
      
      private var _wait:AnimPathNodeWaitDef;
      
      private var _timer:Timer;
      
      public function AnimPathView_Wait(param1:AnimPathNodeWaitDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._wait = param1;
      }
   }
}
