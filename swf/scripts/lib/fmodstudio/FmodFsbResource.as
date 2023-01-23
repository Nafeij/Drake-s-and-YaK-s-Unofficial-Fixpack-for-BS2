package lib.fmodstudio
{
   import engine.resource.ILoaderFactory;
   import engine.resource.ResourceManager;
   import flash.utils.ByteArray;
   import lib.engine.sound.fmod.FmodSoundResource;
   
   public class FmodFsbResource extends FmodSoundResource
   {
       
      
      private var _streaming:Boolean;
      
      private var _bankName:String;
      
      public function FmodFsbResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
      
      public function set bankName(param1:String) : void
      {
         this._bankName = param1;
      }
      
      public function get bankName() : String
      {
         return this._bankName;
      }
      
      public function set streaming(param1:Boolean) : void
      {
         this._streaming = param1;
      }
      
      public function get streaming() : Boolean
      {
         return this._streaming;
      }
      
      override protected function checkValidResource() : Boolean
      {
         return this._bankName != null && this._bankName != "";
      }
      
      override protected function handleDriverLoadResource(param1:String, param2:ByteArray) : Boolean
      {
         return _soundDriver.loadResource(this._bankName,param2,this._streaming);
      }
      
      override protected function internalUnload() : void
      {
         if(_resourceLoaded)
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("FmodFsbResource unloading " + url);
            }
            if(!_soundDriver.unloadResource(this._bankName,0))
            {
               logger.error("Failed to unload bank [" + this._bankName + "]");
            }
            _resourceLoaded = false;
         }
      }
   }
}
