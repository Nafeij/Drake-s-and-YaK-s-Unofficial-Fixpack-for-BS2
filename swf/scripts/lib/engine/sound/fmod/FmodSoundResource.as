package lib.engine.sound.fmod
{
   import engine.resource.ILoaderFactory;
   import engine.resource.ResourceManager;
   import engine.resource.URLBinaryResource;
   import engine.sound.ISoundDriver;
   import flash.errors.IllegalOperationError;
   import flash.utils.ByteArray;
   
   public class FmodSoundResource extends URLBinaryResource
   {
       
      
      private var _numBytes:int;
      
      protected var _soundDriver:IFmodSoundDriver;
      
      protected var _resourceLoaded:Boolean;
      
      protected var _illegalOpMessage:String;
      
      public function FmodSoundResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override protected function internalOnLoadComplete() : void
      {
         this.handleFinishLoading();
      }
      
      protected function checkValidResource() : Boolean
      {
         return true;
      }
      
      protected function handleDriverLoadResource(param1:String, param2:ByteArray) : Boolean
      {
         return this._soundDriver.loadBaseResource(param1,param2);
      }
      
      private function handleFinishLoading() : void
      {
         if(!this._soundDriver || !this.checkValidResource())
         {
            throw new IllegalOperationError("FmodSoundResource.handleFinishLoading " + this._illegalOpMessage);
         }
         if(this._soundDriver && loader.complete && !error)
         {
            if(this._resourceLoaded)
            {
               throw new IllegalOperationError("FmodSoundResource.handleFinishLoading - Resource has already been loaded. Cannot load twice.");
            }
            this._numBytes = super.numBytes;
            this._resourceLoaded = true;
            if(!this.handleDriverLoadResource(url,data as ByteArray))
            {
               setError();
            }
            loader.unload();
         }
      }
      
      public function get soundDriver() : ISoundDriver
      {
         return this._soundDriver;
      }
      
      public function set soundDriver(param1:ISoundDriver) : void
      {
         this._soundDriver = param1 as IFmodSoundDriver;
      }
      
      override public function get numBytes() : int
      {
         if(this._resourceLoaded)
         {
            return this._numBytes;
         }
         return 0;
      }
   }
}
