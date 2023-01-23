package engine.battle.ability.def
{
   import engine.ability.IAbilityDef;
   import engine.ability.IAbilityDefLevel;
   import engine.ability.IAbilityDefLevels;
   import engine.ability.def.AbilityDefLevel;
   import engine.ability.def.AbilityDefLevels;
   import engine.core.logging.ILogger;
   import engine.entity.UnitStatCosts;
   import flash.utils.Dictionary;
   
   public class BattleAbilityDefLevels extends AbilityDefLevels
   {
       
      
      public var abilitiesByTag:Dictionary;
      
      public function BattleAbilityDefLevels(param1:String)
      {
         super(param1);
      }
      
      override public function clone(param1:ILogger) : IAbilityDefLevels
      {
         var _loc3_:AbilityDefLevel = null;
         var _loc4_:BattleAbilityDef = null;
         var _loc2_:BattleAbilityDefLevels = new BattleAbilityDefLevels(_name + "_clone");
         for each(_loc3_ in abilities)
         {
            _loc4_ = _loc3_.def as BattleAbilityDef;
            _loc2_.setAbilityDefLevel(_loc4_,_loc3_.level,_loc3_.rankAcquired,param1);
         }
         _loc2_.cacheAbilityTags();
         return _loc2_;
      }
      
      public function updateFromRank(param1:int, param2:UnitStatCosts) : void
      {
         var _loc3_:IAbilityDefLevel = null;
         var _loc4_:BattleAbilityDef = null;
         var _loc5_:int = 0;
         for each(_loc3_ in abilities)
         {
            _loc4_ = _loc3_.def as BattleAbilityDef;
            if(_loc4_.tag == BattleAbilityTag.SPECIAL)
            {
               _loc5_ = param2.getAbilityLevel(param1,_loc3_.rankAcquired);
               _loc3_.level = _loc5_;
            }
         }
      }
      
      override protected function handleDirtyAbilities() : void
      {
         this.abilitiesByTag = null;
      }
      
      override public function setAbilityDefLevel(param1:IAbilityDef, param2:int, param3:int, param4:ILogger) : IAbilityDefLevel
      {
         if(!(param1 is BattleAbilityDef))
         {
            throw new ArgumentError("no , not battle...");
         }
         return super.setAbilityDefLevel(param1,param2,param3,param4);
      }
      
      private function cacheAbilityTags() : void
      {
         var _loc1_:AbilityDefLevel = null;
         var _loc2_:BattleAbilityDef = null;
         var _loc3_:BattleAbilityTag = null;
         var _loc4_:Vector.<AbilityDefLevel> = null;
         if(this.abilitiesByTag)
         {
            return;
         }
         this.abilitiesByTag = new Dictionary();
         for each(_loc1_ in abilities)
         {
            _loc2_ = _loc1_.def as BattleAbilityDef;
            _loc3_ = _loc2_.tag;
            _loc4_ = this.getAbilityDefLevelsByTag(_loc3_);
            _loc4_.push(_loc1_);
         }
      }
      
      public function getAbilityDefLevelsByTag(param1:BattleAbilityTag) : Vector.<AbilityDefLevel>
      {
         this.cacheAbilityTags();
         var _loc2_:Vector.<AbilityDefLevel> = this.abilitiesByTag[param1];
         if(!_loc2_)
         {
            _loc2_ = new Vector.<AbilityDefLevel>();
            this.abilitiesByTag[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function getFirstAbilityByTag(param1:BattleAbilityTag) : AbilityDefLevel
      {
         this.cacheAbilityTags();
         var _loc2_:Vector.<AbilityDefLevel> = this.getAbilityDefLevelsByTag(param1);
         return _loc2_.length > 0 ? _loc2_[0] : null;
      }
   }
}
