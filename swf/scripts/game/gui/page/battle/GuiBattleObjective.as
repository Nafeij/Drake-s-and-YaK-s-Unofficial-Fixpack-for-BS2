package game.gui.page.battle
{
   import engine.battle.board.model.BattleObjective;
   import engine.core.locale.LocaleCategory;
   import engine.gui.IGuiButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.IGuiContext;
   
   public class GuiBattleObjective
   {
       
      
      public var mc:MovieClip;
      
      public var _token:String;
      
      private var _context:IGuiContext;
      
      private var _objective:BattleObjective;
      
      public var _button:IGuiButton;
      
      private var _gui:GuiBattleObjectives;
      
      private var _str:String;
      
      public function GuiBattleObjective(param1:MovieClip, param2:GuiBattleObjectives, param3:IGuiContext)
      {
         super();
         this._gui = param2;
         this._context = param3;
         this.mc = param1;
         param1.mouseEnabled = false;
         param1.mouseChildren = true;
         this.setState(false);
      }
      
      public static function createText(param1:BattleObjective, param2:IGuiContext) : String
      {
         if(!param1)
         {
            return "";
         }
         var _loc3_:String = "";
         var _loc4_:String = param1.def.token;
         if(_loc4_)
         {
            _loc3_ = param2.translateCategory(_loc4_,LocaleCategory.BATTLE_OBJ);
         }
         if(param1.def.count)
         {
            _loc3_ += " (" + param1.count + " / " + param1.def.count + ")";
         }
         return _loc3_;
      }
      
      public function toString() : String
      {
         return "GuiBattleObjective " + this._objective;
      }
      
      public function cleanup() : void
      {
         this.setObjective(null);
      }
      
      public function get objective() : BattleObjective
      {
         return this._objective;
      }
      
      public function setObjective(param1:BattleObjective) : void
      {
         if(this._objective == param1)
         {
            return;
         }
         if(this._objective)
         {
            this._objective.removeEventListener(Event.COMPLETE,this.objectiveCompleteHandler);
            this._objective.removeEventListener(Event.CHANGE,this.objectiveChangeHandler);
         }
         this._objective = param1;
         if(this._objective)
         {
            this._objective.addEventListener(Event.COMPLETE,this.objectiveCompleteHandler);
            this._objective.addEventListener(Event.CHANGE,this.objectiveChangeHandler);
         }
         this._token = param1.def.token;
         this.setState(param1.complete);
      }
      
      private function objectiveChangeHandler(param1:Event) : void
      {
         this.updateText();
      }
      
      private function objectiveCompleteHandler(param1:Event) : void
      {
         this.setState(Boolean(this._objective) && this._objective.complete);
      }
      
      public function updateText() : void
      {
         if(!this.objective)
         {
            return;
         }
         var _loc1_:TextField = this.mc.getChildByName("text") as TextField;
         if(_loc1_)
         {
            _loc1_.mouseEnabled = false;
            this._str = createText(this.objective,this._context);
            _loc1_.htmlText = this._str;
            this._context.locale.fixTextFieldFormat(_loc1_);
         }
      }
      
      private function setState(param1:Boolean) : void
      {
         if(this._button)
         {
            this._button.setDownFunction(null);
         }
         if(param1)
         {
            this.mc.gotoAndStop(2);
         }
         else
         {
            this.mc.gotoAndStop(1);
         }
         this._button = this.mc.getChildByName("button") as IGuiButton;
         if(!this._button)
         {
            this._button = this.mc.getChildByName("buttonComplete") as IGuiButton;
         }
         if(this._button)
         {
            this._button.setDownFunction(this.buttonDownHandler);
         }
         this.updateText();
      }
      
      private function buttonDownHandler(param1:*) : void
      {
         this._gui.showObjectiveInfo(this._objective);
      }
   }
}
