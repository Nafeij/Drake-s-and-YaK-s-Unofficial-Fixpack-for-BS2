package engine.entity.def
{
   import flash.events.Event;
   
   public class EntityDefEvent extends Event
   {
      
      public static const APPEARANCE:String = "EntityDefEvent.APPEARANCE";
      
      public static const ITEM:String = "EntityDefEvent.ITEM";
       
      
      public var entity:IEntityDef;
      
      public function EntityDefEvent(param1:String, param2:IEntityDef)
      {
         super(param1,false,false);
         this.entity = param2;
      }
   }
}
