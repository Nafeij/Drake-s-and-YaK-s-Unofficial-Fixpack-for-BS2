package engine.resource.loader
{
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.sound.ISoundDriver;
   import engine.sound.def.SoundLibraryResource;
   import engine.sound.view.SoundController;
   
   public class SoundControllerManager
   {
       
      
      private var _id:String;
      
      private var _url:String;
      
      private var _soundDriver:ISoundDriver;
      
      private var _logger:ILogger;
      
      private var _callback:Function;
      
      private var _isLoaded:Boolean;
      
      private var _soundController:SoundController;
      
      private var _soundLibraryResource:SoundLibraryResource;
      
      public function SoundControllerManager(param1:String, param2:String, param3:ResourceManager, param4:ISoundDriver, param5:Function, param6:ILogger)
      {
         var id:String = param1;
         var url:String = param2;
         var resourceManager:ResourceManager = param3;
         var soundDriver:ISoundDriver = param4;
         var loadCompleteCallback:Function = param5;
         var logger:ILogger = param6;
         super();
         this._id = id;
         this._url = url;
         this._logger = logger;
         this._soundDriver = soundDriver;
         this._callback = loadCompleteCallback;
         try
         {
            this._soundLibraryResource = resourceManager.getResource(url,SoundLibraryResource) as SoundLibraryResource;
            this._soundLibraryResource.addResourceListener(this.soundLibraryResourceLoaded);
         }
         catch(error:Error)
         {
            logger.error("SoundControllerManager failed to load: \'" + url + "\' " + error);
         }
      }
      
      public function get soundController() : SoundController
      {
         return this._soundController;
      }
      
      public function get isLoaded() : Boolean
      {
         return this._isLoaded;
      }
      
      public function cleanup() : void
      {
         this._soundDriver = null;
         this._logger = null;
         this._callback = null;
         this._soundController.cleanup();
         this._soundController = null;
         this._soundLibraryResource.release();
         this._soundLibraryResource = null;
      }
      
      private function soundLibraryResourceLoaded(param1:ResourceLoadedEvent) : void
      {
         this._soundLibraryResource.removeResourceListener(this.soundLibraryResourceLoaded);
         this._soundController = new SoundController(this._id,this._soundDriver,this.soundControllerCompleted,this._logger);
         this._soundController.library = this._soundLibraryResource.library;
      }
      
      private function soundControllerCompleted(param1:SoundController) : void
      {
         this._logger.info("SoundController \'" + this._id + "\' completed loading");
         this._isLoaded = true;
         if(this._callback != null)
         {
            this._callback();
         }
      }
   }
}
