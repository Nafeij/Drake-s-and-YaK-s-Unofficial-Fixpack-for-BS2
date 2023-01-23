package engine.scene
{
   import engine.scene.model.ISceneAudio;
   
   public class GlobalAmbience
   {
       
      
      private var _audio:ISceneAudio;
      
      public function GlobalAmbience()
      {
         super();
      }
      
      public function get audio() : ISceneAudio
      {
         return this._audio;
      }
      
      public function set audio(param1:ISceneAudio) : void
      {
         if(this._audio == param1)
         {
            return;
         }
         if(this._audio)
         {
            this._audio.cleanup();
         }
         this._audio = param1;
         if(!this._audio)
         {
         }
      }
   }
}
