package game.gui.page
{
   import com.greensock.TweenMax;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.util.ArrayUtil;
   import engine.resource.BitmapResource;
   import engine.resource.Resource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.resource.loader.SoundControllerManager;
   import engine.saga.ISaga;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariable;
   import flash.errors.IllegalOperationError;
   import flash.ui.Keyboard;
   import game.gui.GamePage;
   import game.gui.IGuiTallyTotal;
   import game.gui.IGuiTransition;
   import game.gui.travel.IGuiTravelSoundPlayer;
   import game.gui.travel.IGuiTravelTop;
   import game.saga.tally.ITallyStep;
   import game.saga.tally.TallyAnimStep;
   import game.saga.tally.TallyMessageStep;
   import game.saga.tally.TallyStep;
   import game.saga.tally.TallySumStep;
   
   public class TallyPage extends GamePage implements IGuiTravelSoundPlayer
   {
      
      public static var mcClazzTallyBanner:Class;
      
      public static var mcClazzTallyText:Class;
      
      public static var mcClazzTallyNumber:Class;
      
      private static const SUM_TEXT:String = "tally_total";
       
      
      private var _saga:ISaga;
      
      private var _scenePage:ScenePage;
      
      private var _onComplete:Function;
      
      private var _tallySteps:Vector.<ITallyStep>;
      
      private var _tallyStepsCount:int = 0;
      
      private var _tallyDisplays:Vector.<IGuiTallyTotal>;
      
      private var _travelGui:IGuiTravelTop;
      
      private var _daysAwarded:Number = 0;
      
      private var _tallyInProgress:Boolean = false;
      
      private var _transitionGui:IGuiTransition;
      
      private var _cmd_tally_complete:Cmd;
      
      private var _gplayer:int = 0;
      
      private var _transitionBanner:Resource;
      
      private var _soundControllerManager:SoundControllerManager;
      
      private var _onPreloadComplete:Function;
      
      private var _onPreloadCompleteParams:Array;
      
      private var _soundsLoaded:Boolean;
      
      private var _imagesLoaded:Boolean;
      
      private var _short:Boolean;
      
      private var _transitionTextCentered:Boolean = false;
      
      private var _cachedTallyTextOffset:Number = 0;
      
      private var _animatingSteps:Vector.<TallyStep>;
      
      private var _stepsToRemove:Vector.<TallyStep>;
      
      private var _needToProcessNextStep:Boolean = false;
      
      private var _delayStart:Boolean = false;
      
      public function TallyPage(param1:ScenePage, param2:Boolean = false, param3:int = 2731, param4:int = 1536)
      {
         this._cmd_tally_complete = new Cmd("tally_complete",this.cmdCompleteFunc);
         this._animatingSteps = new Vector.<TallyStep>();
         this._stepsToRemove = new Vector.<TallyStep>();
         super(param1.config,param3,param4);
         this.name = "tally_page";
         this._short = param2;
         fitConstraints.maxHeight = fitConstraints.minHeight = 703;
         this._saga = config.saga as ISaga;
         this._scenePage = param1;
         this._tallySteps = new Vector.<ITallyStep>();
         this._tallyDisplays = new Vector.<IGuiTallyTotal>();
         if(Boolean(this._scenePage) && Boolean(this._scenePage.travelPage))
         {
            this._travelGui = this._scenePage.travelPage.getGuiTop();
            this._scenePage.travelPage.guiTop.travelGuiSoundPlayer = this;
         }
      }
      
      public function preloadShatterAssets(param1:Function, param2:Array) : void
      {
         this._onPreloadComplete = param1;
         this._onPreloadCompleteParams = param2;
         this._soundControllerManager = new SoundControllerManager("shatterLoader","saga3/sound/saga3_shatter.sound.json.z",config.resman,config.soundSystem.driver,this.shatterSoundsLoadComplete,config.logger);
         this._transitionBanner = getPageResource("common/gui/darkness_transition/darkness_transition_banner.png",BitmapResource);
         this._transitionBanner.addResourceListener(this.shatterImagesLoadComplete);
      }
      
      private function shatterSoundsLoadComplete() : void
      {
         this._soundsLoaded = true;
         this.loadingComplete();
      }
      
      private function shatterImagesLoadComplete(param1:ResourceLoadedEvent) : void
      {
         this._imagesLoaded = true;
         param1.resource.removeResourceListener(this.shatterImagesLoadComplete);
         this.loadingComplete();
      }
      
      private function loadingComplete() : void
      {
         if(this._soundsLoaded && this._imagesLoaded)
         {
            this._onPreloadComplete(this._onPreloadCompleteParams);
         }
      }
      
      public function addTallyText(param1:String, param2:String, param3:String) : void
      {
         if(!this.tallyInProgress())
         {
            this._tallySteps.push(new TallyStep(param1,param2,param3,this._soundControllerManager));
         }
      }
      
      public function addTallyAnim(param1:String, param2:String) : void
      {
         if(!this.tallyInProgress())
         {
            this._tallySteps.push(new TallyAnimStep(param1,param2));
         }
      }
      
      public function addPostTotalMessage(param1:String) : void
      {
         if(!this.tallyInProgress())
         {
            this._tallySteps.push(new TallyMessageStep(param1));
         }
      }
      
      public function addSumStep() : void
      {
         this._tallySteps.push(new TallySumStep(SUM_TEXT,this._soundControllerManager));
      }
      
      public function setCallback(param1:Function) : void
      {
         this._onComplete = param1;
      }
      
      override protected function handleStart() : void
      {
         if(this.tallyInProgress())
         {
            throw new IllegalOperationError("TallyManager.startTally can only be called when no tally is in progress");
         }
         if(!this._saga.isOptionsShowing)
         {
            this.delayStart();
         }
         else
         {
            this._delayStart = true;
         }
      }
      
      private function delayStart() : void
      {
         if(this._travelGui)
         {
            this._travelGui.shatterInProgress = this._tallyInProgress = true;
         }
         this._gplayer = GpBinder.gpbinder.createLayer("TallyPage");
         setFullPageMovieClipClass(mcClazzTallyBanner);
         this._tallyStepsCount = this.getTallySteps(this._tallySteps);
         this._transitionGui = fullScreenMc as IGuiTransition;
         if(this._transitionGui)
         {
            this._transitionGui.init(this._scenePage.config.gameGuiContext);
            this.resizeHandler();
            this._transitionGui.animateOnScreen(this.processNextStep);
         }
         else
         {
            this.processNextStep();
         }
      }
      
      private function getTallySteps(param1:Vector.<ITallyStep>) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] is TallyStep)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function tallyInProgress() : Boolean
      {
         return this._tallyInProgress;
      }
      
      override public function cleanup() : void
      {
         var _loc1_:IGuiTallyTotal = null;
         GpDevBinder.instance.unbind(this.cmdCompleteFunc);
         GpBinder.gpbinder.unbind(this._cmd_tally_complete);
         GpBinder.gpbinder.removeLayer(this._gplayer);
         config.keybinder.unbind(this._cmd_tally_complete);
         this._cmd_tally_complete.cleanup();
         this._cmd_tally_complete = null;
         if(this._scenePage && this._scenePage.travelPage && Boolean(this._scenePage.travelPage.guiTop))
         {
            this._scenePage.travelPage.guiTop.travelGuiSoundPlayer = null;
         }
         this._soundControllerManager.cleanup();
         this._soundControllerManager = null;
         while(this._tallyDisplays.length > 0)
         {
            _loc1_ = this._tallyDisplays.pop();
            this.cleanupTallyText(_loc1_);
         }
         if(this._transitionGui)
         {
            this._transitionGui.cleanup();
         }
         super.cleanup();
      }
      
      private function processNextStep() : void
      {
         if(this._saga.paused)
         {
            this._needToProcessNextStep = true;
            return;
         }
         if(this._tallySteps.length < 1)
         {
            this._soundControllerManager.soundController.playSound("ui_break_thefinal_mega",null);
            TweenMax.delayedCall(4,this.completeTally);
            return;
         }
         var _loc1_:ITallyStep = this._tallySteps.pop();
         if(!_loc1_)
         {
            this.processNextStep();
            return;
         }
         if(_loc1_ is TallySumStep)
         {
            this.processTallySumStep(_loc1_ as TallySumStep);
         }
         else if(_loc1_ is TallyStep)
         {
            this.processTallyStep(_loc1_ as TallyStep);
         }
         else if(_loc1_ is TallyAnimStep)
         {
            this.processTallyAnimStep(_loc1_ as TallyAnimStep);
         }
         else if(_loc1_ is TallyMessageStep)
         {
            this.processTallyMessageStep(_loc1_ as TallyMessageStep);
         }
         else
         {
            this.processNextStep();
         }
      }
      
      private function processTallySumStep(param1:TallySumStep) : void
      {
         param1.daysValue = this._saga.getVarNumber(param1.varName);
         param1.finalValue = int(param1.daysValue);
         param1.countUp = true;
         param1.useDays = true;
         var _loc2_:IGuiTallyTotal = this.createAndInitializeTallyText(param1);
         _loc2_.numValue = param1.startValue;
         param1.gui = _loc2_;
         param1.delay = 0.3;
         param1.currentValue = 0;
         param1.complete = this.stepAnimComplete;
         _loc2_.animateToSum(param1,this._transitionGui,this.startRollText);
      }
      
      private function processTallyMessageStep(param1:TallyMessageStep) : void
      {
         this._transitionGui.displayMessage(param1.messageKey,this.processNextStep);
      }
      
      private function processTallyAnimStep(param1:TallyAnimStep) : void
      {
         this._travelGui.playRange(param1.startLabel,param1.endLabel,this.processNextStep);
         this.playTallyAnimStepAudio(param1);
      }
      
      private function playTallyAnimStepAudio(param1:TallyAnimStep) : void
      {
         switch(param1.startLabel)
         {
            case "start_hub_shatter":
               this._soundControllerManager.soundController.playSound("ui_break_main_shield",null);
               break;
            case "start_button_fall":
               this._soundControllerManager.soundController.playSound("ui_break_main_map",null);
               break;
            case "start_supplies_fall":
               this._soundControllerManager.soundController.playSound("ui_break_main_supplies",null);
               break;
            case "start_varl_fall":
            case "start_fighters_fall":
               this._soundControllerManager.soundController.playSound("ui_break_people_break_first",null);
               break;
            case "start_peasants_fall":
               this._soundControllerManager.soundController.playSound("ui_break_people_break_second",null);
         }
      }
      
      private function processTallyStep(param1:TallyStep) : void
      {
         param1.startValue = this._saga.getVarNumber(param1.varName);
         param1.finalValue = 0;
         param1.multValue = !!param1.multName ? Number(this._saga.getVarNumber(param1.multName)) : 1;
         param1.daysValue = param1.startValue * param1.multValue;
         var _loc2_:IGuiTallyTotal = this.createAndInitializeTallyText(param1);
         _loc2_.displayHours = true;
         param1.delay = 0.3;
         param1.currentValue = param1.startValue;
         param1.gui = _loc2_;
         if(this._short)
         {
            param1.startValue = 0;
            param1.finalValue = this._saga.getVarNumber(param1.varName);
            param1.countUp = true;
            param1.addsToDays = true;
            this._daysAwarded += this._saga.getVarNumber(param1.varName);
            _loc2_.snapToFinalPoint(this._tallyStepsCount - this.getTallySteps(this._tallySteps),param1,this._transitionGui.textTopLocation);
            param1.complete = this.stepAnimComplete;
            this.startRollText(param1);
         }
         else
         {
            param1.addsToDays = true;
            _loc2_.animateToTallyPoint(param1,this._transitionGui.textBottomLocation,this.startRollText);
            this._soundControllerManager.soundController.playSound("ui_break_swipes",null);
            param1.complete = this.stepAnimToFinal;
            this._animatingSteps.push(param1);
         }
      }
      
      private function createAndInitializeTallyText(param1:TallyStep) : IGuiTallyTotal
      {
         var _loc2_:IGuiTallyTotal = new mcClazzTallyText() as IGuiTallyTotal;
         this._transitionGui.displayObjectContainer.addChild(_loc2_.displayObject);
         _loc2_.init(this._scenePage.config.gameGuiContext);
         _loc2_.initializeText(param1.text,param1.startValue,this._transitionGui);
         if(param1 is TallySumStep)
         {
            _loc2_.setSumStepOffset();
         }
         else if(this._cachedTallyTextOffset == 0)
         {
            this._cachedTallyTextOffset = _loc2_.initTallyTextWidth(this._tallySteps);
            _loc2_.textXOffset = this._cachedTallyTextOffset;
         }
         else
         {
            _loc2_.textXOffset = this._cachedTallyTextOffset;
         }
         this._tallyDisplays.push(_loc2_);
         return _loc2_;
      }
      
      private function cleanupTallyText(param1:IGuiTallyTotal) : void
      {
         this._transitionGui.displayObjectContainer.removeChild(param1.displayObject);
         param1.cleanup();
      }
      
      private function completeTally() : void
      {
         this._transitionGui.displayCompleteButton(this.onCompleteButton);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this._cmd_tally_complete,"tally_complete");
         config.keybinder.bind(false,false,false,Keyboard.SPACE,this._cmd_tally_complete,"tally_complete");
         config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this._cmd_tally_complete,"tally_complete");
         GpBinder.gpbinder.bindPress(GpControlButton.A,this._cmd_tally_complete,"TallyPage");
         GpDevBinder.instance.bind(null,GpControlButton.A,1,this.cmdCompleteFunc,[null]);
      }
      
      override public function handleOptionsShowing(param1:Boolean) : void
      {
         if(this._delayStart && !param1)
         {
            this._delayStart = false;
            this.delayStart();
         }
      }
      
      private function cmdCompleteFunc(param1:CmdExec) : void
      {
         this.onCompleteButton();
      }
      
      private function onCompleteButton() : void
      {
         this._tallySteps.length = 0;
         if(this._travelGui)
         {
            this._travelGui.shatterInProgress = this._tallyInProgress = false;
         }
         if(this._onComplete != null)
         {
            this._onComplete();
         }
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         if(this._transitionGui)
         {
            this._transitionGui.killTweens();
            this._transitionGui.displayObjectContainer.x = 0;
            this._transitionGui.displayObjectContainer.y = 0;
         }
      }
      
      public function playDayIncrementSound() : void
      {
         if(Boolean(this._soundControllerManager) && Boolean(this._soundControllerManager.soundController))
         {
            this._soundControllerManager.soundController.playSound("ui_break_count_up",null);
         }
      }
      
      override public function update(param1:int) : void
      {
         var _loc4_:TallyStep = null;
         var _loc5_:TallyStep = null;
         super.update(param1);
         if(Boolean(this._gplayer) && this._saga.isOptionsShowing)
         {
            GpBinder.gpbinder.disableBindsFromGroup("TallyPage");
         }
         else if(!this._gplayer && !this._saga.isOptionsShowing)
         {
            GpBinder.gpbinder.enableBindsFromGroup("TallyPage");
         }
         if(this._saga.paused)
         {
            return;
         }
         if(this._needToProcessNextStep)
         {
            this._needToProcessNextStep = false;
            this.processNextStep();
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._animatingSteps.length)
         {
            _loc4_ = this._animatingSteps[_loc2_];
            _loc4_.update(param1);
            if(_loc4_.addsToDays)
            {
               this._daysAwarded += _loc4_.lastFrameAward;
            }
            _loc2_++;
         }
         if(this._travelGui)
         {
            this._travelGui.days = this._daysAwarded;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._stepsToRemove.length)
         {
            _loc5_ = this._stepsToRemove[_loc3_];
            if(this._animatingSteps.indexOf(_loc5_) > -1)
            {
               ArrayUtil.removeAt(this._animatingSteps,this._animatingSteps.indexOf(_loc5_));
            }
            _loc3_++;
         }
         this._stepsToRemove.length = 0;
      }
      
      private function startRollText(param1:TallyStep) : void
      {
         param1.doRollText = true;
         if(this._animatingSteps.indexOf(param1) < 0)
         {
            this._animatingSteps.push(param1);
         }
      }
      
      private function stepAnimToFinal(param1:TallyStep) : void
      {
         param1.gui.animateToFinal(this._tallyStepsCount - this.getTallySteps(this._tallySteps),param1,this._transitionGui.textTopLocation,this.stepAnimComplete);
         this._soundControllerManager.soundController.playSound("ui_break_swipes",null);
      }
      
      private function stepAnimComplete(param1:TallyStep) : void
      {
         this._stepsToRemove.push(param1);
         if(!param1.addsToDays)
         {
            this.processNextStep();
            return;
         }
         var _loc2_:IVariable = this._saga.getVar(SagaVar.VAR_DAYS_REMAINING,null);
         _loc2_.asNumber += param1.daysValue;
         this.processNextStep();
      }
      
      public function get cleanedUp() : Boolean
      {
         return cleanedup;
      }
   }
}
