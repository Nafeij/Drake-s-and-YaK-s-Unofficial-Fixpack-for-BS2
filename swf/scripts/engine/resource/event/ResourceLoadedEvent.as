package engine.resource.event
{
   import engine.resource.IResource;
   import flash.events.Event;
   
   public class ResourceLoadedEvent extends Event
   {
       
      
      public var resource:IResource;
      
      public function ResourceLoadedEvent(param1:String, param2:IResource)
      {
         super(param1);
         this.resource = param2;
      }
   }
}
