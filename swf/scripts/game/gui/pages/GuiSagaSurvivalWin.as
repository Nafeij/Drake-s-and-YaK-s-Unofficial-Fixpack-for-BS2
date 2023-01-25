package game.gui.pages
{
   import com.greensock.TweenMax;
   import engine.achievement.AchievementDef;
   import engine.achievement.AchievementListDef;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.util.AppInfo;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGpNavButtonGlowy;
   import engine.saga.Saga;
   import engine.saga.SagaSurvivalDef_Leaderboard;
   import engine.saga.SagaSurvivalDef_Leaderboards;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiSagaSurvivalWin;
   import game.gui.page.IGuiSagaSurvivalWinListener;
   
   public class GuiSagaSurvivalWin extends GuiBase implements IGuiSagaSurvivalWin
   {
       
      
      public var _stars:MovieClip;
      
      public var _score_total:TextField;
      
      public var _rank:TextField;
      
      public var _rank_delta:TextField;
      
      public var _trios:Dictionary;
      
      public var _trioList:Vector.<GuiSagaSurvivalWin_Trio>;
      
      public var _trioQueue:Vector.<GuiSagaSurvivalWin_Trio>;
      
      public var saga:Saga;
      
      public var _$ss_win_total_score:TextField;
      
      public var _$ss_win_lb_rank:TextField;
      
      public var _$ss_win_acv:TextField;
      
      public var _$ss_win_score:TextField;
      
      public var _$ss_win_victory:TextField;
      
      public var _$ss_win_defeat:TextField;
      
      public var _acv:GuiAcvPlaceholderHelper;
      
      public var unlockedAcvIds:Array;
      
      private var _tooltip:MovieClip;
      
      private var _tooltip_text:TextField;
      
      public var _button$close:ButtonWithIndex;
      
      private var _buttonCloseY:int;
      
      private var _gp:GuiSagaSurvivalWin_gp;
      
      private var cmd_close:Cmd;
      
      private var _victory:Boolean;
      
      private var _achievementIndex:int;
      
      private var _display_total:int;
      
      private var lb_rank_prev:int;
      
      private var lb_rank_next:int;
      
      private var _tooltipHandle:int;
      
      private var _speedThrough:Boolean;
      
      public function GuiSagaSurvivalWin()
      {
         this._trios = new Dictionary();
         this._trioList = new Vector.<GuiSagaSurvivalWin_Trio>();
         this._trioQueue = new Vector.<GuiSagaSurvivalWin_Trio>();
         this.unlockedAcvIds = [];
         this._gp = new GuiSagaSurvivalWin_gp();
         this.cmd_close = new Cmd("cmd_survival_win_close",this.cmdfunc_close);
         super();
         this._score_total = requireGuiChild("score_total") as TextField;
         this._rank = requireGuiChild("rank") as TextField;
         this._rank_delta = requireGuiChild("rank_delta") as TextField;
         this._stars = requireGuiChild("stars") as MovieClip;
         this._tooltip = requireGuiChild("tooltip") as MovieClip;
         this._tooltip.mouseChildren = this._tooltip.mouseEnabled = false;
         this._tooltip_text = this._tooltip.getChildByName("text") as TextField;
         this._tooltip.visible = false;
         this._$ss_win_total_score = requireGuiChild("$ss_win_total_score") as TextField;
         this._$ss_win_lb_rank = requireGuiChild("$ss_win_lb_rank") as TextField;
         this._$ss_win_acv = requireGuiChild("$ss_win_acv") as TextField;
         this._$ss_win_score = requireGuiChild("$ss_win_score") as TextField;
         this._$ss_win_victory = requireGuiChild("$ss_win_victory") as TextField;
         this._$ss_win_defeat = requireGuiChild("$ss_win_defeat") as TextField;
         this._button$close = requireGuiChild("button$close") as ButtonWithIndex;
         this._buttonCloseY = this._button$close.y;
         this._$ss_win_victory.visible = false;
         this._$ss_win_defeat.visible = false;
         this._$ss_win_total_score.visible = false;
         this._$ss_win_lb_rank.visible = false;
         this._$ss_win_acv.visible = false;
         this._$ss_win_score.visible = false;
         this._score_total.visible = false;
         this._rank.visible = false;
         this._rank_delta.visible = false;
         super.visible = false;
      }
      
      public function randomDriftStars() : void
      {
      }
      
      public function get display_total() : int
      {
         return this._display_total;
      }
      
      public function set display_total(param1:int) : void
      {
         if(this._display_total == param1)
         {
            return;
         }
         this._display_total = param1;
         this._score_total.text = param1.toString();
         _context.playSound("ui_stats_glisten");
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1 && Boolean(_context))
         {
            this.startTheShow();
         }
         if(this._gp)
         {
            this._gp.visible = param1;
         }
      }
      
      private function startTheShow() : void
      {
         this.saga = _context.saga;
         this._victory = this.saga.survivalProgress >= this.saga.survivalTotal;
         this._$ss_win_victory.visible = false;
         this._$ss_win_defeat.visible = false;
         this._button$close.visible = false;
         this.randomDriftStars();
         this.showValue("kills");
         this.showValue("deaths");
         this.showValue("time");
         this.showValue("reloads");
         this.showValue("recruits");
         this.showValue("damage_done");
         this.showValue("damage_taken");
         TweenMax.delayedCall(this._tt(1),this.startTitle);
      }
      
      public function _tt(param1:Number) : Number
      {
         return this._speedThrough ? 0 : param1;
      }
      
      private function startTitle() : void
      {
         var _loc1_:TextField = null;
         if(this._victory)
         {
            _loc1_ = this._$ss_win_victory;
         }
         else
         {
            _loc1_ = this._$ss_win_defeat;
         }
         _loc1_.visible = true;
         _loc1_.x = -2731 / 2;
         _loc1_.alpha = 0;
         TweenMax.to(_loc1_,this._tt(1),{
            "x":0,
            "alpha":1,
            "onComplete":this.startAchievements
         });
      }
      
      private function startAchievements() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._achievementIndex >= this.unlockedAcvIds.length)
         {
            this.startAnimationg();
            return;
         }
         this._$ss_win_acv.visible = true;
         var _loc1_:String = String(this.unlockedAcvIds[this._achievementIndex]);
         _loc2_ = this._acv.addAchievement(_loc1_);
         if(_loc2_)
         {
            _loc3_ = _loc2_.x;
            _loc4_ = _loc2_.y;
            _loc2_.x -= 64;
            _loc2_.y -= 64;
            _loc2_.scaleX = _loc2_.scaleY = 2;
            TweenMax.to(_loc2_,this._tt(0.25),{
               "scaleX":1,
               "scaleY":1,
               "x":_loc3_,
               "y":_loc4_
            });
         }
         _context.playSound("ui_stats_hi");
         ++this._achievementIndex;
         TweenMax.delayedCall(this._tt(0.5),this.startAchievements);
      }
      
      private function showValue(param1:String) : void
      {
         if(!this.saga)
         {
            return;
         }
         var _loc2_:int = this.saga.getVarInt("survival_win_" + param1 + "_num");
         var _loc3_:int = this.saga.getVarInt("survival_win_" + param1 + "_score");
         var _loc4_:GuiSagaSurvivalWin_Trio = this._trios[param1];
         this._trioQueue.push(_loc4_);
         this._trioList.push(_loc4_);
         _loc4_.showValue(_loc2_,_loc3_);
      }
      
      public function startAnimationg() : void
      {
         var _loc1_:GuiSagaSurvivalWin_Trio = this._trioQueue[0];
         _loc1_.startAnimating();
      }
      
      public function handleTrioComplete(param1:GuiSagaSurvivalWin_Trio) : void
      {
         _context.logger.info("completed " + param1.name);
         this._trioQueue.shift();
         if(this._trioQueue.length == 0)
         {
            TweenMax.delayedCall(this._tt(0.5),this.startAnimatingTotal);
            return;
         }
         TweenMax.delayedCall(this._tt(0.25),this.startAnimationg);
      }
      
      public function startAnimatingTotal() : void
      {
         var _loc1_:int = _context.saga.getVarInt("survival_win_score");
         this._$ss_win_total_score.visible = true;
         this._score_total.visible = true;
         this._display_total = 0;
         this._score_total.text = this._display_total.toString();
         TweenMax.to(this,this._tt(3),{
            "display_total":_loc1_,
            "onComplete":this.totalTweenCompleteHandler
         });
      }
      
      private function totalTweenCompleteHandler() : void
      {
         _context.playSound("ui_stats_total");
         _context.playSound("ui_victory");
         this._gp.readyToNav = true;
         TweenMax.delayedCall(this._tt(1),this.startAnimatingLeaderboard);
      }
      
      public function startAnimatingLeaderboard() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc1_:SagaSurvivalDef_Leaderboards = this.saga.survival.def.leaderboards;
         var _loc2_:int = this.saga.difficulty;
         var _loc3_:int = _loc1_.getCategoryForDifficulty(_loc2_);
         var _loc4_:SagaSurvivalDef_Leaderboard = _loc1_.getLeaderboardByVarname(_loc3_,"survival_win_score",true);
         if(!_loc4_)
         {
            TweenMax.to(this._rank_delta,this._tt(0.25),{
               "scaleX":1,
               "scaleY":1,
               "x":_loc5_,
               "y":_loc6_,
               "onComplete":this.leaderboardDeltaTweenCompleteHandler
            });
            return;
         }
         this.lb_rank_next = this.saga.getVarInt(_loc4_.name + "_rank_next");
         this.lb_rank_prev = this.saga.getVarInt(_loc4_.name + "_rank_prev");
         if(!this.lb_rank_next)
         {
            this.leaderboardDeltaTweenCompleteHandler();
            return;
         }
         this._$ss_win_lb_rank.visible = true;
         this._rank.visible = true;
         this._rank.text = this.lb_rank_next.toString();
         _loc5_ = this._rank.x;
         _loc6_ = this._rank.y;
         this._rank.x -= 100;
         this._rank.y -= 35;
         this._rank.scaleX = this._rank.scaleY = 2;
         _context.playSound("ui_count_swords");
         TweenMax.to(this._rank,this._tt(0.25),{
            "scaleX":1,
            "scaleY":1,
            "x":_loc5_,
            "y":_loc6_,
            "onComplete":this.leaderboardTweenCompleteHandler
         });
      }
      
      private function leaderboardTweenCompleteHandler() : void
      {
         TweenMax.delayedCall(this._tt(0.5),this.startAnimatingLeaderboardDelta);
      }
      
      public function startAnimatingLeaderboardDelta() : void
      {
         if(!this.lb_rank_prev)
         {
            this.leaderboardDeltaTweenCompleteHandler();
            return;
         }
         var _loc1_:int = this.lb_rank_next - this.lb_rank_prev;
         this._rank_delta.visible = true;
         this._rank_delta.text = "( " + StringUtil.numberWithSign(_loc1_,0) + " )";
         _context.playSound("ui_stats_hi");
         var _loc2_:Number = this._rank_delta.x;
         var _loc3_:Number = this._rank_delta.y;
         this._rank_delta.x -= 100;
         this._rank_delta.y -= 35;
         this._rank_delta.scaleX = this._rank_delta.scaleY = 2;
         TweenMax.to(this._rank_delta,this._tt(0.25),{
            "scaleX":1,
            "scaleY":1,
            "x":_loc2_,
            "y":_loc3_,
            "onComplete":this.leaderboardDeltaTweenCompleteHandler
         });
      }
      
      private function leaderboardDeltaTweenCompleteHandler() : void
      {
         this._button$close.visible = true;
         this._button$close.y = 1536;
         TweenMax.to(this._button$close,this._tt(0.5),{
            "y":this._buttonCloseY,
            "onComplete":this.handleButtonCloseTween
         });
         TweenMax.delayedCall(5,this.finish);
      }
      
      public function handleButtonCloseTween() : void
      {
         this._gp.showClose();
      }
      
      private function finish() : void
      {
         if(!_context)
         {
            return;
         }
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.MUSIC_ONESHOT;
         if(this._victory)
         {
            _loc1_.id = "saga2/music/ch14/14mC1-V";
         }
         else
         {
            _loc1_.id = "saga2/music/battle/LOSE";
         }
         this.saga.executeActionDef(_loc1_,null,null);
      }
      
      private function _makeTrio(param1:String) : void
      {
         var _loc2_:TextField = requireGuiChild("$ss_win_" + param1) as TextField;
         var _loc3_:TextField = requireGuiChild("num_" + param1) as TextField;
         var _loc4_:TextField = requireGuiChild("score_" + param1) as TextField;
         var _loc5_:MovieClip = requireGuiChild("r_" + param1) as MovieClip;
         var _loc6_:GuiGpNavButtonGlowy = _loc5_ as GuiGpNavButtonGlowy;
         var _loc7_:GuiSagaSurvivalWin_Trio = new GuiSagaSurvivalWin_Trio(param1,this,_loc2_,_loc3_,_loc4_,_loc6_);
         this._trios[param1] = _loc7_;
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaSurvivalWinListener, param3:Saga, param4:AppInfo) : void
      {
         var _loc6_:AchievementDef = null;
         super.initGuiBase(param1);
         param3 = _context.saga;
         this._button$close.guiButtonContext = param1;
         this._button$close.setDownFunction(this.buttonCloseHandler);
         this._acv = new GuiAcvPlaceholderHelper(this,_context,true);
         this._acv.addEventListener(GuiAcvPlaceholderHelper.EVENT_TOOLTIP,this.acvTooltipHandler);
         var _loc5_:AchievementListDef = param3.def.achievements;
         for each(_loc6_ in _loc5_.defs)
         {
            if(param3.getVarBool(_loc6_.id + "_unlk"))
            {
               this.unlockedAcvIds.push(_loc6_.id);
            }
         }
         this._makeTrio("kills");
         this._makeTrio("deaths");
         this._makeTrio("time");
         this._makeTrio("reloads");
         this._makeTrio("recruits");
         this._makeTrio("damage_done");
         this._makeTrio("damage_taken");
         this._gp.init(this);
      }
      
      private function acvTooltipHandler(param1:Event) : void
      {
         this.hideTooltip(this._tooltipHandle);
      }
      
      private function buttonCloseHandler(param1:*) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiSagaSurvivalWin_Trio = null;
         if(this._gp)
         {
            this._gp.cleanup();
            this._gp = null;
         }
         TweenMax.killTweensOf(this);
         TweenMax.killTweensOf(this._$ss_win_victory);
         TweenMax.killTweensOf(this._$ss_win_defeat);
         TweenMax.killTweensOf(this._rank);
         TweenMax.killTweensOf(this._rank_delta);
         TweenMax.killDelayedCallsTo(this.finish);
         TweenMax.killDelayedCallsTo(this.startAchievements);
         TweenMax.killDelayedCallsTo(this.startAnimatingTotal);
         TweenMax.killDelayedCallsTo(this.startAnimationg);
         TweenMax.killDelayedCallsTo(this.startAnimatingLeaderboard);
         TweenMax.killDelayedCallsTo(this.startAnimatingLeaderboardDelta);
         for each(_loc1_ in this._trios)
         {
            _loc1_.cleanup();
         }
         this._trios = null;
         this._stars = null;
         this._score_total = null;
         this._rank = null;
         this._rank_delta = null;
         this._trioQueue = null;
         this.saga = null;
         this._$ss_win_acv = null;
         this._$ss_win_lb_rank = null;
         this._$ss_win_acv = null;
         this._$ss_win_score = null;
         this._acv.cleanup();
         this._acv = null;
         this.unlockedAcvIds = null;
         super.cleanupGuiBase();
      }
      
      public function showScoreLabel() : void
      {
         this._$ss_win_score.visible = true;
      }
      
      public function unhoverRibbon() : void
      {
         var _loc1_:GuiSagaSurvivalWin_Trio = null;
         this.hideTooltip(this._tooltipHandle);
         for each(_loc1_ in this._trios)
         {
            _loc1_.hovering = false;
            _loc1_.ribbon.setHovering(false);
         }
      }
      
      public function showTooltip(param1:String, param2:int, param3:int) : int
      {
         this._tooltip.visible = true;
         this._tooltip_text.htmlText = param1;
         _context.locale.fixTextFieldFormat(this._tooltip_text);
         this._tooltip.x = param2;
         this._tooltip.y = param3;
         return ++this._tooltipHandle;
      }
      
      public function hideTooltip(param1:int) : void
      {
         if(param1 != this._tooltipHandle)
         {
            return;
         }
         this._tooltip.visible = false;
      }
      
      public function speedThroughResults() : Boolean
      {
         var _loc1_:* = !this._speedThrough;
         if(_loc1_)
         {
            this._speedThrough = true;
            if(this._trioQueue.length)
            {
               this._trioQueue[0].speedThroughResults();
            }
            return true;
         }
         return false;
      }
      
      private function cmdfunc_close(param1:CmdExec) : void
      {
         if(this.speedThroughResults())
         {
            return;
         }
      }
   }
}
