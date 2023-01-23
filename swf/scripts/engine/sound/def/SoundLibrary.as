package engine.sound.def
{
   import engine.core.logging.ILogger;
   import engine.fmod.FmodProjectInfo;
   import flash.utils.Dictionary;
   
   public class SoundLibrary implements ISoundLibrary
   {
       
      
      private var soundDefsByName:Dictionary;
      
      private var _soundDefs:Vector.<ISoundDef>;
      
      protected var logger:ILogger;
      
      public var inheritUrls:Vector.<String>;
      
      public var inherits:Vector.<SoundLibrary>;
      
      protected var _sku:String = "common";
      
      private var _fmodProjectInfos:Array;
      
      public var _url:String;
      
      public function SoundLibrary(param1:String, param2:ILogger)
      {
         this.soundDefsByName = new Dictionary();
         this._soundDefs = new Vector.<ISoundDef>();
         this.inheritUrls = new Vector.<String>();
         this.inherits = new Vector.<SoundLibrary>();
         super();
         this._url = param1;
         this.logger = param2;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function get fmodProjectInfos() : Array
      {
         var _loc1_:Dictionary = null;
         var _loc2_:ISoundDef = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         if(!this._fmodProjectInfos)
         {
            this._fmodProjectInfos = [];
            _loc1_ = new Dictionary();
            for each(_loc2_ in this._soundDefs)
            {
               _loc4_ = _loc2_.eventName.indexOf("/");
               if(_loc4_ > 0)
               {
                  _loc5_ = _loc2_.eventName.substr(0,_loc4_);
                  _loc1_[_loc5_] = _loc5_;
               }
            }
            for each(_loc3_ in _loc1_)
            {
               this._fmodProjectInfos.push(FmodProjectInfo.create(this._sku + "/fmod/",_loc3_));
            }
         }
         return this._fmodProjectInfos;
      }
      
      public function getAllSoundDefs(param1:Vector.<ISoundDef>) : Vector.<ISoundDef>
      {
         var _loc2_:ISoundDef = null;
         var _loc3_:ISoundLibrary = null;
         if(!param1)
         {
            param1 = new Vector.<ISoundDef>();
         }
         for each(_loc2_ in this._soundDefs)
         {
            param1.push(_loc2_);
         }
         for each(_loc3_ in this.inherits)
         {
            _loc3_.getAllSoundDefs(param1);
         }
         return param1;
      }
      
      public function get soundDefs() : Vector.<ISoundDef>
      {
         return this._soundDefs;
      }
      
      public function get sku() : String
      {
         return this._sku;
      }
      
      public function getSoundDef(param1:String) : ISoundDef
      {
         var _loc3_:SoundLibrary = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:ISoundDef = this.soundDefsByName[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         for each(_loc3_ in this.inherits)
         {
            _loc2_ = _loc3_.getSoundDef(param1);
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function addSoundDef(param1:ISoundDef) : void
      {
         this._soundDefs.push(param1);
         this.soundDefsByName[param1.soundName] = param1;
      }
      
      public function get errors() : int
      {
         var _loc2_:SoundDef = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._soundDefs)
         {
         }
         return _loc1_;
      }
      
      public function includeSoundDefFrom(param1:SoundLibrary, param2:String) : void
      {
         var _loc3_:ISoundDef = null;
         if(!this.getSoundDef(param2))
         {
            _loc3_ = param1.getSoundDef(param2);
            if(_loc3_)
            {
               this.addSoundDef(_loc3_);
            }
         }
      }
   }
}
