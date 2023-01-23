package engine.sound
{
   import engine.fmod.FmodProjectInfo;
   
   public interface ISoundPreloader
   {
       
      
      function addSound(param1:String) : void;
      
      function addProjectInfo(param1:FmodProjectInfo) : void;
      
      function setPreloadUrl(param1:String) : void;
      
      function load(param1:Function) : void;
      
      function get complete() : Boolean;
   }
}
