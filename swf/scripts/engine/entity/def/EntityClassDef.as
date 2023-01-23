package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.math.Box;
   import engine.stat.def.StatRanges;
   
   public class EntityClassDef implements IEntityClassDef
   {
       
      
      protected var _id:String;
      
      protected var _name:String;
      
      protected var _description:String;
      
      protected var _parentEntityClassId:String;
      
      protected var _parentEntityClass:IEntityClassDef;
      
      protected var _statRanges:StatRanges;
      
      protected var _passive:String;
      
      protected var _attacks:Vector.<String>;
      
      protected var _actives:Vector.<String>;
      
      protected var _additionalActives:Vector.<String>;
      
      protected var _allChildEntityClasses:Vector.<IEntityClassDef>;
      
      protected var _playerOnlyChildEntityClasses:Vector.<IEntityClassDef>;
      
      protected var _race:String;
      
      protected var _bounds:Box;
      
      protected var _propAnimUrl:String;
      
      protected var _gender:String;
      
      protected var _mobile:Boolean;
      
      protected var _collidable:Boolean = true;
      
      protected var _partyTag:String;
      
      protected var _partyTagDisplay:String;
      
      protected var _partyTagLimit:String;
      
      protected var _playerClass:Boolean = true;
      
      private var locale:Locale;
      
      protected var _shadowUrl:String;
      
      protected var _disableShadow:Boolean;
      
      protected var _isWarped:Boolean;
      
      protected var _hasSubmergedMove:Boolean;
      
      protected var _appearanceDefs:Vector.<IEntityAppearanceDef>;
      
      public function EntityClassDef(param1:Locale)
      {
         this._statRanges = new StatRanges();
         this._attacks = new Vector.<String>();
         this._actives = new Vector.<String>();
         this._additionalActives = new Vector.<String>();
         this._allChildEntityClasses = new Vector.<IEntityClassDef>();
         this._playerOnlyChildEntityClasses = new Vector.<IEntityClassDef>();
         this._appearanceDefs = new Vector.<IEntityAppearanceDef>();
         super();
         this.locale = param1;
      }
      
      public function get hasSubmergedMove() : Boolean
      {
         return this._hasSubmergedMove;
      }
      
      public function get isWarped() : Boolean
      {
         return this._isWarped;
      }
      
      public function changeLocale(param1:Locale) : void
      {
         this.locale = param1;
         this.updateDisplayLocalizations();
      }
      
      public function get playerOnlyChildEntityClasses() : Vector.<IEntityClassDef>
      {
         return this._playerOnlyChildEntityClasses;
      }
      
      public function get playerClass() : Boolean
      {
         return this._playerClass;
      }
      
      public function set playerClass(param1:Boolean) : void
      {
         this._playerClass = param1;
      }
      
      public function get partyTag() : String
      {
         return this._partyTag;
      }
      
      public function set partyTag(param1:String) : void
      {
         this._partyTag = param1;
         this._partyTagDisplay = this.locale.translate(LocaleCategory.ENTITY,this._partyTag);
      }
      
      public function getPartyTagLimit(param1:EntitiesMetadata) : int
      {
         return param1.getPartyTagLimit(this._partyTag);
      }
      
      public function setPartyTagLimit(param1:EntitiesMetadata, param2:int) : void
      {
         param1.setPartyTagLimit(this._partyTag,param2);
      }
      
      public function get partyTagDisplay() : String
      {
         return this._partyTagDisplay;
      }
      
      public function set partyTagDisplay(param1:String) : void
      {
         this._partyTagDisplay = param1;
         this.locale.getLocalizer(LocaleCategory.ENTITY).setValue(this._partyTag,param1);
         this.updateDisplayLocalizations();
      }
      
      public function get parentEntityClass() : IEntityClassDef
      {
         return this._parentEntityClass;
      }
      
      public function get passive() : String
      {
         return this._passive;
      }
      
      public function set passive(param1:String) : void
      {
         this._passive = param1;
      }
      
      public function get attacks() : Vector.<String>
      {
         return this._attacks;
      }
      
      public function set attacks(param1:Vector.<String>) : void
      {
         this._attacks = param1;
      }
      
      public function get actives() : Vector.<String>
      {
         return this._actives;
      }
      
      public function set actives(param1:Vector.<String>) : void
      {
         this._actives = param1;
      }
      
      public function get additionalActives() : Vector.<String>
      {
         return this._additionalActives;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
         this.updateDisplayLocalizations();
      }
      
      private function updateDisplayLocalizations() : void
      {
         if(this.locale)
         {
            this._partyTagDisplay = this.locale.translate(LocaleCategory.ENTITY,this._partyTag);
            this._name = this.locale.translate(LocaleCategory.ENTITY,this.nameToken);
            this._description = this.locale.translate(LocaleCategory.ENTITY,this.descriptionToken);
         }
      }
      
      private function get nameToken() : String
      {
         return this._id;
      }
      
      private function get descriptionToken() : String
      {
         return this._id + "_desc";
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         if(this._name != param1)
         {
            this._name = param1;
            this.locale.getLocalizer(LocaleCategory.ENTITY).setValue(this.nameToken,param1);
            this.updateDisplayLocalizations();
         }
      }
      
      public function get description() : String
      {
         return this._description;
      }
      
      public function set description(param1:String) : void
      {
         if(this._description != param1)
         {
            this._description = param1;
            this.locale.getLocalizer(LocaleCategory.ENTITY).setValue(this.descriptionToken,param1);
            this._partyTagDisplay = this.locale.translate(LocaleCategory.ENTITY,this._partyTag);
         }
      }
      
      public function get statRanges() : StatRanges
      {
         return this._statRanges;
      }
      
      public function get parentEntityClassId() : String
      {
         return this._parentEntityClassId;
      }
      
      public function set parentEntityClassId(param1:String) : void
      {
         this._parentEntityClassId = param1;
      }
      
      public function get allChildEntityClasses() : Vector.<IEntityClassDef>
      {
         return this._allChildEntityClasses;
      }
      
      public function link(param1:EntityClassDefList) : void
      {
         var _loc2_:EntityClassDef = null;
         if(!this._parentEntityClassId)
         {
            return;
         }
         this._parentEntityClass = param1.fetch(this._parentEntityClassId);
         if(this._parentEntityClass)
         {
            _loc2_ = this._parentEntityClass as EntityClassDef;
            if(_loc2_)
            {
               _loc2_.addChild(this,this.playerClass);
            }
         }
      }
      
      internal function addChild(param1:IEntityClassDef, param2:Boolean) : void
      {
         this.allChildEntityClasses.push(param1);
         if(param2)
         {
            this.playerOnlyChildEntityClasses.push(param1);
         }
      }
      
      public function purge() : void
      {
         this._parentEntityClass = null;
         this._allChildEntityClasses.splice(0,this._allChildEntityClasses.length);
         this._playerOnlyChildEntityClasses.splice(0,this._playerOnlyChildEntityClasses.length);
      }
      
      public function get race() : String
      {
         return this._race;
      }
      
      public function set race(param1:String) : void
      {
         this._race = param1;
      }
      
      public function get bounds() : Box
      {
         return this._bounds;
      }
      
      public function set bounds(param1:Box) : void
      {
         this._bounds = param1;
      }
      
      public function get propAnimUrl() : String
      {
         return this._propAnimUrl;
      }
      
      public function set propAnimUrl(param1:String) : void
      {
         this._propAnimUrl = param1;
      }
      
      public function get mobile() : Boolean
      {
         return this._mobile;
      }
      
      public function set mobile(param1:Boolean) : void
      {
         this._mobile = param1;
      }
      
      public function get collidable() : Boolean
      {
         return this._collidable;
      }
      
      public function getEntityClassAppearanceDef(param1:int) : IEntityAppearanceDef
      {
         if(param1 >= 0 && param1 < this._appearanceDefs.length)
         {
            return this._appearanceDefs[param1];
         }
         return null;
      }
      
      public function get appearanceDefs() : Vector.<IEntityAppearanceDef>
      {
         return this._appearanceDefs;
      }
      
      private function getAppearanceNameToken(param1:int) : String
      {
         return "var_" + this.id + "_" + param1;
      }
      
      private function getAppearanceDescToken(param1:int) : String
      {
         return "var_" + this.id + "_" + param1 + "_desc";
      }
      
      public function getAppearanceName(param1:int) : String
      {
         var _loc2_:String = this.getAppearanceNameToken(param1);
         return this.locale.translate(LocaleCategory.ENTITY,_loc2_);
      }
      
      public function getAppearanceDesc(param1:int) : String
      {
         var _loc2_:String = this.getAppearanceDescToken(param1);
         return this.locale.translate(LocaleCategory.ENTITY,_loc2_);
      }
      
      public function getAppearanceIndex(param1:IEntityAppearanceDef) : int
      {
         return this.appearanceDefs.indexOf(param1);
      }
      
      public function setAppearanceName(param1:int, param2:String) : void
      {
         var _loc3_:String = this.getAppearanceNameToken(param1);
         this.locale.getLocalizer(LocaleCategory.ENTITY).setValue(_loc3_,param2);
      }
      
      public function setAppearanceDesc(param1:int, param2:String) : void
      {
         var _loc3_:String = this.getAppearanceDescToken(param1);
         this.locale.getLocalizer(LocaleCategory.ENTITY).setValue(_loc3_,param2);
      }
      
      public function get shadowUrl() : String
      {
         return this._shadowUrl;
      }
      
      public function get disableShadow() : Boolean
      {
         return this._disableShadow;
      }
      
      public function get gender() : String
      {
         return !!this._gender ? this._gender : (!!this._parentEntityClass ? this._parentEntityClass.gender : null);
      }
      
      public function set gender(param1:String) : void
      {
         this._gender = param1;
      }
   }
}
