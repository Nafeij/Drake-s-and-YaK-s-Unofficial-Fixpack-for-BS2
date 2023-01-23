package game.gui.battle
{
   import com.greensock.TweenMax;
   import engine.battle.board.model.BattleObjective;
   import engine.battle.board.model.BattleScenario;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiObjectiveResults extends GuiBase
   {
       
      
      public var guiObjectives:Vector.<GuiMatchResolutionObjective>;
      
      public var _scenario:BattleScenario;
      
      private var _cursor:int = 0;
      
      private var _mr:GuiMatchResolution;
      
      private var waiting:Boolean;
      
      private var delay_end:Number = 2;
      
      private var delay_next:Number = 1;
      
      private var hiding:Boolean;
      
      private var clickStage:Stage;
      
      public function GuiObjectiveResults()
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:GuiMatchResolutionObjective = null;
         this.guiObjectives = new Vector.<GuiMatchResolutionObjective>();
         super();
         this.visible = false;
         var _loc1_:int = 0;
         while(_loc1_ < numChildren)
         {
            _loc2_ = getChildAt(_loc1_);
            _loc3_ = _loc2_ as GuiMatchResolutionObjective;
            if(_loc3_)
            {
               this.guiObjectives.push(_loc3_);
            }
            _loc1_++;
         }
      }
      
      public function init(param1:IGuiContext, param2:BattleScenario, param3:GuiMatchResolution) : void
      {
         super.initGuiBase(param1);
         this._scenario = param2;
         this._mr = param3;
      }
      
      public function cleanup() : void
      {
         TweenMax.killDelayedCallsTo(this.hide);
         TweenMax.killDelayedCallsTo(this.playOneObjective);
         TweenMax.killDelayedCallsTo(this.hide);
         super.cleanupGuiBase();
      }
      
      public function displayAndPlay() : void
      {
         var _loc1_:Number = NaN;
         this.clickStage = stage;
         if(this.clickStage)
         {
            this.clickStage.addEventListener(MouseEvent.CLICK,this.clickHandler);
         }
         if(this._cursor >= this._scenario.objectives.length)
         {
            throw new ArgumentError("Don\'t activate this unless you have some objectives");
         }
         visible = true;
         _loc1_ = this.y;
         this.y = _loc1_ - 600;
         TweenMax.to(this,1,{
            "delay":0.5,
            "y":_loc1_,
            "onComplete":this.playOneObjective
         });
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         if(this.waiting)
         {
            this.hide();
         }
      }
      
      private function playOneObjective() : void
      {
         if(this._cursor >= this._scenario.objectives.length)
         {
            this.waiting = true;
            TweenMax.delayedCall(this.delay_end,this.hide);
            return;
         }
         var _loc1_:BattleObjective = this._scenario.objectives[this._cursor];
         var _loc2_:GuiMatchResolutionObjective = this.guiObjectives[this._cursor];
         _loc2_.init(_context,_loc1_.def.token,_loc1_._complete);
         ++this._cursor;
         TweenMax.delayedCall(this.delay_next,this.playOneObjective);
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
         this.waiting = false;
         this.hiding = true;
         TweenMax.killTweensOf(this);
         TweenMax.killDelayedCallsTo(this.hide);
         TweenMax.killDelayedCallsTo(this.playOneObjective);
         TweenMax.to(this,0.5,{
            "y":800,
            "onComplete":null
         });
         this._mr.handleObjectiveResultsComplete();
      }
   }
}
