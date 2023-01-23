package engine.entity.model
{
   import engine.core.IUpdateable;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IShitlistDefProvider;
   import engine.entity.def.Item;
   import engine.stat.model.IStatsProvider;
   import flash.events.IEventDispatcher;
   
   public interface IEntity extends IStatsProvider, IEventDispatcher, IUpdateable, IShitlistDefProvider
   {
       
      
      function get name() : String;
      
      function get id() : String;
      
      function get def() : IEntityDef;
      
      function get isPlayer() : Boolean;
      
      function get isEnemy() : Boolean;
      
      function get playerControlled() : Boolean;
      
      function setVisible(param1:Boolean, param2:int) : void;
      
      function flashVisible(param1:int) : void;
      
      function get visibleFadeMs() : int;
      
      function get numericId() : uint;
      
      function get item() : Item;
      
      function get entityItem() : Item;
      
      function set entityItem(param1:Item) : void;
      
      function get titleItem() : Item;
      
      function set titleItem(param1:Item) : void;
   }
}
