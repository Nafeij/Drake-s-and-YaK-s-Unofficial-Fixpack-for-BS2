package engine.entity.model
{
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ITitleDef;
   import engine.entity.def.Item;
   import engine.entity.def.ShitlistDef;
   import engine.stat.model.Stats;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   
   public class Entity extends EventDispatcher implements IEntity
   {
      
      private static var lastId:int = 0;
       
      
      public var _def:IEntityDef;
      
      private var _stats:Stats;
      
      private var _fakeStats:Stats;
      
      private var _fake:Boolean = false;
      
      private var _id:String;
      
      protected var _visible:Boolean = true;
      
      protected var _visibleFadeMs:int;
      
      protected var _entityItem:Item;
      
      protected var _titleItem:Item;
      
      private var _numericId:uint;
      
      public var _shitlistDef:ShitlistDef;
      
      public var _cleanedup:Boolean;
      
      public function Entity(param1:IEntityDef, param2:String, param3:uint)
      {
         super();
         this._def = param1;
         this._id = makeId(param1,param2);
         this._numericId = param3;
         this._stats = new Stats(this,false);
      }
      
      public static function makeId(param1:IEntityDef, param2:String) : String
      {
         if(param2)
         {
            return param2;
         }
         return param1.id + "_" + (++lastId).toString(16);
      }
      
      public function get cleanedup() : Boolean
      {
         return this._cleanedup;
      }
      
      public function cleanupEntity() : void
      {
         this._stats = null;
         this._cleanedup = true;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get name() : String
      {
         return !!this._def ? this._def.name : null;
      }
      
      public function get stats() : Stats
      {
         if(this._cleanedup)
         {
            throw new IllegalOperationError("Access of cleanedup entity " + this._id);
         }
         return this._fake ? this._fakeStats : this._stats;
      }
      
      public function get def() : IEntityDef
      {
         return this._def;
      }
      
      override public function toString() : String
      {
         if(this._cleanedup)
         {
            throw new IllegalOperationError("Access of cleanedup entity " + this._id);
         }
         return this.id;
      }
      
      public function setFakeEntityStats(param1:Boolean, param2:ILogger) : void
      {
         if(param1)
         {
            if(this._fakeStats == null)
            {
               this._fakeStats = this._stats.clone(this);
            }
            else
            {
               this._fakeStats.synchronizeFrom(this._stats);
            }
            this._fake = true;
         }
         else
         {
            this._fake = false;
         }
      }
      
      final public function get fake() : Boolean
      {
         return this._fake;
      }
      
      public function get isPlayer() : Boolean
      {
         return true;
      }
      
      public function get isEnemy() : Boolean
      {
         return false;
      }
      
      public function get playerControlled() : Boolean
      {
         return true;
      }
      
      public function update(param1:int) : void
      {
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function get visibleToPlayer() : Boolean
      {
         return this._visible || this.isPlayer;
      }
      
      public function get visibleFadeMs() : int
      {
         return this._visibleFadeMs;
      }
      
      public function setVisible(param1:Boolean, param2:int) : void
      {
         if(param1 == this._visible)
         {
            return;
         }
         this._visibleFadeMs = param2;
         this._visible = param1;
         this.handleSetVisible();
      }
      
      public function flashVisible(param1:int) : void
      {
         this._visibleFadeMs = param1;
         this.handleFlashVisible();
      }
      
      protected function handleSetVisible() : void
      {
      }
      
      protected function handleFlashVisible() : void
      {
      }
      
      public function get numericId() : uint
      {
         return this._numericId;
      }
      
      public function get entityItem() : Item
      {
         return this._entityItem;
      }
      
      public function set entityItem(param1:Item) : void
      {
         this._entityItem = param1;
      }
      
      public function get item() : Item
      {
         return !!this._entityItem ? this._entityItem : this._def.defItem;
      }
      
      public function get title() : ITitleDef
      {
         return this._def.defTitle;
      }
      
      public function get titleRank() : int
      {
         return this._stats.titleRank;
      }
      
      public function get titleItem() : Item
      {
         return this._titleItem;
      }
      
      public function set titleItem(param1:Item) : void
      {
         this._titleItem = param1;
      }
      
      public function set titleRank(param1:int) : void
      {
         this._stats.titleRank = param1;
      }
      
      public function get shitlistDef() : ShitlistDef
      {
         return this._shitlistDef;
      }
   }
}
