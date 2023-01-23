package game.gui
{
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.locale.LocaleCategory;
   import engine.saga.SagaVar;
   import flash.display.MovieClip;
   
   public class GuiHeroicTitleButton extends ButtonWithIndex
   {
      
      private static const MAX_TITLE_LEVEL:int = 5;
       
      
      private var _plus:MovieClip;
      
      private var showing_tip_heroic_title:Boolean;
      
      private var tutorial_id:int;
      
      public function GuiHeroicTitleButton()
      {
         super();
      }
      
      public function init(param1:IGuiContext) : void
      {
         this.guiButtonContext = param1;
         this._plus = getChildByName("plus") as MovieClip;
         this._plus.visible = false;
      }
      
      public function updatePlus(param1:int) : void
      {
         this._plus.visible = param1 < MAX_TITLE_LEVEL;
      }
      
      public function button_clicked() : void
      {
         this._hideTipHeroicTitles(true);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1)
         {
            this.attemptShowTipHeroicTitles();
         }
         else
         {
            this._hideTipHeroicTitles(false);
         }
      }
      
      private function attemptShowTipHeroicTitles() : Boolean
      {
         if(this.tutorial_id || !this.visible || !_context || !_context.saga)
         {
            return false;
         }
         var _loc1_:Boolean = _context.saga.getVarBool(SagaVar.VAR_TIP_HEROIC_TITLE);
         if(_loc1_)
         {
            return false;
         }
         this._showTipHeroicTitles();
         return true;
      }
      
      private function _showTipHeroicTitles() : void
      {
         var _loc1_:String = _context.translateCategory("tut_heroeic_title",LocaleCategory.TUTORIAL);
         this.tutorial_id = _context.createTutorialPopup(this,_loc1_,TutorialTooltipAlign.RIGHT,TutorialTooltipAnchor.RIGHT,true,false,null);
         this.showing_tip_heroic_title = true;
      }
      
      private function _hideTipHeroicTitles(param1:Boolean) : void
      {
         if(param1)
         {
            _context.saga.setVar(SagaVar.VAR_TIP_HEROIC_TITLE,true);
         }
         if(this.showing_tip_heroic_title)
         {
            _context.removeAllTooltips();
            this.tutorial_id = 0;
            this.showing_tip_heroic_title = false;
         }
      }
   }
}
