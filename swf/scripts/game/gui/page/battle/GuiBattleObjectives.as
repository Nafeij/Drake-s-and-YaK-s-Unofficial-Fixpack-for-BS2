package game.gui.page.battle
{
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleObjective;
   import engine.battle.board.model.BattleScenario;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.gui.GuiContextEvent;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   
   public class GuiBattleObjectives extends Sprite
   {
      
      public static var mcClazzBattleObjective:Class;
       
      
      private var gbos:Vector.<GuiBattleObjective>;
      
      private var _board:BattleBoard;
      
      private var _context:IGuiContext;
      
      private var logger:ILogger;
      
      private var _hoverGbo:BattleObjective;
      
      private var scenario:BattleScenario;
      
      public var bottom_obj:GuiBattleObjective;
      
      private var _hoverDialog:IGuiDialog;
      
      public function GuiBattleObjectives(param1:IGuiContext)
      {
         this.gbos = new Vector.<GuiBattleObjective>();
         super();
         name = "battle_objectives";
         this._context = param1;
         this.logger = this._context.logger;
         mouseEnabled = false;
         mouseChildren = true;
         var _loc2_:Number = BoundedCamera.computeDpiScaling(1024,768);
         this.scaleX = this.scaleY = _loc2_;
         this._context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         var _loc2_:GuiBattleObjective = null;
         for each(_loc2_ in this.gbos)
         {
            _loc2_.updateText();
         }
      }
      
      public function set board(param1:BattleBoard) : void
      {
         if(this._board == param1)
         {
            return;
         }
         if(this._board)
         {
            this._board.removeEventListener(BattleBoardEvent.OBJECTIVES,this.boardObjectivesHandler);
         }
         this._board = param1;
         if(this._board)
         {
            if(this._board)
            {
               this._board.addEventListener(BattleBoardEvent.OBJECTIVES,this.boardObjectivesHandler);
            }
         }
         this.boardObjectivesHandler(null);
      }
      
      private function boardObjectivesHandler(param1:BattleBoardEvent) : void
      {
         if(this._board)
         {
            this.setScenario(this._board._scenario);
         }
         else
         {
            this.setObjectives(null);
         }
      }
      
      public function setScenario(param1:BattleScenario) : void
      {
         this.scenario = param1;
         this.setObjectives(!!param1 ? param1.objectives : null);
      }
      
      public function setObjectives(param1:Vector.<BattleObjective>) : void
      {
         var _loc3_:int = 0;
         var _loc4_:BattleObjective = null;
         if(param1)
         {
            _loc3_ = 0;
            for each(_loc4_ in param1)
            {
               this.setObjective(_loc3_,_loc4_);
               _loc3_++;
            }
         }
         var _loc2_:int = !!param1 ? int(param1.length) : 0;
         if(this.gbos.length > _loc2_)
         {
            this.gbos.splice(_loc2_,this.gbos.length - _loc2_);
         }
      }
      
      public function setObjective(param1:int, param2:BattleObjective) : void
      {
         var _loc3_:GuiBattleObjective = null;
         while(this.gbos.length <= param1)
         {
            _loc3_ = this.makeGuiBattleObjective();
            this.gbos.push(_loc3_);
            addChild(_loc3_.mc);
            _loc3_.mc.name = "obj_" + param1;
            _loc3_.mc.y = param1 * _loc3_.mc.height;
            this.bottom_obj = _loc3_;
         }
         _loc3_ = this.gbos[param1];
         _loc3_.setObjective(param2);
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiBattleObjective = null;
         for each(_loc1_ in this.gbos)
         {
            _loc1_.cleanup();
         }
         this.gbos = null;
      }
      
      private function makeGuiBattleObjective() : GuiBattleObjective
      {
         var _loc1_:MovieClip = new mcClazzBattleObjective() as MovieClip;
         var _loc2_:GuiBattleObjective = new GuiBattleObjective(_loc1_,this,this._context);
         _loc1_.name = "assets.battle_objective_" + numChildren;
         return _loc2_;
      }
      
      public function get hoverGbo() : BattleObjective
      {
         return this._hoverGbo;
      }
      
      public function set hoverGbo(param1:BattleObjective) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(this._hoverGbo == param1)
         {
            return;
         }
         this._hoverGbo = param1;
         if(this._hoverDialog)
         {
            this._hoverDialog.closeDialog(null);
            this._hoverDialog = null;
         }
         if(this._hoverGbo)
         {
            this._hoverDialog = this._context.createDialog();
            _loc2_ = String(this._context.translateCategory("_dialog_title",LocaleCategory.BATTLE_OBJ));
            _loc3_ = String(this._context.translateCategory(this._hoverGbo.def.token + "_desc",LocaleCategory.BATTLE_OBJ));
            if(this._hoverGbo.complete)
            {
               _loc3_ = this._context.translateCategory("_complete",LocaleCategory.BATTLE_OBJ) + "\n\n\n" + _loc3_;
            }
            _loc4_ = String(this._context.translate("ok"));
            this._hoverDialog.openDialog(_loc2_,_loc3_,_loc4_,this.hoverDialogClosedHandler);
         }
         if(this._context.saga)
         {
            this._context.saga.triggerBattleObjectiveOpened(param1);
         }
      }
      
      private function hoverDialogClosedHandler(param1:*) : void
      {
         this.hoverGbo = null;
      }
      
      public function showObjectiveInfo(param1:BattleObjective) : void
      {
         this.hoverGbo = param1;
      }
   }
}
