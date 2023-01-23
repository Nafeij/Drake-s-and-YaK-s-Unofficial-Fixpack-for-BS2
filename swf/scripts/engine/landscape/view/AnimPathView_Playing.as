package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodePlayingDef;
   import flash.geom.Matrix;
   
   public class AnimPathView_Playing extends AnimPathViewNode
   {
       
      
      private var _playingDef:AnimPathNodePlayingDef;
      
      public function AnimPathView_Playing(param1:AnimPathNodePlayingDef, param2:AnimPathView)
      {
         super(param1,param2);
         this._playingDef = param1;
      }
      
      override public function evaluate(param1:int) : Matrix
      {
         this.refreshParams();
         if(param1 < _startTime_ms)
         {
            return null;
         }
         this.view.shouldBePlaying = this._playingDef.playing;
         sprite.animToggle(this._playingDef.playing);
         return null;
      }
   }
}
