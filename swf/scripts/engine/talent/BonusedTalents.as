package engine.talent
{
   import engine.math.Rng;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import flash.utils.Dictionary;
   
   public class BonusedTalents
   {
      
      public static const NullBonusedTalents:BonusedTalents = new BonusedTalents(null,null);
      
      private static var _bonusStats:Dictionary;
       
      
      public var talents:Talents;
      
      public var stats:Stats;
      
      private var _talentRankDefsByAffectedStat:Dictionary;
      
      public var talentBonuses:Dictionary;
      
      public function BonusedTalents(param1:Talents, param2:Stats)
      {
         this._talentRankDefsByAffectedStat = new Dictionary();
         this.talentBonuses = new Dictionary();
         super();
         this.talents = param1;
         this.stats = param2;
         this._cacheTalents();
      }
      
      private static function _addCached(param1:TalentRankDef, param2:Dictionary) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:Vector.<TalentRankDef> = param2[param1.affectedStatType];
         if(!_loc3_)
         {
            _loc3_ = new Vector.<TalentRankDef>();
            param2[param1.affectedStatType] = _loc3_;
         }
         _loc3_.push(param1);
      }
      
      public static function getBonusStat(param1:StatType) : StatType
      {
         if(!_bonusStats)
         {
            _bonusStats = new Dictionary();
            _bonusStats[StatType.STRENGTH] = StatType.TAL_BONUS_STR;
            _bonusStats[StatType.ARMOR] = StatType.TAL_BONUS_ARM;
            _bonusStats[StatType.ARMOR_BREAK] = StatType.TAL_BONUS_BRK;
            _bonusStats[StatType.EXERTION] = StatType.TAL_BONUS_EXE;
            _bonusStats[StatType.WILLPOWER] = StatType.TAL_BONUS_WIL;
         }
         return _bonusStats[param1];
      }
      
      public static function getBonusForParentStat(param1:StatType, param2:Stats) : int
      {
         if(!param2)
         {
            return 0;
         }
         var _loc3_:StatType = getBonusStat(param1);
         var _loc4_:int = param2.getValue(_loc3_);
         var _loc5_:int = param2.getValue(StatType.TAL_BONUS_ALL);
         return Math.max(_loc5_,_loc4_);
      }
      
      public function _cacheTalents() : void
      {
         var _loc2_:Talent = null;
         var _loc3_:TalentRankDef = null;
         var _loc4_:int = 0;
         this._talentRankDefsByAffectedStat = new Dictionary();
         if(!this.talents)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.talents.talentList.length)
         {
            _loc2_ = this.talents.talentList[_loc1_];
            _loc3_ = _loc2_.rankDef;
            if(_loc3_)
            {
               if(this.stats)
               {
                  _loc4_ = getBonusForParentStat(_loc3_.talentDef.parentStatType,this.stats);
                  if(_loc4_)
                  {
                     _loc3_ = _loc3_.talentDef.getRank(_loc3_.rank + _loc4_);
                     this.talentBonuses[_loc2_] = _loc4_;
                  }
               }
               _addCached(_loc3_,this._talentRankDefsByAffectedStat);
            }
            _loc1_++;
         }
      }
      
      public function getTalentRankDefsByAffectedStat(param1:StatType) : Vector.<TalentRankDef>
      {
         return this._talentRankDefsByAffectedStat[param1];
      }
      
      public function generateTalentResults(param1:StatType, param2:Rng, param3:Vector.<TalentRankDef>) : void
      {
         var _loc5_:TalentRankDef = null;
         if(param3.length)
         {
            param3.splice(0,param3.length);
         }
         var _loc4_:Vector.<TalentRankDef> = this._talentRankDefsByAffectedStat[param1];
         if(_loc4_)
         {
            for each(_loc5_ in _loc4_)
            {
               if(param2 == null || _loc5_.percent == 100 || param2.nextMinMax(0,100) < _loc5_.percent)
               {
                  param3.push(_loc5_);
               }
            }
         }
      }
   }
}
