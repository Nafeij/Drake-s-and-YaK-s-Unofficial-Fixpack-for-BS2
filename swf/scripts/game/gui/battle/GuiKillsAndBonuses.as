package game.gui.battle
{
   import com.greensock.TweenMax;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleRewardData;
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.PopupIconsGroup;
   
   public class GuiKillsAndBonuses extends GuiBase
   {
       
      
      public var _winStreak:GuiMatchResolutionSpear;
      
      public var _winBonus:GuiMatchResolutionSpear;
      
      public var _underdogBonus:GuiMatchResolutionSpear;
      
      public var _kills:GuiMatchResolutionSpear;
      
      public var _expertBonus:GuiMatchResolutionSpear;
      
      public var _dailyStreak:GuiMatchResolutionSpear;
      
      public var _dailyIcon:PopupIconsGroup;
      
      public var _expertIcon:PopupIconsGroup;
      
      public var _underdogIcon:PopupIconsGroup;
      
      public var _winStreakIcon:PopupIconsGroup;
      
      public var listener:IGuiMatchResolutionListener;
      
      public var killsAndBonusesStartingY:Number;
      
      public var killIcon:PopupIconsGroup;
      
      public var winIcon:PopupIconsGroup;
      
      public var battleRewardData:BattleRewardData;
      
      public var victor:Boolean;
      
      public var bonusYSpacing:Number;
      
      public var bonusesVector:Vector.<BonusMovieAndIcon>;
      
      public var bonusesIndex:int;
      
      public var previousBonus:MovieClip;
      
      public const totalPopupIcons:int = 6;
      
      public function GuiKillsAndBonuses()
      {
         this.bonusesVector = new Vector.<BonusMovieAndIcon>();
         super();
         this.mouseEnabled = this.mouseChildren = false;
         this._winStreak = getChildByName("winStreak") as GuiMatchResolutionSpear;
         this._winBonus = getChildByName("winBonus") as GuiMatchResolutionSpear;
         this._underdogBonus = getChildByName("underdogBonus") as GuiMatchResolutionSpear;
         this._kills = getChildByName("kills") as GuiMatchResolutionSpear;
         this._expertBonus = getChildByName("expertBonus") as GuiMatchResolutionSpear;
         this._dailyStreak = getChildByName("dailyStreak") as GuiMatchResolutionSpear;
         this._dailyIcon = getChildByName("dailyIcon") as PopupIconsGroup;
         this._expertIcon = getChildByName("expertIcon") as PopupIconsGroup;
         this._underdogIcon = getChildByName("underdogIcon") as PopupIconsGroup;
         this._winStreakIcon = getChildByName("winStreakIcon") as PopupIconsGroup;
      }
      
      public function init(param1:IGuiContext, param2:IGuiMatchResolutionListener, param3:BattleRewardData) : void
      {
         this.victor = this.victor;
         this.battleRewardData = param3;
         this.listener = param2;
         super.initGuiBase(param1);
         this.visible = false;
         this.listener = param2;
         this.killsAndBonusesStartingY = y;
         this.bonusYSpacing = this._winBonus.y - this._kills.y;
         this._kills.init(param1,"mr_bonus_kills");
         this._winBonus.init(param1,"mr_bonus_win");
         this._winStreak.init(param1,"mr_bonus_winstreak");
         this._expertBonus.init(param1,"mr_bonus_expert");
         this._dailyStreak.init(param1,"mr_bonus_dailystreak");
         this._underdogBonus.init(param1,"mr_bonus_underdog");
         var _loc4_:MovieClip = getChildByName("skullPopups") as MovieClip;
         this.killIcon = GuiUtil.performCensor(_loc4_,_context.censorId,logger) as PopupIconsGroup;
         this.killIcon.init(param1,18);
         this.winIcon = getChildByName("winBonusIcon") as PopupIconsGroup;
         this.winIcon.init(param1,this.totalPopupIcons);
         this._winStreakIcon = getChildByName("winStreakIcon") as PopupIconsGroup;
         this._winStreakIcon.init(param1,this.totalPopupIcons);
         this._expertIcon = getChildByName("expertIcon") as PopupIconsGroup;
         this._expertIcon.init(param1,this.totalPopupIcons);
         this._dailyIcon = getChildByName("dailyIcon") as PopupIconsGroup;
         this._dailyIcon.init(param1,this.totalPopupIcons);
         this._underdogIcon = getChildByName("underdogIcon") as PopupIconsGroup;
         this._underdogIcon.init(param1,this.totalPopupIcons);
         this.previousBonus = this._kills;
         if(param3)
         {
            this.bonusesVector.push(new BonusMovieAndIcon(this._kills,this.killIcon,param3.getAward(BattleRenownAwardType.KILLS)));
            this.bonusesVector.push(new BonusMovieAndIcon(this._winBonus,this.winIcon,param3.getAward(BattleRenownAwardType.WIN)));
            this.bonusesVector.push(new BonusMovieAndIcon(this._winStreak,this._winStreakIcon,param3.getAward(BattleRenownAwardType.STREAK)));
            this.bonusesVector.push(new BonusMovieAndIcon(this._expertBonus,this._expertIcon,param3.getAward(BattleRenownAwardType.EXPERT)));
            this.bonusesVector.push(new BonusMovieAndIcon(this._dailyStreak,this._dailyIcon,param3.getAward(BattleRenownAwardType.DAILY)));
            this.bonusesVector.push(new BonusMovieAndIcon(this._underdogBonus,this._underdogIcon,param3.getAward(BattleRenownAwardType.UNDERDOG)));
         }
      }
      
      public function cleanup() : void
      {
         this.bonusesVector = null;
         this._underdogIcon.cleanup();
         this._underdogIcon = null;
         this._dailyIcon.cleanup();
         this._dailyIcon = null;
         this._expertIcon.cleanup();
         this._expertIcon = null;
         this._winStreakIcon.cleanup();
         this._winStreakIcon = null;
         this.winIcon.cleanup();
         this.winIcon = null;
         this.killIcon.cleanup();
         this.killIcon = null;
         this._underdogBonus.cleanupGuiBase();
         this._dailyStreak.cleanupGuiBase();
         this._expertBonus.cleanupGuiBase();
         this._winStreak.cleanupGuiBase();
         this._winBonus.cleanupGuiBase();
         this._kills.cleanupGuiBase();
         this.listener = null;
         this.battleRewardData = null;
         super.cleanupGuiBase();
      }
      
      public function displayAndPlay() : void
      {
         this._winBonus.visible = this.winIcon.visible = false;
         this._winStreak.visible = this._winStreakIcon.visible = false;
         this._expertBonus.visible = this._expertIcon.visible = false;
         this._dailyStreak.visible = this._dailyIcon.visible = false;
         this._underdogBonus.visible = this._underdogIcon.visible = false;
         y = this.killsAndBonusesStartingY - this.height;
         this.visible = true;
         TweenMax.to(this,1,{
            "y":this.killsAndBonusesStartingY,
            "onComplete":this.playBonuses
         });
      }
      
      private function playBonuses() : void
      {
         if(this.bonusesIndex >= this.bonusesVector.length)
         {
            TweenMax.to(this,0.5,{"onComplete":this.hide});
            return;
         }
         this.nextBonusAnimate(this.bonusesVector[this.bonusesIndex].movieClip,this.bonusesVector[this.bonusesIndex].icon);
         this.previousBonus = this.bonusesVector[this.bonusesIndex].movieClip;
         ++this.bonusesIndex;
      }
      
      private function nextBonusAnimate(param1:MovieClip, param2:PopupIconsGroup) : void
      {
         param1.visible = true;
         if(param1.y != this.previousBonus.y)
         {
            context.playSound("ui_stats_hi");
            param1.y = this.previousBonus.y;
            param2.y = param1.y + this.bonusYSpacing;
            TweenMax.to(param1,0.4,{
               "y":param1.y + this.bonusYSpacing,
               "onComplete":this.nextBonusDoneAnimating,
               "onCompleteParams":[param2]
            });
         }
         else
         {
            TweenMax.to(param1,0.4,{
               "y":param1.y,
               "onComplete":this.nextBonusDoneAnimating,
               "onCompleteParams":[param2]
            });
         }
      }
      
      private function hide() : void
      {
         TweenMax.to(this,0.5,{
            "delay":1.5,
            "y":this.killsAndBonusesStartingY + this.height * 1.3,
            "onComplete":this.listener.onKillsAndbonusesComplete
         });
      }
      
      private function nextBonusDoneAnimating(param1:PopupIconsGroup) : void
      {
         param1.visible = true;
         param1.playAndResetPopups(this.playBonuses);
      }
   }
}

import game.gui.PopupIconsGroup;
import game.gui.battle.GuiMatchResolutionSpear;

class BonusMovieAndIcon
{
    
   
   private var _movieClip:GuiMatchResolutionSpear;
   
   private var _icon:PopupIconsGroup;
   
   private var _renown:int;
   
   private const framesToPlayNext:int = 5;
   
   public function BonusMovieAndIcon(param1:GuiMatchResolutionSpear, param2:PopupIconsGroup, param3:int)
   {
      super();
      this._movieClip = param1;
      this._icon = param2;
      this._renown = param3;
      this._icon.setup(this._renown,this.framesToPlayNext,6);
   }
   
   public function get renown() : int
   {
      return this._renown;
   }
   
   public function get icon() : PopupIconsGroup
   {
      return this._icon;
   }
   
   public function get movieClip() : GuiMatchResolutionSpear
   {
      return this._movieClip;
   }
}
