package engine.sound.view
{
   import engine.sound.ISoundEventId;
   import engine.sound.def.ISoundDef;
   
   public interface ISound
   {
       
      
      function get playing() : Boolean;
      
      function start() : void;
      
      function stop(param1:Boolean) : void;
      
      function restart() : void;
      
      function isLooping() : Boolean;
      
      function setParameter(param1:String, param2:Number) : void;
      
      function getParameter(param1:String) : Number;
      
      function setVolume(param1:Number) : void;
      
      function get def() : ISoundDef;
      
      function get systemid() : ISoundEventId;
   }
}
