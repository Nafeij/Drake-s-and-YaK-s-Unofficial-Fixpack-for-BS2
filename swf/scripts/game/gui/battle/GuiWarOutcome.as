package game.gui.battle
{
   import com.greensock.TweenMax;
   import engine.battle.fsm.BattleRenownAwardType;
   import engine.battle.fsm.BattleRewardData;
   import engine.gui.GuiUtil;
   import engine.saga.WarOutcome;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.PopupIconsGroup;
   
   public class GuiWarOutcome extends GuiBase
   {
       
      
      public var _kills:GuiMatchResolutionSpear;
      
      public var _winBonus:GuiMatchResolutionSpear;
      
      public var _casualtiesVarl:GuiMatchResolutionSpear;
      
      public var _casualtiesFighters:GuiMatchResolutionSpear;
      
      public var _casualtiesPeasants:GuiMatchResolutionSpear;
      
      public var _injuries:GuiMatchResolutionSpear;
      
      public var _killIcon:PopupIconsGroup;
      
      public var _winIcon:PopupIconsGroup;
      
      public var listener:IGuiMatchResolutionListener;
      
      public var killsAndBonusesStartingY:Number;
      
      public var battleRewardData:BattleRewardData;
      
      public var bonusYSpacing:Number;
      
      public var bonusesVector:Vector.<BonusMovieAndIcon>;
      
      public var bonusesIndex:int;
      
      public var previousBonus:MovieClip;
      
      public const totalPopupIcons:int = 6;
      
      private var outcome:WarOutcome;
      
      private var waiting:Boolean;
      
      private var delay_end:Number = 0.5;
      
      private var delay_next:Number = 0.5;
      
      private var hiding:Boolean;
      
      private var clickStage:Stage;
      
      public function GuiWarOutcome()
      {
         this.bonusesVector = new Vector.<BonusMovieAndIcon>();
         super();
         this._kills = getChildByName("kills") as GuiMatchResolutionSpear;
         this._winBonus = getChildByName("winBonus") as GuiMatchResolutionSpear;
         this._casualtiesVarl = getChildByName("casualtiesVarl") as GuiMatchResolutionSpear;
         this._casualtiesFighters = getChildByName("casualtiesFighters") as GuiMatchResolutionSpear;
         this._casualtiesPeasants = getChildByName("casualtiesPeasants") as GuiMatchResolutionSpear;
         this._injuries = getChildByName("injuries") as GuiMatchResolutionSpear;
         this._winIcon = getChildByName("winIcon") as PopupIconsGroup;
      }
      
      public function init(param1:IGuiContext, param2:IGuiMatchResolutionListener, param3:WarOutcome, param4:BattleRewardData) : void
      {
         this.outcome = param3;
         this.battleRewardData = param4;
         this.listener = param2;
         super.initGuiBase(param1);
         this.visible = false;
         this.listener = param2;
         if(!param3)
         {
            return;
         }
         this._kills.init(param1,"mr_bonus_kills");
         this._winBonus.init(param1,"mr_bonus_win");
         this._casualtiesVarl.init(param1,"mr_varl_lost");
         this._casualtiesFighters.init(param1,"mr_fighters_lost");
         this._casualtiesPeasants.init(param1,"mr_clansmen_lost");
         this._injuries.init(param1,"mr_injuries");
         this.killsAndBonusesStartingY = y;
         var _loc5_:MovieClip = getChildByName("skullPopups") as MovieClip;
         this._killIcon = GuiUtil.performCensor(_loc5_,_context.censorId,logger) as PopupIconsGroup;
         this._killIcon.init(param1,18);
         this.bonusYSpacing = this._winBonus.y - this._kills.y;
         this._winIcon.init(param1,this.totalPopupIcons);
         this.previousBonus = this._kills;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param4)
         {
            _loc6_ = param4.getAward(BattleRenownAwardType.KILLS);
            _loc7_ = param4.getAward(BattleRenownAwardType.WIN);
         }
         this.bonusesVector.push(new BonusMovieAndIcon(this._kills,this._killIcon,_loc6_));
         this.bonusesVector.push(new BonusMovieAndIcon(this._winBonus,this._winIcon,_loc7_));
         this.bonusesVector.push(new BonusMovieAndIcon(this._casualtiesPeasants,null,param3.casualties_peasants));
         this.bonusesVector.push(new BonusMovieAndIcon(this._casualtiesFighters,null,param3.casualties_fighters));
         this.bonusesVector.push(new BonusMovieAndIcon(this._casualtiesVarl,null,param3.casualties_varl));
         this.bonusesVector.push(new BonusMovieAndIcon(this._injuries,null,param3.injuries.length));
      }
      
      public function cleanup() : void
      {
         TweenMax.killTweensOf(this);
         TweenMax.killDelayedCallsTo(this.playBonuses);
         if(this.clickStage)
         {
            this.clickStage.removeEventListener(MouseEvent.CLICK,this.clickHandler);
            this.clickStage = null;
         }
         this.bonusesVector = null;
         this._winIcon.cleanupGuiBase();
         if(this._killIcon)
         {
            this._killIcon.cleanupGuiBase();
         }
         this._injuries.cleanupGuiBase();
         this._casualtiesPeasants.cleanupGuiBase();
         this._casualtiesFighters.cleanupGuiBase();
         this._casualtiesVarl.cleanupGuiBase();
         this._winBonus.cleanupGuiBase();
         this._kills.cleanupGuiBase();
         this.listener = null;
         this.battleRewardData = null;
         super.cleanupGuiBase();
      }
      
      public function displayAndPlay() : void
      {
         this.clickStage = stage;
         if(this.clickStage)
         {
            this.clickStage.addEventListener(MouseEvent.CLICK,this.clickHandler);
         }
         this._winBonus.visible = this._winIcon.visible = false;
         this._casualtiesPeasants.visible = false;
         this._casualtiesFighters.visible = false;
         this._casualtiesVarl.visible = false;
         this._injuries.visible = false;
         y = this.killsAndBonusesStartingY - this.height;
         this.visible = true;
         TweenMax.to(this,1,{
            "y":this.killsAndBonusesStartingY,
            "onComplete":this.playBonuses
         });
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         if(this.waiting)
         {
            this.hide();
         }
      }
      
      private function playBonuses() : void
      {
         if(!this.bonusesVector || this.bonusesIndex >= this.bonusesVector.length)
         {
            this.waiting = true;
            TweenMax.to(this,this.delay_end,{"onComplete":this.hide});
            return;
         }
         this.nextBonusAnimate(this.bonusesVector[this.bonusesIndex].movieClip,this.bonusesVector[this.bonusesIndex].icon);
         this.previousBonus = this.bonusesVector[this.bonusesIndex].movieClip;
         ++this.bonusesIndex;
      }
      
      private function nextBonusAnimate(param1:GuiMatchResolutionSpear, param2:PopupIconsGroup) : void
      {
         param1.visible = true;
         if(param1.y != this.previousBonus.y)
         {
            context.playSound("ui_stats_hi");
            param1.y = this.previousBonus.y;
            if(param2)
            {
               param2.y = param1.y + this.bonusYSpacing;
            }
            TweenMax.to(param1,0.2,{
               "y":param1.y + this.bonusYSpacing,
               "onComplete":this.nextBonusDoneAnimating,
               "onCompleteParams":[param1,param2]
            });
         }
         else
         {
            TweenMax.to(param1,0.2,{
               "y":param1.y,
               "onComplete":this.nextBonusDoneAnimating,
               "onCompleteParams":[param1,param2]
            });
         }
      }
      
      private function hide() : void
      {
         if(this.hiding || !this.waiting)
         {
            return;
         }
         if(this.clickStage)
         {
            this.clickStage.removeEventListener(MouseEvent.CLICK,this.clickHandler);
         }
         if(!this.listener)
         {
            return;
         }
         this.waiting = false;
         this.hiding = true;
         TweenMax.killTweensOf(this);
         TweenMax.killDelayedCallsTo(this.playBonuses);
         TweenMax.to(this,0.5,{
            "y":this.killsAndBonusesStartingY + 800,
            "onComplete":this.listener.onKillsAndbonusesComplete
         });
      }
      
      private function nextBonusDoneAnimating(param1:GuiMatchResolutionSpear, param2:PopupIconsGroup) : void
      {
         if(param2)
         {
            param2.visible = true;
            param2.playAndResetPopups(this.playBonuses);
         }
         else
         {
            TweenMax.delayedCall(this.delay_next,this.playBonuses);
         }
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
      var _loc4_:Number = NaN;
      super();
      this._movieClip = param1;
      this._icon = param2;
      this._renown = param3;
      if(this._icon)
      {
         this._icon.setup(this._renown,this.framesToPlayNext,6);
         if(this._movieClip)
         {
            _loc4_ = this._icon.leftBoundary + this._icon.x - 10;
            this._movieClip.imposeRightBoundary(_loc4_ - Number(this._movieClip.x));
         }
      }
      else
      {
         this._movieClip.setTextValue(this._renown.toString());
      }
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
