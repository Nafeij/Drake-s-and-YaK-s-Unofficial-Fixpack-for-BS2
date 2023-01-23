package game.gui
{
   import engine.stat.def.StatType;
   import engine.talent.Talent;
   import engine.talent.TalentDef;
   import engine.talent.TalentDefs;
   import engine.talent.Talents;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class GuiStatButton extends ButtonWithIndex
   {
       
      
      public var statType:StatType;
      
      public var _plus:MovieClip;
      
      public var _rankCircle:MovieClip;
      
      public var _rankText:TextField;
      
      public var _pointsAvailable:int;
      
      public var _talents:Talents;
      
      public var _value:int;
      
      public var _original:int;
      
      public var _max:int;
      
      public function GuiStatButton()
      {
         super();
      }
      
      private static function displayCorrectButtonStat(param1:ButtonWithIndex, param2:StatType) : void
      {
         var _loc5_:MovieClip = null;
         var _loc3_:String = !!param2 ? param2.abbrev : "AB0";
         var _loc4_:int = 0;
         while(_loc4_ < param1.numChildren)
         {
            _loc5_ = param1.getChildAt(_loc4_) as MovieClip;
            if(_loc5_)
            {
               _loc5_.visible = _loc5_.name == _loc3_;
            }
            _loc4_++;
         }
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      public function set talents(param1:Talents) : void
      {
         if(this._talents == param1)
         {
            return;
         }
         this._talents = param1;
         this.updateUpgradable();
      }
      
      public function init(param1:IGuiContext, param2:StatType) : void
      {
         var _loc3_:String = null;
         super.guiButtonContext = param1;
         this.statType = param2;
         this._plus = getChildByName("plus") as MovieClip;
         this._rankCircle = getChildByName("rankCircle") as MovieClip;
         this._rankText = getChildByName("rankText") as TextField;
         this._plus.visible = false;
         this._rankCircle.visible = false;
         this._rankText.visible = false;
         displayCorrectButtonStat(this,param2);
         if(param1.saga)
         {
            _loc3_ = param1.saga.def.talentDefs.getSoundUiByParentStatType(param2);
            if(_loc3_)
            {
               this.clickSound = _loc3_;
            }
         }
         this.updateUpgradable();
         this.rank = 0;
      }
      
      public function set rank(param1:int) : void
      {
         if(param1 > 0)
         {
            this._rankText.text = param1.toString();
         }
         this._rankCircle.visible = this._rankText.visible = param1 > 0;
      }
      
      public function set availablePoints(param1:int) : void
      {
         this._pointsAvailable = param1;
         this.updateUpgradable();
      }
      
      private function computeUpgradable() : Boolean
      {
         var _loc1_:Talent = null;
         var _loc2_:TalentDefs = null;
         var _loc3_:Vector.<TalentDef> = null;
         if(!Talents.ENABLED)
         {
            return false;
         }
         if(!this.statType || this._pointsAvailable < 0)
         {
            return false;
         }
         if(this._value < this._max)
         {
            return false;
         }
         if(this._pointsAvailable && this.statType && Boolean(this._talents))
         {
            _loc1_ = this._talents.getTalentByParentStatType(this.statType);
            if(_loc1_)
            {
               if(_loc1_.rank < _loc1_.def.maxUpgradableRankIndex)
               {
                  return true;
               }
               return false;
            }
            _loc2_ = !!_context.saga ? _context.saga.def.talentDefs : null;
            if(_loc2_)
            {
               _loc3_ = _loc2_.getDefsByParentStatType(this.statType);
               if(Boolean(_loc3_) && Boolean(_loc3_.length))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function updateUpgradable() : void
      {
         this.upgradable = this.computeUpgradable();
      }
      
      private function set upgradable(param1:Boolean) : void
      {
         this._plus.visible = param1;
      }
      
      public function get isUpgradable() : Boolean
      {
         return this._plus.visible;
      }
      
      public function setStatValue(param1:int, param2:int, param3:int, param4:int, param5:int) : void
      {
         this._pointsAvailable = param4;
         this._value = param1;
         this._original = param2;
         this._max = param3;
         this.updateUpgradable();
      }
   }
}
