package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class EntityClassDefList extends EventDispatcher
   {
       
      
      public var classList:Vector.<EntityClassDef>;
      
      private var _entityClasses:Dictionary;
      
      private var skus:Dictionary;
      
      public var meta:EntitiesMetadata;
      
      public var ok:Boolean = true;
      
      public var url:String;
      
      public var type:String;
      
      public var parentUrl:String;
      
      public var components:Vector.<EntityClassDefList>;
      
      public var parent:EntityClassDefList;
      
      public function EntityClassDefList()
      {
         this.classList = new Vector.<EntityClassDef>();
         this._entityClasses = new Dictionary();
         this.skus = new Dictionary();
         this.components = new Vector.<EntityClassDefList>();
         super();
      }
      
      public function fetch(param1:String, param2:Boolean = true) : IEntityClassDef
      {
         var _loc4_:EntityClassDefList = null;
         var _loc3_:IEntityClassDef = this._entityClasses[param1];
         if(_loc3_)
         {
            return _loc3_;
         }
         if(this.components)
         {
            for each(_loc4_ in this.components)
            {
               _loc3_ = _loc4_.fetch(param1,param2);
               if(_loc3_)
               {
                  return _loc3_;
               }
            }
         }
         return Boolean(this.parent) && param2 ? this.parent.fetch(param1) : null;
      }
      
      public function get entityClasses() : Dictionary
      {
         return this._entityClasses;
      }
      
      public function registerAll(param1:EntityClassDefList, param2:ILogger) : void
      {
         var _loc3_:EntityClassDef = null;
         if(!this.meta)
         {
            this.meta = param1.meta;
         }
         for each(_loc3_ in param1.entityClasses)
         {
            this.register(_loc3_,param2);
         }
      }
      
      public function register(param1:EntityClassDef, param2:ILogger) : void
      {
         var _loc3_:EntityClassDef = this._entityClasses[param1.id];
         if(_loc3_)
         {
            param2.info("EntityClassDefManager.register overrideing " + param1.id);
            this.unregister(_loc3_);
         }
         this.classList.push(param1);
         this._entityClasses[param1.id] = param1;
      }
      
      public function unregister(param1:EntityClassDef) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:int = this.classList.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.classList.splice(_loc2_,1);
         }
         delete this._entityClasses[param1.id];
      }
      
      internal function init() : void
      {
         var _loc1_:EntityClassDef = null;
         for each(_loc1_ in this._entityClasses)
         {
            _loc1_.purge();
         }
         for each(_loc1_ in this._entityClasses)
         {
            _loc1_.link(this);
         }
      }
      
      public function removeEntityClass(param1:String) : void
      {
         this.unregister(this._entityClasses[param1]);
      }
      
      public function setClassId(param1:EntityClassDef, param2:String) : void
      {
         if(this.fetch(param2))
         {
            return;
         }
         delete this._entityClasses[param1.id];
         param1.id = param2;
         this._entityClasses[param1.id] = param1;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function changeLocale(param1:Locale) : void
      {
         var _loc2_:EntityClassDef = null;
         for each(_loc2_ in this.classList)
         {
            _loc2_.changeLocale(param1);
         }
         if(this.parent)
         {
            this.parent.changeLocale(param1);
         }
      }
   }
}
