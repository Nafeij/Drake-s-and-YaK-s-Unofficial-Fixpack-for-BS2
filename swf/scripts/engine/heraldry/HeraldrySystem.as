package engine.heraldry
{
   import engine.core.pref.PrefBag;
   import engine.resource.ResourceManager;
   import engine.saga.ISagaExpression;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class HeraldrySystem extends EventDispatcher
   {
      
      public static var ADDITIONAL_PLATFORM_URL:String = null;
      
      public static var platformHeraldryExcludes:Vector.<String> = new Vector.<String>();
      
      private static const PREF_SELECTED_HERALDRY:String = "PREF_SELECTED_HERALDRY";
      
      public static const EVENT_SELECTED_HERALDRY:String = "EVENT_SELECTED_HERALDRY";
      
      public static var SUPPRESS_ADDITIONAL_HERALDRY:Boolean = false;
       
      
      public var baseCrestUrl:String;
      
      public var baseBannerUrl:String;
      
      public var crestDefs:Vector.<CrestDef>;
      
      public var crestDefsById:Dictionary;
      
      public var heraldryDefs:Vector.<HeraldryDef>;
      
      public var heraldryDefsById:Dictionary;
      
      public var tags:Vector.<String>;
      
      public var tagsBitByName:Dictionary;
      
      private var _selectedHeraldry:Heraldry;
      
      public var additionalUrl:String;
      
      private var prefs:PrefBag;
      
      private var selectedHeraldryLoader:HeraldryLoader;
      
      public function HeraldrySystem(param1:PrefBag)
      {
         this.crestDefs = new Vector.<CrestDef>();
         this.crestDefsById = new Dictionary();
         this.heraldryDefs = new Vector.<HeraldryDef>();
         this.heraldryDefsById = new Dictionary();
         this.tags = new Vector.<String>();
         this.tagsBitByName = new Dictionary();
         super();
         this.prefs = param1;
      }
      
      public function loadSelectedHeraldry(param1:ResourceManager) : void
      {
         var _loc3_:HeraldryDef = null;
         if(!this.prefs)
         {
            return;
         }
         var _loc2_:String = this.prefs.getPref(PREF_SELECTED_HERALDRY);
         if(_loc2_)
         {
            _loc3_ = this.heraldryDefsById[_loc2_];
            if(_loc3_)
            {
               this.selectedHeraldryLoader = new HeraldryLoader(param1,_loc3_,this);
               this.selectedHeraldryLoader.addEventListener(Event.COMPLETE,this.heraldryLoaderComplete);
               this.selectedHeraldryLoader.loadHeraldry();
            }
         }
      }
      
      private function heraldryLoaderComplete(param1:Event) : void
      {
         var _loc2_:HeraldryLoader = param1.target as HeraldryLoader;
         if(_loc2_)
         {
            if(_loc2_ != this.selectedHeraldryLoader)
            {
               _loc2_.cleanup();
               return;
            }
            this.selectedHeraldry = _loc2_.heraldry;
         }
      }
      
      public function cleanup() : void
      {
         if(this.selectedHeraldryLoader)
         {
            this.selectedHeraldryLoader.cleanup();
            this.selectedHeraldryLoader = null;
         }
         if(this.selectedHeraldry)
         {
            this.selectedHeraldry.cleanup();
            this.selectedHeraldry = null;
         }
      }
      
      public function getHeraldryDefs(param1:RegExp, param2:int, param3:ISagaExpression) : Vector.<HeraldryDef>
      {
         var _loc5_:HeraldryDef = null;
         var _loc4_:Vector.<HeraldryDef> = new Vector.<HeraldryDef>();
         for each(_loc5_ in this.heraldryDefs)
         {
            if(_loc5_.filtered(param1,param2,param3))
            {
               _loc4_.push(_loc5_);
            }
            else
            {
               _loc5_.filtered(param1,param2,param3);
               _loc4_.length;
            }
         }
         return _loc4_;
      }
      
      public function addCrestDef(param1:CrestDef) : void
      {
         if(param1.id in this.crestDefsById)
         {
            throw new ArgumentError("Duplicate crest id [" + param1.id + "]");
         }
         this.crestDefs.push(param1);
         this.crestDefsById[param1.id] = param1;
         this.incorporateCrestDefTags(param1);
      }
      
      private function incorporateCrestDefTags(param1:CrestDef) : void
      {
         var _loc2_:String = null;
         var _loc3_:uint = 0;
         if(!param1 || !param1.tagsArray)
         {
            return;
         }
         param1.tags = 0;
         for each(_loc2_ in param1.tagsArray)
         {
            _loc3_ = this.registerTag(_loc2_);
            param1.tags |= _loc3_;
         }
      }
      
      private function incorporateHeraldryDefTags(param1:HeraldryDef) : void
      {
         var _loc2_:String = null;
         var _loc3_:uint = 0;
         if(!param1 || !param1.tagsArray)
         {
            return;
         }
         param1.tags = 0;
         for each(_loc2_ in param1.tagsArray)
         {
            _loc3_ = this.registerTag(_loc2_);
            param1.tags |= _loc3_;
         }
      }
      
      public function registerTag(param1:String) : uint
      {
         var _loc2_:uint = uint(this.tagsBitByName[param1]);
         if(!_loc2_)
         {
            _loc2_ = uint(1 << this.tags.length);
            this.tagsBitByName[param1] = _loc2_;
            this.tags.push(param1);
         }
         return _loc2_;
      }
      
      public function makeTagsArray(param1:uint) : Array
      {
         var _loc3_:String = null;
         var _loc4_:uint = 0;
         var _loc2_:Array = [];
         for(_loc3_ in this.tagsBitByName)
         {
            _loc4_ = uint(this.tagsBitByName[_loc3_]);
            if((param1 & _loc4_) != 0)
            {
               _loc2_.push(_loc3_);
            }
         }
         _loc2_.sort();
         return _loc2_;
      }
      
      public function addHeraldryDef(param1:HeraldryDef) : void
      {
         if(!param1.id)
         {
            param1.createTempId();
         }
         this.heraldryDefs.push(param1);
         this.heraldryDefsById[param1.id] = param1;
         param1.crestDef = this.getCrestDefById(param1._crestId);
         this.incorporateHeraldryDefTags(param1);
      }
      
      public function removeHeraldryDef(param1:HeraldryDef) : void
      {
         var _loc2_:int = this.heraldryDefs.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.heraldryDefs.splice(_loc2_,1);
         }
         delete this.heraldryDefsById[param1.id];
      }
      
      public function moveHeraldryDefUp(param1:HeraldryDef) : void
      {
         var _loc2_:int = this.heraldryDefs.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.heraldryDefs.splice(_loc2_,1);
            this.heraldryDefs.splice(_loc2_ - 1,0,param1);
         }
      }
      
      public function moveHeraldryDefDown(param1:HeraldryDef) : void
      {
         var _loc2_:int = this.heraldryDefs.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.heraldryDefs.length - 1)
         {
            this.heraldryDefs.splice(_loc2_,1);
            this.heraldryDefs.splice(_loc2_ + 1,0,param1);
         }
      }
      
      public function getCrestDefById(param1:String) : CrestDef
      {
         return this.crestDefsById[param1];
      }
      
      public function getBannerUrl(param1:String) : String
      {
         return this.baseBannerUrl + param1 + ".png";
      }
      
      public function getCrestUrl(param1:String) : String
      {
         return this.baseCrestUrl + param1 + ".png";
      }
      
      public function get selectedHeraldry() : Heraldry
      {
         return this._selectedHeraldry;
      }
      
      public function set selectedHeraldry(param1:Heraldry) : void
      {
         var _loc2_:String = null;
         if(this._selectedHeraldry == param1)
         {
            return;
         }
         if(this._selectedHeraldry)
         {
            this._selectedHeraldry.cleanup();
         }
         this._selectedHeraldry = param1;
         if(this.prefs)
         {
            _loc2_ = !!this._selectedHeraldry ? this._selectedHeraldry.def.id : null;
            this.prefs.setPref(PREF_SELECTED_HERALDRY,_loc2_);
         }
         dispatchEvent(new Event(EVENT_SELECTED_HERALDRY));
      }
      
      public function mergeHeraldrySystem(param1:HeraldrySystem) : void
      {
         var _loc2_:CrestDef = null;
         var _loc3_:HeraldryDef = null;
         for each(_loc2_ in param1.crestDefs)
         {
            this.addCrestDef(_loc2_);
         }
         for each(_loc3_ in param1.heraldryDefs)
         {
            this.addHeraldryDef(_loc3_);
         }
      }
      
      public function resetHeraldryDefIds() : String
      {
         var _loc3_:HeraldryDef = null;
         var _loc4_:String = null;
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:int = 0;
         for each(_loc3_ in this.heraldryDefs)
         {
            _loc4_ = _loc3_.id;
            _loc3_.createHashId();
            if(_loc1_[_loc3_.id])
            {
               return "Heraldry [" + _loc3_.name + "] (index " + _loc2_ + ") is identical to heraldry [" + _loc3_.name + "]";
            }
            _loc1_[_loc3_.id] = _loc3_;
            _loc2_++;
         }
         this.heraldryDefsById = _loc1_;
         return null;
      }
   }
}
