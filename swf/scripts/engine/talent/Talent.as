package engine.talent
{
   public class Talent
   {
       
      
      public var def:TalentDef;
      
      private var _rank:int;
      
      public var origRank:int;
      
      public var rankDef:TalentRankDef;
      
      public function Talent(param1:TalentDef, param2:int)
      {
         super();
         this.def = param1;
         this.rank = param2;
      }
      
      public function get rank() : int
      {
         return this._rank;
      }
      
      public function set rank(param1:int) : void
      {
         this._rank = param1;
         this.rankDef = this.def.getRank(this._rank);
      }
      
      public function clone() : Talent
      {
         var _loc1_:Talent = new Talent(this.def,this.rank);
         _loc1_.origRank = this.rank;
         return _loc1_;
      }
      
      public function internal_incrementRank() : void
      {
         if(this._rank < this.def.maxUpgradableRankIndex)
         {
            ++this.rank;
         }
      }
      
      public function internal_decrementRank() : void
      {
         if(this._rank > 0 && this._rank > this.origRank)
         {
            --this.rank;
         }
      }
      
      public function get isUpgraded() : Boolean
      {
         return this._rank > this.origRank;
      }
   }
}
