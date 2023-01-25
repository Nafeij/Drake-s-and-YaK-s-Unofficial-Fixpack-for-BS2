package game.gui.pages
{
   import engine.core.locale.LocaleCategory;
   import engine.core.util.AppInfo;
   import engine.gui.GuiContextEvent;
   import engine.gui.IGuiButton;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.saga.SagaLeaderboards;
   import engine.saga.SagaLeaderboardsEvent;
   import engine.saga.SagaSurvival;
   import engine.saga.SagaSurvivalEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.ActivitySpinner;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiChitsGroup;
   import game.gui.GuiLeaderboardRow;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   import game.gui.page.IGuiSagaSurvivalLeaderboards;
   import game.gui.page.IGuiSagaSurvivalLeaderboardsListener;
   import tbs.srv.data.LeaderboardData;
   import tbs.srv.data.LeaderboardEntryData;
   
   public class GuiSagaSurvivalLeaderboards extends GuiBase implements IGuiSagaSurvivalLeaderboards
   {
       
      
      public var listener:IGuiSagaSurvivalLeaderboardsListener;
      
      private var appInfo:AppInfo;
      
      private var saga:Saga;
      
      public var _button_close:ButtonWithIndex;
      
      public var _button_$ss_lb_global:ButtonWithIndex;
      
      public var _button_$ss_lb_friends:ButtonWithIndex;
      
      public var _mc_texts_rank:MovieClip;
      
      public var _mc_texts_score:MovieClip;
      
      public var _mc_texts_name:MovieClip;
      
      public var _texts_rank:Vector.<TextField>;
      
      public var _texts_score:Vector.<TextField>;
      
      public var _texts_name:Vector.<TextField>;
      
      public var _button_board_next:ButtonWithIndex;
      
      public var _button_board_prev:ButtonWithIndex;
      
      public var _button_diff$normal:ButtonWithIndex;
      
      public var _button_diff$hard:ButtonWithIndex;
      
      public var _text_board_name:TextField;
      
      public var _chits_group:GuiChitsGroup;
      
      public var _text_info_desc:TextField;
      
      public var _text_board_filter:TextField;
      
      private var _category:int = 1;
      
      private var _global:Boolean = true;
      
      private var color_name_leader:int = 16767921;
      
      private var color_name:int = 14742783;
      
      private var color_name_self:int = 6343167;
      
      public var rows:Vector.<GuiLeaderboardRow>;
      
      public var _gp:GuiSagaSurvivalLeaderboards_gp;
      
      private var networkErrorDialog:IGuiDialog;
      
      private var _$ss_lb_rank:TextField;
      
      private var _$ss_lb_score:TextField;
      
      private var _$ss_lb_name:TextField;
      
      private var _$ss_lb_title:TextField;
      
      private var activitySpinner:ActivitySpinner;
      
      private var _boards:Vector.<LeaderboardData>;
      
      private var _dirtyGui:Boolean = true;
      
      private var _currentLeaderboard:LeaderboardData;
      
      private var _waitingOnData:Boolean;
      
      public function GuiSagaSurvivalLeaderboards()
      {
         var _loc2_:GuiLeaderboardRow = null;
         this._texts_rank = new Vector.<TextField>();
         this._texts_score = new Vector.<TextField>();
         this._texts_name = new Vector.<TextField>();
         this.rows = new Vector.<GuiLeaderboardRow>();
         this._gp = new GuiSagaSurvivalLeaderboards_gp();
         this._boards = new Vector.<LeaderboardData>();
         super();
         super.visible = false;
         this._button_$ss_lb_global = requireGuiChild("button_$ss_lb_global") as ButtonWithIndex;
         this._button_$ss_lb_friends = requireGuiChild("button_$ss_lb_friends") as ButtonWithIndex;
         this._mc_texts_rank = requireGuiChild("mc_texts_rank") as MovieClip;
         this._mc_texts_score = requireGuiChild("mc_texts_score") as MovieClip;
         this._mc_texts_name = requireGuiChild("mc_texts_name") as MovieClip;
         this._button_board_next = requireGuiChild("button_board_next") as ButtonWithIndex;
         this._button_board_prev = requireGuiChild("button_board_prev") as ButtonWithIndex;
         this._button_diff$normal = requireGuiChild("button_diff$normal") as ButtonWithIndex;
         this._button_diff$hard = requireGuiChild("button_diff$hard") as ButtonWithIndex;
         this._$ss_lb_rank = requireGuiChild("$ss_lb_rank") as TextField;
         this._$ss_lb_score = requireGuiChild("$ss_lb_score") as TextField;
         this._$ss_lb_name = requireGuiChild("$ss_lb_name") as TextField;
         this._$ss_lb_title = requireGuiChild("$ss_lb_title") as TextField;
         this._button_diff$normal.isToggle = true;
         this._button_diff$normal.canToggleUp = false;
         this._button_diff$normal.index = 1;
         this._button_diff$hard.isToggle = true;
         this._button_diff$hard.canToggleUp = false;
         this._button_diff$hard.index = 2;
         registerScalableTextfieldAlign(this._$ss_lb_rank);
         registerScalableTextfieldAlign(this._$ss_lb_score);
         registerScalableTextfieldAlign(this._$ss_lb_name);
         this._text_board_name = requireGuiChild("text_board_name") as TextField;
         this._text_board_filter = requireGuiChild("text_board_filter") as TextField;
         this._chits_group = requireGuiChild("chits_group") as GuiChitsGroup;
         this._text_info_desc = requireGuiChild("text_info_desc") as TextField;
         var _loc1_:int = 0;
         while(_loc1_ < this._mc_texts_score.numChildren)
         {
            if(this._mc_texts_rank.numChildren <= _loc1_ || this._mc_texts_name.numChildren <= _loc1_)
            {
               break;
            }
            _loc2_ = new GuiLeaderboardRow(this._mc_texts_rank.getChildAt(_loc1_) as TextField,this._mc_texts_score.getChildAt(_loc1_) as TextField,this._mc_texts_name.getChildAt(_loc1_) as TextField);
            this._mc_texts_name.parent.addChild(_loc2_);
            this.rows.push(_loc2_);
            _loc1_++;
         }
      }
      
      public function get global() : Boolean
      {
         return this._global;
      }
      
      public function set global(param1:Boolean) : void
      {
         if(this._global == param1)
         {
            return;
         }
         this._global = param1;
         this._updateBoards();
      }
      
      public function set category(param1:int) : void
      {
         if(this._category == param1)
         {
            return;
         }
         this._category = param1;
         this._updateBoards();
      }
      
      public function get difficulty() : int
      {
         return this._button_diff$normal.toggled ? 2 : 3;
      }
      
      private function updateDifficultyStates() : void
      {
         this._button_diff$normal.toggled = this._category == 1;
         this._button_diff$hard.toggled = this._category == 2;
      }
      
      private function _updateBoards() : void
      {
         var _loc1_:SagaSurvival = !!this.saga ? this.saga.survival : null;
         if(_loc1_)
         {
            if(this._global)
            {
               this._boards = _loc1_.leaderboards_global[this._category];
            }
            else
            {
               this._boards = _loc1_.leaderboards_friends[this._category];
            }
         }
         this._chits_group.numVisibleChits = this._boards.length;
         this.refreshGui();
      }
      
      private function refreshGui() : void
      {
         var _loc10_:TextField = null;
         var _loc11_:TextField = null;
         var _loc12_:TextField = null;
         var _loc15_:LeaderboardEntryData = null;
         var _loc16_:int = 0;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc19_:uint = 0;
         var _loc20_:int = 0;
         if(!this._boards || !this._boards.length)
         {
            logger.error("No boards?");
            return;
         }
         if(!enabled)
         {
            this._dirtyGui = true;
            return;
         }
         this._dirtyGui = false;
         this.updateDifficultyStates();
         this._button_$ss_lb_global.enabled = !this._global;
         this._button_$ss_lb_friends.enabled = this._global;
         var _loc1_:int = this._chits_group.activeChitIndex;
         this._chits_group.activeChitIndex = MathUtil.clampValue(_loc1_,0,this._boards.length - 1);
         var _loc2_:LeaderboardData = this._boards[this._chits_group.activeChitIndex];
         this._currentLeaderboard = _loc2_;
         var _loc3_:SagaSurvival = !!this.saga ? this.saga.survival : null;
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:Vector.<String> = _loc3_.def.leaderboards.getLeaderboardNamesForCategory(this._category);
         var _loc5_:String = _loc4_[this._chits_group.activeChitIndex];
         var _loc6_:int = _loc5_.lastIndexOf("_");
         var _loc7_:String = _loc5_.substring(0,_loc6_);
         this._text_board_name.htmlText = _context.translateCategory(_loc7_,LocaleCategory.LEADERBOARD);
         _context.currentLocale.fixTextFieldFormat(this._text_board_name);
         var _loc8_:String = this._global ? "ss_lb_global" : "ss_lb_friends";
         var _loc9_:String = "ss_lb_scope_" + SagaSurvival.categories[this._category];
         this._text_board_filter.htmlText = _context.translate(_loc8_) + " - " + _context.translate(_loc9_);
         _context.currentLocale.fixTextFieldFormat(this._text_board_filter);
         this._text_info_desc.htmlText = _context.translateCategory(_loc7_ + "_desc",LocaleCategory.LEADERBOARD);
         _context.currentLocale.fixTextFieldFormat(this._text_info_desc);
         var _loc13_:int = !!_loc2_ ? int(Math.min(_loc2_.entries.length,this.rows.length)) : 0;
         var _loc14_:int = 0;
         while(_loc14_ < _loc13_)
         {
            _loc15_ = _loc2_.entries[_loc14_];
            _loc16_ = _loc15_.value;
            _loc17_ = _loc15_.display_name;
            _loc18_ = _loc15_.account_id;
            _loc19_ = uint(this.color_name);
            _loc20_ = _loc14_ + 1;
            if(_loc20_ == _loc13_)
            {
               if(_loc2_.user_rank > _loc13_)
               {
                  _loc17_ = _loc2_.user_display_name;
                  _loc16_ = _loc2_.user_value;
                  _loc20_ = _loc2_.user_rank;
                  _loc18_ = _loc2_.user_account_id;
                  _loc19_ = uint(this.color_name_self);
               }
            }
            if(_loc2_.entryBelongsToUser(_loc15_))
            {
               _loc19_ = uint(this.color_name_self);
            }
            else if(_loc14_ == 0)
            {
               _loc19_ = uint(this.color_name_leader);
            }
            this.rows[_loc14_].showEntry(_loc20_,_loc19_,_loc17_,_loc16_,_loc18_);
            _loc14_++;
         }
         while(_loc14_ < this.rows.length)
         {
            this.rows[_loc14_].clear();
            _loc14_++;
         }
         this.activitySpinner.visible = visible && enabled && SagaLeaderboards.count_fetch > 0;
         this.refreshGp();
      }
      
      private function boardPrevHandler(param1:IGuiButton) : void
      {
         --this._chits_group.activeChitIndex;
         this.refreshGui();
      }
      
      private function boardNextHandler(param1:IGuiButton) : void
      {
         ++this._chits_group.activeChitIndex;
         this.refreshGui();
      }
      
      private function buttonDifficultyHandler(param1:ButtonWithIndex) : void
      {
         this.category = param1.index;
      }
      
      private function buttonFriendsHandler(param1:IGuiButton) : void
      {
         this.global = false;
      }
      
      private function buttonGlobalHandler(param1:IGuiButton) : void
      {
         this.global = true;
      }
      
      private function _fetchTexts(param1:MovieClip, param2:Vector.<TextField>) : void
      {
         var _loc4_:TextField = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_) as TextField;
            param2.push(_loc4_);
            _loc3_++;
         }
      }
      
      public function cleanup() : void
      {
         this.activitySpinner.release();
         super.cleanupGuiBase();
         this.visible = false;
         this.saga = null;
         this.appInfo = null;
         this.listener = null;
         if(this.networkErrorDialog)
         {
            this.networkErrorDialog.cleanup();
            this.networkErrorDialog = null;
         }
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         if(param1 == super.enabled)
         {
            return;
         }
         super.enabled = param1;
         this.mouseEnabled = this.mouseChildren = param1;
         this._gp.enabled = param1;
         if(!param1)
         {
            removeChild(this._mc_texts_name);
            removeChild(this._mc_texts_rank);
            removeChild(this._mc_texts_score);
            removeChild(this._chits_group);
            removeChild(this._text_info_desc);
            removeChild(this._text_board_filter);
            removeChild(this._text_board_name);
         }
         else
         {
            addChild(this._mc_texts_name);
            addChild(this._mc_texts_rank);
            addChild(this._mc_texts_score);
            addChild(this._chits_group);
            addChild(this._text_info_desc);
            addChild(this._text_board_filter);
            addChild(this._text_board_name);
         }
         this._mc_texts_name.visible = param1;
         this._mc_texts_rank.visible = param1;
         this._mc_texts_score.visible = param1;
         this._chits_group.visible = param1;
         this._text_info_desc.visible = param1;
         this._text_board_filter.visible = param1;
         this._text_board_name.visible = param1;
         this._$ss_lb_rank.visible = param1;
         this._$ss_lb_score.visible = param1;
         this._$ss_lb_name.visible = param1;
         this._$ss_lb_title.visible = param1;
         this._button_$ss_lb_friends.visible = param1;
         this._button_$ss_lb_global.visible = param1;
         this._button_board_next.visible = param1;
         this._button_board_prev.visible = param1;
         this._button_diff$hard.visible = param1;
         this._button_diff$normal.visible = param1;
         if(param1)
         {
            if(Boolean(this.saga) && Boolean(this.saga.survival))
            {
               this.saga.survival.requestAllSurvivalLeaderboards();
            }
            SagaSurvival.dispatcher.addEventListener(SagaSurvivalEvent.CHANGED,this.survivalLeaderboardChangedHandler);
            SagaSurvival.dispatcher.addEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.survivalLeaderboardErrorHandler);
         }
         else
         {
            SagaSurvival.dispatcher.removeEventListener(SagaSurvivalEvent.CHANGED,this.survivalLeaderboardChangedHandler);
            SagaSurvival.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.survivalLeaderboardErrorHandler);
         }
         if(param1)
         {
            if(this._dirtyGui)
            {
               this.refreshGui();
            }
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1 == super.visible)
         {
            return;
         }
         super.visible = param1;
         if(param1)
         {
            this.refreshGui();
         }
         else if(this.networkErrorDialog)
         {
            this.networkErrorDialog.closeDialog("");
         }
         this.activitySpinner.visible = visible && enabled && SagaLeaderboards.count_fetch > 0;
      }
      
      private function survivalLeaderboardChangedHandler(param1:SagaSurvivalEvent) : void
      {
         this.activitySpinner.visible = visible && enabled && SagaLeaderboards.count_fetch > 0;
         var _loc2_:LeaderboardData = param1.leaderboard;
         if(!_loc2_)
         {
            return;
         }
         this._updateBoards();
         if(!this._currentLeaderboard)
         {
            this.refreshGui();
            return;
         }
         if(_loc2_.leaderboard_type == this._currentLeaderboard.leaderboard_type)
         {
            if(_loc2_.global == this._currentLeaderboard.global)
            {
               this.refreshGui();
            }
         }
      }
      
      private function survivalLeaderboardErrorHandler(param1:SagaLeaderboardsEvent) : void
      {
         if(this.networkErrorDialog)
         {
            this.networkErrorDialog.cleanup();
         }
         var _loc2_:String = String(_context.translate("ok"));
         var _loc3_:String = String(_context.translateCategory("platform_network_error",LocaleCategory.PLATFORM));
         var _loc4_:String = String(_context.translateCategory("platform_leaderboard_inaccessible",LocaleCategory.PLATFORM));
         this.networkErrorDialog = _context.createDialog();
         this.networkErrorDialog.openDialog(_loc3_,_loc4_,_loc2_);
         SagaSurvival.dispatcher.removeEventListener(SagaLeaderboardsEvent.FETCH_ERROR,this.survivalLeaderboardErrorHandler);
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaSurvivalLeaderboardsListener, param3:Saga, param4:AppInfo, param5:IGuiButton) : void
      {
         super.initGuiBase(param1);
         this._button_close = param5 as ButtonWithIndex;
         this.saga = _context.saga;
         this.appInfo = param4;
         this.listener = param2;
         this._gp.init(this);
         this._button_board_prev.guiButtonContext = param1;
         this._button_board_next.guiButtonContext = param1;
         this._button_$ss_lb_friends.guiButtonContext = param1;
         this._button_$ss_lb_global.guiButtonContext = param1;
         this._button_diff$normal.guiButtonContext = param1;
         this._button_diff$hard.guiButtonContext = param1;
         this._button_diff$normal.setDownFunction(this.buttonDifficultyHandler);
         this._button_diff$hard.setDownFunction(this.buttonDifficultyHandler);
         this._button_$ss_lb_friends.setDownFunction(this.buttonFriendsHandler);
         this._button_$ss_lb_global.setDownFunction(this.buttonGlobalHandler);
         this._button_board_prev.setDownFunction(this.boardPrevHandler);
         this._button_board_next.setDownFunction(this.boardNextHandler);
         this._chits_group.init(param1);
         this._chits_group.activeChitIndex = 0;
         this.activitySpinner = new ActivitySpinner(param3.resman,"common/gui/notification/save_spinner.png",170,170,33);
         addChild(this.activitySpinner);
         this.activitySpinner.x = width - this._button_close.x - this.activitySpinner.targetWidth * 0.5;
         this.activitySpinner.y = this._button_close.y + this._button_close.height * 0.5;
         this.activitySpinner.visible = false;
         this._updateBoards();
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
      }
      
      private function localeHandler(param1:Event) : void
      {
         scaleTextfields();
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
      }
      
      public function getDifficultyButton(param1:int) : ButtonWithIndex
      {
         switch(param1)
         {
            case 2:
               return this._button_diff$normal;
            case 3:
               return this._button_diff$hard;
            default:
               return null;
         }
      }
      
      public function getNextDifficultyButton() : ButtonWithIndex
      {
         if(this._button_diff$normal.toggled)
         {
            return this._button_diff$hard;
         }
         return this._button_diff$normal;
      }
      
      public function refreshGp() : void
      {
         if(this._gp)
         {
            this._gp.updateNav();
         }
      }
   }
}
