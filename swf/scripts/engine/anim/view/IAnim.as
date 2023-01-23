package engine.anim.view
{
   import engine.anim.def.IAnimDef;
   
   public interface IAnim
   {
       
      
      function cleanup() : void;
      
      function get def() : IAnimDef;
      
      function get elapsedMs() : int;
      
      function get count() : int;
      
      function get frame() : int;
      
      function get playing() : Boolean;
      
      function get repeatLimit() : int;
      
      function set repeatLimit(param1:int) : void;
      
      function get timeLimitMs() : int;
      
      function set timeLimitMs(param1:int) : void;
      
      function peekAccumulatedMovement() : Number;
      
      function popAccumulatedMovement() : Number;
      
      function setAccumulatedMovement(param1:Number) : void;
      
      function set remainingDistance(param1:Number) : void;
      
      function set reverse(param1:Boolean) : void;
      
      function set playbackSpeed(param1:Number) : void;
      
      function get clip() : AnimClip;
      
      function finishAsap() : void;
      
      function advance(param1:int, param2:Boolean = false) : int;
      
      function start(param1:int) : void;
      
      function stop() : void;
      
      function restart() : void;
      
      function set singleFrameOffsetValid(param1:Boolean) : void;
      
      function set singleFrameOffset(param1:int) : void;
   }
}
