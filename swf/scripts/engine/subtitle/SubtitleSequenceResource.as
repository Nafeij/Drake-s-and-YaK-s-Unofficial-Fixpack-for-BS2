package engine.subtitle
{
   import engine.resource.ILoaderFactory;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   
   public class SubtitleSequenceResource extends DefResource
   {
       
      
      public var sequence:SubtitleSequence;
      
      public function SubtitleSequenceResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override protected function internalOnLoadComplete() : void
      {
         super.internalOnLoadComplete();
         if(jo)
         {
            this.sequence = new SubtitleSequence(logger).fromJson(jo,logger);
            this.sequence.url = url;
         }
      }
   }
}
