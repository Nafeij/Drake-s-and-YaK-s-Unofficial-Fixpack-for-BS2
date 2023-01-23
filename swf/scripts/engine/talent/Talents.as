package engine.talent
{
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class Talents
   {
      
      public static var ENABLED:Boolean = true;
       
      
      public var id:String;
      
      public var talentList:Vector.<Talent>;
      
      private var _talentByParentStatType:Dictionary;
      
      private var _talentById:Dictionary;
      
      private var _totalRanks:int;
      
      public function Talents(param1:String)
      {
         this.talentList = new Vector.<Talent>();
         this._talentByParentStatType = new Dictionary();
         this._talentById = new Dictionary();
         super();
         this.id = param1;
      }
      
      public function getTalentByDef(param1:TalentDef, param2:Boolean) : Talent
      {
         var _loc4_:Talent = null;
         if(!param1)
         {
            return null;
         }
         var _loc3_:Talent = this._talentById[param1.id];
         if(!_loc3_ && param2)
         {
            _loc4_ = this._talentByParentStatType[param1.parentStatType];
            this.removeTalent(_loc4_);
            _loc3_ = new Talent(param1,0);
            this.addTalent(_loc3_,false);
         }
         return _loc3_;
      }
      
      public function removeTalent(param1:Talent) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _loc2_ = this.talentList.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.talentList.splice(_loc2_,1);
            }
            delete this._talentByParentStatType[param1.def.parentStatType];
            delete this._talentById[param1.def.id];
            this._totalRanks -= param1.rank;
         }
      }
      
      public function getTalentById(param1:String) : Talent
      {
         if(!param1)
         {
            return null;
         }
         return this._talentById[param1];
      }
      
      public function addTalent(param1:Talent, param2:Boolean) : Talent
      {
         this.talentList.push(param1);
         this._talentById[param1.def.id] = param1;
         this._talentByParentStatType[param1.def.parentStatType] = param1;
         this._totalRanks += param1.rank;
         if(param2)
         {
            this.cacheTalents();
         }
         return param1;
      }
      
      private function cacheTalents() : void
      {
      }
      
      public function getTalentByParentStatType(param1:StatType) : Talent
      {
         return this._talentByParentStatType[param1];
      }
      
      public function computeTotalRanks() : void
      {
         var _loc1_:Talent = null;
         this._totalRanks = 0;
         for each(_loc1_ in this.talentList)
         {
            this._totalRanks += _loc1_.rank;
         }
      }
      
      public function clone() : Talents
      {
         var _loc2_:Talent = null;
         var _loc1_:Talents = new Talents(this.id + "_clone");
         for each(_loc2_ in this.talentList)
         {
            _loc2_ = _loc2_.clone();
            _loc1_.addTalent(_loc2_,false);
         }
         _loc1_.cacheTalents();
         return _loc1_;
      }
      
      public function get totalRanks() : int
      {
         return this._totalRanks;
      }
      
      public function incrementRank(param1:TalentDef) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:Talent = this.getTalentByDef(param1,true);
         this._totalRanks -= _loc2_.rank;
         _loc2_.internal_incrementRank();
         this._totalRanks += _loc2_.rank;
         this.cacheTalents();
      }
      
      public function decrementRank(param1:TalentDef) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:Talent = this.getTalentByDef(param1,true);
         this._totalRanks -= _loc2_.rank;
         _loc2_.internal_decrementRank();
         this._totalRanks += _loc2_.rank;
         if(_loc2_.rank == 0)
         {
            this.removeTalent(_loc2_);
         }
         this.cacheTalents();
      }
   }
}
