package com.google.analytics.core
{
   import com.google.analytics.utils.Variables;
   
   public class Organic
   {
      
      public static var throwErrors:Boolean = false;
       
      
      private var _sources:Array;
      
      private var _sourcesCache:Array;
      
      private var _sourcesEngine:Array;
      
      private var _ignoredReferrals:Array;
      
      private var _ignoredReferralsCache:Object;
      
      private var _ignoredKeywords:Array;
      
      private var _ignoredKeywordsCache:Object;
      
      public function Organic()
      {
         super();
         this._sources = [];
         this._sourcesCache = [];
         this._sourcesEngine = [];
         this._ignoredReferrals = [];
         this._ignoredReferralsCache = {};
         this._ignoredKeywords = [];
         this._ignoredKeywordsCache = {};
      }
      
      public static function getKeywordValueFromPath(param1:String, param2:String) : String
      {
         var _loc3_:String = null;
         var _loc4_:Variables = null;
         if(param2.indexOf(param1 + "=") > -1)
         {
            if(param2.charAt(0) == "?")
            {
               param2 = param2.substr(1);
            }
            param2 = param2.split("+").join("%20");
            _loc4_ = new Variables(param2);
            _loc3_ = String(_loc4_[param1]);
         }
         return _loc3_;
      }
      
      public function get count() : int
      {
         return this._sources.length;
      }
      
      public function get sources() : Array
      {
         return this._sources;
      }
      
      public function get ignoredReferralsCount() : int
      {
         return this._ignoredReferrals.length;
      }
      
      public function get ignoredKeywordsCount() : int
      {
         return this._ignoredKeywords.length;
      }
      
      public function addSource(param1:String, param2:String) : void
      {
         var _loc3_:OrganicReferrer = new OrganicReferrer(param1,param2);
         if(this._sourcesCache[_loc3_.toString()] == undefined)
         {
            this._sources.push(_loc3_);
            this._sourcesCache[_loc3_.toString()] = this._sources.length - 1;
            if(this._sourcesEngine[_loc3_.engine] == undefined)
            {
               this._sourcesEngine[_loc3_.engine] = [this._sources.length - 1];
            }
            else
            {
               this._sourcesEngine[_loc3_.engine].push(this._sources.length - 1);
            }
         }
         else if(throwErrors)
         {
            throw new Error(_loc3_.toString() + " already exists, we don\'t add it.");
         }
      }
      
      public function addIgnoredReferral(param1:String) : void
      {
         if(this._ignoredReferralsCache[param1] == undefined)
         {
            this._ignoredReferrals.push(param1);
            this._ignoredReferralsCache[param1] = this._ignoredReferrals.length - 1;
         }
         else if(throwErrors)
         {
            throw new Error("\"" + param1 + "\" already exists, we don\'t add it.");
         }
      }
      
      public function addIgnoredKeyword(param1:String) : void
      {
         if(this._ignoredKeywordsCache[param1] == undefined)
         {
            this._ignoredKeywords.push(param1);
            this._ignoredKeywordsCache[param1] = this._ignoredKeywords.length - 1;
         }
         else if(throwErrors)
         {
            throw new Error("\"" + param1 + "\" already exists, we don\'t add it.");
         }
      }
      
      public function clear() : void
      {
         this.clearEngines();
         this.clearIgnoredReferrals();
         this.clearIgnoredKeywords();
      }
      
      public function clearEngines() : void
      {
         this._sources = [];
         this._sourcesCache = [];
         this._sourcesEngine = [];
      }
      
      public function clearIgnoredReferrals() : void
      {
         this._ignoredReferrals = [];
         this._ignoredReferralsCache = {};
      }
      
      public function clearIgnoredKeywords() : void
      {
         this._ignoredKeywords = [];
         this._ignoredKeywordsCache = {};
      }
      
      public function getKeywordValue(param1:OrganicReferrer, param2:String) : String
      {
         var _loc3_:String = param1.keyword;
         return getKeywordValueFromPath(_loc3_,param2);
      }
      
      public function getReferrerByName(param1:String) : OrganicReferrer
      {
         var _loc2_:int = 0;
         if(this.match(param1))
         {
            _loc2_ = int(this._sourcesEngine[param1][0]);
            return this._sources[_loc2_];
         }
         return null;
      }
      
      public function isIgnoredReferral(param1:String) : Boolean
      {
         if(this._ignoredReferralsCache.hasOwnProperty(param1))
         {
            return true;
         }
         return false;
      }
      
      public function isIgnoredKeyword(param1:String) : Boolean
      {
         if(this._ignoredKeywordsCache.hasOwnProperty(param1))
         {
            return true;
         }
         return false;
      }
      
      public function match(param1:String) : Boolean
      {
         if(param1 == "")
         {
            return false;
         }
         param1 = param1.toLowerCase();
         if(this._sourcesEngine[param1] != undefined)
         {
            return true;
         }
         return false;
      }
   }
}
