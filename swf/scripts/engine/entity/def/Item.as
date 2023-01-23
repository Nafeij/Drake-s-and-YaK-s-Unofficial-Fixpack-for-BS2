package engine.entity.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.stat.model.IStatModProvider;
   import engine.stat.model.StatMod;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Item extends EventDispatcher implements IStatModProvider
   {
      
      public static var EVENT_OWNER:String = "Item.EVENT_OWNER";
       
      
      public var id:String;
      
      public var defid:String;
      
      public var def:ItemDef;
      
      private var _owner:IEntityDef;
      
      public var passive:IBattleAbilityDef;
      
      public function Item()
      {
         super();
      }
      
      public static function createName(param1:String, param2:int) : String
      {
         return param1 + ":" + param2;
      }
      
      public static function getDefIdFromName(param1:String) : String
      {
         var _loc2_:int = !!param1 ? param1.indexOf(":") : -1;
         if(_loc2_ > 0)
         {
            return param1.substring(0,_loc2_);
         }
         return null;
      }
      
      public static function getNumberFromName(param1:String) : int
      {
         var _loc2_:int = !!param1 ? param1.indexOf(":") : -1;
         if(_loc2_ > 0)
         {
            return int(param1.substring(_loc2_ + 1));
         }
         return 0;
      }
      
      override public function toString() : String
      {
         return this.id;
      }
      
      public function resolve(param1:ItemListDef) : void
      {
         this.def = param1.getItemDef(this.defid);
      }
      
      public function get owner() : IEntityDef
      {
         return this._owner;
      }
      
      public function set owner(param1:IEntityDef) : void
      {
         if(this._owner == param1)
         {
            return;
         }
         this._owner = param1;
         dispatchEvent(new Event(EVENT_OWNER));
      }
      
      public function handleStatModUsed(param1:StatMod) : void
      {
      }
      
      public function get isStatModProviderRemoved() : Boolean
      {
         return false;
      }
   }
}
