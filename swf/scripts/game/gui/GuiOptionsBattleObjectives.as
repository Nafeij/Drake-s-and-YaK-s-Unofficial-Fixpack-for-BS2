package game.gui
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.board.model.BattleObjective;
   import engine.battle.board.model.BattleScenario;
   import engine.battle.board.model.IBattleScenario;
   import engine.core.locale.LocaleCategory;
   import engine.gui.GuiGpNav;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.page.battle.GuiBattleObjective;
   
   public class GuiOptionsBattleObjectives extends GuiBase implements IGuiOptionsBattleObjectives
   {
       
      
      private var _button_close:ButtonWithIndex;
      
      private var _body:TextField;
      
      private var buttons:Vector.<ButtonWithIndex>;
      
      private var _scenario:BattleScenario;
      
      private var nav:GuiGpNav;
      
      private var listener:IGuiOptionsBattleObjectivesListener;
      
      public function GuiOptionsBattleObjectives()
      {
         this.buttons = new Vector.<ButtonWithIndex>();
         super();
         name = "GuiOptionsBattleObjectives";
         super.visible = false;
      }
      
      public function showScenario(param1:IBattleScenario) : void
      {
         this.scenario = param1 as BattleScenario;
         this.visible = true;
      }
      
      public function get scenario() : BattleScenario
      {
         return this._scenario;
      }
      
      public function set scenario(param1:BattleScenario) : void
      {
         if(this._scenario == param1)
         {
            return;
         }
         this._scenario = param1;
         this._resetTexts();
      }
      
      private function _resetTexts() : void
      {
         var _loc2_:ButtonWithIndex = null;
         var _loc3_:BattleObjective = null;
         var _loc4_:String = null;
         var _loc1_:int = 0;
         if(this._scenario)
         {
            while(_loc1_ < this._scenario.objectives.length)
            {
               if(_loc1_ >= this.buttons.length)
               {
                  break;
               }
               _loc3_ = this._scenario.objectives[_loc1_];
               _loc2_ = this.buttons[_loc1_];
               _loc4_ = GuiBattleObjective.createText(_loc3_,_context);
               _loc2_.buttonText = _loc4_;
               _loc2_.isToggle = _loc3_.complete;
               _loc2_.canToggleUpBlockerAllowsPress = true;
               _loc2_.toggled = _loc3_.complete;
               _loc2_.canToggleUp = false;
               _loc2_.visible = true;
               _loc1_++;
            }
            if(_loc1_ > 0)
            {
               this.nav.selected = this.buttons[0];
               this.objectiveHandler(this.buttons[0]);
            }
         }
         while(_loc1_ < this.buttons.length)
         {
            _loc2_ = this.buttons[_loc1_];
            _loc2_.visible = false;
            _loc1_++;
         }
      }
      
      public function init(param1:IGuiContext, param2:IGuiOptionsBattleObjectivesListener) : void
      {
         var _loc4_:String = null;
         var _loc5_:ButtonWithIndex = null;
         initGuiBase(param1,true);
         this.listener = param2;
         this.nav = new GuiGpNav(param1,"bobj",this);
         this.nav.pressOnNavigate = true;
         this.nav.setCallbackNavigate(this.navNavigateHandler);
         this._body = requireGuiChild("body") as TextField;
         this._body.text = "";
         this._button_close = requireGuiChild("button_close") as ButtonWithIndex;
         this._button_close.setDownFunction(this.closeHandler);
         this.onOperationModeChange(null);
         var _loc3_:int = 0;
         while(_loc3_ < 9)
         {
            _loc4_ = "objective_" + _loc3_;
            _loc5_ = getChildByName(_loc4_) as ButtonWithIndex;
            if(!_loc5_)
            {
               break;
            }
            this.buttons.push(_loc5_);
            _loc5_.guiButtonContext = _context;
            _loc5_.index = _loc3_;
            _loc5_.setDownFunction(this.objectiveHandler);
            this.nav.add(_loc5_);
            registerLocaleChangeChild(_loc5_);
            _loc3_++;
         }
         mouseEnabled = true;
         mouseChildren = true;
         this.visible = false;
      }
      
      override public function handleLocaleChange() : void
      {
         this._resetTexts();
         super.handleLocaleChange();
      }
      
      private function objectiveHandler(param1:ButtonWithIndex) : void
      {
         var _loc4_:String = null;
         var _loc2_:int = param1.index;
         if(!this._scenario)
         {
            return;
         }
         var _loc3_:BattleObjective = this._scenario.objectives[_loc2_];
         if(_loc3_)
         {
            _loc4_ = String(_context.translateCategory(_loc3_.def.token + "_desc",LocaleCategory.BATTLE_OBJ));
            this._body.htmlText = _loc4_;
            _context.locale.fixTextFieldFormat(this._body);
            if(_context.saga)
            {
               _context.saga.triggerBattleObjectiveOpened(_loc3_);
            }
         }
         else
         {
            this._body.htmlText = "";
         }
      }
      
      private function closeHandler(param1:ButtonWithIndex) : void
      {
         this.listener.guiOptionsBattleObjectivesClose();
      }
      
      public function cleanup() : void
      {
         var _loc1_:ButtonWithIndex = null;
         this.visible = false;
         this.nav.cleanup();
         this._button_close.cleanup();
         for each(_loc1_ in this.buttons)
         {
            _loc1_.cleanup();
         }
         cleanupGuiBase();
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         x = param1 / 2;
         y = param2 / 2;
      }
      
      public function closeOptionsBattleObjectives() : Boolean
      {
         if(visible)
         {
            context.playSound("ui_generic");
            this.visible = false;
            return true;
         }
         return false;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         if(this.nav)
         {
            if(super.visible)
            {
               this.nav.activate();
            }
            else
            {
               this.nav.deactivate();
            }
         }
         if(super.visible)
         {
            PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            this.onOperationModeChange(null);
         }
         else
         {
            PlatformInput.dispatcher.removeEventListener(PlatformInput.EVENT_LAST_INPUT,this.onOperationModeChange);
            this.scenario = null;
         }
      }
      
      private function navNavigateHandler(param1:int, param2:int, param3:Boolean) : Boolean
      {
         var _loc4_:int = param2;
         switch(param1)
         {
            case 2:
               _loc4_ = (_loc4_ + 1) % this._scenario.objectives.length;
               break;
            case 0:
               _loc4_ = _loc4_ - 1 >= 0 ? _loc4_ - 1 : int(this._scenario.objectives.length - 1);
         }
         this.nav.selected = this.buttons[_loc4_];
         this.objectiveHandler(this.buttons[_loc4_]);
         return param3;
      }
      
      private function onOperationModeChange(param1:Event) : void
      {
         this._button_close.visible = PlatformInput.hasClicker || !PlatformInput.lastInputGp;
      }
      
      public function ensureTopGp() : void
      {
         if(this.nav)
         {
            this.nav.reactivate();
         }
      }
   }
}
