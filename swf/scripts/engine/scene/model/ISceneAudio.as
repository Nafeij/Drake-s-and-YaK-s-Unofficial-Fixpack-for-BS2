package engine.scene.model
{
   import engine.sound.ISoundDefBundleListener;
   
   public interface ISceneAudio extends ISoundDefBundleListener
   {
       
      
      function cleanup() : void;
   }
}
