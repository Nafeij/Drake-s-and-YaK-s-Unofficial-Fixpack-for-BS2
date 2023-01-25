package engine.saga
{
   public class CaravanDef
   {
       
      
      public var name:String;
      
      public var shortname:String;
      
      public var roster:Vector.<String>;
      
      public var party:Vector.<String>;
      
      public var saga:SagaDef;
      
      public var leader:String;
      
      public var heraldryEnabled:Boolean;
      
      public var banner:int = 1;
      
      public var disable_metrics:Boolean;
      
      public var saves:Boolean = true;
      
      public var ga:Boolean;
      
      public var animBaseUrl:String;
      
      public var closePoleUrl:String;
      
      public var trainingPopUrl:String;
      
      public var campUrls:Array;
      
      public function CaravanDef(param1:SagaDef)
      {
         this.roster = new Vector.<String>();
         this.party = new Vector.<String>();
         super();
         this.name = this.name;
         this.saga = param1;
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function hasPartyMember(param1:String) : Boolean
      {
         return this.party.indexOf(param1) >= 0;
      }
      
      public function hasRosterMember(param1:String) : Boolean
      {
         return this.roster.indexOf(param1) >= 0;
      }
      
      public function promoteRosterMember(param1:String) : void
      {
         var _loc2_:int = this.roster.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.roster.splice(_loc2_,1);
            this.roster.splice(_loc2_ - 1,0,param1);
         }
      }
      
      public function demoteRosterMember(param1:String) : void
      {
         var _loc2_:int = this.roster.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.roster.length - 1)
         {
            this.roster.splice(_loc2_,1);
            this.roster.splice(_loc2_ + 1,0,param1);
         }
      }
      
      public function removeRosterMember(param1:String) : void
      {
         var _loc2_:int = this.roster.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.roster.splice(_loc2_,1);
         }
      }
      
      public function promotePartyMember(param1:String) : void
      {
         var _loc2_:int = this.party.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.party.splice(_loc2_,1);
            this.party.splice(_loc2_ - 1,0,param1);
         }
      }
      
      public function demotePartyMember(param1:String) : void
      {
         var _loc2_:int = this.party.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.party.length - 1)
         {
            this.party.splice(_loc2_,1);
            this.party.splice(_loc2_ + 1,0,param1);
         }
      }
      
      public function removePartyMember(param1:String) : void
      {
         var _loc2_:int = this.party.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.party.splice(_loc2_,1);
         }
      }
      
      public function getCampUrlForBiome(param1:int) : String
      {
         var _loc2_:String = null;
         if(Boolean(this.campUrls) && this.campUrls.length > param1)
         {
            _loc2_ = String(this.campUrls[param1]);
         }
         if(!_loc2_)
         {
            _loc2_ = this.saga.getCampUrlForBiome(param1);
         }
         if(!_loc2_)
         {
            throw new ArgumentError("no camp url determined for biome " + param1);
         }
         return _loc2_;
      }
   }
}
