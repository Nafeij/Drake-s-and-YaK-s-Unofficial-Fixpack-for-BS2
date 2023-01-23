package engine.saga.save
{
   import flash.errors.IllegalOperationError;
   
   public class SagaSaveCollection
   {
       
      
      public var id:String;
      
      public var profile_saves:Vector.<SagaSave>;
      
      public var profile_urls:Vector.<String>;
      
      public function SagaSaveCollection(param1:String, param2:int, param3:Boolean)
      {
         super();
         this.id = param1;
         this.profile_saves = new Vector.<SagaSave>(param2);
         if(param3)
         {
            this.profile_urls = new Vector.<String>(param2);
         }
      }
      
      public function setSaveAtProfile(param1:int, param2:SagaSave) : void
      {
         if(param1 >= this.profile_saves.length)
         {
            if(param2)
            {
            }
            this.profile_saves.length = param1 + 1;
         }
         this.profile_saves[param1] = param2;
      }
      
      public function setUrlAtProfile(param1:int, param2:String) : void
      {
         if(!this.profile_urls)
         {
            throw new IllegalOperationError("unsupported");
         }
         if(param1 >= this.profile_urls.length)
         {
            if(!param2)
            {
               return;
            }
            this.profile_urls.length = param1 + 1;
         }
         this.profile_urls[param1] = param2;
      }
   }
}
