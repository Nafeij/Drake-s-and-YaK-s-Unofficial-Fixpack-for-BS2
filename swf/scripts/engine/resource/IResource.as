package engine.resource
{
   import engine.resource.loader.IResourceLoader;
   import flash.events.IEventDispatcher;
   
   public interface IResource extends IEventDispatcher
   {
       
      
      function get url() : String;
      
      function get ok() : Boolean;
      
      function get resource() : *;
      
      function release() : void;
      
      function addReference() : void;
      
      function addResourceListener(param1:Function) : void;
      
      function removeResourceListener(param1:Function) : void;
      
      function get loader() : IResourceLoader;
   }
}
