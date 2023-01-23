package engine.entity.def
{
   import engine.core.util.Enum;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class EntityAppearanceDef extends EventDispatcher implements IEntityAppearanceDef
   {
      
      public static const EVENT_APPEARANCE_CHANGE:String = "EntityAppearanceDef.EVENT_APPEARANCE_CHANGE";
      
      public static var _nextId:int = 1;
       
      
      protected var _portraitUrl:String;
      
      protected var _backPortraitOffset:int;
      
      protected var _backPortraitUrl:String;
      
      protected var _versusPortraitUrl:String;
      
      protected var _promotePortraitUrl:String;
      
      protected var _portraitFoley:String;
      
      protected var _baseIconUrl:String;
      
      protected var _iconUrls:Vector.<String>;
      
      protected var _soundsUrl:String;
      
      protected var _animsUrl:String;
      
      protected var _vfxUrl:String;
      
      protected var _unlock_id:String;
      
      protected var _acquire_id:String;
      
      public var entClass:IEntityClassDef;
      
      public var ent:IEntityDef;
      
      public var _idStr:String;
      
      public function EntityAppearanceDef(param1:IEntityClassDef, param2:IEntityDef)
      {
         this._iconUrls = new Vector.<String>(Enum.getCount(EntityIconType),true);
         super();
         this.entClass = param1;
         this.ent = param2;
         this.makeIdStr();
      }
      
      private function makeIdStr() : void
      {
         this._idStr = "c_";
         this._idStr += !!this.entClass ? this.entClass.id : "none";
         this._idStr += ".e_";
         this._idStr += !!this.ent ? this.ent.id : "none";
         this._idStr += "." + (_nextId++).toString();
      }
      
      public function get id() : String
      {
         return this._idStr;
      }
      
      public function get entityClass() : IEntityClassDef
      {
         return this.entClass;
      }
      
      public function clone() : IEntityAppearanceDef
      {
         var _loc1_:EntityAppearanceDef = null;
         _loc1_ = new EntityAppearanceDef(this.entClass,this.ent);
         _loc1_._portraitUrl = this._portraitUrl;
         _loc1_._backPortraitOffset = this._backPortraitOffset;
         _loc1_._backPortraitUrl = this._backPortraitUrl;
         _loc1_._versusPortraitUrl = this._versusPortraitUrl;
         _loc1_._promotePortraitUrl = this._promotePortraitUrl;
         _loc1_._portraitFoley = this._portraitFoley;
         _loc1_._baseIconUrl = this._baseIconUrl;
         _loc1_._soundsUrl = this._soundsUrl;
         _loc1_._animsUrl = this._animsUrl;
         _loc1_._vfxUrl = this._vfxUrl;
         _loc1_._unlock_id = this._unlock_id;
         _loc1_._acquire_id = this._acquire_id;
         _loc1_.setupIcons(this._baseIconUrl);
         return _loc1_;
      }
      
      public function setupIcons(param1:String) : void
      {
         var _loc2_:EntityIconType = null;
         var _loc3_:String = null;
         this._baseIconUrl = param1;
         for each(_loc2_ in Enum.getVector(EntityIconType))
         {
            _loc3_ = _loc2_.transform(param1);
            this.setIconUrl(_loc2_,_loc3_);
         }
      }
      
      public function get portraitFoley() : String
      {
         return this._portraitFoley;
      }
      
      public function set portraitFoley(param1:String) : void
      {
         this._portraitFoley = param1;
      }
      
      public function getIconUrl(param1:EntityIconType) : String
      {
         return this._iconUrls[param1.value];
      }
      
      public function hasIcons() : Boolean
      {
         return this._baseIconUrl != "";
      }
      
      private function notifyChange() : void
      {
         dispatchEvent(new Event(EVENT_APPEARANCE_CHANGE));
      }
      
      public function setIconUrl(param1:EntityIconType, param2:String) : void
      {
         this._iconUrls[param1.value] = param2;
         this.notifyChange();
      }
      
      public function get portraitUrl() : String
      {
         return this._portraitUrl;
      }
      
      public function get backPortraitUrl() : String
      {
         return this._backPortraitUrl;
      }
      
      public function get versusPortraitUrl() : String
      {
         return this._versusPortraitUrl;
      }
      
      public function get promotePortraitUrl() : String
      {
         return this._promotePortraitUrl;
      }
      
      public function get soundsUrl() : String
      {
         return this._soundsUrl;
      }
      
      public function get animsUrl() : String
      {
         return this._animsUrl;
      }
      
      public function get vfxUrl() : String
      {
         return this._vfxUrl;
      }
      
      public function get baseIconUrl() : String
      {
         return this._baseIconUrl;
      }
      
      public function get unlock_id() : String
      {
         return this._unlock_id;
      }
      
      public function get acquire_id() : String
      {
         return this._acquire_id;
      }
      
      public function set portraitUrl(param1:String) : void
      {
         this._portraitUrl = param1;
         this.notifyChange();
      }
      
      public function set backPortraitUrl(param1:String) : void
      {
         this._backPortraitUrl = param1;
         this.notifyChange();
      }
      
      public function set versusPortraitUrl(param1:String) : void
      {
         this._versusPortraitUrl = param1;
         this.notifyChange();
      }
      
      public function set promotePortraitUrl(param1:String) : void
      {
         this._promotePortraitUrl = param1;
         this.notifyChange();
      }
      
      public function set soundsUrl(param1:String) : void
      {
         this._soundsUrl = param1;
         this.notifyChange();
      }
      
      public function set animsUrl(param1:String) : void
      {
         this._animsUrl = param1;
         this.notifyChange();
      }
      
      public function set vfxUrl(param1:String) : void
      {
         this._vfxUrl = param1;
         this.notifyChange();
      }
      
      public function set baseIconUrl(param1:String) : void
      {
         this._baseIconUrl = param1;
         this.setupIcons(param1);
         this.notifyChange();
      }
      
      public function set unlock_id(param1:String) : void
      {
         this._unlock_id = param1;
         this.notifyChange();
      }
      
      public function set acquire_id(param1:String) : void
      {
         this._acquire_id = param1;
         this.notifyChange();
      }
      
      public function get backPortraitOffset() : int
      {
         return this._backPortraitOffset;
      }
      
      public function set backPortraitOffset(param1:int) : void
      {
         this._backPortraitOffset = param1;
         this.notifyChange();
      }
   }
}
