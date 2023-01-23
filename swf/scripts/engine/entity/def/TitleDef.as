package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   
   public class TitleDef implements ITitleDef
   {
       
      
      protected var _id:String;
      
      protected var _icon:String;
      
      protected var _iconBuffUrl:String;
      
      private var _name_f:String;
      
      private var _name_m:String;
      
      private var _desc_f:String;
      
      private var _desc_m:String;
      
      protected var _titleRanks:Vector.<ItemDef>;
      
      protected var _locale:Locale;
      
      protected var _unlockVarName:String;
      
      private var _minRank:int = 0;
      
      public function TitleDef(param1:Locale)
      {
         super();
         this._locale = param1;
         this._titleRanks = new Vector.<ItemDef>();
      }
      
      public function addRank(param1:ItemDef) : uint
      {
         this._titleRanks.push(param1);
         this.calcMinRank();
         return this._titleRanks.length - 1;
      }
      
      public function setRank(param1:uint, param2:ItemDef) : void
      {
         if(param1 < this._titleRanks.length)
         {
            this._titleRanks[param1] = param2;
         }
         else
         {
            this._titleRanks.length = param1 + 1;
            this._titleRanks[param1] = param2;
         }
      }
      
      public function getDescription(param1:String) : String
      {
         return param1 == "female" ? this.description_f : this.description_m;
      }
      
      public function getName(param1:String) : String
      {
         return param1 == "female" ? this.name_f : this.name_m;
      }
      
      public function get name_m() : String
      {
         if(!this._name_m)
         {
            this._name_m = this._locale.translate(LocaleCategory.TITLE,this.id + "^m",true);
            if(!this._name_m)
            {
               this._name_m = this._locale.translate(LocaleCategory.TITLE,this.id);
            }
         }
         return this._name_m;
      }
      
      public function get name_f() : String
      {
         if(!this._name_f)
         {
            this._name_f = this._locale.translate(LocaleCategory.TITLE,this.id + "^f",true);
            if(!this._name_f)
            {
               this._name_f = this._locale.translate(LocaleCategory.TITLE,this.id + "^m",true);
               if(!this._name_f)
               {
                  this._name_f = this._locale.translate(LocaleCategory.TITLE,this.id);
               }
            }
         }
         return this._name_f;
      }
      
      public function get description_m() : String
      {
         if(!this._desc_m)
         {
            this._desc_m = this._locale.translate(LocaleCategory.TITLE,this.id + "_desc^m",true);
            if(!this._desc_m)
            {
               this._desc_m = this._locale.translate(LocaleCategory.TITLE,this.id + "_desc");
            }
         }
         return this._desc_m;
      }
      
      public function get description_f() : String
      {
         if(!this._desc_f)
         {
            this._desc_f = this._locale.translate(LocaleCategory.TITLE,this.id + "_desc^f",true);
            if(!this._desc_f)
            {
               this._desc_f = this._locale.translate(LocaleCategory.TITLE,this.id + "_desc^m",true);
               if(!this._desc_f)
               {
                  this._desc_f = this._locale.translate(LocaleCategory.TITLE,this.id + "_desc");
               }
            }
         }
         return this._desc_f;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function getRank(param1:uint) : ItemDef
      {
         if(param1 >= this._titleRanks.length)
         {
            return null;
         }
         return this._titleRanks[param1];
      }
      
      public function changeLocale(param1:Locale) : void
      {
         var _loc2_:ItemDef = null;
         this._locale = param1;
         for each(_loc2_ in this._titleRanks)
         {
            _loc2_.changeLocale(param1);
         }
         this._name_f = null;
         this._name_m = null;
         this._desc_m = null;
         this._desc_f = null;
      }
      
      public function get icon() : String
      {
         return this._icon;
      }
      
      public function get ranks() : Vector.<ItemDef>
      {
         return this._titleRanks;
      }
      
      public function get numRanks() : int
      {
         if(this._titleRanks)
         {
            return this._titleRanks.length;
         }
         return -1;
      }
      
      public function get minRank() : int
      {
         return this._minRank;
      }
      
      public function get iconBuffUrl() : String
      {
         return this._iconBuffUrl;
      }
      
      public function get unlockVarName() : String
      {
         return this._unlockVarName;
      }
      
      private function calcMinRank() : void
      {
         var _loc1_:ItemDef = null;
         this._minRank = int.MAX_VALUE;
         for each(_loc1_ in this._titleRanks)
         {
            if(_loc1_.rank < this._minRank)
            {
               this._minRank = _loc1_.rank;
            }
         }
      }
   }
}
