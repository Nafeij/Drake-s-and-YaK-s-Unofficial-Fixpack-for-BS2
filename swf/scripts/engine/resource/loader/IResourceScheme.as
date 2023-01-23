package engine.resource.loader
{
   import engine.resource.IVideoFinder;
   import flash.events.IEventDispatcher;
   import flash.utils.IDataInput;
   
   public interface IResourceScheme extends IEventDispatcher, IVideoFinder
   {
       
      
      function get scheme() : String;
      
      function hasFile(param1:String) : Boolean;
      
      function load(param1:String, param2:SagaURLLoader) : void;
      
      function getFileStream(param1:String) : IDataInput;
   }
}
