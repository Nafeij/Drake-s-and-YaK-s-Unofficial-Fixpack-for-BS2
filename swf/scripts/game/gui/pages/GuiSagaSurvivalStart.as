package game.gui.pages
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import engine.achievement.AchievementDef;
   import engine.achievement.AchievementListDef;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBinder;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.AppInfo;
   import engine.core.util.MovieClipAdapter;
   import engine.core.util.StringUtil;
   import engine.gui.GuiContextEvent;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaLeaderboards;
   import engine.saga.SagaSurvival;
   import engine.saga.SagaVar;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.save.SagaSave;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiSagaSurvivalLeaderboardsListener;
   import game.gui.page.IGuiSagaSurvivalStart;
   import game.gui.page.IGuiSagaSurvivalStartListener;
   
   public class GuiSagaSurvivalStart extends GuiBase implements IGuiSagaSurvivalStart, ISoundDefBundleListener, IGuiSagaSurvivalLeaderboardsListener
   {
      
      private static var _welcomed:Boolean;
      
      private static const rLum:Number = 0.2125 / 4;
      
      private static const gLum:Number = 0.7154 / 4;
      
      private static const bLum:Number = 0.0721 / 4;
      
      private static const grayscaleColorFilterMatrix:Array = [rLum,gLum,bLum,0,0,rLum,gLum,bLum,0,0,rLum,gLum,bLum,0,0,0,0,0,1,0];
      
      private static var LEADERBOARD_UP_Y:int = -1536;
       
      
      public var listener:IGuiSagaSurvivalStartListener;
      
      private var appInfo:AppInfo;
      
      public var _$ss_difficulty:TextField;
      
      public var _$ss_achievements:TextField;
      
      public var _$ss_battles_won:TextField;
      
      public var _$easy:TextField;
      
      public var _$normal:TextField;
      
      public var _$hard:TextField;
      
      public var _button$ss_start:ButtonWithIndex;
      
      public var _button$ss_resume:ButtonWithIndex;
      
      public var _buttonClose:ButtonWithIndex;
      
      public var _button$ss_lb:ButtonWithIndex;
      
      public var _button_diff$easy:ButtonWithIndex;
      
      public var _button_diff$normal:ButtonWithIndex;
      
      public var _button_diff$hard:ButtonWithIndex;
      
      private var cmd_space:Cmd;
      
      private var saga:Saga;
      
      private var _resumes:Array;
      
      private var _resumeCount:int = 0;
      
      private var _freeProfile:int = -1;
      
      private var _resume:SagaSave;
      
      private var _resume_profile_index:int = -1;
      
      public var acv_placeholders:Vector.<MovieClip>;
      
      public var acv_icons:Vector.<GuiIcon>;
      
      private var acv_placeholdersToIndex:Dictionary;
      
      private var _acv_tooltip:MovieClip;
      
      private var acv_placeholders_rect:Rectangle;
      
      private var _welcome:MovieClip;
      
      public var _button$ss_continue:ButtonWithIndex;
      
      private var _gp:GuiSagaSurvivalStart_gp;
      
      public var _leaderboards:GuiSagaSurvivalLeaderboards;
      
      private var _mc_acvs:MovieClip;
      
      private var _mc_difficulty:MovieClip;
      
      private var _glow:MovieClip;
      
      private var _glow_mca:MovieClipAdapter;
      
      private var _hoverAcvPlaceholder:DisplayObjectContainer;
      
      private var bundle:ISoundDefBundle;
      
      private var cmf:ColorMatrixFilter;
      
      private var glow:GlowFilter;
      
      public function GuiSagaSurvivalStart()
      {
         var _loc2_:String = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         this.cmd_space = new Cmd("ss_space",this.cmdSpaceFunc);
         this.acv_placeholders = new Vector.<MovieClip>();
         this.acv_icons = new Vector.<GuiIcon>();
         this.acv_placeholdersToIndex = new Dictionary();
         this._gp = new GuiSagaSurvivalStart_gp();
         this.cmf = new ColorMatrixFilter(grayscaleColorFilterMatrix);
         this.glow = new GlowFilter(10145518,1,12,12,3,2);
         super();
         super.visible = false;
         name = "gui_survival_start";
         this._glow = requireGuiChild("glow") as MovieClip;
         this._glow.mouseEnabled = this._glow.mouseChildren = false;
         this._glow.stop();
         this._leaderboards = requireGuiChild("leaderboards") as GuiSagaSurvivalLeaderboards;
         this._leaderboards.enabled = false;
         this._leaderboards.visible = false;
         this._$ss_achievements = requireGuiChild("$ss_achievements") as TextField;
         this._$ss_battles_won = requireGuiChild("$ss_battles_won") as TextField;
         this._$easy = requireGuiChild("$easy") as TextField;
         this._$normal = requireGuiChild("$normal") as TextField;
         this._$hard = requireGuiChild("$hard") as TextField;
         this._button$ss_resume = requireGuiChild("button$ss_resume") as ButtonWithIndex;
         this._button$ss_resume.setDownFunction(this.buttonResumeHandler);
         this._button$ss_lb = requireGuiChild("button$ss_lb") as ButtonWithIndex;
         this._button$ss_lb.setDownFunction(this.buttonLeaderboardsHandler);
         this._button$ss_lb.visible = SagaSurvival.ENABLED_LEADERBOARDS && SagaLeaderboards.isSupported;
         this._buttonClose = requireGuiChild("buttonClose") as ButtonWithIndex;
         this._buttonClose.setDownFunction(this.buttonCloseHandler);
         this._mc_difficulty = requireGuiChild("mc_difficulty") as MovieClip;
         this._mc_difficulty.mouseEnabled = false;
         this._mc_difficulty.mouseChildren = true;
         this._button$ss_start = requireGuiChild("button$ss_start",this._mc_difficulty) as ButtonWithIndex;
         this._button$ss_start.setDownFunction(this.buttonStartHandler);
         this._$ss_difficulty = requireGuiChild("$ss_difficulty",this._mc_difficulty) as TextField;
         this._button_diff$easy = requireGuiChild("button_diff$easy",this._mc_difficulty) as ButtonWithIndex;
         this._button_diff$easy.setDownFunction(this.buttonDifficultyHandler);
         this._button_diff$easy.isToggle = true;
         this._button_diff$easy.canToggleUp = false;
         this._button_diff$easy.index = 1;
         this._button_diff$normal = requireGuiChild("button_diff$normal",this._mc_difficulty) as ButtonWithIndex;
         this._button_diff$normal.setDownFunction(this.buttonDifficultyHandler);
         this._button_diff$normal.isToggle = true;
         this._button_diff$normal.canToggleUp = false;
         this._button_diff$normal.index = 2;
         this._button_diff$hard = requireGuiChild("button_diff$hard",this._mc_difficulty) as ButtonWithIndex;
         this._button_diff$hard.setDownFunction(this.buttonDifficultyHandler);
         this._button_diff$hard.isToggle = true;
         this._button_diff$hard.canToggleUp = false;
         this._button_diff$hard.index = 3;
         this._acv_tooltip = requireGuiChild("acv_tooltip") as MovieClip;
         this._acv_tooltip.mouseEnabled = this._acv_tooltip.mouseChildren = false;
         this._acv_tooltip.visible = false;
         this._welcome = requireGuiChild("welcome") as MovieClip;
         this._welcome.mouseEnabled = false;
         this._welcome.mouseChildren = true;
         this._welcome.visible = false;
         this._button$ss_continue = this._welcome.getChildByName("button$ss_continue") as ButtonWithIndex;
         this._button$ss_continue.setDownFunction(this.buttonContinueHandler);
         recursiveRegisterScalableTextfields2d(this._welcome,true);
         this._setupTextCrown("d1");
         this._setupTextCrown("d2");
         this._setupTextCrown("d3");
         this._mc_acvs = requireGuiChild("mc_acvs") as MovieClip;
         this._mc_acvs.mouseEnabled = false;
         this._mc_acvs.mouseChildren = true;
         this.acv_placeholders_rect = new Rectangle(this._mc_acvs.x,this._mc_acvs.y,this._mc_acvs.width,this._mc_acvs.height);
         var _loc1_:int = 0;
         while(_loc1_ < 20)
         {
            _loc2_ = "acv_" + _loc1_;
            _loc3_ = this._mc_acvs.getChildByName(_loc2_) as MovieClip;
            if(!_loc3_)
            {
               break;
            }
            _loc4_ = _loc3_.getChildByName("bg") as MovieClip;
            _loc4_.visible = false;
            this.acv_placeholdersToIndex[_loc3_] = this.acv_placeholders.length;
            this.acv_placeholders.push(_loc3_);
            _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.acvRollOutHandler);
            _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.acvRollOverHandler);
            _loc1_++;
         }
         this._$ss_difficulty.cacheAsBitmap = true;
         this._$ss_achievements.cacheAsBitmap = true;
         this._$ss_battles_won.cacheAsBitmap = true;
         this._$easy.cacheAsBitmap = true;
         this._$normal.cacheAsBitmap = true;
         this._$hard.cacheAsBitmap = true;
         registerScalableTextfieldAlign(this._$ss_battles_won,"center");
         registerScalableTextfieldAlign(this._$easy,"center");
         registerScalableTextfieldAlign(this._$normal,"center");
         registerScalableTextfieldAlign(this._$hard,"center");
         this._welcome.scaleX = this._welcome.scaleY = Platform.textScale;
         this._acv_tooltip.scaleX = this._acv_tooltip.scaleY = Platform.textScale;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(this._gp)
         {
            this._gp.visible = param1;
         }
         if(param1)
         {
            if(!Platform.optimizeForConsole)
            {
               if(Boolean(this.saga) && Boolean(this.saga.survival))
               {
                  this.saga.survival.requestAllSurvivalLeaderboards();
               }
            }
            if(!this._glow.cacheAsBitmap)
            {
               if(this._glow_mca)
               {
                  this._glow_mca.playLooping();
               }
            }
            if(_context)
            {
               _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
            }
            this.localeHandler(null);
         }
         else
         {
            if(_context)
            {
               _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
            }
            if(this._glow_mca)
            {
               this._glow_mca.stop();
            }
         }
      }
      
      private function localeHandler(param1:Event) : void
      {
         scaleTextfields();
      }
      
      private function acvRollOutHandler(param1:MouseEvent) : void
      {
         this.setHoverAcvPlaceholder(param1.target as MovieClip,false);
      }
      
      private function acvRollOverHandler(param1:MouseEvent) : void
      {
         this.setHoverAcvPlaceholder(param1.target as MovieClip,true);
      }
      
      private function getAchievementDefForPlaceholder(param1:DisplayObjectContainer) : AchievementDef
      {
         if(!param1 || !this.saga || !this.saga.def)
         {
            return null;
         }
         var _loc2_:int = int(this.acv_placeholdersToIndex[param1]);
         if(_loc2_ < 0 || _loc2_ >= this.saga.def.achievements.defs.length)
         {
            return null;
         }
         return this.saga.def.achievements.defs[_loc2_];
      }
      
      private function isUnlockedPlaceholder(param1:DisplayObjectContainer) : Boolean
      {
         var _loc2_:AchievementDef = this.getAchievementDefForPlaceholder(param1);
         return Boolean(_loc2_) && SagaAchievements.isUnlocked(_loc2_.id);
      }
      
      public function setHoverAcvPlaceholder(param1:DisplayObjectContainer, param2:Boolean) : void
      {
         if(!this.saga || !this.saga.def)
         {
            return;
         }
         if(this._hoverAcvPlaceholder)
         {
            if(this.isUnlockedPlaceholder(this._hoverAcvPlaceholder))
            {
               this._hoverAcvPlaceholder.filters = [];
            }
            else
            {
               this._hoverAcvPlaceholder.filters = [this.cmf];
            }
         }
         if(param2)
         {
            this._hoverAcvPlaceholder = param1;
         }
         else
         {
            this._hoverAcvPlaceholder = null;
         }
         if(this._hoverAcvPlaceholder)
         {
            if(this.isUnlockedPlaceholder(this._hoverAcvPlaceholder))
            {
               this._hoverAcvPlaceholder.filters = [this.glow];
            }
            else
            {
               this._hoverAcvPlaceholder.filters = [this.cmf,this.glow];
            }
         }
         this.renderHoverAcvTooltip();
      }
      
      private function renderHoverAcvTooltip() : void
      {
         var _loc1_:AchievementDef = this.getAchievementDefForPlaceholder(this._hoverAcvPlaceholder);
         if(!_loc1_)
         {
            this._acv_tooltip.visible = false;
            return;
         }
         var _loc2_:TextField = this._acv_tooltip.getChildByName("text") as TextField;
         var _loc3_:String = "";
         _loc3_ += "<font color=\'#ffff00\'>" + _loc1_.name + "</font>\n";
         _loc3_ += _loc1_.description;
         _loc2_.htmlText = _loc3_;
         _context.locale.fixTextFieldFormat(_loc2_,null,null,true);
         setChildIndex(this._acv_tooltip,numChildren - 1);
         this._acv_tooltip.visible = true;
         this._acv_tooltip.y = this.acv_placeholders_rect.y + this._hoverAcvPlaceholder.y + 140;
         this._acv_tooltip.x = this.acv_placeholders_rect.x + this._hoverAcvPlaceholder.x + 66 - this._acv_tooltip.width / 2;
         this._acv_tooltip.x = Math.max(this.acv_placeholders_rect.left,this._acv_tooltip.x);
         this._acv_tooltip.x = Math.min(this.acv_placeholders_rect.right - this._acv_tooltip.width,this._acv_tooltip.x);
      }
      
      private function _setupTextCrown(param1:String) : void
      {
         var _loc2_:TextField = requireGuiChild("text_" + param1) as TextField;
         _loc2_.mouseEnabled = false;
         _loc2_.visible = false;
         var _loc3_:MovieClip = requireGuiChild("crown_" + param1) as MovieClip;
         _loc3_.mouseEnabled = _loc3_.mouseChildren = false;
         _loc3_.visible = false;
      }
      
      public function get isWelcoming() : Boolean
      {
         return Boolean(this._welcome) && this._welcome.visible;
      }
      
      public function closeWelcoming() : Boolean
      {
         if(this._welcome.visible)
         {
            this._button$ss_continue.press();
            return true;
         }
         return false;
      }
      
      private function cmdSpaceFunc(param1:CmdExec) : void
      {
         if(this._leaderboards.visible)
         {
            return;
         }
         if(this.closeWelcoming())
         {
            return;
         }
         this.buttonStartHandler(null);
      }
      
      public function init(param1:IGuiContext, param2:IGuiSagaSurvivalStartListener, param3:Saga, param4:AppInfo) : void
      {
         super.initGuiBase(param1);
         _context.logger.info("_button$ss_lb.visible=" + this._button$ss_lb.visible);
         this.saga = _context.saga;
         KeyBinder.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_space,"");
         this.appInfo = param4;
         this.listener = param2;
         this._glow_mca = new MovieClipAdapter(this._glow,30,null,false,logger);
         this._leaderboards.init(_context,this,param3,param4,this._buttonClose);
         this._button$ss_resume.guiButtonContext = _context;
         this._button$ss_start.guiButtonContext = _context;
         this._button_diff$easy.guiButtonContext = _context;
         this._button_diff$hard.guiButtonContext = _context;
         this._button_diff$normal.guiButtonContext = _context;
         this._buttonClose.guiButtonContext = _context;
         this._button$ss_continue.guiButtonContext = _context;
         this._button$ss_lb.guiButtonContext = _context;
         param1.locale.translateDisplayObjects(LocaleCategory.GUI,this,logger);
         var _loc5_:int = param3.getVarInt(SagaVar.VAR_SURVIVAL_TOTAL);
         this._updateCrown("d1",_loc5_);
         this._updateCrown("d2",_loc5_);
         this._updateCrown("d3",_loc5_);
         this.updateDifficultyStates();
         this.setupResumes();
         this._button$ss_resume.visible = this._resumeCount > 0;
         this.setupAchievements();
         if(!_welcomed)
         {
            this._welcome.visible = true;
            _welcomed = true;
         }
         var _loc6_:ActionDef = new ActionDef(null);
         _loc6_.type = ActionType.MUSIC_START;
         _loc6_.id = "saga2/music/ch14/14mC1-S1-L1";
         param3.executeActionDef(_loc6_,null,null);
         this._gp.init(this);
         this.visible = true;
      }
      
      private function _playWinMusic() : void
      {
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
      }
      
      private function setupAchievements() : void
      {
         var _loc2_:MovieClip = null;
         var _loc4_:AchievementDef = null;
         var _loc5_:GuiIcon = null;
         var _loc1_:AchievementListDef = this.saga.def.achievements;
         if(!_loc1_)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.defs.length)
         {
            if(_loc3_ >= this.acv_placeholders.length)
            {
               _context.logger.error("Too many achievements (" + _loc1_.defs.length + ") for survival");
               break;
            }
            _loc2_ = this.acv_placeholders[_loc3_];
            _loc2_.visible = true;
            _loc4_ = _loc1_.defs[_loc3_];
            _loc5_ = _context.getIcon(_loc4_.iconUrl);
            _loc5_.layout = GuiIconLayoutType.ACTUAL;
            _loc5_.x = _loc5_.y = 0;
            _loc5_.name = "acv_icon_" + StringUtil.padLeft(_loc3_.toString(),"0",2);
            _loc2_.addChild(_loc5_);
            this.acv_icons.push(_loc5_);
            if(!SagaAchievements.isUnlocked(_loc4_.id))
            {
               _loc2_.filters = [this.cmf];
            }
            _loc3_++;
         }
         while(_loc3_ < this.acv_placeholders.length)
         {
            _loc2_ = this.acv_placeholders[_loc3_];
            _loc2_.visible = false;
            _loc3_++;
         }
      }
      
      private function setupResumes() : void
      {
         var _loc2_:SagaSave = null;
         this._resumes = this.saga.saveManager.getResumeSaves(this.saga.def.id,this.saga.isSurvival);
         if(!this._resumes)
         {
            this._resumes = [];
         }
         this._resume_profile_index = -1;
         var _loc1_:int = 0;
         while(_loc1_ < this._resumes.length)
         {
            _loc2_ = this._resumes[_loc1_];
            if(_loc2_)
            {
               if(this.saga.isSurvivalReloadable(_loc2_))
               {
                  this._resume = _loc2_;
                  this._resume_profile_index = _loc1_;
               }
               ++this._resumeCount;
            }
            else if(this._freeProfile < 0)
            {
               this._freeProfile = _loc1_;
            }
            _loc1_++;
         }
         if(this._resumeCount > 1)
         {
            this._resume = null;
            this._resume_profile_index = -1;
         }
      }
      
      private function _updateCrown(param1:String, param2:int) : void
      {
         var _loc3_:int = this.saga.getMasterSaveKeyInt("survival_" + param1);
         var _loc4_:TextField = this["text_" + param1];
         var _loc5_:MovieClip = this["crown_" + param1];
         if(_loc4_)
         {
            _loc4_.visible = _loc3_ > 0 && _loc3_ < param2;
            if(_loc4_.visible)
            {
               _loc4_.text = _loc3_.toString();
            }
         }
         if(_loc5_)
         {
            _loc5_.visible = _loc3_ >= param2;
         }
      }
      
      private function buttonStartHandler(param1:*) : void
      {
         this.saga.showSaveProfileStart(this.profileStartHandler);
      }
      
      private function profileStartHandler() : void
      {
         this._playWinMusic();
      }
      
      private function setHolderMcEnabled(param1:MovieClip, param2:Boolean) : void
      {
         param1.cacheAsBitmap = !param2;
         param1.mouseEnabled = false;
         param1.mouseChildren = param2;
      }
      
      private function setMcEnabled(param1:MovieClip, param2:Boolean) : void
      {
         param1.cacheAsBitmap = !param2;
         param1.mouseEnabled = param2;
         param1.mouseChildren = param2;
      }
      
      private function buttonLeaderboardsHandler(param1:*) : void
      {
         this._gp.visible = false;
         this._leaderboards.visible = true;
         this.setHolderMcEnabled(this._mc_difficulty,false);
         this.setHolderMcEnabled(this._mc_acvs,false);
         this._glow_mca.stop();
         this._glow.cacheAsBitmap = true;
         this.setMcEnabled(this._button$ss_start,false);
         this.setMcEnabled(this._button$ss_resume,false);
         this.setMcEnabled(this._button$ss_lb,false);
         this.setMcEnabled(this._button_diff$easy,false);
         this.setMcEnabled(this._button_diff$normal,false);
         this.setMcEnabled(this._button_diff$hard,false);
         this._leaderboards.y = LEADERBOARD_UP_Y;
         TweenMax.killTweensOf(this._leaderboards);
         _context.playSound("ui_map_open");
         TweenMax.to(this._leaderboards,0.5,{
            "y":0,
            "onComplete":this.leaderboardsTweenInCompleteHandler
         });
      }
      
      private function leaderboardsTweenInCompleteHandler() : void
      {
         this._leaderboards.enabled = true;
         this._leaderboards.refreshGp();
         _context.playSound("ui_end_turn");
      }
      
      private function buttonResumeHandler(param1:*) : void
      {
         if(this._resume)
         {
            if(this._resume_profile_index < 0)
            {
               logger.error("Resume from invalid profile index!");
               return;
            }
            if(!this.saga.checkSurvivalReloadable(this._resume))
            {
               return;
            }
            this.saga.loadExistingSave(this._resume,this._resume_profile_index);
         }
         else
         {
            this.saga.showSaveProfileLoad();
         }
      }
      
      private function buttonContinueHandler(param1:*) : void
      {
         this._welcome.visible = false;
         this._gp.handleWelcomeClosed();
      }
      
      private function buttonCloseHandler(param1:*) : void
      {
         if(this._leaderboards.visible)
         {
            _context.playSound("ui_map_open");
            TweenMax.killTweensOf(this._leaderboards);
            this._leaderboards.enabled = false;
            TweenMax.to(this._leaderboards,0.5,{
               "y":LEADERBOARD_UP_Y,
               "onComplete":this.leaderboardsTweenOutCompleteHandler
            });
            return;
         }
         _context.saga.showStartPage(true);
      }
      
      private function leaderboardsTweenOutCompleteHandler() : void
      {
         this._leaderboards.visible = false;
         this._gp.visible = this.visible;
         this.setHolderMcEnabled(this._mc_difficulty,true);
         this.setHolderMcEnabled(this._mc_acvs,true);
         this.setMcEnabled(this._button$ss_start,true);
         this.setMcEnabled(this._button$ss_resume,true);
         this.setMcEnabled(this._button$ss_lb,true);
         this.setMcEnabled(this._button_diff$easy,true);
         this.setMcEnabled(this._button_diff$normal,true);
         this.setMcEnabled(this._button_diff$hard,true);
         this._glow.cacheAsBitmap = false;
         this._glow_mca.playLooping();
      }
      
      private function buttonDifficultyHandler(param1:ButtonWithIndex) : void
      {
         _context.saga.difficulty = param1.index;
         this.saga.setMasterSaveKey("difficulty",this.saga.difficulty);
         this.updateDifficultyStates();
      }
      
      private function updateDifficultyStates() : void
      {
         this._button_diff$easy.toggled = _context.saga.difficulty == 1;
         this._button_diff$normal.toggled = _context.saga.difficulty == 2;
         this._button_diff$hard.toggled = _context.saga.difficulty == 3;
         if(this._gp)
         {
            this._gp.updateDifficulty();
         }
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiIcon = null;
         var _loc2_:MovieClip = null;
         super.cleanupGuiBase();
         TweenMax.killTweensOf(this._leaderboards);
         this._gp.cleanup();
         this._gp = null;
         if(this.bundle)
         {
            this.bundle.removeListener(this);
         }
         KeyBinder.keybinder.unbind(this.cmd_space);
         this.cmd_space.cleanup();
         for each(_loc1_ in this.acv_icons)
         {
            _loc1_.release();
         }
         if(this._glow_mca)
         {
            this._glow_mca.cleanup();
            this._glow_mca = null;
         }
         for each(_loc2_ in this.acv_placeholders)
         {
            _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.acvRollOutHandler);
            _loc2_.removeEventListener(MouseEvent.ROLL_OVER,this.acvRollOverHandler);
         }
      }
      
      public function getDifficultyButton(param1:int) : ButtonWithIndex
      {
         switch(param1)
         {
            case 1:
               return this._button_diff$easy;
            case 2:
               return this._button_diff$normal;
            case 3:
               return this._button_diff$hard;
            default:
               return null;
         }
      }
   }
}
