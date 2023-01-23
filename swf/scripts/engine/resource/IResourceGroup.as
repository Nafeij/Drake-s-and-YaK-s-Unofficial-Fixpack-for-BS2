package engine.resource
{
   import engine.core.util.IRefcount;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   public interface IResourceGroup extends IEventDispatcher, IRefcount
   {
       
      
      function addResource(param1:IResource, param2:String) : void;
      
      function get urlUnmappings() : Dictionary;
      
      function get originalUrlToResources() : Dictionary;
      
      function release() : void;
      
      function releaseResource(param1:String) : void;
      
      function get isReleased() : Boolean;
      
      function getDebugInfo() : String;
      
      function get complete() : Boolean;
      
      function removeResourceGroupListener(param1:Function) : void;
      
      function addResourceGroupListener(param1:Function) : void;
   }
}
