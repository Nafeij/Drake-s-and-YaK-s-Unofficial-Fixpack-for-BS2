package engine.core.util
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Refcount extends EventDispatcher
   {
       
      
      private var m_refcount:uint;
      
      private var m_owner:Object;
      
      public function Refcount(param1:Object)
      {
         super();
         this.m_owner = param1;
      }
      
      public function get owner() : Object
      {
         return this.m_owner;
      }
      
      public function releaseReference() : void
      {
         if(this.m_refcount > 0)
         {
            --this.m_refcount;
            if(0 == this.m_refcount)
            {
               dispatchEvent(new Event(Event.UNLOAD));
            }
         }
      }
      
      public function addReference() : void
      {
         ++this.m_refcount;
      }
      
      public function get refcount() : uint
      {
         return this.m_refcount;
      }
   }
}
