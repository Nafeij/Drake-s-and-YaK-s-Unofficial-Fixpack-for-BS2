package game.gui
{
   import engine.core.util.StringUtil;
   import engine.gui.GuiContextEvent;
   import engine.gui.IEngineGuiContext;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   import engine.saga.save.SagaSave;
   
   public class GuiTooltipStatusSurvival extends GuiTooltipStatus
   {
       
      
      private var _localeDirty:Boolean;
      
      private var ss:SagaSave;
      
      public function GuiTooltipStatusSurvival()
      {
         super();
      }
      
      override public function get maxLines() : int
      {
         return 6;
      }
      
      override public function handleLocaleChange() : void
      {
         this._updateGui();
      }
      
      override public function init(param1:IEngineGuiContext) : void
      {
         super.init(param1);
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         if(!visible)
         {
            this._localeDirty = true;
            return;
         }
         this._localeDirty = false;
         tooltipSetLeftText(0,_context.translate("difficulty") + ":");
         tooltipSetLeftText(1,_context.translate("survival_progress") + ":");
         tooltipSetLeftText(2,_context.translate("survival_reloads") + ":");
         tooltipSetLeftText(3,_context.translate("survival_deaths") + ":");
         tooltipSetLeftText(4,_context.translate("survival_recruits") + ":");
         tooltipSetLeftText(5,_context.translate("survival_elapsed") + ":");
         _tooltip_text_title.htmlText = _context.translate("ss_welcome_title");
         _context.locale.fixTextFieldFormat(_tooltip_text_title);
         scaleTextfields();
      }
      
      public function set tooltipSagaSave(param1:SagaSave) : void
      {
         this.ss = param1;
         this._updateGui();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1 != super.visible)
         {
            super.visible = param1;
            if(param1)
            {
               this._updateGui();
            }
         }
      }
      
      private function _updateGui() : void
      {
         var _loc3_:* = null;
         if(!visible)
         {
            return;
         }
         var _loc1_:Saga = _context.saga;
         if(!_loc1_)
         {
            return;
         }
         if(this._localeDirty)
         {
            this.localeHandler(null);
         }
         var _loc2_:int = 0;
         if(this.ss)
         {
            tooltipSetRightText(0,_loc1_.getDifficultyStringHtml(this.ss.getDifficulty(_loc1_)));
            tooltipSetRightText(1,this.ss.survivalProgress + " / " + _loc1_.survivalTotal);
            _loc3_ = this.ss.survivalReloadCount.toString();
            if(this.ss.survivalReloadRequired)
            {
               _loc3_ += "<font color=\'#ff4444\'>+1</font>";
            }
            tooltipSetRightText(2,_loc3_ + " / " + this.ss.getSurvivalReloadLimit(_loc1_));
            tooltipSetRightText(3,this.ss.getVarInt(_loc1_,SagaVar.VAR_SURVIVAL_NUM_DEATHS).toString());
            tooltipSetRightText(4,this.ss.getVarInt(_loc1_,SagaVar.VAR_SURVIVAL_NUM_RECRUITS).toString());
            _loc2_ = this.ss.getVarInt(_loc1_,SagaVar.VAR_SURVIVAL_ELAPSED_SEC);
         }
         else
         {
            tooltipSetRightText(0,_loc1_.getDifficultyStringHtml(_loc1_.difficulty));
            tooltipSetRightText(1,_loc1_.survivalProgress + " / " + _loc1_.survivalTotal);
            tooltipSetRightText(2,_loc1_.survivalReloadCount + " / " + _loc1_.survivalReloadLimit);
            tooltipSetRightText(3,_loc1_.getVarInt(SagaVar.VAR_SURVIVAL_NUM_DEATHS).toString());
            tooltipSetRightText(4,_loc1_.getVarInt(SagaVar.VAR_SURVIVAL_NUM_RECRUITS).toString());
            _loc2_ = _loc1_.getVarInt(SagaVar.VAR_SURVIVAL_ELAPSED_SEC);
         }
         tooltipSetRightText(5,StringUtil.formatMinSec(_loc2_));
         tooltipRender();
      }
   }
}
