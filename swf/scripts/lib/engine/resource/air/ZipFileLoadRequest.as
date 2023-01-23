package lib.engine.resource.air
{
   import engine.resource.loader.SagaURLLoader;
   
   public class ZipFileLoadRequest
   {
       
      
      public var path:String;
      
      public var loader:SagaURLLoader;
      
      public function ZipFileLoadRequest(param1:String, param2:SagaURLLoader)
      {
         super();
         this.path = param1;
         this.loader = param2;
      }
   }
}
