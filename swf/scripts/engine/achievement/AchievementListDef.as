package engine.achievement
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.locale.Localizer;
   import flash.utils.Dictionary;
   
   public class AchievementListDef
   {
       
      
      public var _progressVar2Defs:Dictionary;
      
      public var defs:Vector.<AchievementDef>;
      
      private var _id2def:Dictionary;
      
      public function AchievementListDef()
      {
         this._progressVar2Defs = new Dictionary();
         this.defs = new Vector.<AchievementDef>();
         this._id2def = new Dictionary();
         super();
      }
      
      public function fetch(param1:String) : AchievementDef
      {
         return this._id2def[param1];
      }
      
      protected function addDef(param1:AchievementDef) : void
      {
         this._id2def[param1.id] = param1;
         this.defs.push(param1);
         var _loc2_:Vector.<AchievementDef> = this._progressVar2Defs[param1.progressVar];
         if(!_loc2_)
         {
            _loc2_ = new Vector.<AchievementDef>();
            this._progressVar2Defs[param1.progressVar] = _loc2_;
         }
         _loc2_.push(param1);
      }
      
      public function getAchievementDefsForProgressVar(param1:String) : Vector.<AchievementDef>
      {
         return this._progressVar2Defs[param1];
      }
      
      public function localizeAchievementDefs(param1:Locale) : void
      {
         var _loc3_:AchievementDef = null;
         var _loc2_:Localizer = param1.getLocalizer(LocaleCategory.ACHIEVEMENT);
         for each(_loc3_ in this.defs)
         {
            _loc3_.localizeAchievementDef(_loc2_);
         }
      }
   }
}
