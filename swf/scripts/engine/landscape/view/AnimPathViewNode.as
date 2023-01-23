package engine.landscape.view
{
   import engine.landscape.def.AnimPathNodeDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import flash.geom.Matrix;
   
   public class AnimPathViewNode
   {
       
      
      public var spriteDef:LandscapeSpriteDef;
      
      public var sprite:DisplayObjectWrapper;
      
      public var view:AnimPathView;
      
      public var nodeDef:AnimPathNodeDef;
      
      public var nodeMatrix:Matrix = null;
      
      protected var _startTime_ms:int = 0;
      
      protected var _duration_ms:int = 0;
      
      public function AnimPathViewNode(param1:AnimPathNodeDef, param2:AnimPathView)
      {
         super();
         this.nodeDef = param1;
         this.view = param2;
         this.sprite = param2.sprite;
         this.spriteDef = param2.animPathDef.sprite;
         this.nodeMatrix = new Matrix();
      }
      
      public function cleanup() : void
      {
         this.view = null;
         this.sprite = null;
         this.nodeDef = null;
         this.spriteDef = null;
      }
      
      public function evaluate(param1:int) : Matrix
      {
         return null;
      }
      
      protected function refreshParams() : void
      {
         this._startTime_ms = this.nodeDef.startTimeSecs * 1000;
         this._duration_ms = this.nodeDef.durationSecs * 1000;
      }
      
      public function reset() : void
      {
      }
   }
}
